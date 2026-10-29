import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/media/photo_picker.dart';
import '../../../core/time/clock.dart';
import '../../wardrobe/data/wardrobe_repository.dart';
import '../data/studio_repository.dart';
import '../domain/analysis_task.dart';
import '../domain/last_worn.dart';
import 'studio_state.dart';

/// Provider for StudioViewModel. Kept alive so a review draft survives
/// switching pillars.
final studioViewModelProvider =
    StateNotifierProvider<StudioViewModel, StudioState>((ref) {
  throw UnimplementedError('TASK-003-S01');
});

/// ViewModel for Flow A: tray, consent, scope sheet, analysis, review, save.
class StudioViewModel extends StateNotifier<StudioState> {
  StudioViewModel({
    required StudioRepository studioRepository,
    required WardrobeRepository wardrobeRepository,
    required PhotoPicker photoPicker,
    required Clock clock,
  }) : super(StudioState.initial());

  /// Opens the picker for the remaining capacity and stages valid photos.
  Future<void> pickPhotos() => throw UnimplementedError('TASK-003-S09');

  void removePhoto(String assetId) => throw UnimplementedError('TASK-003-S02');

  void setConsent(bool checked) => throw UnimplementedError('TASK-003-S01');

  /// Records consent and opens the scope sheet (DRAFT → SANITIZING).
  /// Ignored unless [StudioState.canAnalyze].
  Future<void> analyze() => throw UnimplementedError('TASK-003-S01');

  void toggleTask(AnalysisTask task) =>
      throw UnimplementedError('TASK-003-S10');

  /// Closes the sheet and returns to DRAFT, keeping photos and consent.
  void reselectPhotos() => throw UnimplementedError('TASK-003-S03');

  /// Runs the analysis (→ AWAITING_REVIEW or FAILED).
  /// Ignored unless [StudioState.canConfirmScope].
  Future<void> confirmScope() => throw UnimplementedError('TASK-003-S11');

  /// "Try again" after every photo failed.
  Future<void> retryAnalysis() => throw UnimplementedError('TASK-003-S11');

  void expandItem(int index) => throw UnimplementedError('TASK-003-S04');

  void editItem(
    int index, {
    String? typeCode,
    String? color,
    String? material,
    String? styleTag,
  }) =>
      throw UnimplementedError('TASK-003-S04');

  /// Ignored for an exact date in the future (CHG-003 A-01).
  void setLastWorn(int index, LastWornInput lastWorn) =>
      throw UnimplementedError('TASK-003-S13');

  /// Saves every reviewed item at once (→ COMPLETED). Ignored while saving.
  Future<void> save() => throw UnimplementedError('TASK-003-S05');

  /// Starts a fresh batch after a completed save.
  void startNewBatch() => throw UnimplementedError('TASK-003-S05');
}
