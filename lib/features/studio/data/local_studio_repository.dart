import 'dart:convert';

import 'package:sqlite_async/sqlite3_common.dart' show Row;
import 'package:sqlite_async/sqlite_async.dart';

import '../../../core/errors/failures.dart';
import '../../../core/media/photo_sanitizer.dart';
import '../../../core/storage/attachment_store.dart';
import '../../../core/storage/object_id.dart';
import '../../../core/time/clock.dart';
import '../domain/analysis_selection.dart';
import '../domain/analysis_task.dart';
import '../domain/batch_status.dart';
import '../domain/extracted_item.dart';
import '../domain/last_worn.dart';
import '../domain/media_asset.dart';
import '../domain/photo_storage.dart';
import '../domain/photo_tray.dart';
import '../domain/privacy_consent.dart';
import '../domain/review_draft.dart';
import '../domain/upload_batch.dart';
import 'studio_repository.dart';

/// [StudioRepository] over the local `upload_batches`, `media_assets`,
/// `ai_processing_jobs`, `extracted_items` and `consents` tables.
///
/// Analysis is still a fake (AI-001 replaces it, CHG-006 G-01): a photo with
/// a URI fixture uses it (an empty fixture is "no clothes found"); any other
/// stored photo gets one of the three sample sets, chosen from a stable hash
/// of its sanitized bytes. Photos are sanitized before any byte reaches the
/// [AttachmentStore] (TASK-007). Picked file URIs are local paths and are
/// never stored; restored photos are `attachment://<id>`.
class LocalStudioRepository implements StudioRepository {
  static const String _purpose = 'WARDROBE';

  final SqliteConnection _db;
  final String _ownerId;
  final AttachmentStore _attachments;
  final ObjectIdGenerator _ids;
  final Clock _clock;
  final PhotoSanitizer _sanitizer;
  final Map<String, List<StudioFixtureItem>> _fixtures;
  final Set<String> _failingUris;

  LocalStudioRepository({
    required SqliteConnection db,
    required String ownerId,
    required AttachmentStore attachments,
    required ObjectIdGenerator ids,
    required Clock clock,
    PhotoSanitizer sanitizer = const PhotoSanitizer(),
    Map<String, List<StudioFixtureItem>> fixtures =
        MockStudioRepository.presetFixtures,
    Set<String> failingUris = const {},
  })  : _db = db,
        _ownerId = ownerId,
        _attachments = attachments,
        _ids = ids,
        _clock = clock,
        _sanitizer = sanitizer,
        _fixtures = fixtures,
        _failingUris = failingUris;

  /// The sample sets a real photo can get, in a fixed order.
  static final List<List<StudioFixtureItem>> _samples =
      MockStudioRepository.presetFixtures.values.toList();

  @override
  Future<PrivacyConsent> recordConsent(PrivacyConsent consent) =>
      _write('Could not record your consent.', () async {
        final stored = PrivacyConsent(
          id: _ids.next(),
          version: consent.version,
          grantedAt: consent.grantedAt,
          includesBodyProcessing: consent.includesBodyProcessing,
        );
        await _db.execute(
          'INSERT INTO consents(id, user_id, version, includes_body, '
          'granted_at) VALUES (?, ?, ?, ?, ?)',
          [
            stored.id,
            _ownerId,
            stored.version,
            stored.includesBodyProcessing ? 1 : 0,
            stored.grantedAt.toIso8601String(),
          ],
        );
        return stored;
      });

  @override
  Future<PrivacyConsent?> activeConsent() =>
      _read('Could not read your consent.', () async {
        final row = await _db.getOptional(
          'SELECT * FROM consents WHERE user_id = ? AND revoked_at IS NULL '
          'ORDER BY granted_at DESC LIMIT 1',
          [_ownerId],
        );
        if (row == null) return null;
        return PrivacyConsent(
          id: row['id'] as String,
          version: row['version'] as String,
          grantedAt: DateTime.parse(row['granted_at'] as String),
          includesBodyProcessing: row['includes_body'] == 1,
        );
      });

  @override
  Future<ReviewDraft> analyze({
    required List<MediaAsset> assets,
    required AnalysisSelection selection,
  }) =>
      _write("Garblo couldn't read these photos.", () async {
        final bySlot = [...assets]
          ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));
        final items = <ExtractedItem>[];
        final failed = <String>{};
        for (final asset in bySlot) {
          if (_failingUris.contains(asset.uri)) {
            failed.add(asset.assetId);
            continue;
          }
          final found = await _fixtureFor(asset);
          for (var i = 0; i < found.length; i++) {
            items.add(ExtractedItem(
              draftId: _ids.next(),
              assetId: asset.assetId,
              slotIndex: asset.slotIndex,
              itemIndex: i + 1,
              name: found[i].name,
              confidence: found[i].confidence,
              ai: found[i].attributes,
              value: found[i].attributes,
            ));
          }
        }
        await _recordJobs(bySlot, selection, failed);
        return ReviewDraft(
          photoCount: assets.length,
          failedPhotoCount: failed.length,
          items: List.unmodifiable(items),
        );
      });

  @override
  Future<UploadBatch?> loadOpenBatch() =>
      _read('Could not restore your photos.', () async {
        final batch = await _db.getOptional(
          'SELECT * FROM upload_batches WHERE user_id = ? '
          "AND status NOT IN ('COMPLETED', 'DELETED_BY_USER') "
          'ORDER BY updated_at DESC LIMIT 1',
          [_ownerId],
        );
        if (batch == null) return null;
        final batchId = batch['id'] as String;
        final assetRows = await _db.getAll(
          'SELECT * FROM media_assets WHERE batch_id = ? AND removed = 0 '
          'ORDER BY slot_index',
          [batchId],
        );
        final assets = [for (final row in assetRows) _assetFromRow(row)];
        final status = _statusFrom(batch['status'] as String);
        return UploadBatch(
          batchId: batchId,
          status: status,
          tray: PhotoTray(
              assets: List.unmodifiable(assets),
              nextSequence: assets.length + 1),
          selection: AnalysisSelection({
            if (batch['req_outfit'] == 1) AnalysisTask.outfitExtraction,
            if (batch['req_pose'] == 1) AnalysisTask.poseEstimation,
            if (batch['req_background'] == 1) AnalysisTask.backgroundAnalysis,
          }),
          consentId: batch['consent_id'] as String?,
          review: status == BatchStatus.awaitingReview
              ? await _review(batchId, assets.length)
              : null,
        );
      });

  /// One write transaction, issued before the first `await`, so a save made
  /// just before the app closes is queued ahead of the close.
  @override
  Future<void> saveBatch(UploadBatch batch) async {
    final now = _clock.now().toIso8601String();
    final removedFiles = <String>[];
    try {
      await _db.writeTransaction((tx) async {
        final existing = await tx.getOptional(
            'SELECT created_at FROM upload_batches WHERE id = ?',
            [batch.batchId]);
        await tx.execute(
            'DELETE FROM upload_batches WHERE id = ?', [batch.batchId]);
        await tx.execute(
          'INSERT INTO upload_batches(id, user_id, purpose, consent_id, '
          'status, req_outfit, req_pose, req_background, created_at, '
          'updated_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            batch.batchId,
            _ownerId,
            _purpose,
            batch.consentId,
            _statusCode(batch.status),
            _flag(batch.selection.contains(AnalysisTask.outfitExtraction)),
            _flag(batch.selection.contains(AnalysisTask.poseEstimation)),
            _flag(batch.selection.contains(AnalysisTask.backgroundAnalysis)),
            existing?['created_at'] ?? now,
            now,
          ],
        );

        final inTray = {for (final a in batch.tray.assets) a.assetId};
        final stale = await tx.getAll(
          'SELECT id, attachment_id FROM media_assets '
          'WHERE batch_id = ? AND removed = 0',
          [batch.batchId],
        );
        for (final row in stale) {
          if (inTray.contains(row['id'])) continue;
          // Taken out of the tray: keep the row, drop the photo (R9).
          await tx.execute(
            'UPDATE media_assets SET removed = 1, attachment_id = NULL '
            'WHERE id = ?',
            [row['id']],
          );
          final file = row['attachment_id'] as String?;
          if (file != null) removedFiles.add(file);
        }
        for (final asset in batch.tray.assets) {
          await _upsertAsset(tx, batch.batchId, asset, now);
        }

        await tx.execute(
            'DELETE FROM extracted_items WHERE batch_id = ?', [batch.batchId]);
        for (final item in batch.review?.items ?? const <ExtractedItem>[]) {
          await tx.execute(
            'INSERT INTO extracted_items(id, user_id, batch_id, asset_id, '
            'item_index, name, confidence, ai, value, last_worn_input, '
            'created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              item.draftId,
              _ownerId,
              batch.batchId,
              item.assetId,
              item.itemIndex,
              item.name,
              item.confidence,
              jsonEncode(_attributesJson(item.ai)),
              jsonEncode(_attributesJson(item.value)),
              jsonEncode(_lastWornJson(item.lastWorn)),
              now,
            ],
          );
        }
      });
    } catch (error) {
      throw StorageFailure('Could not save your photos.', error);
    }
    for (final file in removedFiles) {
      await _deleteFileQuietly(file);
    }
  }

  @override
  Future<PhotoStorageResult> storePhotos({
    required String batchId,
    required List<StagedPhoto> photos,
  }) async {
    final stored = <MediaAsset>[];
    final failed = <String>[];
    for (final staged in photos) {
      final bytes = staged.photo.bytes;
      if (bytes == null) {
        // A sample photo without bytes: nothing to sanitize or keep.
        await _writeAsset(batchId, staged.asset);
        stored.add(staged.asset);
        continue;
      }
      String? attachmentId;
      try {
        final clean =
            _sanitizer.sanitize(bytes, mimeType: staged.photo.mimeType);
        attachmentId = await _attachments.save(clean.bytes);
        final asset = MediaAsset(
          assetId: staged.asset.assetId,
          slotIndex: staged.asset.slotIndex,
          uri: staged.asset.uri,
          mimeType: clean.mimeType,
          attachmentId: attachmentId,
          orientation: clean.orientation,
        );
        await _writeAsset(batchId, asset);
        stored.add(asset);
      } on Failure {
        // Nothing may be kept for a photo that could not be protected.
        if (attachmentId != null) await _deleteFileQuietly(attachmentId);
        failed.add(staged.asset.assetId);
      }
    }
    return PhotoStorageResult(
      stored: List.unmodifiable(stored),
      failedAssetIds: List.unmodifiable(failed),
    );
  }

  @override
  Future<void> discardBatch(String batchId) async {
    final files = <String>[];
    try {
      await _db.writeTransaction((tx) async {
        final rows = await tx.getAll(
          'SELECT attachment_id FROM media_assets '
          'WHERE batch_id = ? AND attachment_id IS NOT NULL',
          [batchId],
        );
        files.addAll(rows.map((r) => r['attachment_id'] as String));
        for (final table in [
          'media_assets',
          'ai_processing_jobs',
          'extracted_items',
        ]) {
          await tx.execute('DELETE FROM $table WHERE batch_id = ?', [batchId]);
        }
        await tx.execute('DELETE FROM upload_batches WHERE id = ?', [batchId]);
      });
    } catch (error) {
      throw StorageFailure('Could not discard these photos.', error);
    }
    for (final file in files) {
      await _deleteFileQuietly(file);
    }
  }

  Future<List<StudioFixtureItem>> _fixtureFor(MediaAsset asset) async {
    final byUri = _fixtures[asset.uri];
    if (byUri != null) return byUri;
    final attachmentId = asset.attachmentId ?? await _storedAttachment(asset);
    if (attachmentId == null) return const [];
    final bytes = await _attachments.read(attachmentId);
    return _samples[stableHash(bytes) % _samples.length];
  }

  Future<String?> _storedAttachment(MediaAsset asset) async {
    final row = await _db.getOptional(
        'SELECT attachment_id FROM media_assets WHERE id = ?', [asset.assetId]);
    return row?['attachment_id'] as String?;
  }

  /// One job per photo × selected task (spec C6). The ID is deterministic,
  /// so a retry updates the job instead of adding one (CHG-006 G-03).
  Future<void> _recordJobs(
    List<MediaAsset> assets,
    AnalysisSelection selection,
    Set<String> failed,
  ) async {
    if (assets.isEmpty) return;
    final marks = List.filled(assets.length, '?').join(', ');
    final rows = await _db.getAll(
      'SELECT id, batch_id FROM media_assets WHERE id IN ($marks)',
      [for (final a in assets) a.assetId],
    );
    final batchOf = {
      for (final row in rows) row['id'] as String: row['batch_id'] as String,
    };
    final now = _clock.now().toIso8601String();
    await _db.writeTransaction((tx) async {
      for (final asset in assets) {
        final batchId = batchOf[asset.assetId];
        if (batchId == null) continue;
        for (final task in selection.tasks) {
          final type = _taskCode(task);
          final status = task == AnalysisTask.outfitExtraction
              ? (failed.contains(asset.assetId) ? 'FAILED' : 'COMPLETED')
              // No person detection before AI-004 (CHG-006 G-04).
              : 'SKIPPED_NO_PERSON';
          final id = deterministicObjectId([batchId, asset.assetId, type]);
          final existing = await tx.getOptional(
              'SELECT created_at FROM ai_processing_jobs WHERE id = ?', [id]);
          await tx.execute('DELETE FROM ai_processing_jobs WHERE id = ?', [id]);
          await tx.execute(
            'INSERT INTO ai_processing_jobs(id, user_id, batch_id, asset_id, '
            'task_type, status, created_at, updated_at) '
            'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
            [
              id,
              _ownerId,
              batchId,
              asset.assetId,
              type,
              status,
              existing?['created_at'] ?? now,
              now,
            ],
          );
        }
      }
    });
  }

  Future<ReviewDraft> _review(String batchId, int trayCount) async {
    final rows = await _db.getAll(
      'SELECT e.*, a.slot_index FROM extracted_items e '
      'JOIN media_assets a ON a.id = e.asset_id '
      'WHERE e.batch_id = ? ORDER BY a.slot_index, e.item_index',
      [batchId],
    );
    final jobs = await _db.get(
      'SELECT count(DISTINCT asset_id) AS photos, '
      "count(DISTINCT CASE WHEN task_type = 'OUTFIT_EXTRACTION' "
      "AND status = 'FAILED' THEN asset_id END) AS failed "
      'FROM ai_processing_jobs WHERE batch_id = ?',
      [batchId],
    );
    final photos = jobs['photos'] as int;
    return ReviewDraft(
      photoCount: photos == 0 ? trayCount : photos,
      failedPhotoCount: jobs['failed'] as int,
      items: List.unmodifiable([
        for (final row in rows)
          ExtractedItem(
            draftId: row['id'] as String,
            assetId: row['asset_id'] as String,
            slotIndex: row['slot_index'] as int,
            itemIndex: row['item_index'] as int,
            name: row['name'] as String,
            confidence: (row['confidence'] as num).toDouble(),
            ai: _attributesFrom(row['ai'] as String),
            value: _attributesFrom(row['value'] as String),
            lastWorn: _lastWornFrom(row['last_worn_input'] as String?),
          ),
      ]),
    );
  }

  Future<void> _writeAsset(String batchId, MediaAsset asset) =>
      _db.writeTransaction((tx) =>
          _upsertAsset(tx, batchId, asset, _clock.now().toIso8601String()));

  Future<void> _upsertAsset(SqliteWriteContext tx, String batchId,
      MediaAsset asset, String now) async {
    final existing = await tx.getOptional(
        'SELECT created_at FROM media_assets WHERE id = ?', [asset.assetId]);
    await tx.execute('DELETE FROM media_assets WHERE id = ?', [asset.assetId]);
    await tx.execute(
      'INSERT INTO media_assets(id, user_id, batch_id, slot_index, mime_type, '
      'attachment_id, orientation, exif_gps_stripped, bystanders_blurred, '
      'contains_person, removed, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, 0, 0, 0, ?)',
      [
        asset.assetId,
        _ownerId,
        batchId,
        asset.slotIndex,
        asset.mimeType,
        asset.attachmentId,
        asset.orientation,
        asset.attachmentId == null ? 0 : 1,
        existing?['created_at'] ?? now,
      ],
    );
  }

  Future<void> _deleteFileQuietly(String attachmentId) async {
    try {
      await _attachments.delete(attachmentId);
    } catch (_) {
      // Best effort; delete all (TASK-008) removes the whole folder.
    }
  }

  static MediaAsset _assetFromRow(Row row) {
    final attachmentId = row['attachment_id'] as String?;
    final assetId = row['id'] as String;
    return MediaAsset(
      assetId: assetId,
      slotIndex: row['slot_index'] as int,
      uri: attachmentId == null
          ? 'asset://$assetId'
          : 'attachment://$attachmentId',
      mimeType: row['mime_type'] as String,
      attachmentId: attachmentId,
      orientation: (row['orientation'] as int?) ?? 1,
    );
  }

  static int _flag(bool value) => value ? 1 : 0;

  static String _taskCode(AnalysisTask task) => switch (task) {
        AnalysisTask.outfitExtraction => 'OUTFIT_EXTRACTION',
        AnalysisTask.poseEstimation => 'POSE_ESTIMATION',
        AnalysisTask.backgroundAnalysis => 'BACKGROUND_ANALYSIS',
      };

  /// `awaitingReview` → `AWAITING_REVIEW` (spec T2 names).
  static String _statusCode(BatchStatus status) => status.name
      .replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}')
      .toUpperCase();

  static BatchStatus _statusFrom(String code) =>
      BatchStatus.values.firstWhere((s) => _statusCode(s) == code);

  static Map<String, String> _attributesJson(ItemAttributes a) => {
        'type_code': a.typeCode,
        'color': a.color,
        'material': a.material,
        'style_tag': a.styleTag,
      };

  static ItemAttributes _attributesFrom(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return ItemAttributes(
      typeCode: map['type_code'] as String,
      color: map['color'] as String,
      material: map['material'] as String,
      styleTag: map['style_tag'] as String,
    );
  }

  static Map<String, String?> _lastWornJson(LastWornInput input) => {
        'option': input.option.name,
        'exact_date': input.exactDate?.toIso8601String(),
      };

  static LastWornInput _lastWornFrom(String? json) {
    if (json == null) return const LastWornInput.dontRemember();
    final map = jsonDecode(json) as Map<String, dynamic>;
    final date = map['exact_date'] as String?;
    return LastWornInput(
      LastWornOption.values.byName(map['option'] as String),
      exactDate: date == null ? null : DateTime.parse(date),
    );
  }

  static Future<T> _read<T>(String message, Future<T> Function() read) async {
    try {
      return await read();
    } on Failure {
      rethrow;
    } catch (error) {
      throw StorageFailure(message, error);
    }
  }

  static Future<T> _write<T>(String message, Future<T> Function() write) =>
      _read(message, write);
}
