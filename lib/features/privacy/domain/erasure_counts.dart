import 'package:flutter/foundation.dart';

/// What a deletion would remove, shown before the second tap (AC-09.2).
@immutable
class ErasureCounts {
  final int photos;
  final int pieces;
  final int bodyPhotos;
  final int tryOnImages;

  const ErasureCounts({
    required this.photos,
    required this.pieces,
    required this.bodyPhotos,
    required this.tryOnImages,
  });

  static const ErasureCounts none =
      ErasureCounts(photos: 0, pieces: 0, bodyPhotos: 0, tryOnImages: 0);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErasureCounts &&
          photos == other.photos &&
          pieces == other.pieces &&
          bodyPhotos == other.bodyPhotos &&
          tryOnImages == other.tryOnImages;

  @override
  int get hashCode => Object.hash(photos, pieces, bodyPhotos, tryOnImages);
}
