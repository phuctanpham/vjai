import 'package:garblo/core/time/clock.dart';

/// Clock frozen at [fixed], for deterministic date rules.
class FixedClock implements Clock {
  DateTime fixed;

  FixedClock(this.fixed);

  @override
  DateTime now() => fixed;
}

/// The reference "today" used across Phase 1 tests (spec v2.7 date).
final DateTime testToday = DateTime(2026, 10, 29, 9);
