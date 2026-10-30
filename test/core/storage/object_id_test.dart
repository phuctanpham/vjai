import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/storage/object_id.dart';

import '../../helpers/fixed_clock.dart';

final _hex24 = RegExp(r'^[0-9a-f]{24}$');

void main() {
  group('ObjectIdGenerator', () {
    test('[TASK-005-S06] IDs are 24 lowercase hex characters', () {
      final ids = ObjectIdGenerator(clock: FixedClock(testToday));

      for (var i = 0; i < 50; i++) {
        final id = ids.next();
        expect(id, matches(_hex24));
        expect(isObjectId(id), isTrue);
      }
    });

    test('[TASK-005-S06] the first 4 bytes are the seconds since epoch', () {
      final ids = ObjectIdGenerator(clock: FixedClock(testToday));

      final seconds = int.parse(ids.next().substring(0, 8), radix: 16);

      expect(seconds, testToday.millisecondsSinceEpoch ~/ 1000);
    });

    test('[TASK-005-S06] 10,000 IDs in the same second are unique', () {
      final ids = ObjectIdGenerator(clock: FixedClock(testToday));

      final all = {for (var i = 0; i < 10000; i++) ids.next()};

      expect(all, hasLength(10000));
    });

    test('[TASK-005-S06] two generators (two runs) do not collide', () {
      final clock = FixedClock(testToday);
      final a = ObjectIdGenerator(clock: clock, random: Random(1));
      final b = ObjectIdGenerator(clock: clock, random: Random(2));

      final fromA = {for (var i = 0; i < 1000; i++) a.next()};
      final fromB = {for (var i = 0; i < 1000; i++) b.next()};

      expect(fromA.intersection(fromB), isEmpty);
    });

    test('[TASK-005-S06] IDs sort by creation time', () {
      final clock = FixedClock(testToday);
      final ids = ObjectIdGenerator(clock: clock);

      final created = <String>[];
      for (var i = 0; i < 5; i++) {
        created.add(ids.next());
        created.add(ids.next()); // same second: the counter orders them
        clock.fixed = clock.fixed.add(const Duration(seconds: 1));
      }

      expect([...created]..sort(), created);
    });
  });

  group('isObjectId', () {
    test('[TASK-005-S06] rejects anything but 24 lowercase hex', () {
      expect(isObjectId('65f0c1a2b3c4d5e6f7a8b9c0'), isTrue);
      for (final bad in [
        '',
        '65f0c1a2b3c4d5e6f7a8b9c',
        '65f0c1a2b3c4d5e6f7a8b9c00',
        '65F0C1A2B3C4D5E6F7A8B9C0',
        '65f0c1a2b3c4d5e6f7a8b9cg',
        '../../65f0c1a2b3c4d5e6f7',
        'asset_1',
      ]) {
        expect(isObjectId(bad), isFalse, reason: bad);
      }
    });
  });

  group('deterministicObjectId', () {
    test('[TASK-005-S07] the same parts give the same ID', () {
      final a = deterministicObjectId(['owner', '2026-10-29', 'a,b,c']);
      final b = deterministicObjectId(['owner', '2026-10-29', 'a,b,c']);

      expect(a, b);
      expect(isObjectId(a), isTrue);
    });

    test('[TASK-005-S07] any change in the parts changes the ID', () {
      final base = deterministicObjectId(['owner', '2026-10-29', 'a,b']);

      expect(
          deterministicObjectId(['owner', '2026-10-30', 'a,b']), isNot(base));
      expect(
          deterministicObjectId(['other', '2026-10-29', 'a,b']), isNot(base));
      expect(
          deterministicObjectId(['2026-10-29', 'owner', 'a,b']), isNot(base));
    });

    test('[TASK-005-S07] part boundaries matter', () {
      expect(deterministicObjectId(['ab', 'c']),
          isNot(deterministicObjectId(['a', 'bc'])));
    });
  });
}
