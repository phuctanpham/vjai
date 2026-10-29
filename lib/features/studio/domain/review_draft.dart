import 'package:flutter/foundation.dart';

import 'extracted_item.dart';

/// How an analysis ended (UC-02 and UC-03 states).
enum AnalysisOutcome {
  success,

  /// Some photos could not be read; the rest produced items.
  partial,

  /// No photo could be read; the batch is FAILED.
  allFailed,

  /// Photos were read but no clothes were found.
  zeroItems,
}

/// The review workspace data for one batch (4a).
@immutable
class ReviewDraft {
  final int photoCount;
  final int failedPhotoCount;

  /// Ordered by photo slot, then by position within the photo (AC-03.3).
  final List<ExtractedItem> items;

  const ReviewDraft({
    required this.photoCount,
    required this.failedPhotoCount,
    required this.items,
  });

  AnalysisOutcome get outcome => throw UnimplementedError('TASK-003-S11');

  /// Spec T7 › G3 4a: "FROM {P} PHOTOS · {N} PIECES", singular forms
  /// "1 PHOTO" / "1 PIECE" (C2).
  String get bannerText => throw UnimplementedError('TASK-003-S11');

  /// For a partial result: "1 photo couldn't be read" / "2 photos couldn't
  /// be read" (UC-02 states). Null otherwise.
  String? get failureNote => throw UnimplementedError('TASK-003-S11');

  ReviewDraft replaceItem(int index, ExtractedItem item) =>
      throw UnimplementedError('TASK-003-S04');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S04');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S04');
}
