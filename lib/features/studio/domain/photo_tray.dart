import 'package:flutter/foundation.dart';

import '../../../core/media/photo_picker.dart';
import 'media_asset.dart';

/// The photos staged in the current batch, in pick order (1a/2a).
@immutable
class PhotoTray {
  static const int maxPhotos = 10;
  static const Set<String> acceptedMimeTypes = {'image/jpeg', 'image/png'};

  final List<MediaAsset> assets;

  /// Next value used to build a unique asset ID (`asset_<n>`).
  final int nextSequence;

  const PhotoTray({required this.assets, required this.nextSequence});

  factory PhotoTray.empty() => throw UnimplementedError('TASK-003-S02');

  int get count => throw UnimplementedError('TASK-003-S02');
  bool get isEmpty => throw UnimplementedError('TASK-003-S02');
  bool get isFull => throw UnimplementedError('TASK-003-S09');
  int get remainingCapacity => throw UnimplementedError('TASK-003-S09');

  /// Stages accepted photos after the current ones. Files that are not JPG or
  /// PNG are rejected; photos beyond [maxPhotos] are not added (I2).
  PhotoTrayAddResult add(List<PickedPhoto> picked) =>
      throw UnimplementedError('TASK-003-S09');

  /// Removes one photo; the others keep their order (AC-01.4).
  PhotoTray remove(String assetId) => throw UnimplementedError('TASK-003-S02');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S02');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S02');
}

/// Outcome of [PhotoTray.add].
@immutable
class PhotoTrayAddResult {
  final PhotoTray tray;

  /// Files skipped because they are not JPG or PNG.
  final int rejectedCount;

  /// Valid files not added because the tray was full.
  final int overLimitCount;

  const PhotoTrayAddResult({
    required this.tray,
    required this.rejectedCount,
    required this.overLimitCount,
  });
}
