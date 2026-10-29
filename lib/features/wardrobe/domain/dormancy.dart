import 'wardrobe_item.dart';

/// Shared dormancy rules (spec I8, I12, N6, TAC-04.2).
class DormancyRules {
  const DormancyRules._();

  static const int thresholdDays = 30;

  /// Days shown on the Archive (I8). Whole days from the item's reference
  /// date to [today], by calendar date. The reference date is the latest of
  /// [lastWear] and the item's `lastWornEstimate`, or `createdAt` when
  /// neither exists. The estimate counts here so an old garment indexed
  /// today shows as benched at once (C3, AC-04.6).
  static int daysUnworn({
    required WardrobeItem item,
    required DateTime today,
    DateTime? lastWear,
  }) {
    final candidates = [
      if (lastWear != null) lastWear,
      if (item.lastWornEstimate != null) item.lastWornEstimate!,
    ];
    final reference = candidates.isEmpty
        ? item.createdAt
        : candidates.reduce((a, b) => a.isAfter(b) ? a : b);
    return _daysBetween(reference, today);
  }

  /// Spec T7 › G3 5a: "▲ BENCHED · {d} DAYS" at or above [thresholdDays],
  /// otherwise null. Shape + word, never colour only.
  static String? badgeLabel(int daysUnworn) =>
      daysUnworn >= thresholdDays ? '▲ BENCHED · $daysUnworn DAYS' : null;

  /// Whether a wear on [wornOn] rescues the item (N6, I12): the gap of
  /// [thresholdDays]+ is measured from [previousWear] (a logged wear) or from
  /// `createdAt`, and never from the estimated `lastWornEstimate`.
  /// Feeds rescue XP, quests and the "30-day rescue" badge (Flow C).
  static bool isRescueEligible({
    required WardrobeItem item,
    required DateTime wornOn,
    DateTime? previousWear,
  }) =>
      _daysBetween(previousWear ?? item.createdAt, wornOn) >= thresholdDays;

  /// Calendar days from [from] to [to], ignoring time of day and DST.
  static int _daysBetween(DateTime from, DateTime to) {
    final start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(to.year, to.month, to.day);
    return end.difference(start).inDays;
  }
}
