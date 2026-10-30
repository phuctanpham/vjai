import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/media/photo_picker.dart';
import '../../../core/time/clock.dart';
import '../../wardrobe/data/wardrobe_repository.dart';
import '../../wardrobe/domain/wardrobe_item.dart';
import '../data/studio_repository.dart';
import '../domain/analysis_task.dart';
import '../domain/batch_status.dart';
import '../domain/extracted_item.dart';
import '../domain/last_worn.dart';
import '../domain/privacy_consent.dart';
import '../domain/review_draft.dart';
import 'studio_state.dart';

/// Provider for StudioViewModel. Kept alive so a review draft survives
/// switching pillars.
final studioViewModelProvider =
    StateNotifierProvider<StudioViewModel, StudioState>((ref) {
  return StudioViewModel(
    studioRepository: ref.watch(studioRepositoryProvider),
    wardrobeRepository: ref.watch(wardrobeRepositoryProvider),
    photoPicker: ref.watch(photoPickerProvider),
    clock: ref.watch(clockProvider),
  );
});

/// ViewModel for Flow A: tray, consent, scope sheet, analysis, review, save.
class StudioViewModel extends StateNotifier<StudioState> {
  static const String analysisFailedMessage = "Couldn't read these photos.";
  static const String saveFailedMessage = "Couldn't index your Pieces.";

  final StudioRepository _studioRepository;
  final WardrobeRepository _wardrobeRepository;
  final PhotoPicker _photoPicker;
  final Clock _clock;

  /// Counts batches so saved item IDs stay unique across batches.
  int _batchNumber = 1;

  StudioViewModel({
    required StudioRepository studioRepository,
    required WardrobeRepository wardrobeRepository,
    required PhotoPicker photoPicker,
    required Clock clock,
  })  : _studioRepository = studioRepository,
        _wardrobeRepository = wardrobeRepository,
        _photoPicker = photoPicker,
        _clock = clock,
        super(StudioState.initial());

  /// Opens the picker for the remaining capacity and stages valid photos.
  Future<void> pickPhotos() async {
    if (state.batchStatus != BatchStatus.draft || state.tray.isFull) return;

    final picked =
        await _photoPicker.pick(maxCount: state.tray.remainingCapacity);
    final result = state.tray.add(picked);
    final notice = _pickNotice(result.rejectedCount, result.overLimitCount);
    state = state.copyWith(
      tray: result.tray,
      notice: notice,
      clearNotice: notice == null,
    );
  }

  void removePhoto(String assetId) {
    if (state.batchStatus != BatchStatus.draft) return;
    state = state.copyWith(tray: state.tray.remove(assetId), clearNotice: true);
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
    } on Failure catch (failure) {
      state = state.copyWith(errorMessage: failure.message);
    }
  }

  void toggleTask(AnalysisTask task) {
    if (!state.isScopeSheetOpen) return;
    state = state.copyWith(selection: state.selection.toggle(task));
  }

  /// Closes the sheet and returns to DRAFT, keeping photos and consent.
  void reselectPhotos() {
    if (!state.batchStatus.canTransitionTo(BatchStatus.draft)) return;
    state = state.copyWith(
      batchStatus: BatchStatus.draft,
      clearReview: true,
      clearError: true,
    );
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
    } on Failure {
      state = state.copyWith(isSaving: false, errorMessage: saveFailedMessage);
    }
  }

  /// Starts a fresh batch after a completed save. The recorded consent is
  /// kept for the next batch (D3).
  void startNewBatch() {
    _batchNumber++;
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
    } on ArgumentError {
      // Unknown type codes are not offered by the picker; ignore them.
    }
  }

  WardrobeItem _toWardrobeItem(ExtractedItem item, DateTime now) {
    return WardrobeItem(
      itemId: 'item_b${_batchNumber}_${item.draftId}',
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

  static String? _pickNotice(int rejected, int overLimit) {
    final parts = [
      if (rejected == 1) 'Only JPG and PNG are supported. 1 file was skipped.',
      if (rejected > 1)
        'Only JPG and PNG are supported. $rejected files were skipped.',
      if (overLimit == 1)
        "You can add up to 10 photos per batch. 1 wasn't added.",
      if (overLimit > 1)
        "You can add up to 10 photos per batch. $overLimit weren't added.",
    ];
    return parts.isEmpty ? null : parts.join(' ');
  }
}
