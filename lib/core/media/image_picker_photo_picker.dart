import 'package:image_picker/image_picker.dart';

import 'image_mime.dart';
import 'photo_picker.dart';

/// [PhotoPicker] backed by `image_picker` (CHG-005 P2-D4): multi-select from
/// the gallery, bytes read in full, MIME type sniffed from the bytes. Covered
/// by device checks, not `flutter test`.
class ImagePickerPhotoPicker implements PhotoPicker {
  final ImagePicker _picker;

  ImagePickerPhotoPicker([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  @override
  Future<List<PickedPhoto>> pick({required int maxCount}) async {
    if (maxCount <= 0) return const [];
    // pickMultiImage needs a limit of at least 2.
    final files = maxCount == 1
        ? [await _picker.pickImage(source: ImageSource.gallery)]
            .whereType<XFile>()
            .toList()
        : await _picker.pickMultiImage(limit: maxCount);
    return [
      // Not every platform enforces the limit; the tray caps it again (I2).
      for (final file in files.take(maxCount)) await _toPhoto(file),
    ];
  }

  static Future<PickedPhoto> _toPhoto(XFile file) async {
    final bytes = await file.readAsBytes();
    return PickedPhoto(
      uri: file.path,
      // The content decides; HEIC is then rejected by the tray (P2-D4).
      mimeType: sniffImageMime(bytes) ?? 'application/octet-stream',
      bytes: bytes,
    );
  }
}
