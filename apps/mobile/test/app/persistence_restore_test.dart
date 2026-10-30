import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/media/photo_picker.dart';
import 'package:garblo/core/storage/attachment_store.dart';
import 'package:garblo/core/storage/object_id.dart';
import 'package:garblo/features/gu_match/data/local_gu_match_repository.dart';
import 'package:garblo/features/gu_match/domain/occasion.dart';
import 'package:garblo/features/gu_match/domain/styling_context.dart';
import 'package:garblo/features/gu_match/domain/swipe_status.dart';
import 'package:garblo/features/gu_match/presentation/gu_match_state.dart';
import 'package:garblo/features/gu_match/presentation/gu_match_view_model.dart';
import 'package:garblo/features/studio/data/local_studio_repository.dart';
import 'package:garblo/features/studio/data/studio_repository.dart';
import 'package:garblo/features/studio/domain/batch_status.dart';
import 'package:garblo/features/studio/presentation/studio_view_model.dart';
import 'package:garblo/features/wardrobe/data/local_wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/local_wear_repository.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/image_fixtures.dart';
import '../helpers/local_db.dart';
import '../helpers/wardrobe_fixtures.dart';

const _owner = '65f0c1a2b3c4d5e6f7a8b9c0';
const _shirtUri = 'content://gallery/violet.jpg';
const _sneakersUri = 'content://gallery/sneakers.png';

/// Polls [check] for up to two seconds.
Future<void> _eventually(Future<bool> Function() check) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!await check()) {
    if (DateTime.now().isAfter(deadline)) {
      fail('condition not met within 2 s');
    }
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
}

/// An app restart at ViewModel level: the old ViewModels are dropped, the
/// database is closed and reopened, and new ViewModels call `restore()`.
void main() {
  late TestDatabase t;
  late Directory files;
  late AttachmentStore attachments;
  final clock = FixedClock(testToday);

  setUp(() async {
    clock.fixed = testToday;
    t = await TestDatabase.open();
    files = await tempDir('restore_files');
    attachments =
        FileAttachmentStore(root: files, ids: ObjectIdGenerator(clock: clock));
  });

  tearDown(() async {
    await t.dispose();
    if (await files.exists()) await files.delete(recursive: true);
  });

  group('Flow A restore', () {
    StudioViewModel studioOn(SqliteDatabase db, PhotoPicker picker) {
      final ids = ObjectIdGenerator(clock: clock);
      return StudioViewModel(
        studioRepository: LocalStudioRepository(
          db: db,
          ownerId: _owner,
          attachments: attachments,
          ids: ids,
          clock: clock,
          fixtures: {
            _shirtUri: MockStudioRepository
                .presetFixtures['preset://flatlay-violet-shirt.jpg']!,
            _sneakersUri: MockStudioRepository
                .presetFixtures['preset://flatlay-cream-sneakers.png']!,
          },
        ),
        wardrobeRepository: LocalWardrobeRepository(db: db, ownerId: _owner),
        photoPicker: picker,
        clock: clock,
        ids: ids,
      );
    }

    FakePhotoPicker picker() => FakePhotoPicker([
          [
            PickedPhoto(
                uri: _shirtUri,
                mimeType: 'image/jpeg',
                bytes: jpegWithMetadata()),
            PickedPhoto(
                uri: _sneakersUri,
                mimeType: 'image/png',
                bytes: pngWithMetadata()),
          ],
        ]);

    test('[TASK-005-S03] staged photos and consent come back after a restart',
        () async {
      final before = studioOn(t.db, picker());
      await before.pickPhotos();
      before.setConsent(true);
      await before.analyze();
      final tray = before.state.tray.assets;
      final consent = before.state.consent;
      before.dispose();

      final db = await t.reopen();
      final after = studioOn(db, FakePhotoPicker(const []));
      await after.restore();

      expect(after.state.batchStatus, BatchStatus.sanitizing);
      expect(after.state.tray.assets.map((a) => a.assetId),
          tray.map((a) => a.assetId));
      expect(after.state.consent, consent);
      expect(after.state.consentChecked, isTrue);
      after.dispose();
    });

    test('[TASK-005-S03] the review with edits comes back after a restart',
        () async {
      final before = studioOn(t.db, picker());
      await before.pickPhotos();
      before.setConsent(true);
      await before.analyze();
      await before.confirmScope();
      before.editItem(0, color: 'Lilac');
      final review = before.state.review;
      expect(review!.items, hasLength(2));
      before.dispose();

      final db = await t.reopen();
      final after = studioOn(db, FakePhotoPicker(const []));
      await after.restore();

      expect(after.state.batchStatus, BatchStatus.awaitingReview);
      expect(after.state.review, review);
      expect(after.state.review!.items.first.value.color, 'Lilac');
      expect(after.state.saveLabel, 'Index 2 Pieces');
      after.dispose();
    });

    test('[TASK-005-S03] batch and asset IDs are ObjectIds', () async {
      final vm = studioOn(t.db, picker());
      await vm.pickPhotos();

      expect(vm.state.tray.assets.every((a) => isObjectId(a.assetId)), isTrue);
      final batches = await t.db.getAll('SELECT id FROM upload_batches');
      expect(batches.map((r) => isObjectId(r['id'] as String)), [true]);
      vm.dispose();
    });

    test('[TASK-005-S04] saved Piece IDs are hashed from the draft IDs',
        () async {
      final vm = studioOn(t.db, picker());
      await vm.pickPhotos();
      vm.setConsent(true);
      await vm.analyze();
      await vm.confirmScope();
      final drafts = vm.state.review!.items.map((i) => i.draftId).toList();

      await vm.save();

      expect(vm.state.batchStatus, BatchStatus.completed);
      final rows = await t.db.getAll('SELECT id FROM wardrobe_items');
      expect(rows.map((r) => r['id']).toSet(), {
        for (final d in drafts) deterministicObjectId([d])
      });
      vm.dispose();
    });

    test('[TASK-005-S03] nothing to restore leaves a fresh draft', () async {
      final vm = studioOn(t.db, FakePhotoPicker(const []));

      await vm.restore();

      expect(vm.state.batchStatus, BatchStatus.draft);
      expect(vm.state.tray.isEmpty, isTrue);
      expect(vm.state.consent, isNull);
      vm.dispose();
    });
  });

  group('Flow B restore', () {
    GuMatchViewModel guMatchOn(SqliteDatabase db) => GuMatchViewModel(
          repository: LocalGuMatchRepository(
            db: db,
            ownerId: _owner,
            wardrobeRepository:
                LocalWardrobeRepository(db: db, ownerId: _owner),
            wearRepository: LocalWearRepository(db: db, ownerId: _owner),
            clock: clock,
            ids: ObjectIdGenerator(clock: clock),
          ),
          clock: clock,
        );

    setUp(() async {
      await LocalWardrobeRepository(db: t.db, ownerId: _owner).saveItems([
        wardrobeItem('violet', name: 'Violet shirt', typeCode: 'SHIRT'),
        wardrobeItem('tee', name: 'White T-shirt', typeCode: 'T_SHIRT'),
        wardrobeItem('wide',
            name: 'Wide-leg trousers', typeCode: 'WIDE_LEG_TROUSERS'),
        wardrobeItem('jeans', name: 'Black jeans', typeCode: 'JEANS'),
        wardrobeItem('sneakers', name: 'Cream sneakers', typeCode: 'SNEAKERS'),
        wardrobeItem('loafers', name: 'Black loafers', typeCode: 'LOAFERS'),
      ]);
    });

    test('[TASK-005-S03] the studio chips and prompt come back', () async {
      final before = guMatchOn(t.db);
      await before.load();
      before.toggleOccasion(Occasion.work);
      before.setPrompt('Pitch day');
      // Draft writes are fire-and-forget; let them land before the restart.
      await _eventually(() async {
        final rows = await t.db.getAll('SELECT prompt FROM session_draft');
        return rows.isNotEmpty && rows.single['prompt'] == 'Pitch day';
      });
      before.dispose();

      final db = await t.reopen();
      final after = guMatchOn(db);
      await after.restore();

      expect(
          after.state.context,
          const StylingContext(
              occasions: {Occasion.work}, prompt: 'Pitch day'));
      expect(after.state.phase, GuMatchPhase.studio);
      after.dispose();
    });

    test('[TASK-005-S03] the deck reopens at the first undecided Fit',
        () async {
      final before = guMatchOn(t.db);
      await before.load();
      before.toggleOccasion(Occasion.coffee);
      await before.startSwiping();
      final deck = before.state.deck.map((c) => c.candidateId).toList();
      await before.pass();
      before.dispose();

      final db = await t.reopen();
      final after = guMatchOn(db);
      await after.restore();

      expect(after.state.phase, GuMatchPhase.deck);
      expect(after.state.deck.map((c) => c.candidateId), deck);
      expect(after.state.deck.first.swipeStatus, SwipeStatus.swipedLeftPassed);
      expect(after.state.currentIndex, 1);
      after.dispose();
    });

    test('[TASK-005-S03] a fully decided deck reopens the studio', () async {
      final before = guMatchOn(t.db);
      await before.load();
      before.toggleOccasion(Occasion.coffee);
      await before.startSwiping();
      while (before.state.phase == GuMatchPhase.deck) {
        await before.pass();
      }
      before.dispose();

      final db = await t.reopen();
      final after = guMatchOn(db);
      await after.restore();

      expect(after.state.phase, GuMatchPhase.studio);
      expect(after.state.context.occasions, {Occasion.coffee});
      after.dispose();
    });
  });
}
