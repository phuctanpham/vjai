import 'package:flutter/foundation.dart';

import 'analysis_selection.dart';
import 'batch_status.dart';
import 'photo_tray.dart';
import 'review_draft.dart';

/// The open upload batch as persisted (spec `upload_batches` + its assets and
/// review drafts), so Flow A resumes after a restart (TASK-005-S03).
@immutable
class UploadBatch {
  final String batchId;
  final BatchStatus status;
  final PhotoTray tray;
  final AnalysisSelection selection;
  final String? consentId;

  /// Review drafts with the user's edits; null before analysis.
  final ReviewDraft? review;

  const UploadBatch({
    required this.batchId,
    required this.status,
    required this.tray,
    required this.selection,
    this.consentId,
    this.review,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadBatch &&
          batchId == other.batchId &&
          status == other.status &&
          tray == other.tray &&
          selection == other.selection &&
          consentId == other.consentId &&
          review == other.review;

  @override
  int get hashCode =>
      Object.hash(batchId, status, tray, selection, consentId, review);
}
