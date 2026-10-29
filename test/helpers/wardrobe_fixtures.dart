import 'package:garblo/core/media/photo_picker.dart';
import 'package:garblo/features/wardrobe/domain/wardrobe_item.dart';

import 'fixed_clock.dart';

/// Builds a wardrobe item with sensible defaults for tests.
WardrobeItem wardrobeItem(
  String id, {
  String typeCode = 'T_SHIRT',
  String? name,
  String color = 'White',
  String material = 'Cotton',
  String styleTag = 'Basic',
  DateTime? createdAt,
  DateTime? lastWornEstimate,
  bool isArchived = false,
}) =>
    WardrobeItem(
      itemId: id,
      name: name ?? 'Item $id',
      typeCode: typeCode,
      color: color,
      material: material,
      styleTag: styleTag,
      createdAt: createdAt ?? testToday,
      lastWornEstimate: lastWornEstimate,
      isArchived: isArchived,
    );

DateTime daysBefore(int days) => testToday.subtract(Duration(days: days));

PickedPhoto jpg(String name) =>
    PickedPhoto(uri: 'test://$name.jpg', mimeType: 'image/jpeg');

PickedPhoto png(String name) =>
    PickedPhoto(uri: 'test://$name.png', mimeType: 'image/png');

PickedPhoto heic(String name) =>
    PickedPhoto(uri: 'test://$name.heic', mimeType: 'image/heic');

/// Picker that returns scripted results, unfiltered, like a gallery that
/// cannot enforce limits. Records the max count it was asked for.
class FakePhotoPicker implements PhotoPicker {
  final List<List<PickedPhoto>> _responses;
  final List<int> requestedMaxCounts = [];

  FakePhotoPicker(List<List<PickedPhoto>> responses)
      : _responses = List.of(responses);

  @override
  Future<List<PickedPhoto>> pick({required int maxCount}) async {
    requestedMaxCounts.add(maxCount);
    return _responses.isEmpty ? const [] : _responses.removeAt(0);
  }
}
