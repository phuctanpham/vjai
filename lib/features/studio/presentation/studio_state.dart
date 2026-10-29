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
  factory StudioState.initial() => StudioState(
        batchStatus: BatchStatus.draft,
        tray: PhotoTray.empty(),
        consentChecked: false,
        selection: AnalysisSelection.defaults(),
        expandedIndex: 0,
        isSaving: false,
      );

  /// 1 ≤ photos ≤ 10 AND consent, while the batch is a draft (I1).
  bool get canAnalyze =>
      batchStatus == BatchStatus.draft &&
      tray.count >= 1 &&
      tray.count <= PhotoTray.maxPhotos &&
      consentChecked;

  /// The 3a sheet is open while the batch is sanitizing.
  bool get isScopeSheetOpen => batchStatus == BatchStatus.sanitizing;

  bool get canConfirmScope => isScopeSheetOpen && selection.isValid;

  bool get canSave =>
      batchStatus == BatchStatus.awaitingReview &&
      !isSaving &&
      (review?.items.isNotEmpty ?? false);

  /// Spec T7 › G4: "Index N Pieces", "Index 1 Piece", "Nothing to index".
  String get saveLabel {
    final count = review?.items.length ?? 0;
    if (count == 0) return 'Nothing to index';
    return count == 1 ? 'Index 1 Piece' : 'Index $count Pieces';
  }

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
  }) {
    return StudioState(
      batchStatus: batchStatus ?? this.batchStatus,
      tray: tray ?? this.tray,
      consentChecked: consentChecked ?? this.consentChecked,
      consent: consent ?? this.consent,
      selection: selection ?? this.selection,
      review: clearReview ? null : (review ?? this.review),
      expandedIndex: expandedIndex ?? this.expandedIndex,
      isSaving: isSaving ?? this.isSaving,
      notice: clearNotice ? null : (notice ?? this.notice),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudioState &&
          batchStatus == other.batchStatus &&
          tray == other.tray &&
          consentChecked == other.consentChecked &&
          consent == other.consent &&
          selection == other.selection &&
          review == other.review &&
          expandedIndex == other.expandedIndex &&
          isSaving == other.isSaving &&
          notice == other.notice &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(batchStatus, tray, consentChecked, consent,
      selection, review, expandedIndex, isSaving, notice, errorMessage);
}
