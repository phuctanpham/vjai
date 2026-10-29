import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/wardrobe/domain/item_group.dart';

import '../../../helpers/wardrobe_fixtures.dart';

void main() {
  group('WardrobeItem', () {
    test('group is derived from the type code', () {
      expect(wardrobeItem('a', typeCode: 'LOAFERS').group, ItemGroup.shoes);
      expect(wardrobeItem('a', typeCode: 'SCARF').group, ItemGroup.accessories);
    });

    test('value equality and hashCode', () {
      final a = wardrobeItem('a', lastWornEstimate: daysBefore(41));
      final b = wardrobeItem('a', lastWornEstimate: daysBefore(41));

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == wardrobeItem('b', lastWornEstimate: daysBefore(41)), isFalse);
    });

    test('copyWith changes only the given fields', () {
      final item = wardrobeItem('a', color: 'White');

      final archived = item.copyWith(isArchived: true);

      expect(archived.isArchived, isTrue);
      expect(archived.color, 'White');
      expect(archived.itemId, 'a');
      expect(item.isArchived, isFalse);
    });
  });
}
