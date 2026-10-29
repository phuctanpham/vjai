import 'package:flutter/foundation.dart';

import '../domain/analysis_selection.dart';
import '../domain/batch_status.dart';
import '../domain/photo_tray.dart';
import '../domain/privacy_consent.dart';
import '../domain/review_draft.dart';

/// State of the Add pillar for one upload batch (1a → 4a).
@immutable
class StudioState {
  final BatchStatus batchStatus;
  final PhotoTray tray;
  final bool consentChecked;

  /// Recorded when "Analyze with Garblo" is tapped (AC-01.8).
  final PrivacyConsent? consent;
  final AnalysisSelection selection;
  final ReviewDraft? review;

  /// Index of the expanded review item.
  final int expandedIndex;
  final bool isSaving;

  /// Picker notice such as "Only JPG and PNG are supported. 1 file was skipped."
  final String? notice;
  final String? errorMessage;

  const StudioState({
    required this.batchStatus,
    required this.tray,
    required this.consentChecked,
    required this.selection,
    required this.expandedIndex,
    required this.isSaving,
    this.consent,
    this.review,
    this.notice,
    this.errorMessage,
  });

  /// Draft batch, empty tray, consent unchecked, default selection.
  factory StudioState.initial() => throw UnimplementedError('TASK-003-S01');

  /// 1 ≤ photos ≤ 10 AND consent, while the batch is a draft (I1).
  bool get canAnalyze => throw UnimplementedError('TASK-003-S01');

  /// The 3a sheet is open while the batch is sanitizing.
  bool get isScopeSheetOpen => throw UnimplementedError('TASK-003-S03');

  bool get canConfirmScope => throw UnimplementedError('TASK-003-S10');

  bool get canSave => throw UnimplementedError('TASK-003-S06');

  /// Spec T7 › G4: "Index N Pieces", "Index 1 Piece", "Nothing to index".
  String get saveLabel => throw UnimplementedError('TASK-003-S05');

  StudioState copyWith({
    BatchStatus? batchStatus,
    PhotoTray? tray,
    bool? consentChecked,
    PrivacyConsent? consent,
    AnalysisSelection? selection,
    ReviewDraft? review,
    bool clearReview = false,
    int? expandedIndex,
    bool? isSaving,
    String? notice,
    bool clearNotice = false,
    String? errorMessage,
    bool clearError = false,
  }) =>
      throw UnimplementedError('TASK-003-S01');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S01');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S01');
}
