import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/wardrobe/domain/item_group.dart';
import 'package:garblo/features/wardrobe/domain/item_type.dart';

void main() {
  group('ItemTypeCatalog', () {
    test('covers all six groups, including Accessories (P6)', () {
      final groups = ItemTypeCatalog.all.map((t) => t.group).toSet();

      expect(groups, ItemGroup.values.toSet());
      expect(ItemTypeCatalog.typesIn(ItemGroup.accessories), isNotEmpty);
    });

    test('every type has exactly one group and a unique code', () {
      final codes = ItemTypeCatalog.all.map((t) => t.code).toList();

      expect(codes.toSet(), hasLength(codes.length));
      for (final type in ItemTypeCatalog.all) {
        expect(ItemTypeCatalog.typesIn(type.group), contains(type));
        final others = ItemGroup.values.where((g) => g != type.group);
        for (final other in others) {
          expect(ItemTypeCatalog.typesIn(other), isNot(contains(type)));
        }
      }
    });

    test('[TASK-003-S04] the group is derived from the type code', () {
      expect(ItemTypeCatalog.groupOf('SHIRT'), ItemGroup.tops);
      expect(ItemTypeCatalog.groupOf('WIDE_LEG_TROUSERS'), ItemGroup.bottoms);
      expect(ItemTypeCatalog.groupOf('SNEAKERS'), ItemGroup.shoes);
      expect(ItemTypeCatalog.groupOf('TOTE_BAG'), ItemGroup.bags);
      expect(ItemTypeCatalog.groupOf('BUCKET_HAT'), ItemGroup.hats);
      expect(ItemTypeCatalog.groupOf('TIE'), ItemGroup.accessories);
    });

    test('[TASK-003-S04] unknown codes are not in the catalog', () {
      expect(ItemTypeCatalog.byCode('SPACESUIT'), isNull);
      expect(() => ItemTypeCatalog.groupOf('SPACESUIT'),
          throwsA(isA<ArgumentError>()));
    });

    test('labels', () {
      expect(ItemTypeCatalog.byCode('T_SHIRT')!.label, 'T-shirt');
      expect(ItemTypeCatalog.byCode('WIDE_LEG_TROUSERS')!.label,
          'Wide-leg trousers');
      expect(ItemGroup.values.map((g) => g.label).toList(),
          ['Tops', 'Bottoms', 'Shoes', 'Bags', 'Hats', 'Accessories']);
    });
  });
}
