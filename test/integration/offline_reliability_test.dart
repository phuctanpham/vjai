import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/media/photo_picker.dart';
import 'package:garblo/core/storage/attachment_store.dart';
import 'package:garblo/core/storage/garblo_database.dart';
import 'package:garblo/core/storage/install_identity.dart';
import 'package:garblo/core/storage/local_data_store.dart';
import 'package:garblo/core/storage/object_id.dart';
import 'package:garblo/core/storage/phone_schema.dart';
import 'package:garblo/features/gu_match/data/local_gu_match_repository.dart';
import 'package:garblo/features/gu_match/domain/occasion.dart';
import 'package:garblo/features/gu_match/presentation/gu_match_state.dart';
import 'package:garblo/features/gu_match/presentation/gu_match_view_model.dart';
import 'package:garblo/features/studio/data/local_studio_repository.dart';
import 'package:garblo/features/studio/data/studio_repository.dart';
import 'package:garblo/features/studio/domain/batch_status.dart';
import 'package:garblo/features/studio/domain/privacy_consent.dart';
import 'package:garblo/features/studio/presentation/studio_view_model.dart';
import 'package:garblo/features/wardrobe/data/local_wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/local_wear_repository.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';
import 'package:garblo/features/wardrobe/domain/item_group.dart';
import 'package:garblo/features/wardrobe/domain/wardrobe_item.dart';
import 'package:garblo/features/wardrobe/presentation/wardrobe_state.dart';
import 'package:garblo/features/wardrobe/presentation/wardrobe_view_model.dart';
import 'package:sqlite3/sqlite3.dart' as raw;
import 'package:sqlite_async/sqlite_async.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/image_fixtures.dart';
import '../helpers/local_db.dart';
import '../helpers/reliability.dart';
import '../helpers/wardrobe_fixtures.dart';

const _owner = '65f0c1a2b3c4d5e6f7a8b9c0';
const _shirtUri = 'content://gallery/violet.jpg';
const _sneakersUri = 'content://gallery/sneakers.png';

/// Pieces indexed in earlier sessions, enough for a Gu Match deck.
final _earlierPieces = [
  wardrobeItem('violet', name: 'Violet shirt', typeCode: 'SHIRT'),
  wardrobeItem('tee', name: 'White T-shirt', typeCode: 'T_SHIRT'),
  wardrobeItem('wide',
      name: 'Wide-leg trousers', typeCode: 'WIDE_LEG_TROUSERS'),
  wardrobeItem('jeans', name: 'Black jeans', typeCode: 'JEANS'),
  wardrobeItem('sneakers', name: 'Cream sneakers', typeCode: 'SNEAKERS'),
  wardrobeItem('loafers', name: 'Black loafers', typeCode: 'LOAFERS'),
];

FakePhotoPicker _twoPhotos() => FakePhotoPicker([
      [
        PickedPhoto(
            uri: _shirtUri, mimeType: 'image/jpeg', bytes: jpegWithMetadata()),
        PickedPhoto(
            uri: _sneakersUri, mimeType: 'image/png', bytes: pngWithMetadata()),
      ],
    ]);

Future<int> _count(SqliteConnection db, String table) async =>
    (await db.get('SELECT count(*) AS n FROM $table'))['n'] as int;

/// One run of the app on [db]: the local repositories and ViewModels as
/// `bootstrap.dart` wires them. A restart is a new run on a reopened file.
class _Run {
  final SqliteConnection db;
  final AttachmentStore attachments;
  final FixedClock clock;
  final ObjectIdGenerator ids;
  final LocalWardrobeRepository wardrobe;
  final LocalWearRepository wear;
  final LocalStudioRepository studioRepository;

  _Run(this.db, this.attachments, this.clock)
      : ids = ObjectIdGenerator(clock: clock),
        wardrobe = LocalWardrobeRepository(db: db, ownerId: _owner),
        wear = LocalWearRepository(db: db, ownerId: _owner),
        studioRepository = LocalStudioRepository(
          db: db,
          ownerId: _owner,
          attachments: attachments,
          ids: ObjectIdGenerator(clock: clock),
          clock: clock,
          fixtures: {
            _shirtUri: MockStudioRepository
                .presetFixtures['preset://flatlay-violet-shirt.jpg']!,
            _sneakersUri: MockStudioRepository
                .presetFixtures['preset://flatlay-cream-sneakers.png']!,
          },
        );

  StudioViewModel studio({
    PhotoPicker? picker,
    WardrobeRepository? wardrobeRepository,
  }) =>
      StudioViewModel(
        studioRepository: studioRepository,
        wardrobeRepository: wardrobeRepository ?? wardrobe,
        photoPicker: picker ?? FakePhotoPicker(const []),
        clock: clock,
        ids: ids,
      );

  LocalGuMatchRepository guMatchRepository({
    WardrobeRepository? wardrobeRepository,
    WearRepository? wearRepository,
  }) =>
      LocalGuMatchRepository(
        db: db,
        ownerId: _owner,
        wardrobeRepository: wardrobeRepository ?? wardrobe,
        wearRepository: wearRepository ?? wear,
        clock: clock,
        ids: ids,
      );

  GuMatchViewModel guMatch({
    WardrobeRepository? wardrobeRepository,
    WearRepository? wearRepository,
  }) =>
      GuMatchViewModel(
        repository: guMatchRepository(
          wardrobeRepository: wardrobeRepository,
          wearRepository: wearRepository,
        ),
        clock: clock,
      );

  WardrobeViewModel archive({WardrobeRepository? wardrobeRepository}) =>
      WardrobeViewModel(
        wardrobeRepository: wardrobeRepository ?? wardrobe,
        wearRepository: wear,
        clock: clock,
      );

  /// Flow A up to the review: photos → consent → scope → "Index 2 Pieces".
  Future<StudioViewModel> reviewTwoPhotos({
    WardrobeRepository? wardrobeRepository,
  }) async {
    final vm =
        studio(picker: _twoPhotos(), wardrobeRepository: wardrobeRepository);
    await vm.pickPhotos();
    vm.setConsent(true);
    await vm.analyze();
    await vm.confirmScope();
    expect(vm.state.saveLabel, 'Index 2 Pieces');
    return vm;
  }

  /// Flow B up to a liked first Fit with the "Wearing this today?" prompt.
  Future<GuMatchViewModel> likeFirstFit(
      {WearRepository? wearRepository}) async {
    final vm = guMatch(wearRepository: wearRepository);
    await vm.load();
    vm.toggleOccasion(Occasion.coffee);
    await vm.startSwiping();
    expect(vm.state.phase, GuMatchPhase.deck);
    await vm.like();
    expect(vm.state.isWearPromptVisible, isTrue);
    return vm;
  }
}

/// Builders for a database file at each schema version older than
/// `PhoneSchema.version`. A new version must add its predecessor here.
final Map<int, void Function(String path)> _priorVersions = {
  // A file SQLite created before any Garblo migration ran.
  0: (path) {
    final db = raw.sqlite3.open(path);
    db.execute('PRAGMA user_version = 0');
    db.dispose();
  },
};

Future<Map<String, List<Map<String, Object?>>>> _dump(
    SqliteConnection db) async {
  return {
    for (final table in PhoneSchema.tables)
      table.name: (await db.getAll('SELECT * FROM ${table.name} ORDER BY id'))
          .map((row) => Map<String, Object?>.of(row))
          .toList(),
  };
}

void main() {
  late TestDatabase t;
  late Directory files;
  late AttachmentStore attachments;
  final clock = FixedClock(testToday);
  final images = <TestDatabase>[];

  Future<TestDatabase> crashImage() async {
    final image = await t.crashImage();
    images.add(image);
    return image;
  }

  setUp(() async {
    clock.fixed = testToday;
    t = await TestDatabase.open();
    files = await tempDir('reliability_files');
    attachments =
        FileAttachmentStore(root: files, ids: ObjectIdGenerator(clock: clock));
  });

  tearDown(() async {
    for (final image in images) {
      await image.dispose();
    }
    images.clear();
    await t.dispose();
    if (await files.exists()) await files.delete(recursive: true);
  });

  test(
      '[TASK-009-S01] the complete Phase 1 journey works with network access '
      'disabled', () async {
    final attempts = await withoutNetwork(() async {
      final run = _Run(t.db, attachments, clock);
      await run.wardrobe.saveItems(_earlierPieces);

      final studio = await run.reviewTwoPhotos();
      await studio.save();
      expect(studio.state.batchStatus, BatchStatus.completed);
      expect(studio.state.errorMessage, isNull);
      studio.dispose();

      final archive = run.archive();
      await archive.load();
      expect(archive.state.status, WardrobeStatus.loaded);
      expect(archive.state.total, 8);
      archive.dispose();

      final guMatch = await run.likeFirstFit();
      await guMatch.confirmWearing();
      expect(guMatch.state.isWearPromptVisible, isFalse);
      expect(guMatch.state.currentIndex, 1);
      guMatch.dispose();

      expect(await run.wear.getEvents(), hasLength(1));
    });

    expect(attempts, 0, reason: 'P2 makes no network connection');
  });

  group('app-kill (crash images)', () {
    List<WardrobeItem> threePieces() => [
          wardrobeItem('65f0c1a2b3c4d5e6f7a8b901'),
          wardrobeItem('65f0c1a2b3c4d5e6f7a8b902'),
          wardrobeItem('65f0c1a2b3c4d5e6f7a8b903'),
        ];

    test('[TASK-009-S02] a kill part-way through Save N items leaves none',
        () async {
      TestDatabase? image;
      final repo = LocalWardrobeRepository(
        db: t.db,
        ownerId: _owner,
        onInsert: (index) async {
          if (index == 2) image = await crashImage();
        },
      );

      await repo.saveItems(threePieces());

      expect(await _count(image!.db, 'wardrobe_items'), 0);
      expect(await _count(t.db, 'wardrobe_items'), 3);
    });

    test('[TASK-009-S02] a kill right after Save N items leaves all of them',
        () async {
      await LocalWardrobeRepository(db: t.db, ownerId: _owner)
          .saveItems(threePieces());
      final image = await crashImage();

      expect(await _count(image.db, 'wardrobe_items'), 3);
    });

    test(
        '[TASK-009-S02] killed during "Index N Pieces", the restart shows the '
        'same review and saves it once', () async {
      TestDatabase? image;
      final killing = LocalWardrobeRepository(
        db: t.db,
        ownerId: _owner,
        onInsert: (index) async {
          if (index == 1) image ??= await crashImage();
        },
      );
      final before = await _Run(t.db, attachments, clock)
          .reviewTwoPhotos(wardrobeRepository: killing);
      final review = before.state.review;
      await before.save();
      before.dispose();

      final after = _Run(image!.db, attachments, clock).studio();
      await after.restore();
      expect(after.state.batchStatus, BatchStatus.awaitingReview);
      expect(after.state.review, review);
      expect(await _count(image!.db, 'wardrobe_items'), 0);

      await after.save();
      expect(after.state.batchStatus, BatchStatus.completed);
      expect(await _count(image!.db, 'wardrobe_items'), 2);
      after.dispose();
    });

    test('[TASK-009-S05] replaying "Index N Pieces" after a crash adds no rows',
        () async {
      TestDatabase? image;
      final before = await _Run(t.db, attachments, clock).reviewTwoPhotos(
        wardrobeRepository: _ThenRepository(
          LocalWardrobeRepository(db: t.db, ownerId: _owner),
          afterSave: () async => image = await crashImage(),
        ),
      );
      await before.save();
      before.dispose();

      // Killed after the Pieces committed, before the batch was COMPLETED.
      final after = _Run(image!.db, attachments, clock).studio();
      await after.restore();
      expect(after.state.batchStatus, BatchStatus.awaitingReview);
      expect(await _count(image!.db, 'wardrobe_items'), 2);

      await after.save();
      expect(after.state.batchStatus, BatchStatus.completed);
      expect(await _count(image!.db, 'wardrobe_items'), 2);
      after.dispose();
    });
  });

  group('replay', () {
    final consent = PrivacyConsent(
      version: PrivacyConsent.studioVersion,
      grantedAt: testToday,
      includesBodyProcessing: true,
    );

    test('[TASK-009-S05] replaying a consent after a restart adds no row',
        () async {
      final first =
          await _Run(t.db, attachments, clock).studioRepository.recordConsent(
                consent,
              );

      final db = await t.reopen();
      final replay = await _Run(db, attachments, clock)
          .studioRepository
          .recordConsent(consent);

      expect(replay.id, first.id);
      expect(await _count(db, 'consents'), 1);
    });

    test('[TASK-009-S05] a replayed consent does not undo a withdrawal',
        () async {
      final run = _Run(t.db, attachments, clock);
      await run.studioRepository.recordConsent(consent);
      await t.db.execute(
          'UPDATE consents SET revoked_at = ?', [testToday.toIso8601String()]);

      await run.studioRepository.recordConsent(consent);

      expect(await _count(t.db, 'consents'), 1);
      expect(await run.studioRepository.activeConsent(), isNull);
    });

    test(
        '[TASK-009-S04] replaying a wear confirmation after a restart adds no '
        'event', () async {
      await LocalWardrobeRepository(db: t.db, ownerId: _owner)
          .saveItems(_earlierPieces);
      final before = await _Run(t.db, attachments, clock).likeFirstFit();
      final fit = before.state.currentCandidate!;
      await before.confirmWearing();
      before.dispose();

      final db = await t.reopen();
      final run = _Run(db, attachments, clock);
      final logged = await run.guMatchRepository().confirmWearing(fit);

      expect(logged, isFalse, reason: 'already logged today');
      expect(await run.wear.getEvents(), hasLength(1));
    });
  });

  test(
      '[TASK-009-S03] one restart restores the Archive, wear log, open review '
      'and Gu Match deck together', () async {
    final before = _Run(t.db, attachments, clock);
    await before.wardrobe.saveItems(_earlierPieces);
    final guMatch = await before.likeFirstFit();
    await guMatch.confirmWearing();
    final deck = guMatch.state.deck.map((c) => c.candidateId).toList();
    guMatch.dispose();
    final studio = await before.reviewTwoPhotos();
    final review = studio.state.review;
    final consent = studio.state.consent;
    studio.dispose();
    final events = await before.wear.getEvents();

    final db = await t.reopen();
    final after = _Run(db, attachments, clock);

    final restoredStudio = after.studio();
    await restoredStudio.restore();
    expect(restoredStudio.state.batchStatus, BatchStatus.awaitingReview);
    expect(restoredStudio.state.review, review);
    expect(restoredStudio.state.consent, consent);
    restoredStudio.dispose();

    final restoredGuMatch = after.guMatch();
    await restoredGuMatch.restore();
    expect(restoredGuMatch.state.phase, GuMatchPhase.deck);
    expect(restoredGuMatch.state.deck.map((c) => c.candidateId), deck);
    expect(restoredGuMatch.state.currentIndex, 1);
    restoredGuMatch.dispose();

    final archive = after.archive();
    await archive.load();
    expect(archive.state.total, _earlierPieces.length);
    archive.dispose();

    expect(await after.wear.getEvents(), events);
  });

  group('migrations', () {
    test('[TASK-009-S06] every prior schema version has an upgrade fixture',
        () {
      expect(_priorVersions.keys.toSet(),
          {for (var v = 0; v < PhoneSchema.version; v++) v});
    });

    for (final entry in _priorVersions.entries) {
      test(
          '[TASK-009-S06] a version ${entry.key} file upgrades to the current '
          'schema and keeps its rows', () async {
        final dir = await tempDir('migration_${entry.key}');
        addTearDown(() => dir.delete(recursive: true));
        final path = '${dir.path}${Platform.pathSeparator}garblo.db';
        useHostSqlite();
        entry.value(path);
        final before = raw.sqlite3.open(path);
        final rowsBefore = {
          for (final row in before
              .select("SELECT name FROM sqlite_master WHERE type = 'table'"))
            row['name'] as String: before
                .select('SELECT * FROM "${row['name']}"')
                .map((r) => Map<String, Object?>.of(r))
                .toList(),
        };
        before.dispose();

        final db = await GarbloDatabase.open(
            path: path, key: TestDatabase.testKey, beforeOpen: useHostSqlite);
        addTearDown(db.close);

        expect(await GarbloDatabase.schemaVersion(db), PhoneSchema.version);
        for (final table in PhoneSchema.tables) {
          await db.get('SELECT count(*) FROM ${table.name}');
        }
        for (final MapEntry(key: table, value: rows) in rowsBefore.entries) {
          final after = await db.getAll('SELECT * FROM "$table"');
          expect(after.map((r) => Map<String, Object?>.of(r)).toList(), rows,
              reason: table);
        }
      });
    }

    test(
        '[TASK-009-S06] a current database with rows in every table reopens '
        'with every row intact', () async {
      final run = _Run(t.db, attachments, clock);
      await run.wardrobe.saveItems(_earlierPieces);
      final guMatch = await run.likeFirstFit();
      await guMatch.confirmWearing();
      guMatch.dispose();
      final studio = await run.reviewTwoPhotos();
      studio.dispose();
      final before = await _dump(t.db);
      for (final MapEntry(key: table, value: rows) in before.entries) {
        expect(rows, isNotEmpty, reason: '$table has no row to keep');
      }

      final db = await t.reopen();

      expect(await GarbloDatabase.schemaVersion(db), PhoneSchema.version);
      expect(await _dump(db), before);
    });
  });

  group('photo files and rows', () {
    test(
        '[TASK-009-S07] after a restart every photo file has its row, every '
        'row its file, and the files are sanitized', () async {
      final studio = await _Run(t.db, attachments, clock).reviewTwoPhotos();
      studio.dispose();

      final db = await t.reopen();
      final rows = await db.getAll(
          'SELECT attachment_id FROM media_assets WHERE attachment_id IS NOT NULL');
      final referenced = {for (final r in rows) r['attachment_id'] as String};

      expect(referenced, hasLength(2));
      expect((await attachments.listIds()).toSet(), referenced);
      for (final id in referenced) {
        final bytes = await attachments.read(id);
        expect(containsAscii(bytes, gpsMarker), isFalse);
        expect(containsAscii(bytes, xmpMarker), isFalse);
        expect(containsAscii(bytes, pngTextMarker), isFalse);
        expect(containsAscii(bytes, imageDataMarker), isTrue);
      }
    });

    test(
        '[TASK-009-S07] a photo file left without a row by a kill is removed '
        'when the store opens', () async {
      final identity = InstallIdentity(
          store: FakeSecureStore(), ids: ObjectIdGenerator(clock: clock));
      final dir = await tempDir('store');
      addTearDown(() => dir.delete(recursive: true));
      LocalDataStore store() => LocalDataStore(
            databasePath: '${dir.path}${Platform.pathSeparator}garblo.db',
            attachments: attachments,
            identity: identity,
            beforeOpen: useHostSqlite,
          );
      final first = store();
      final studio =
          await _Run(await first.open(), attachments, clock).reviewTwoPhotos();
      studio.dispose();
      // What a kill between writing a sanitized file and its row leaves.
      final orphan = await attachments.save(jpegImageData(jpegWithMetadata()));
      await first.database.close();

      final restarted = store();
      final db = await restarted.open();
      addTearDown(db.close);

      final rows = await db.getAll(
          'SELECT attachment_id FROM media_assets WHERE attachment_id IS NOT NULL');
      final ids = (await attachments.listIds()).toSet();
      expect(ids, isNot(contains(orphan)));
      expect(ids, {for (final r in rows) r['attachment_id'] as String});
      expect(ids, hasLength(2));
    });
  });

  group('offline error states', () {
    test(
        '[TASK-009-S08] a failed "Index N Pieces" is explicit and saves once '
        'on retry', () async {
      var failNext = true;
      final flaky = LocalWardrobeRepository(
        db: t.db,
        ownerId: _owner,
        onInsert: (index) async {
          if (failNext && index == 1) {
            failNext = false;
            throw StateError('disk full');
          }
        },
      );
      final vm = await _Run(t.db, attachments, clock)
          .reviewTwoPhotos(wardrobeRepository: flaky);

      await vm.save();
      expect(vm.state.errorMessage, StudioViewModel.saveFailedMessage);
      expect(vm.state.isSaving, isFalse);
      expect(vm.state.batchStatus, BatchStatus.awaitingReview);
      expect(vm.state.canSave, isTrue);
      expect(await _count(t.db, 'wardrobe_items'), 0);

      await vm.save();
      expect(vm.state.errorMessage, isNull);
      expect(vm.state.batchStatus, BatchStatus.completed);
      expect(await _count(t.db, 'wardrobe_items'), 2);
      vm.dispose();
    });

    test(
        '[TASK-009-S08] a failed "Wear today" is explicit, keeps the prompt '
        'and logs once on retry', () async {
      final run = _Run(t.db, attachments, clock);
      await run.wardrobe.saveItems(_earlierPieces);
      final vm = await run.likeFirstFit(
          wearRepository: FlakyWearRepository(run.wear, failWrites: 1));

      await vm.confirmWearing();
      expect(vm.state.errorMessage, 'Could not log the wear.');
      expect(vm.state.isWearPromptVisible, isTrue);
      expect(vm.state.isBusy, isFalse);
      expect(vm.state.currentIndex, 0);

      await vm.confirmWearing();
      expect(vm.state.errorMessage, isNull);
      expect(vm.state.isWearPromptVisible, isFalse);
      expect(vm.state.currentIndex, 1);
      expect(await run.wear.getEvents(), hasLength(1));
      vm.dispose();
    });

    test(
        '[TASK-009-S08] an Archive that fails to load shows an error and '
        'loads on retry', () async {
      final run = _Run(t.db, attachments, clock);
      await run.wardrobe.saveItems(_earlierPieces);
      final vm = run.archive(
          wardrobeRepository:
              FlakyWardrobeRepository(run.wardrobe, failLoads: 1));

      await vm.load();
      expect(vm.state.status, WardrobeStatus.error);
      expect(vm.state.errorMessage, 'Could not load your Archive.');

      await vm.retry();
      expect(vm.state.status, WardrobeStatus.loaded);
      expect(vm.state.total, _earlierPieces.length);
      expect(vm.state.errorMessage, isNull);
      vm.dispose();
    });

    test(
        '[TASK-009-S08] a Gu Match that fails to load shows an error and '
        'loads on retry', () async {
      final run = _Run(t.db, attachments, clock);
      await run.wardrobe.saveItems(_earlierPieces);
      final vm = run.guMatch(
          wardrobeRepository:
              FlakyWardrobeRepository(run.wardrobe, failLoads: 1));

      await vm.load();
      expect(vm.state.status, GuMatchStatus.error);
      expect(vm.state.errorMessage, isNotNull);

      await vm.retry();
      expect(vm.state.status, GuMatchStatus.loaded);
      expect(vm.state.readyCount, _earlierPieces.length);
      expect(vm.state.errorMessage, isNull);
      vm.dispose();
    });
  });
}

/// Runs [afterSave] right after [inner] commits the Pieces, so a crash
/// image can be taken before the batch is marked COMPLETED.
class _ThenRepository implements WardrobeRepository {
  final WardrobeRepository inner;
  final Future<void> Function() afterSave;

  _ThenRepository(this.inner, {required this.afterSave});

  @override
  Future<void> saveItems(List<WardrobeItem> items) async {
    await inner.saveItems(items);
    await afterSave();
  }

  @override
  Future<WardrobePage> getItems({ItemGroup? group, String? cursor}) =>
      inner.getItems(group: group, cursor: cursor);

  @override
  Future<int> countEligible() => inner.countEligible();

  @override
  Future<List<WardrobeItem>> getEligibleItems() => inner.getEligibleItems();
}
