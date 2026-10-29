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
  DateTime? resolve(DateTime today) => throw UnimplementedError('TASK-003-S13');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S13');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S13');
}
