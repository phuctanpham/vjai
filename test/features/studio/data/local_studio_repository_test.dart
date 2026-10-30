import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/media/photo_picker.dart';
import 'package:garblo/core/storage/attachment_store.dart';
import 'package:garblo/core/storage/object_id.dart';
import 'package:garblo/features/studio/data/local_studio_repository.dart';
import 'package:garblo/features/studio/domain/analysis_selection.dart';
import 'package:garblo/features/studio/domain/analysis_task.dart';
import 'package:garblo/features/studio/domain/batch_status.dart';
import 'package:garblo/features/studio/domain/last_worn.dart';
import 'package:garblo/features/studio/domain/media_asset.dart';
import 'package:garblo/features/studio/domain/photo_storage.dart';
import 'package:garblo/features/studio/domain/photo_tray.dart';
import 'package:garblo/features/studio/domain/privacy_consent.dart';
import 'package:garblo/features/studio/domain/upload_batch.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/image_fixtures.dart';
import '../../../helpers/local_db.dart';

const _owner = '65f0c1a2b3c4d5e6f7a8b9c0';

void main() {
  late TestDatabase t;
  late Directory files;
  late AttachmentStore attachments;
  late ObjectIdGenerator ids;
  final clock = FixedClock(testToday);

  LocalStudioRepository repoOn(SqliteConnection db) => LocalStudioRepository(
        db: db,
        ownerId: _owner,
        attachments: attachments,
        ids: ids,
        clock: clock,
      );

  setUp(() async {
    t = await TestDatabase.open();
    files = await tempDir('studio_files');
    ids = ObjectIdGenerator(clock: clock);
    attachments = FileAttachmentStore(root: files, ids: ids);
  });

  tearDown(() async {
    await t.dispose();
    if (await files.exists()) await files.delete(recursive: true);
  });

  MediaAsset asset(int slot, String uri) => MediaAsset(
        assetId: ids.next(),
        slotIndex: slot,
        uri: uri,
        mimeType: uri.endsWith('.png') ? 'image/png' : 'image/jpeg',
      );

  /// Stores two real photos for [batchId] and returns the stored assets.
  Future<List<MediaAsset>> storeTwo(
      LocalStudioRepository repo, String batchId) async {
    final staged = [
      StagedPhoto(
        asset: asset(1, 'content://gallery/1.jpg'),
        photo: PickedPhoto(
            uri: 'content://gallery/1.jpg',
            mimeType: 'image/jpeg',
            bytes: jpegWithMetadata(orientation: 6)),
      ),
      StagedPhoto(
        asset: asset(2, 'content://gallery/2.png'),
        photo: PickedPhoto(
            uri: 'content://gallery/2.png',
            mimeType: 'image/png',
            bytes: pngWithMetadata()),
      ),
    ];
    final result = await repo.storePhotos(batchId: batchId, photos: staged);
    return result.stored;
  }

  group('Consent', () {
    test('[TASK-005-S03] a recorded consent gets an ID and is active',
        () async {
      final repo = repoOn(t.db);

      final stored = await repo.recordConsent(PrivacyConsent(
        version: PrivacyConsent.studioVersion,
        grantedAt: testToday,
        includesBodyProcessing: true,
      ));

      expect(isObjectId(stored.id!), isTrue);
      expect(stored.isActive, isTrue);
      expect(await repo.activeConsent(), stored);
    });

    test('[TASK-005-S03] the consent survives closing and reopening', () async {
      final stored = await repoOn(t.db).recordConsent(PrivacyConsent(
        version: PrivacyConsent.studioVersion,
        grantedAt: testToday,
        includesBodyProcessing: true,
      ));

      final reopened = await t.reopen();

      expect(await repoOn(reopened).activeConsent(), stored);
      final row = await reopened.get('SELECT user_id FROM consents');
      expect(row['user_id'], _owner);
    });

    test('[TASK-005-S03] no consent means none is active', () async {
      expect(await repoOn(t.db).activeConsent(), isNull);
    });
  });

  group('Analysis', () {
    test(
        '[TASK-005-S03] fixture analysis returns ObjectId draft IDs in slot order',
        () async {
      final repo = repoOn(t.db);
      final assets = [
        asset(2, 'preset://flatlay-cream-sneakers.png'),
        asset(1, 'preset://flatlay-violet-shirt.jpg'),
      ];

      final review = await repo.analyze(
          assets: assets, selection: AnalysisSelection.defaults());

      expect(
          review.items.map((i) => i.name), ['Violet shirt', 'Cream sneakers']);
      expect(review.items.every((i) => isObjectId(i.draftId)), isTrue);
      expect(review.items.map((i) => i.draftId).toSet(), hasLength(2));
    });
  });

  group('Open batch', () {
    test('[TASK-005-S03] there is no open batch on a fresh install', () async {
      expect(await repoOn(t.db).loadOpenBatch(), isNull);
    });

    test(
        '[TASK-005-S03] the open batch with review edits survives closing and '
        'reopening', () async {
      final repo = repoOn(t.db);
      final batchId = ids.next();
      final consent = await repo.recordConsent(PrivacyConsent(
        version: PrivacyConsent.studioVersion,
        grantedAt: testToday,
        includesBodyProcessing: true,
      ));
      final stored = await storeTwo(repo, batchId);
      const selection = AnalysisSelection(
          {AnalysisTask.outfitExtraction, AnalysisTask.poseEstimation});
      final analysed = await repo.analyze(
        assets: [
          for (final a in stored)
            MediaAsset(
              assetId: a.assetId,
              slotIndex: a.slotIndex,
              uri: a.slotIndex == 1
                  ? 'preset://flatlay-violet-shirt.jpg'
                  : 'preset://flatlay-cream-sneakers.png',
              mimeType: a.mimeType,
            ),
        ],
        selection: selection,
      );
      final edited = analysed
          .replaceItem(0, analysed.items[0].edit(color: 'Lilac'))
          .replaceItem(
              1,
              analysed.items[1].withLastWorn(
                  const LastWornInput(LastWornOption.oneToThreeMonths)));
      final batch = UploadBatch(
        batchId: batchId,
        status: BatchStatus.awaitingReview,
        tray: PhotoTray(assets: stored, nextSequence: 3),
        selection: selection,
        consentId: consent.id,
        review: edited,
      );

      await repo.saveBatch(batch);
      final reopened = await t.reopen();
      final restored = await repoOn(reopened).loadOpenBatch();

      expect(restored, isNotNull);
      expect(restored!.batchId, batchId);
      expect(restored.status, BatchStatus.awaitingReview);
      expect(restored.selection, selection);
      expect(restored.consentId, consent.id);
      expect(restored.review, edited);
      expect(restored.tray.assets.map((a) => a.assetId),
          stored.map((a) => a.assetId));
      expect(restored.tray.assets.map((a) => a.slotIndex), [1, 2]);
      expect(restored.tray.assets.map((a) => a.attachmentId),
          stored.map((a) => a.attachmentId));
      expect(restored.tray.assets.map((a) => a.orientation), [6, 1]);
    });

    test(
        '[TASK-005-S03] local file URIs are not stored; photos restore by '
        'attachment', () async {
      final repo = repoOn(t.db);
      final batchId = ids.next();
      final stored = await storeTwo(repo, batchId);
      await repo.saveBatch(UploadBatch(
        batchId: batchId,
        status: BatchStatus.draft,
        tray: PhotoTray(assets: stored, nextSequence: 3),
        selection: AnalysisSelection.defaults(),
      ));

      final restored = await repo.loadOpenBatch();

      for (final a in restored!.tray.assets) {
        expect(a.uri, 'attachment://${a.attachmentId}');
      }
      final dump = await t.db.getAll('SELECT * FROM media_assets');
      expect(dump.toString(), isNot(contains('content://')));
    });

    test('[TASK-005-S03] saving again updates the batch without duplicates',
        () async {
      final repo = repoOn(t.db);
      final batchId = ids.next();
      final stored = await storeTwo(repo, batchId);
      final draft = UploadBatch(
        batchId: batchId,
        status: BatchStatus.draft,
        tray: PhotoTray(assets: stored, nextSequence: 3),
        selection: AnalysisSelection.defaults(),
      );

      await repo.saveBatch(draft);
      await repo.saveBatch(UploadBatch(
        batchId: batchId,
        status: BatchStatus.sanitizing,
        tray: PhotoTray(assets: [stored.first], nextSequence: 3),
        selection: AnalysisSelection.defaults(),
      ));

      final batches =
          await t.db.get('SELECT count(*) AS n FROM upload_batches');
      expect(batches['n'], 1);
      final restored = await repo.loadOpenBatch();
      expect(restored!.status, BatchStatus.sanitizing);
      expect(
          restored.tray.assets.map((a) => a.assetId), [stored.first.assetId]);
    });

    test('[TASK-005-S03] a completed batch is no longer open', () async {
      final repo = repoOn(t.db);
      final batchId = ids.next();
      final stored = await storeTwo(repo, batchId);

      await repo.saveBatch(UploadBatch(
        batchId: batchId,
        status: BatchStatus.completed,
        tray: PhotoTray(assets: stored, nextSequence: 3),
        selection: AnalysisSelection.defaults(),
      ));

      expect(await repo.loadOpenBatch(), isNull);
    });

    test('[TASK-005-S03] rows carry the owner ID', () async {
      final repo = repoOn(t.db);
      final batchId = ids.next();
      final stored = await storeTwo(repo, batchId);
      await repo.saveBatch(UploadBatch(
        batchId: batchId,
        status: BatchStatus.draft,
        tray: PhotoTray(assets: stored, nextSequence: 3),
        selection: AnalysisSelection.defaults(),
      ));

      for (final table in ['upload_batches', 'media_assets']) {
        final owners = await t.db.getAll('SELECT DISTINCT user_id FROM $table');
        expect(owners.map((r) => r['user_id']), [_owner], reason: table);
      }
    });
  });
}
