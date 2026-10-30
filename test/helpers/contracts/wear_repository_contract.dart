import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';
import 'package:garblo/features/wardrobe/domain/wear_event.dart';

import '../fixed_clock.dart';

typedef WearRepositoryFactory = Future<WearRepository> Function();

/// The behaviour every [WearRepository] must share (TASK-005-S08).
void wearRepositoryContract(
  String label,
  WearRepositoryFactory create, {
  Future<void> Function()? cleanUp,
}) {
  group('$label satisfies the WearRepository contract', () {
    if (cleanUp != null) tearDown(cleanUp);

    final yesterday = DateTime(2026, 10, 28, 20);

    test('[TASK-005-S08] one wear event per Fit per day', () async {
      final repo = await create();

      expect(
          await repo.logWear(WearEvent.forLook(
              wornOn: testToday, itemIds: const ['violet', 'wide'])),
          isTrue);
      expect(
          await repo.logWear(WearEvent.forLook(
              wornOn: testToday.add(const Duration(hours: 5)),
              itemIds: const ['wide', 'violet'])),
          isFalse);
      expect(await repo.getEvents(), hasLength(1));
    });

    test('[TASK-005-S08] the same Fit on another day is a new wear', () async {
      final repo = await create();
      const ids = ['violet', 'wide'];

      await repo.logWear(WearEvent.forLook(wornOn: yesterday, itemIds: ids));
      final added = await repo
          .logWear(WearEvent.forLook(wornOn: testToday, itemIds: ids));

      expect(added, isTrue);
      expect(await repo.getEvents(), hasLength(2));
    });

    test('[TASK-005-S08] events round-trip', () async {
      final repo = await create();
      final event = WearEvent.forLook(
        wornOn: testToday,
        itemIds: const ['violet', 'wide', 'sneakers'],
        candidateId: 'cand_1',
      );

      await repo.logWear(event);

      expect(await repo.getEvents(), [event]);
    });

    test('[TASK-005-S08] last worn is the latest wear per Piece', () async {
      final repo = await create();

      await repo.logWear(WearEvent.forLook(
          wornOn: yesterday, itemIds: const ['violet', 'wide']));
      await repo.logWear(
          WearEvent.forLook(wornOn: testToday, itemIds: const ['violet']));

      final lastWorn = await repo.lastWornByItem();
      expect(lastWorn, {
        'violet': DateTime(2026, 10, 29),
        'wide': DateTime(2026, 10, 28),
      });
    });

    test('[TASK-005-S08] wear count is the number of events per Piece',
        () async {
      final repo = await create();

      await repo.logWear(WearEvent.forLook(
          wornOn: yesterday, itemIds: const ['violet', 'wide']));
      await repo.logWear(
          WearEvent.forLook(wornOn: testToday, itemIds: const ['violet']));

      expect(await repo.wearCountByItem(), {'violet': 2, 'wide': 1});
    });

    test('[TASK-005-S08] an empty log has no last worn and no counts',
        () async {
      final repo = await create();

      expect(await repo.lastWornByItem(), isEmpty);
      expect(await repo.wearCountByItem(), isEmpty);
      expect(await repo.getEvents(), isEmpty);
    });
  });
}
