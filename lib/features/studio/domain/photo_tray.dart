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

  factory PhotoTray.empty() => const PhotoTray(assets: [], nextSequence: 1);

  int get count => assets.length;
  bool get isEmpty => assets.isEmpty;
  bool get isFull => count >= maxPhotos;
  int get remainingCapacity => maxPhotos - count;

  /// Stages accepted photos after the current ones. Files that are not JPG or
  /// PNG are rejected; photos beyond [maxPhotos] are not added (I2).
  PhotoTrayAddResult add(List<PickedPhoto> picked) {
    final staged = List.of(assets);
    var sequence = nextSequence;
    var rejected = 0;
    var overLimit = 0;

    for (final photo in picked) {
      if (!acceptedMimeTypes.contains(photo.mimeType)) {
        rejected++;
      } else if (staged.length >= maxPhotos) {
        overLimit++;
      } else {
        staged.add(MediaAsset(
          assetId: 'asset_$sequence',
          slotIndex: _lowestFreeSlot(staged),
          uri: photo.uri,
          mimeType: photo.mimeType,
        ));
        sequence++;
      }
    }

    return PhotoTrayAddResult(
      tray:
          PhotoTray(assets: List.unmodifiable(staged), nextSequence: sequence),
      rejectedCount: rejected,
      overLimitCount: overLimit,
    );
  }

  /// Removes one photo; the others keep their order (AC-01.4).
  PhotoTray remove(String assetId) => PhotoTray(
        assets: List.unmodifiable(assets.where((a) => a.assetId != assetId)),
        nextSequence: nextSequence,
      );

  static int _lowestFreeSlot(List<MediaAsset> staged) {
    final used = staged.map((a) => a.slotIndex).toSet();
    var slot = 1;
    while (used.contains(slot)) {
      slot++;
    }
    return slot;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhotoTray &&
          listEquals(assets, other.assets) &&
          nextSequence == other.nextSequence;

  @override
  int get hashCode => Object.hash(Object.hashAll(assets), nextSequence);
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
