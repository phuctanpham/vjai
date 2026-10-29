import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/studio/domain/last_worn.dart';

void main() {
  // Mid-morning, to prove the time of day is dropped.
  final today = DateTime(2026, 10, 29, 9, 30);
  final todayDate = DateTime(2026, 10, 29);

  group('LastWornInput.resolve (CHG-003 A-01)', () {
    test("[TASK-003-S13] Don't remember resolves to no date", () {
      expect(const LastWornInput.dontRemember().resolve(today), isNull);
    });

    test(
        '[TASK-003-S13] coarse options resolve to the most recent date of their range',
        () {
      const cases = {
        LastWornOption.thisWeek: 0,
        LastWornOption.thisMonth: 7,
        LastWornOption.oneToThreeMonths: 30,
        LastWornOption.overThreeMonths: 90,
      };
      for (final MapEntry(key: option, value: days) in cases.entries) {
        expect(
          LastWornInput(option).resolve(today),
          todayDate.subtract(Duration(days: days)),
          reason: '$option',
        );
      }
    });

    test('[TASK-003-S13] an exact date resolves to that date', () {
      final input = LastWornInput(
        LastWornOption.exactDate,
        exactDate: DateTime(2026, 9, 18, 20),
      );

      expect(input.resolve(today), DateTime(2026, 9, 18));
    });

    test('[TASK-003-S13] an exact date may be today but not in the future', () {
      final laterToday = LastWornInput(
        LastWornOption.exactDate,
        exactDate: DateTime(2026, 10, 29, 23),
      );
      final tomorrow = LastWornInput(
        LastWornOption.exactDate,
        exactDate: DateTime(2026, 10, 30),
      );

      expect(laterToday.resolve(today), todayDate);
      expect(() => tomorrow.resolve(today), throwsA(isA<ArgumentError>()));
    });

    test('value equality', () {
      expect(const LastWornInput(LastWornOption.thisWeek),
          const LastWornInput(LastWornOption.thisWeek));
      expect(
        const LastWornInput(LastWornOption.thisWeek).hashCode,
        const LastWornInput(LastWornOption.thisWeek).hashCode,
      );
    });
  });
}
