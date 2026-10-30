import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/time/clock.dart';

import '../../helpers/fixed_clock.dart';

void main() {
  group('clockProvider', () {
    test('[TASK-002-S08] default clock is the system clock', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final clock = container.read(clockProvider);

      expect(clock, isA<SystemClock>());
      final before = DateTime.now();
      final reading = clock.now();
      final after = DateTime.now();
      expect(reading.isBefore(before), isFalse);
      expect(reading.isAfter(after), isFalse);
    });

    test('[TASK-002-S08] clockProvider can be overridden', () {
      final container = ProviderContainer(
        overrides: [clockProvider.overrideWithValue(FixedClock(testToday))],
      );
      addTearDown(container.dispose);

      expect(container.read(clockProvider).now(), testToday);
    });
  });
}
