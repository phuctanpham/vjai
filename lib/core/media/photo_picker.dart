import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the photo picker. Phase 1 uses preset fixture photos.
final photoPickerProvider = Provider<PhotoPicker>((ref) {
  throw UnimplementedError('TASK-003-S09');
});

/// One photo returned by the picker, before it is staged.
@immutable
class PickedPhoto {
  final String uri;
  final String mimeType;

  const PickedPhoto({required this.uri, required this.mimeType});

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S09');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S09');
}

/// Contract for picking photos from the device. Native pickers sit behind it.
abstract class PhotoPicker {
  /// Returns at most [maxCount] photos, in the order the user picked them.
  Future<List<PickedPhoto>> pick({required int maxCount});
}

/// Phase 1 picker that returns the three preset flat-lay photos.
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
  Future<List<PickedPhoto>> pick({required int maxCount}) {
    throw UnimplementedError('TASK-003-S09');
  }
}
