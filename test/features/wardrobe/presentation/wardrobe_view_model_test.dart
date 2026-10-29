import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/errors/failures.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';
import 'package:garblo/features/wardrobe/domain/item_group.dart';
import 'package:garblo/features/wardrobe/domain/wardrobe_item.dart';
import 'package:garblo/features/wardrobe/domain/wear_event.dart';
import 'package:garblo/features/wardrobe/presentation/wardrobe_state.dart';
import 'package:garblo/features/wardrobe/presentation/wardrobe_view_model.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/wardrobe_fixtures.dart';

class _FlakyWardrobeRepository extends MockWardrobeRepository {
  int loads = 0;

  _FlakyWardrobeRepository({super.items});

  @override
  Future<WardrobePage> getItems({ItemGroup? group, String? cursor}) {
    loads++;
    if (loads == 1) throw const StorageFailure('Could not load your wardrobe.');
    return super.getItems(group: group, cursor: cursor);
  }
}

void main() {
  final items = [
    wardrobeItem('tee',
        name: 'White T-shirt',
        typeCode: 'T_SHIRT',
        createdAt: daysBefore(60),
        lastWornEstimate: daysBefore(41)),
    wardrobeItem('shirt',
        name: 'Short-sleeve shirt',
        typeCode: 'SHIRT',
        createdAt: daysBefore(5)),
    wardrobeItem('jeans', typeCode: 'JEANS', createdAt: daysBefore(2)),
  ];

  WardrobeViewModel build({
    WardrobeRepository? wardrobe,
    WearRepository? wear,
  }) =>
      WardrobeViewModel(
        wardrobeRepository: wardrobe ?? MockWardrobeRepository(items: items),
        wearRepository: wear ?? MockWearRepository(),
        clock: FixedClock(testToday),
      );

  List<WardrobeStatus> recordStatuses(WardrobeViewModel vm) {
    final statuses = <WardrobeStatus>[];
    vm.addListener((s) => statuses.add(s.status), fireImmediately: false);
    return statuses;
  }

  group('WardrobeViewModel', () {
    test('[TASK-003-S07] loads items newest first with the total', () async {
      final vm = build();
      final statuses = recordStatuses(vm);

      await vm.load();

      expect(statuses.first, WardrobeStatus.loading);
      expect(vm.state.status, WardrobeStatus.loaded);
      expect(vm.state.items.map((i) => i.itemId), ['jeans', 'shirt', 'tee']);
      expect(vm.state.total, 3);
      expect(vm.state.activeGroup, isNull);
    });

    test('[TASK-003-S07] an empty wardrobe is the empty state', () async {
      final vm = build(wardrobe: MockWardrobeRepository());

      await vm.load();

      expect(vm.state.status, WardrobeStatus.empty);
      expect(vm.state.total, 0);
    });

    test('[TASK-003-S07] a chip filters without a loading state (AC-04.3)',
        () async {
      final vm = build();
      await vm.load();
      final statuses = recordStatuses(vm);

      await vm.selectGroup(ItemGroup.tops);

      expect(statuses, isNot(contains(WardrobeStatus.loading)));
      expect(vm.state.activeGroup, ItemGroup.tops);
      expect(vm.state.items.map((i) => i.itemId), ['shirt', 'tee']);
      expect(vm.state.total, 3);
    });

    test(
        '[TASK-003-S07] a chip with no items is an empty group, not empty wardrobe',
        () async {
      final vm = build();
      await vm.load();

      await vm.selectGroup(ItemGroup.bags);

      expect(vm.state.status, WardrobeStatus.loaded);
      expect(vm.state.items, isEmpty);
      expect(vm.state.isGroupEmpty, isTrue);
      expect(vm.state.total, 3);
    });

    test('[TASK-003-S07] All clears the filter', () async {
      final vm = build();
      await vm.load();
      await vm.selectGroup(ItemGroup.bottoms);

      await vm.selectGroup(null);

      expect(vm.state.activeGroup, isNull);
      expect(vm.state.items, hasLength(3));
    });

    test('a load failure shows the error state and retry recovers', () async {
      final vm = build(wardrobe: _FlakyWardrobeRepository(items: items));

      await vm.load();
      expect(vm.state.status, WardrobeStatus.error);
      expect(vm.state.errorMessage, isNotNull);

      await vm.retry();
      expect(vm.state.status, WardrobeStatus.loaded);
      expect(vm.state.errorMessage, isNull);
    });

    test('loadMore appends the next page', () async {
      final many = <WardrobeItem>[
        for (var i = 0; i < 25; i++)
          wardrobeItem('i$i', createdAt: daysBefore(i)),
      ];
      final vm = build(wardrobe: MockWardrobeRepository(items: many));
      await vm.load();
      expect(vm.state.items, hasLength(20));

      await vm.loadMore();

      expect(vm.state.items, hasLength(25));
      expect(vm.state.nextCursor, isNull);
    });

    test('[TASK-003-S13] days unworn come from estimates and wear events',
        () async {
      final wear = MockWearRepository(events: [
        WearEvent(
          wornDate: DateTime(testToday.year, testToday.month, testToday.day),
          itemIds: const ['jeans'],
          source: WearSource.likeConfirm,
        ),
      ]);
      final vm = build(wear: wear);

      await vm.load();

      expect(vm.state.daysUnworn['tee'], 41);
      expect(vm.state.daysUnworn['shirt'], 5);
      expect(vm.state.daysUnworn['jeans'], 0);
    });
  });
}
