import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/media/photo_picker.dart';
import '../../../core/storage/object_id.dart';
import '../../../core/storage/storage_providers.dart';
import '../../../core/time/clock.dart';
import '../../wardrobe/data/wardrobe_repository.dart';
import '../../wardrobe/domain/wardrobe_item.dart';
import '../data/studio_repository.dart';
import '../domain/analysis_task.dart';
import '../domain/batch_status.dart';
import '../domain/extracted_item.dart';
import '../domain/last_worn.dart';
import '../domain/photo_storage.dart';
import '../domain/photo_tray.dart';
import '../domain/privacy_consent.dart';
import '../domain/review_draft.dart';
import '../domain/upload_batch.dart';
import 'studio_state.dart';

/// Provider for StudioViewModel. Kept alive so a review draft survives
/// switching pillars. Restores the open batch on creation (TASK-005-S03).
final studioViewModelProvider =
    StateNotifierProvider<StudioViewModel, StudioState>((ref) {
  return StudioViewModel(
    studioRepository: ref.watch(studioRepositoryProvider),
    wardrobeRepository: ref.watch(wardrobeRepositoryProvider),
    photoPicker: ref.watch(photoPickerProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(objectIdGeneratorProvider),
  )..restore();
});

/// ViewModel for Flow A: tray, consent, scope sheet, analysis, review, save.
///
/// Every change to the batch is saved through the repository, so the batch
/// survives a restart (TASK-005-S03). Saves are issued at once, in order;
/// a failed save does not interrupt the flow.
class StudioViewModel extends StateNotifier<StudioState> {
  static const String analysisFailedMessage = "Couldn't read these photos.";
  static const String saveFailedMessage = "Couldn't index your Pieces.";

  final StudioRepository _studioRepository;
  final WardrobeRepository _wardrobeRepository;
  final PhotoPicker _photoPicker;
  final Clock _clock;
  final ObjectIdGenerator _ids;

  /// The open batch (an ObjectId, unique across batches).
  String _batchId;

  StudioViewModel({
    required StudioRepository studioRepository,
    required WardrobeRepository wardrobeRepository,
    required PhotoPicker photoPicker,
    required Clock clock,

    /// Batch and asset IDs (ObjectIds, unique across batches). Defaults to
    /// a generator on [clock].
    ObjectIdGenerator? ids,
  }) : this._(
          studioRepository,
          wardrobeRepository,
          photoPicker,
          clock,
          ids ?? ObjectIdGenerator(clock: clock),
        );

  StudioViewModel._(
    this._studioRepository,
    this._wardrobeRepository,
    this._photoPicker,
    this._clock,
    this._ids,
  )   : _batchId = _ids.next(),
        super(StudioState.initial());

  /// Restores the open batch and the active consent after a restart
  /// (TASK-005-S03). Call once when the ViewModel is created.
  Future<void> restore() async {
    try {
      final consent = await _studioRepository.activeConsent();
      final batch = await _studioRepository.loadOpenBatch();
      var next = StudioState.initial().copyWith(
        consent: consent,
        consentChecked: consent != null,
      );
      if (batch != null) {
        _batchId = batch.batchId;
        var status = _resumable(batch.status);
        // Withdrawn consent: back to the tray to ask again (TASK-008-S03).
        if (consent == null) status = BatchStatus.draft;
        next = next.copyWith(
          batchStatus: status,
          tray: batch.tray,
          selection: batch.selection.isValid ? batch.selection : null,
          review: status == BatchStatus.awaitingReview ? batch.review : null,
          errorMessage:
              status == BatchStatus.failed ? analysisFailedMessage : null,
        );
      }
      state = next;
    } on Failure catch (failure) {
      state = state.copyWith(errorMessage: failure.message);
    }
  }

  /// Opens the picker for the remaining capacity, stages valid photos and
  /// stores their sanitized bytes. A photo that cannot be protected is not
  /// added (TASK-007-S05).
  Future<void> pickPhotos() async {
    if (state.batchStatus != BatchStatus.draft || state.tray.isFull) return;

    final picked =
        await _photoPicker.pick(maxCount: state.tray.remainingCapacity);
    final before = state.tray.count;
    final result = state.tray.add(picked, newAssetId: _ids.next);
    final added = result.tray.assets.sublist(before);
    final accepted = picked
        .where((p) => PhotoTray.acceptedMimeTypes.contains(p.mimeType))
        .take(added.length)
        .toList();

    var tray = result.tray;
    var unprotected = 0;
    if (added.isNotEmpty) {
      PhotoStorageResult storage;
      try {
        storage = await _studioRepository.storePhotos(
          batchId: _batchId,
          photos: [
            for (var i = 0; i < added.length; i++)
              StagedPhoto(asset: added[i], photo: accepted[i]),
          ],
        );
      } on Failure {
        storage = PhotoStorageResult(
          stored: const [],
          failedAssetIds: [for (final a in added) a.assetId],
        );
      }
      final stored = {for (final a in storage.stored) a.assetId: a};
      tray = PhotoTray(
        assets: List.unmodifiable([
          for (final asset in tray.assets)
            if (!storage.failedAssetIds.contains(asset.assetId))
              stored[asset.assetId] ?? asset,
        ]),
        nextSequence: tray.nextSequence,
      );
      unprotected = storage.failedAssetIds.length;
    }

    final notice =
        _pickNotice(result.rejectedCount, result.overLimitCount, unprotected);
    state = state.copyWith(
      tray: tray,
      notice: notice,
      clearNotice: notice == null,
    );
    _persist();
  }

  void removePhoto(String assetId) {
    if (state.batchStatus != BatchStatus.draft) return;
    state = state.copyWith(tray: state.tray.remove(assetId), clearNotice: true);
    _persist();
  }

  void setConsent(bool checked) {
    state = state.copyWith(consentChecked: checked);
  }

  /// Records consent and opens the scope sheet (DRAFT → SANITIZING).
  /// Ignored unless [StudioState.canAnalyze]. A consent already recorded for
  /// this version is reused, not inserted again (D3).
  Future<void> analyze() async {
    if (!state.canAnalyze) return;

    try {
      final consent = state.consent ??
          await _studioRepository.recordConsent(PrivacyConsent(
            version: PrivacyConsent.studioVersion,
            grantedAt: _clock.now(),
            includesBodyProcessing: true,
          ));
      state = state.copyWith(
        batchStatus: BatchStatus.sanitizing,
        consent: consent,
        clearError: true,
      );
      _persist();
    } on Failure catch (failure) {
      state = state.copyWith(errorMessage: failure.message);
    }
  }

  void toggleTask(AnalysisTask task) {
    if (!state.isScopeSheetOpen) return;
    state = state.copyWith(selection: state.selection.toggle(task));
    _persist();
  }

  /// Closes the sheet and returns to DRAFT, keeping photos and consent.
  void reselectPhotos() {
    if (!state.batchStatus.canTransitionTo(BatchStatus.draft)) return;
    state = state.copyWith(
      batchStatus: BatchStatus.draft,
      clearReview: true,
      clearError: true,
    );
    _persist();
  }

  /// Runs the analysis (→ AWAITING_REVIEW or FAILED).
  /// Ignored unless [StudioState.canConfirmScope].
  Future<void> confirmScope() async {
    if (!state.canConfirmScope) return;
    await _runAnalysis();
  }

  /// "Try again" after every photo failed.
  Future<void> retryAnalysis() async {
    if (state.batchStatus != BatchStatus.failed) return;
    await _runAnalysis();
  }

  void expandItem(int index) {
    final review = state.review;
    if (review == null || index < 0 || index >= review.items.length) return;
    state = state.copyWith(expandedIndex: index);
  }

  void editItem(
    int index, {
    String? typeCode,
    String? color,
    String? material,
    String? styleTag,
  }) {
    _updateItem(
      index,
      (item) => item.edit(
        typeCode: typeCode,
        color: color,
        material: material,
        styleTag: styleTag,
      ),
    );
  }

  /// Ignored for an exact date in the future (CHG-003 A-01).
  void setLastWorn(int index, LastWornInput lastWorn) {
    try {
      lastWorn.resolve(_clock.now());
    } on ArgumentError {
      return;
    }
    _updateItem(index, (item) => item.withLastWorn(lastWorn));
  }

  /// Saves every reviewed item at once (→ COMPLETED). Ignored while saving.
  /// Piece IDs are hashed from the draft IDs, so a retried save cannot
  /// duplicate (CHG-005 P2-D8).
  Future<void> save() async {
    final review = state.review;
    if (!state.canSave || review == null) return;

    state = state.copyWith(isSaving: true, clearError: true);
    final now = _clock.now();
    final items = [for (final item in review.items) _toWardrobeItem(item, now)];
    try {
      await _wardrobeRepository.saveItems(items);
      state =
          state.copyWith(batchStatus: BatchStatus.completed, isSaving: false);
      _persist();
    } on Failure {
      state = state.copyWith(isSaving: false, errorMessage: saveFailedMessage);
    }
  }

  /// Starts a fresh batch after a completed save. The recorded consent is
  /// kept for the next batch (D3).
  void startNewBatch() {
    _batchId = _ids.next();
    state = StudioState.initial().copyWith(
      consentChecked: state.consentChecked,
      consent: state.consent,
    );
  }

  Future<void> _runAnalysis() async {
    // Walk the spec state machine: → QUEUED_FOR_AI → AI_PROCESSING.
    _moveTo(BatchStatus.queuedForAi);
    _moveTo(BatchStatus.aiProcessing);
    state = state.copyWith(clearReview: true, clearError: true);
    try {
      final review = await _studioRepository.analyze(
        assets: state.tray.assets,
        selection: state.selection,
      );
      if (review.outcome == AnalysisOutcome.allFailed) {
        state = state.copyWith(
          batchStatus: BatchStatus.failed,
          errorMessage: analysisFailedMessage,
        );
      } else {
        state = state.copyWith(
          batchStatus: BatchStatus.awaitingReview,
          review: review,
          expandedIndex: 0,
        );
      }
    } on Failure {
      state = state.copyWith(
        batchStatus: BatchStatus.failed,
        errorMessage: analysisFailedMessage,
      );
    }
    _persist();
  }

  void _moveTo(BatchStatus next) {
    assert(state.batchStatus.canTransitionTo(next),
        'Skipped transition ${state.batchStatus} → $next');
    state = state.copyWith(batchStatus: next);
  }

  void _updateItem(int index, ExtractedItem Function(ExtractedItem) change) {
    final review = state.review;
    if (review == null ||
        state.isSaving ||
        index < 0 ||
        index >= review.items.length) {
      return;
    }
    try {
      state = state.copyWith(
        review: review.replaceItem(index, change(review.items[index])),
      );
      _persist();
    } on ArgumentError {
      // Unknown type codes are not offered by the picker; ignore them.
    }
  }

  /// Saves the batch as it is now. Called synchronously after each change,
  /// so saves reach the database in order.
  void _persist() {
    final batch = UploadBatch(
      batchId: _batchId,
      status: state.batchStatus,
      tray: state.tray,
      selection: state.selection,
      consentId: state.consent?.id,
      review: state.review,
    );
    unawaited(_studioRepository.saveBatch(batch).catchError((Object _) {
      // Best effort: the flow continues; the next change saves again.
    }));
  }

  /// A batch interrupted mid-analysis resumes on the scope sheet.
  static BatchStatus _resumable(BatchStatus status) => switch (status) {
        BatchStatus.queuedForAi ||
        BatchStatus.aiProcessing =>
          BatchStatus.sanitizing,
        _ => status,
      };

  WardrobeItem _toWardrobeItem(ExtractedItem item, DateTime now) {
    return WardrobeItem(
      itemId: deterministicObjectId([item.draftId]),
      name: item.name,
      typeCode: item.value.typeCode,
      color: item.value.color,
      material: item.value.material,
      styleTag: item.value.styleTag,
      aiConfidence: item.confidence,
      sourceAssetId: item.assetId,
      createdAt: now,
      lastWornEstimate: item.lastWorn.resolve(now),
    );
  }

  static String? _pickNotice(int rejected, int overLimit, int unprotected) {
    final parts = [
      if (rejected == 1) 'Only JPG and PNG are supported. 1 file was skipped.',
      if (rejected > 1)
        'Only JPG and PNG are supported. $rejected files were skipped.',
      if (overLimit == 1)
        "You can add up to 10 photos per batch. 1 wasn't added.",
      if (overLimit > 1)
        "You can add up to 10 photos per batch. $overLimit weren't added.",
      if (unprotected == 1)
        "This photo couldn't be protected, so it wasn't added.",
      if (unprotected > 1)
        "$unprotected photos couldn't be protected, so they weren't added.",
    ];
    return parts.isEmpty ? null : parts.join(' ');
  }
}
