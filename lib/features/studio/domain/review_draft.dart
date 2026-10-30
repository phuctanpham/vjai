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

  AnalysisOutcome get outcome {
    if (photoCount > 0 && failedPhotoCount >= photoCount) {
      return AnalysisOutcome.allFailed;
    }
    if (items.isEmpty) return AnalysisOutcome.zeroItems;
    if (failedPhotoCount > 0) return AnalysisOutcome.partial;
    return AnalysisOutcome.success;
  }

  /// Spec T7 › G3 4a: "FROM {P} PHOTOS · {N} PIECES", singular forms
  /// "1 PHOTO" / "1 PIECE" (C2).
  String get bannerText {
    final photos = photoCount == 1 ? '1 PHOTO' : '$photoCount PHOTOS';
    final pieces = items.length == 1 ? '1 PIECE' : '${items.length} PIECES';
    return 'FROM $photos · $pieces';
  }

  /// For a partial result: "1 photo couldn't be read" / "2 photos couldn't
  /// be read" (UC-02 states). Null otherwise.
  String? get failureNote {
    if (outcome != AnalysisOutcome.partial) return null;
    return failedPhotoCount == 1
        ? "1 photo couldn't be read"
        : "$failedPhotoCount photos couldn't be read";
  }

  ReviewDraft replaceItem(int index, ExtractedItem item) => ReviewDraft(
        photoCount: photoCount,
        failedPhotoCount: failedPhotoCount,
        items: List.unmodifiable([...items]..[index] = item),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewDraft &&
          photoCount == other.photoCount &&
          failedPhotoCount == other.failedPhotoCount &&
          listEquals(items, other.items);

  @override
  int get hashCode =>
      Object.hash(photoCount, failedPhotoCount, Object.hashAll(items));
}
