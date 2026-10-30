import 'package:flutter/foundation.dart';

/// One staged photo of an upload batch.
@immutable
class MediaAsset {
  final String assetId;

  /// 1..10, unique among the photos still in the tray.
  final int slotIndex;
  final String uri;
  final String mimeType;

  /// The sanitized file in the attachment store; null for fixture photos
  /// that have no bytes (TASK-007).
  final String? attachmentId;

  /// EXIF orientation (1–8) read before stripping, so the photo still shows
  /// the right way up (CHG-005 P2-D10).
  final int orientation;

  const MediaAsset({
    required this.assetId,
    required this.slotIndex,
    required this.uri,
    required this.mimeType,
    this.attachmentId,
    this.orientation = 1,
  });

  MediaAsset withStorage({required String? attachmentId, int? orientation}) =>
      MediaAsset(
        assetId: assetId,
        slotIndex: slotIndex,
        uri: uri,
        mimeType: mimeType,
        attachmentId: attachmentId,
        orientation: orientation ?? this.orientation,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaAsset &&
          assetId == other.assetId &&
          slotIndex == other.slotIndex &&
          uri == other.uri &&
          mimeType == other.mimeType &&
          attachmentId == other.attachmentId &&
          orientation == other.orientation;

  @override
  int get hashCode =>
      Object.hash(assetId, slotIndex, uri, mimeType, attachmentId, orientation);
}
