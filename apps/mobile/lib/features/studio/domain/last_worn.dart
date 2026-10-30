import 'package:flutter/foundation.dart';

/// Options of the optional review "Last worn" field (AC-03.11).
enum LastWornOption {
  dontRemember,
  thisWeek,
  thisMonth,
  oneToThreeMonths,
  overThreeMonths,
  exactDate,
}

/// User-facing option labels.
extension LastWornOptionLabel on LastWornOption {
  String get label => switch (this) {
        LastWornOption.dontRemember => "Don't remember",
        LastWornOption.thisWeek => 'This week',
        LastWornOption.thisMonth => 'This month',
        LastWornOption.oneToThreeMonths => '1–3 months ago',
        LastWornOption.overThreeMonths => 'Over 3 months ago',
        LastWornOption.exactDate => 'Exact date',
      };
}

/// The user's "Last worn" answer for one extracted item (C3).
@immutable
class LastWornInput {
  final LastWornOption option;

  /// Set only when [option] is [LastWornOption.exactDate].
  final DateTime? exactDate;

  const LastWornInput(this.option, {this.exactDate});

  const LastWornInput.dontRemember()
      : option = LastWornOption.dontRemember,
        exactDate = null;

  /// The estimated last-worn date, or null for "Don't remember" (dormancy
  /// then falls back to the save date). Coarse options resolve to the most
  /// recent date of their range (CHG-003 A-01). The result has no time of
  /// day. Throws [ArgumentError] for an exact date after [today].
  DateTime? resolve(DateTime today) {
    DateTime daysAgo(int days) =>
        DateTime(today.year, today.month, today.day - days);

    switch (option) {
      case LastWornOption.dontRemember:
        return null;
      case LastWornOption.thisWeek:
        return daysAgo(0);
      case LastWornOption.thisMonth:
        return daysAgo(7);
      case LastWornOption.oneToThreeMonths:
        return daysAgo(30);
      case LastWornOption.overThreeMonths:
        return daysAgo(90);
      case LastWornOption.exactDate:
        final date = exactDate;
        if (date == null) {
          throw ArgumentError.notNull('exactDate');
        }
        final day = DateTime(date.year, date.month, date.day);
        if (day.isAfter(daysAgo(0))) {
          throw ArgumentError.value(date, 'exactDate', 'Is in the future');
        }
        return day;
    }
  }

  /// Short label for the review field.
  String get label {
    final date = exactDate;
    if (option != LastWornOption.exactDate || date == null) {
      return option.label;
    }
    String two(int n) => n.toString().padLeft(2, '0');
    return '${date.year}-${two(date.month)}-${two(date.day)}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LastWornInput &&
          option == other.option &&
          exactDate == other.exactDate;

  @override
  int get hashCode => Object.hash(option, exactDate);
}
