import 'package:sqlite_async/sqlite_async.dart';

import '../../../core/media/photo_sanitizer.dart';
import '../../../core/storage/attachment_store.dart';
import '../../../core/storage/object_id.dart';
import '../../../core/time/clock.dart';
import '../domain/analysis_selection.dart';
import '../domain/media_asset.dart';
import '../domain/photo_storage.dart';
import '../domain/privacy_consent.dart';
import '../domain/review_draft.dart';
import '../domain/upload_batch.dart';
import 'studio_repository.dart';

/// [StudioRepository] over the local `upload_batches`, `media_assets`,
/// `extracted_items` and `consents` tables. Analysis stays the Phase 1
/// fixture fake; draft IDs are ObjectIds. Photos are sanitized before any
/// byte reaches the [AttachmentStore] (TASK-007).
class LocalStudioRepository implements StudioRepository {
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
  });

  @override
  Future<PrivacyConsent> recordConsent(PrivacyConsent consent) =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<ReviewDraft> analyze({
    required List<MediaAsset> assets,
    required AnalysisSelection selection,
  }) =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<PrivacyConsent?> activeConsent() =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<UploadBatch?> loadOpenBatch() =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<void> saveBatch(UploadBatch batch) =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<PhotoStorageResult> storePhotos({
    required String batchId,
    required List<StagedPhoto> photos,
  }) =>
      throw UnimplementedError('TASK-007-S03');

  @override
  Future<void> discardBatch(String batchId) =>
      throw UnimplementedError('TASK-007-S07');
}
