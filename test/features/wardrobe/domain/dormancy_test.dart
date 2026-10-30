import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/wardrobe/domain/dormancy.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/wardrobe_fixtures.dart';

/// Golden fixtures for the shared dormancy rule (I8, TAC-04.2). The server
/// reuses these expected values (BE-003).
void main() {
  group('DormancyRules.daysUnworn', () {
    test('[TASK-003-S13] never-worn items count from their save date', () {
      final item = wardrobeItem('a', createdAt: daysBefore(12));

      expect(DormancyRules.daysUnworn(item: item, today: testToday), 12);
    });

    test('[TASK-003-S13] a Last-worn estimate overrides the save date (C3)',
        () {
      final item = wardrobeItem(
        'violet',
        createdAt: testToday,
        lastWornEstimate: daysBefore(41),
      );

      expect(DormancyRules.daysUnworn(item: item, today: testToday), 41);
    });

    test('[TASK-003-S13] the latest of wear event and estimate wins', () {
      final item = wardrobeItem('a',
          createdAt: daysBefore(100), lastWornEstimate: daysBefore(41));

      expect(
        DormancyRules.daysUnworn(
            item: item, today: testToday, lastWear: daysBefore(3)),
        3,
      );
      expect(
        DormancyRules.daysUnworn(
            item: item, today: testToday, lastWear: daysBefore(60)),
        41,
      );
    });

    test('[TASK-003-S13] wearing today resets dormancy to 0', () {
      final item = wardrobeItem('a', lastWornEstimate: daysBefore(41));

      expect(
        DormancyRules.daysUnworn(
            item: item, today: testToday, lastWear: testToday),
        0,
      );
    });

    test('[TASK-003-S13] days are counted by calendar date, not by hours', () {
      final item = wardrobeItem('a', createdAt: DateTime(2026, 10, 28, 23, 50));

      expect(
        DormancyRules.daysUnworn(
            item: item, today: DateTime(2026, 10, 29, 0, 10)),
        1,
      );
    });
  });

  group('DormancyRules.badgeLabel', () {
    test('[TASK-003-S13] no badge under 30 days', () {
      expect(DormancyRules.badgeLabel(0), isNull);
      expect(DormancyRules.badgeLabel(29), isNull);
    });

    test('[TASK-003-S13] benched status from 30 days, shape + word', () {
      expect(DormancyRules.badgeLabel(30), '▲ BENCHED · 30 DAYS');
      expect(DormancyRules.badgeLabel(41), '▲ BENCHED · 41 DAYS');
    });
  });

  group('DormancyRules.isRescueEligible (N6, I12)', () {
    test('[TASK-003-S14] an estimated Last worn never earns a rescue', () {
      // Indexed today with "Last worn: over 3 months ago": benched on the
      // Archive, but wearing it today is not a rescue.
      final item = wardrobeItem('violet',
          createdAt: testToday, lastWornEstimate: daysBefore(90));

      expect(
        DormancyRules.daysUnworn(item: item, today: testToday),
        90,
        reason: 'the Archive still shows the estimate (C3, AC-04.6)',
      );
      expect(
        DormancyRules.isRescueEligible(item: item, wornOn: testToday),
        isFalse,
      );
    });

    test(
        '[TASK-003-S14] the gap is measured from the save date, ignoring estimates',
        () {
      final item = wardrobeItem('tee',
          createdAt: daysBefore(40), lastWornEstimate: daysBefore(5));

      expect(
        DormancyRules.isRescueEligible(item: item, wornOn: testToday),
        isTrue,
        reason: '40 logged days since saving; the 5-day estimate is ignored',
      );
    });

    test('[TASK-003-S14] the gap is measured from the previous logged wear',
        () {
      final item = wardrobeItem('jeans', createdAt: daysBefore(200));

      expect(
        DormancyRules.isRescueEligible(
            item: item, wornOn: testToday, previousWear: daysBefore(31)),
        isTrue,
      );
      expect(
        DormancyRules.isRescueEligible(
            item: item, wornOn: testToday, previousWear: daysBefore(29)),
        isFalse,
      );
    });
  });
}
