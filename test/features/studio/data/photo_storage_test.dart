import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/media/photo_picker.dart';
import 'package:garblo/core/storage/attachment_store.dart';
import 'package:garblo/core/storage/object_id.dart';
import 'package:garblo/features/studio/data/local_studio_repository.dart';
import 'package:garblo/features/studio/domain/analysis_selection.dart';
import 'package:garblo/features/studio/domain/batch_status.dart';
import 'package:garblo/features/studio/domain/media_asset.dart';
import 'package:garblo/features/studio/domain/photo_storage.dart';
import 'package:garblo/features/studio/domain/photo_tray.dart';
import 'package:garblo/features/studio/domain/upload_batch.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/image_fixtures.dart';
import '../../../helpers/local_db.dart';

const _owner = '65f0c1a2b3c4d5e6f7a8b9c0';

/// Records every byte array handed to the store.
class _RecordingStore implements AttachmentStore {
  final AttachmentStore inner;
  final List<Uint8List> saved = [];

  _RecordingStore(this.inner);

  @override
  Future<String> save(Uint8List bytes) {
    saved.add(bytes);
    return inner.save(bytes);
  }

  @override
  Future<Uint8List> read(String id) => inner.read(id);
  @override
  Future<bool> exists(String id) => inner.exists(id);
  @override
  Future<void> delete(String id) => inner.delete(id);
  @override
  Future<void> deleteAll() => inner.deleteAll();
  @override
  Future<List<String>> listIds() => inner.listIds();
}

void main() {
  late TestDatabase t;
  late Directory files;
  late _RecordingStore attachments;
  late ObjectIdGenerator ids;
  late LocalStudioRepository repo;
  final clock = FixedClock(testToday);

  setUp(() async {
    t = await TestDatabase.open();
    files = await tempDir('photo_files');
    ids = ObjectIdGenerator(clock: clock);
    attachments = _RecordingStore(FileAttachmentStore(root: files, ids: ids));
    repo = LocalStudioRepository(
      db: t.db,
      ownerId: _owner,
      attachments: attachments,
      ids: ids,
      clock: clock,
    );
  });

  tearDown(() async {
    await t.dispose();
    if (await files.exists()) await files.delete(recursive: true);
  });

  StagedPhoto staged(int slot, Uint8List? bytes,
      {String mimeType = 'image/jpeg'}) {
    final uri = 'content://gallery/$slot';
    return StagedPhoto(
      asset: MediaAsset(
          assetId: ids.next(), slotIndex: slot, uri: uri, mimeType: mimeType),
      photo: PickedPhoto(uri: uri, mimeType: mimeType, bytes: bytes),
    );
  }

  Future<int> assetRows(String batchId) async {
    final row = await t.db.get(
        'SELECT count(*) AS n FROM media_assets WHERE batch_id = ?', [batchId]);
    return row['n'] as int;
  }

  group('storePhotos', () {
    test('[TASK-007-S03] the original bytes never reach the attachment store',
        () async {
      final jpeg = jpegWithMetadata();
      final png = pngWithMetadata();

      await repo.storePhotos(batchId: ids.next(), photos: [
        staged(1, jpeg),
        staged(2, png, mimeType: 'image/png'),
      ]);

      expect(attachments.saved, hasLength(2));
      for (final bytes in attachments.saved) {
        expect(listEquals(bytes, jpeg), isFalse);
        expect(listEquals(bytes, png), isFalse);
        for (final marker in [
          gpsMarker,
          xmpMarker,
          iptcMarker,
          pngTextMarker
        ]) {
          expect(containsAscii(bytes, marker), isFalse, reason: marker);
        }
        expect(containsAscii(bytes, imageDataMarker), isTrue);
      }
    });

    test('[TASK-007-S03] stored assets carry the attachment and orientation',
        () async {
      final batchId = ids.next();

      final result = await repo.storePhotos(
          batchId: batchId,
          photos: [staged(1, jpegWithMetadata(orientation: 8))]);

      final stored = result.stored.single;
      expect(result.failedAssetIds, isEmpty);
      expect(isObjectId(stored.attachmentId!), isTrue);
      expect(stored.orientation, 8);
      expect(await attachments.exists(stored.attachmentId!), isTrue);

      final row = await t.db.get(
          'SELECT attachment_id, orientation, exif_gps_stripped, mime_type, '
          'slot_index, user_id FROM media_assets WHERE id = ?',
          [stored.assetId]);
      expect(row['attachment_id'], stored.attachmentId);
      expect(row['orientation'], 8);
      expect(row['exif_gps_stripped'], 1);
      expect(row['mime_type'], 'image/jpeg');
      expect(row['slot_index'], 1);
      expect(row['user_id'], _owner);
    });

    test('[TASK-007-S03] a photo without bytes (sample) stores no file',
        () async {
      final result = await repo
          .storePhotos(batchId: ids.next(), photos: [staged(1, null)]);

      expect(result.stored.single.attachmentId, isNull);
      expect(attachments.saved, isEmpty);
    });

    test(
        '[TASK-007-S05] a photo that fails sanitizing leaves no file and no row',
        () async {
      final batchId = ids.next();
      final good = staged(1, jpegWithMetadata());
      final malformed = staged(2, Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE1]));
      final heic = staged(3, heicBytes(), mimeType: 'image/heic');

      final result = await repo
          .storePhotos(batchId: batchId, photos: [good, malformed, heic]);

      expect(result.stored.map((a) => a.assetId), [good.asset.assetId]);
      expect(
          result.failedAssetIds, [malformed.asset.assetId, heic.asset.assetId]);
      expect(await attachments.listIds(), hasLength(1));
      expect(await assetRows(batchId), 1);
    });
  });

  group('discardBatch', () {
    test('[TASK-007-S07] removes the batch files and rows', () async {
      final batchId = ids.next();
      final result = await repo.storePhotos(batchId: batchId, photos: [
        staged(1, jpegWithMetadata()),
        staged(2, pngWithMetadata(), mimeType: 'image/png'),
      ]);
      await repo.saveBatch(UploadBatch(
        batchId: batchId,
        status: BatchStatus.draft,
        tray: PhotoTray(assets: result.stored, nextSequence: 3),
        selection: AnalysisSelection.defaults(),
      ));

      await repo.discardBatch(batchId);

      expect(await attachments.listIds(), isEmpty);
      expect(await assetRows(batchId), 0);
      for (final table in ['upload_batches', 'extracted_items']) {
        final rows = await t.db.getAll(
            'SELECT id FROM $table WHERE ${table == 'upload_batches' ? 'id' : 'batch_id'} = ?',
            [batchId]);
        expect(rows, isEmpty, reason: table);
      }
      expect(await repo.loadOpenBatch(), isNull);
    });

    test('[TASK-007-S07] other batches are untouched', () async {
      final keep = ids.next();
      final drop = ids.next();
      final kept = await repo
          .storePhotos(batchId: keep, photos: [staged(1, jpegWithMetadata())]);
      await repo
          .storePhotos(batchId: drop, photos: [staged(1, jpegWithMetadata())]);

      await repo.discardBatch(drop);

      expect(await attachments.listIds(), [kept.stored.single.attachmentId]);
      expect(await assetRows(keep), 1);
    });
  });
}
