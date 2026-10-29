import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/studio/domain/extracted_item.dart';
import 'package:garblo/features/studio/domain/last_worn.dart';
import 'package:garblo/features/wardrobe/domain/item_group.dart';

void main() {
  const shirtAi = ItemAttributes(
    typeCode: 'SHIRT',
    color: 'Violet',
    material: 'Cotton',
    styleTag: 'Street',
  );

  const violetShirt = ExtractedItem(
    draftId: 'd1',
    assetId: 'asset_1',
    slotIndex: 1,
    itemIndex: 1,
    name: 'Violet shirt',
    confidence: 0.94,
    ai: shirtAi,
    value: shirtAi,
  );

  group('ExtractedItem', () {
    test('[TASK-003-S04] an untouched draft is not user-modified', () {
      expect(violetShirt.userModified, isFalse);
      expect(violetShirt.group, ItemGroup.tops);
      expect(violetShirt.confidencePercent, 94);
    });

    test('[TASK-003-S04] editing an attribute keeps the AI original', () {
      final edited = violetShirt.edit(material: 'Linen');

      expect(edited.value.material, 'Linen');
      expect(edited.ai.material, 'Cotton');
      expect(edited.userModified, isTrue);
      expect(edited.confidence, 0.94);
    });

    test('[TASK-003-S04] changing the type moves the item to its group', () {
      final edited = violetShirt.edit(typeCode: 'SNEAKERS');

      expect(edited.value.typeCode, 'SNEAKERS');
      expect(edited.group, ItemGroup.shoes);
    });

    test('[TASK-003-S04] user-modified is false when edits restore AI values',
        () {
      final restored =
          violetShirt.edit(material: 'Linen').edit(material: 'Cotton');

      expect(restored.userModified, isFalse);
    });

    test('[TASK-003-S04] unknown type codes are rejected', () {
      expect(() => violetShirt.edit(typeCode: 'SPACESUIT'),
          throwsA(isA<ArgumentError>()));
    });

    test('[TASK-003-S04] Last worn does not count as an attribute edit', () {
      final withLastWorn = violetShirt
          .withLastWorn(const LastWornInput(LastWornOption.thisMonth));

      expect(withLastWorn.lastWorn.option, LastWornOption.thisMonth);
      expect(withLastWorn.userModified, isFalse);
    });

    test('value equality and hashCode', () {
      final copy = violetShirt.edit();

      expect(copy, violetShirt);
      expect(copy.hashCode, violetShirt.hashCode);
      expect(violetShirt.edit(color: 'Black') == violetShirt, isFalse);
    });
  });
}
