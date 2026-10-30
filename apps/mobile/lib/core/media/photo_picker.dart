import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'image_picker_photo_picker.dart';

/// Provider for the photo picker: the device gallery (CHG-006 G-02).
final photoPickerProvider = Provider<PhotoPicker>((ref) {
  return ImagePickerPhotoPicker();
});

/// One photo returned by the picker, before it is staged.
@immutable
class PickedPhoto {
  final String uri;

  /// Sniffed from the bytes for real photos (TASK-007); JPG and PNG are
  /// accepted, anything else (e.g. HEIC) is rejected by the tray.
  final String mimeType;

  /// The original picked bytes, to be sanitized before storage. Null for
  /// Phase 1 preset fixtures. Not part of equality.
  final Uint8List? bytes;

  const PickedPhoto({required this.uri, required this.mimeType, this.bytes});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickedPhoto && uri == other.uri && mimeType == other.mimeType;

  @override
  int get hashCode => Object.hash(uri, mimeType);
}

/// Contract for picking photos from the device. Native pickers sit behind it.
abstract class PhotoPicker {
  /// Returns at most [maxCount] photos, in the order the user picked them.
  Future<List<PickedPhoto>> pick({required int maxCount});
}

/// Returns the three preset flat-lay photos. A test and demo double only;
/// the app uses the gallery (CHG-006 G-02).
class PresetPhotoPicker implements PhotoPicker {
  static const List<PickedPhoto> presets = [
    PickedPhoto(
        uri: 'preset://flatlay-violet-shirt.jpg', mimeType: 'image/jpeg'),
    PickedPhoto(
      uri: 'preset://flatlay-wide-leg-trousers.jpg',
      mimeType: 'image/jpeg',
    ),
    PickedPhoto(
        uri: 'preset://flatlay-cream-sneakers.png', mimeType: 'image/png'),
  ];

  const PresetPhotoPicker();

  @override
  Future<List<PickedPhoto>> pick({required int maxCount}) async =>
      presets.take(maxCount).toList();
}
