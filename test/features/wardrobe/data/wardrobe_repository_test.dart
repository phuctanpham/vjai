import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/errors/failures.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/domain/dormancy.dart';
import 'package:garblo/features/wardrobe/domain/item_group.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/wardrobe_fixtures.dart';

void main() {
  final existing = [
    wardrobeItem('tee', typeCode: 'T_SHIRT', createdAt: daysBefore(10)),
    wardrobeItem('jeans', typeCode: 'JEANS', createdAt: daysBefore(5)),
    wardrobeItem('loafers', typeCode: 'LOAFERS', createdAt: daysBefore(20)),
  ];

  final newItems = [
    wardrobeItem('n1', typeCode: 'SHIRT'),
    wardrobeItem('n2', typeCode: 'WIDE_LEG_TROUSERS'),
    wardrobeItem('n3', typeCode: 'SNEAKERS'),
  ];

  group('MockWardrobeRepository.saveItems', () {
    test('[TASK-003-S05] saves every item and puts them first', () async {
      final repo = MockWardrobeRepository(items: existing);

      await repo.saveItems(newItems);
      final page = await repo.getItems();

      expect(page.total, 6);
      expect(page.items.take(3).map((i) => i.itemId), ['n1', 'n2', 'n3']);
      expect(await repo.countEligible(), 6);
    });

    test('[TASK-003-S05] a failure mid-batch saves nothing', () async {
      final repo = MockWardrobeRepository(items: existing, failSaveAfter: 1);

      await expectLater(
          repo.saveItems(newItems), throwsA(isA<StorageFailure>()));

      final page = await repo.getItems();
      expect(page.total, 3);
      expect(page.items.map((i) => i.itemId), isNot(contains('n1')));
    });

    test('[TASK-003-S05] saving zero items changes nothing', () async {
      final repo = MockWardrobeRepository(items: existing);

      await repo.saveItems(const []);

      expect((await repo.getItems()).total, 3);
    });
  });

  group('MockWardrobeRepository.getItems', () {
    test('[TASK-003-S07] lists newest first', () async {
      final repo = MockWardrobeRepository(items: existing);

      final page = await repo.getItems();

      expect(page.items.map((i) => i.itemId), ['jeans', 'tee', 'loafers']);
    });

    test('[TASK-003-S07] filters by group; the total stays the full count',
        () async {
      final repo = MockWardrobeRepository(items: existing);

      final tops = await repo.getItems(group: ItemGroup.tops);
      final bags = await repo.getItems(group: ItemGroup.bags);

      expect(tops.items.map((i) => i.itemId), ['tee']);
      expect(tops.total, 3);
      expect(bags.items, isEmpty);
      expect(bags.total, 3);
    });

    test('[TASK-003-S07] archived items are excluded everywhere (TAC-04.5)',
        () async {
      final repo = MockWardrobeRepository(items: [
        ...existing,
        wardrobeItem('old', typeCode: 'SHIRT', isArchived: true),
      ]);

      final page = await repo.getItems();

      expect(page.items.map((i) => i.itemId), isNot(contains('old')));
      expect(page.total, 3);
      expect(await repo.countEligible(), 3);
      expect((await repo.getEligibleItems()).map((i) => i.itemId),
          isNot(contains('old')));
    });

    test('[TASK-003-S07] pages hold 20 items and continue by cursor (AC-04.7)',
        () async {
      final many = [
        for (var i = 0; i < 25; i++)
          wardrobeItem('i$i', createdAt: daysBefore(i)),
      ];
      final repo = MockWardrobeRepository(items: many);

      final first = await repo.getItems();
      expect(first.items, hasLength(WardrobeRepository.pageSize));
      expect(first.total, 25);
      expect(first.nextCursor, isNotNull);

      final second = await repo.getItems(cursor: first.nextCursor);
      expect(second.items.map((i) => i.itemId),
          ['i20', 'i21', 'i22', 'i23', 'i24']);
      expect(second.nextCursor, isNull);
    });

    test('a load failure surfaces as a Failure', () async {
      final repo = MockWardrobeRepository(items: existing, failOnLoad: true);

      expect(repo.getItems(), throwsA(isA<Failure>()));
    });
  });

  group('MockWardrobeRepository.seeded', () {
    test('holds nine demo items including a 41-day White T-shirt', () async {
      final repo = MockWardrobeRepository.seeded(testToday);

      final page = await repo.getItems();
      expect(page.total, 9);
      final tee = page.items.singleWhere((i) => i.name == 'White T-shirt');
      expect(DormancyRules.daysUnworn(item: tee, today: testToday), 41);
    });
  });
}
