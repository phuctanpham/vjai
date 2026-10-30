@Tags(['benchmark'])
library;

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/wardrobe/data/local_wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/local_wear_repository.dart';
import 'package:garblo/features/wardrobe/domain/dormancy.dart';
import 'package:garblo/features/wardrobe/domain/wear_event.dart';

import '../../../helpers/local_db.dart';
import '../../../helpers/wardrobe_fixtures.dart';

const _owner = '65f0c1a2b3c4d5e6f7a8b9c0';

void main() {
  late TestDatabase t;

  setUp(() async => t = await TestDatabase.open());
  tearDown(() async => t.dispose());

  test(
    '[TASK-006-S08] Archive dormancy for 500 Pieces and 3,000 wear events '
    'within 300 ms on the host',
    () async {
      final wardrobe = LocalWardrobeRepository(db: t.db, ownerId: _owner);
      final wear = LocalWearRepository(db: t.db, ownerId: _owner);
      final random = Random(42);
      final pieces = [
        for (var i = 0; i < 500; i++)
          wardrobeItem('piece_$i', createdAt: daysBefore(400 + i % 30)),
      ];
      await wardrobe.saveItems(pieces);
      var logged = 0;
      for (var day = 0; logged < 3000; day++) {
        for (var k = 0; k < 10 && logged < 3000; k++) {
          final ids = {
            for (var j = 0; j < 3; j++) 'piece_${random.nextInt(500)}',
          }.toList();
          if (await wear.logWear(
              WearEvent.forLook(wornOn: daysBefore(day), itemIds: ids))) {
            logged++;
          }
        }
      }

      final watch = Stopwatch()..start();
      final items = await wardrobe.getEligibleItems();
      final lastWorn = await wear.lastWornByItem();
      final benched = items
          .where((item) =>
              DormancyRules.daysUnworn(
                item: item,
                today: daysBefore(0),
                lastWear: lastWorn[item.itemId],
              ) >=
              DormancyRules.thresholdDays)
          .length;
      watch.stop();

      // Record the number in the delivery report (TASK-006 acceptance).
      // ignore: avoid_print
      print('TASK-006-S08 host: ${watch.elapsedMilliseconds} ms, '
          '${items.length} Pieces, $logged events, $benched benched');
      expect(items, hasLength(500));
      expect(watch.elapsedMilliseconds, lessThanOrEqualTo(300));
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
