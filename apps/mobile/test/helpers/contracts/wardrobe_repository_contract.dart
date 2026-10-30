import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/domain/item_group.dart';
import 'package:garblo/features/wardrobe/domain/wardrobe_item.dart';

import '../wardrobe_fixtures.dart';

/// Creates a repository already holding [items] (saved in that order).
typedef WardrobeRepositoryFactory = Future<WardrobeRepository> Function(
    List<WardrobeItem> items);

/// The behaviour every [WardrobeRepository] must share (TASK-005-S08). Run
/// against the in-memory and the SQLite implementations.
void wardrobeRepositoryContract(
  String label,
  WardrobeRepositoryFactory create, {
  Future<void> Function()? cleanUp,
}) {
  group('$label satisfies the WardrobeRepository contract', () {
    if (cleanUp != null) tearDown(cleanUp);

    final existing = [
      wardrobeItem('tee', typeCode: 'T_SHIRT', createdAt: daysBefore(10)),
      wardrobeItem('jeans', typeCode: 'JEANS', createdAt: daysBefore(5)),
      wardrobeItem('loafers', typeCode: 'LOAFERS', createdAt: daysBefore(20)),
    ];

    test('[TASK-005-S08] lists newest first', () async {
      final repo = await create(existing);

      final page = await repo.getItems();

      expect(page.items.map((i) => i.itemId), ['jeans', 'tee', 'loafers']);
      expect(page.total, 3);
    });

    test('[TASK-005-S08] round-trips every field', () async {
      final full = WardrobeItem(
        itemId: 'full',
        name: 'Violet shirt',
        typeCode: 'SHIRT',
        color: 'Violet',
        material: 'Cotton',
        styleTag: 'Street',
        aiConfidence: 0.94,
        sourceAssetId: 'asset_1',
        createdAt: daysBefore(2),
        lastWornEstimate: DateTime(2026, 9, 18),
      );
      final repo = await create([full]);

      expect((await repo.getItems()).items.single, full);
      expect((await repo.getEligibleItems()).single, full);
    });

    test('[TASK-005-S08] a saved batch comes first, in review order', () async {
      final repo = await create(existing);
      final batch = [
        wardrobeItem('n1', typeCode: 'SHIRT'),
        wardrobeItem('n2', typeCode: 'WIDE_LEG_TROUSERS'),
        wardrobeItem('n3', typeCode: 'SNEAKERS'),
      ];

      await repo.saveItems(batch);

      final page = await repo.getItems();
      expect(page.items.take(3).map((i) => i.itemId), ['n1', 'n2', 'n3']);
      expect(page.total, 6);
      expect(await repo.countEligible(), 6);
    });

    test('[TASK-005-S08] filters by group; the total stays the full count',
        () async {
      final repo = await create(existing);

      final tops = await repo.getItems(group: ItemGroup.tops);
      final bags = await repo.getItems(group: ItemGroup.bags);

      expect(tops.items.map((i) => i.itemId), ['tee']);
      expect(tops.total, 3);
      expect(bags.items, isEmpty);
      expect(bags.total, 3);
    });

    test('[TASK-005-S08] archived Pieces are excluded everywhere', () async {
      final repo = await create([
        ...existing,
        wardrobeItem('old', typeCode: 'SHIRT', isArchived: true),
      ]);

      expect((await repo.getItems()).items.map((i) => i.itemId),
          isNot(contains('old')));
      expect((await repo.getItems()).total, 3);
      expect(await repo.countEligible(), 3);
      expect((await repo.getEligibleItems()).map((i) => i.itemId),
          isNot(contains('old')));
    });

    test('[TASK-005-S08] pages hold 20 Pieces and continue by cursor',
        () async {
      final repo = await create([
        for (var i = 0; i < 25; i++)
          wardrobeItem('i$i', createdAt: daysBefore(i)),
      ]);

      final first = await repo.getItems();
      expect(first.items, hasLength(WardrobeRepository.pageSize));
      expect(first.total, 25);
      expect(first.nextCursor, isNotNull);

      final second = await repo.getItems(cursor: first.nextCursor);
      expect(second.items.map((i) => i.itemId),
          ['i20', 'i21', 'i22', 'i23', 'i24']);
      expect(second.nextCursor, isNull);
    });

    test('[TASK-005-S08] the filtered pages continue by cursor too', () async {
      final repo = await create([
        for (var i = 0; i < 22; i++)
          wardrobeItem('top$i', typeCode: 'SHIRT', createdAt: daysBefore(i)),
        wardrobeItem('shoe', typeCode: 'SNEAKERS'),
      ]);

      final first = await repo.getItems(group: ItemGroup.tops);
      final second =
          await repo.getItems(group: ItemGroup.tops, cursor: first.nextCursor);

      expect(first.items, hasLength(20));
      expect(second.items.map((i) => i.itemId), ['top20', 'top21']);
      expect(second.total, 23);
    });

    test('[TASK-005-S08] saving zero Pieces changes nothing', () async {
      final repo = await create(existing);

      await repo.saveItems(const []);

      expect(await repo.countEligible(), 3);
    });
  });
}
