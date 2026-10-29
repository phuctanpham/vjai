import 'package:flutter/foundation.dart';

/// One staged photo of an upload batch.
@immutable
class MediaAsset {
  final String assetId;

  /// 1..10, unique among the photos still in the tray.
  final int slotIndex;
  final String uri;
  final String mimeType;

  const MediaAsset({
    required this.assetId,
    required this.slotIndex,
    required this.uri,
    required this.mimeType,
  });

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S02');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S02');
}
