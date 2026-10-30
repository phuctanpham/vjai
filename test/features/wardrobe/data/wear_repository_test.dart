import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';
import 'package:garblo/features/wardrobe/domain/wear_event.dart';

import '../../../helpers/fixed_clock.dart';

void main() {
  group('WearEvent', () {
    test('forLook keeps only the calendar date', () {
      final event = WearEvent.forLook(
        wornOn: DateTime(2026, 10, 29, 18, 45),
        itemIds: const ['a', 'b'],
      );

      expect(event.wornDate, DateTime(2026, 10, 29));
      expect(event.source, WearSource.likeConfirm);
    });

    test('the signature does not depend on item order', () {
      final ab =
          WearEvent.forLook(wornOn: testToday, itemIds: const ['a', 'b']);
      final ba =
          WearEvent.forLook(wornOn: testToday, itemIds: const ['b', 'a']);

      expect(ab.signature, ba.signature);
      expect(
        ab.signature ==
            WearEvent.forLook(wornOn: testToday, itemIds: const ['a', 'c'])
                .signature,
        isFalse,
      );
    });
  });

  group('MockWearRepository', () {
    test('[TASK-004-S06] one wear event per look per day (TAC-07.4)', () async {
      final repo = MockWearRepository();
      final look = WearEvent.forLook(
        wornOn: testToday,
        itemIds: const ['violet', 'wide', 'sneakers'],
        candidateId: 'session_1_cand_1',
      );
      final sameLookLater = WearEvent.forLook(
        wornOn: testToday.add(const Duration(hours: 5)),
        itemIds: const ['sneakers', 'violet', 'wide'],
        candidateId: 'session_2_cand_1',
      );

      expect(await repo.logWear(look), isTrue);
      expect(await repo.logWear(sameLookLater), isFalse);
      expect(await repo.getEvents(), hasLength(1));
    });

    test('[TASK-004-S06] the same look on another day is a new wear', () async {
      final repo = MockWearRepository();
      const ids = ['violet', 'wide', 'sneakers'];

      await repo.logWear(WearEvent.forLook(wornOn: testToday, itemIds: ids));
      final added = await repo.logWear(WearEvent.forLook(
          wornOn: testToday.add(const Duration(days: 1)), itemIds: ids));

      expect(added, isTrue);
      expect(await repo.getEvents(), hasLength(2));
    });

    test('[TASK-004-S06] last worn per item is the latest wear date', () async {
      final repo = MockWearRepository();
      final yesterday = testToday.subtract(const Duration(days: 1));

      await repo.logWear(WearEvent.forLook(
          wornOn: yesterday, itemIds: const ['violet', 'wide']));
      await repo.logWear(
          WearEvent.forLook(wornOn: testToday, itemIds: const ['violet']));

      final lastWorn = await repo.lastWornByItem();
      expect(lastWorn['violet'], DateTime(2026, 10, 29));
      expect(lastWorn['wide'], DateTime(2026, 10, 28));
      expect(lastWorn.containsKey('sneakers'), isFalse);
    });
  });
}
