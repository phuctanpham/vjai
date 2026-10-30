import 'package:image_picker/image_picker.dart';

import 'photo_picker.dart';

/// [PhotoPicker] backed by `image_picker` (CHG-005 P2-D4): multi-select from
/// the gallery, bytes read in full, MIME type sniffed from the bytes. Covered
/// by device checks, not `flutter test`.
class ImagePickerPhotoPicker implements PhotoPicker {
  ImagePickerPhotoPicker([ImagePicker? picker]);

  @override
  Future<List<PickedPhoto>> pick({required int maxCount}) =>
      throw UnimplementedError('TASK-007 (device)');
}
