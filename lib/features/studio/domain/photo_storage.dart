import 'package:flutter/foundation.dart';

import '../../../core/media/photo_picker.dart';
import 'media_asset.dart';

/// A photo just added to the tray, with the picked bytes to sanitize.
@immutable
class StagedPhoto {
  final MediaAsset asset;
  final PickedPhoto photo;

  const StagedPhoto({required this.asset, required this.photo});
}

/// Outcome of storing staged photos (TASK-007).
@immutable
class PhotoStorageResult {
  /// Assets now backed by a sanitized attachment (or fixtures without bytes).
  final List<MediaAsset> stored;

  /// Assets whose photo failed sanitizing: nothing was written for them.
  final List<String> failedAssetIds;

  const PhotoStorageResult({
    required this.stored,
    required this.failedAssetIds,
  });
}
