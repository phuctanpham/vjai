import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/wardrobe/data/local_wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/local_wear_repository.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';
import 'package:garblo/features/wardrobe/domain/dormancy.dart';
import 'package:garblo/features/wardrobe/domain/wardrobe_item.dart';
import 'package:garblo/features/wardrobe/domain/wear_event.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/local_db.dart';
import '../../../helpers/wardrobe_fixtures.dart';

const _owner = '65f0c1a2b3c4d5e6f7a8b9c0';

/// Golden fixtures shared with the in-memory rules (TASK-003-S13).
final _pieces = [
  wardrobeItem('never', createdAt: daysBefore(12)),
  wardrobeItem('estimated',
      createdAt: daysBefore(1), lastWornEstimate: daysBefore(45)),
  wardrobeItem('worn', createdAt: daysBefore(60)),
  wardrobeItem('both',
      createdAt: daysBefore(90), lastWornEstimate: daysBefore(20)),
  wardrobeItem('today', createdAt: daysBefore(40)),
];

final _events = [
  WearEvent.forLook(wornOn: daysBefore(50), itemIds: const ['worn', 'both']),
  WearEvent.forLook(wornOn: daysBefore(33), itemIds: const ['worn']),
  WearEvent.forLook(wornOn: daysBefore(10), itemIds: const ['both']),
  WearEvent.forLook(wornOn: testToday, itemIds: const ['today', 'worn']),
];

Map<String, int> _daysUnworn(
  List<WardrobeItem> items,
  Map<String, DateTime> lastWorn,
) =>
    {
      for (final item in items)
        item.itemId: DormancyRules.daysUnworn(
          item: item,
          today: testToday,
          lastWear: lastWorn[item.itemId],
        ),
    };

void main() {
  late TestDatabase t;
  late LocalWardrobeRepository wardrobe;
  late LocalWearRepository wear;

  setUp(() async {
    t = await TestDatabase.open();
    wardrobe = LocalWardrobeRepository(db: t.db, ownerId: _owner);
    wear = LocalWearRepository(db: t.db, ownerId: _owner);
  });
  tearDown(() async => t.dispose());

  Future<List<Map<String, Object?>>> storedItems(WearEvent event) async {
    final row = await t.db.get('SELECT items FROM wear_events WHERE id = ?',
        [LocalWearRepository.eventId(_owner, event)]);
    return (jsonDecode(row['items'] as String) as List)
        .cast<Map<String, Object?>>();
  }

  group('SQL derived values', () {
    test('[TASK-006-S01] last worn and wear count match the in-memory log',
        () async {
      final memory = MockWearRepository();
      await wardrobe.saveItems(_pieces);
      for (final event in _events) {
        await wear.logWear(event);
        await memory.logWear(event);
      }

      expect(await wear.lastWornByItem(), await memory.lastWornByItem());
      expect(await wear.wearCountByItem(), {'worn': 3, 'both': 2, 'today': 1});
      expect(await wear.lastWornByItem(), {
        'worn': DateTime(2026, 10, 29),
        'both': DateTime(2026, 10, 19),
        'today': DateTime(2026, 10, 29),
      });
    });

    test('[TASK-006-S01] days unworn from SQL match the golden values',
        () async {
      await wardrobe.saveItems(_pieces);
      for (final event in _events) {
        await wear.logWear(event);
      }

      final items = await wardrobe.getEligibleItems();
      final days = _daysUnworn(items, await wear.lastWornByItem());

      expect(days, {
        'never': 12,
        'estimated': 45,
        'worn': 0,
        'both': 10,
        'today': 0,
      });
    });

    test('[TASK-006-S02] 29 days is not benched, 30 days is', () async {
      final at29 = wardrobeItem('at29', createdAt: daysBefore(100));
      final at30 = wardrobeItem('at30', createdAt: daysBefore(100));
      await wardrobe.saveItems([at29, at30]);
      await wear.logWear(WearEvent.forLook(
          wornOn: DateTime(2026, 9, 30, 23, 59), itemIds: const ['at29']));
      await wear.logWear(WearEvent.forLook(
          wornOn: DateTime(2026, 9, 29, 0, 1), itemIds: const ['at30']));

      final days = _daysUnworn(
          await wardrobe.getEligibleItems(), await wear.lastWornByItem());

      expect(days['at29'], 29);
      expect(DormancyRules.badgeLabel(days['at29']!), isNull);
      expect(days['at30'], 30);
      expect(DormancyRules.badgeLabel(days['at30']!), '▲ BENCHED · 30 DAYS');
    });
  });

  group('Provisional gap_days and rescue_eligible', () {
    test('[TASK-006-S03] the first wear counts the gap from the save date',
        () async {
      await wardrobe
          .saveItems([wardrobeItem('old', createdAt: daysBefore(40))]);
      final event =
          WearEvent.forLook(wornOn: testToday, itemIds: const ['old']);

      await wear.logWear(event);

      expect(await storedItems(event), [
        {'item_id': 'old', 'gap_days': 40, 'rescue_eligible': true},
      ]);
    });

    test('[TASK-006-S03] an estimated Last worn never makes a wear eligible',
        () async {
      await wardrobe.saveItems([
        wardrobeItem('fresh',
            createdAt: daysBefore(10), lastWornEstimate: daysBefore(90)),
      ]);
      final event =
          WearEvent.forLook(wornOn: testToday, itemIds: const ['fresh']);

      await wear.logWear(event);

      expect(await storedItems(event), [
        {'item_id': 'fresh', 'gap_days': 10, 'rescue_eligible': false},
      ]);
    });

    test('[TASK-006-S03] the gap runs from the previous logged wear', () async {
      await wardrobe.saveItems([
        wardrobeItem('long', createdAt: daysBefore(100)),
        wardrobeItem('short', createdAt: daysBefore(100)),
      ]);
      await wear.logWear(
          WearEvent.forLook(wornOn: daysBefore(35), itemIds: const ['long']));
      await wear.logWear(
          WearEvent.forLook(wornOn: daysBefore(3), itemIds: const ['short']));
      final event = WearEvent.forLook(
          wornOn: testToday, itemIds: const ['long', 'short']);

      await wear.logWear(event);

      expect(await storedItems(event), [
        {'item_id': 'long', 'gap_days': 35, 'rescue_eligible': true},
        {'item_id': 'short', 'gap_days': 3, 'rescue_eligible': false},
      ]);
    });

    test('[TASK-006-S03] 29 days is not a rescue, 30 days is', () async {
      await wardrobe.saveItems([
        wardrobeItem('d29', createdAt: daysBefore(29)),
        wardrobeItem('d30', createdAt: daysBefore(30)),
      ]);
      final event =
          WearEvent.forLook(wornOn: testToday, itemIds: const ['d29', 'd30']);

      await wear.logWear(event);

      expect(await storedItems(event), [
        {'item_id': 'd29', 'gap_days': 29, 'rescue_eligible': false},
        {'item_id': 'd30', 'gap_days': 30, 'rescue_eligible': true},
      ]);
    });

    test('[TASK-006-S03] a Piece not in the Archive has no gap', () async {
      final event =
          WearEvent.forLook(wornOn: testToday, itemIds: const ['unknown']);

      await wear.logWear(event);

      expect(await storedItems(event), [
        {'item_id': 'unknown', 'gap_days': null, 'rescue_eligible': false},
      ]);
    });
  });

  group('Fit signature', () {
    test('[TASK-006-S04] item order does not change the signature or event',
        () async {
      final abc =
          WearEvent.forLook(wornOn: testToday, itemIds: const ['a', 'b', 'c']);
      final cab =
          WearEvent.forLook(wornOn: testToday, itemIds: const ['c', 'a', 'b']);

      expect(cab.signature, abc.signature);
      expect(LocalWearRepository.eventId(_owner, cab),
          LocalWearRepository.eventId(_owner, abc));

      expect(await wear.logWear(abc), isTrue);
      expect(await wear.logWear(cab), isFalse);
      expect(await wear.wearCountByItem(), {'a': 1, 'b': 1, 'c': 1});
    });
  });
}
