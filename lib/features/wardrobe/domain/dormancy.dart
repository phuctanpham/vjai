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
  }) =>
      throw UnimplementedError('TASK-003-S13');

  /// Spec T7 › G3 5a: "▲ BENCHED · {d} DAYS" at or above [thresholdDays],
  /// otherwise null. Shape + word, never colour only.
  static String? badgeLabel(int daysUnworn) =>
      throw UnimplementedError('TASK-003-S13');

  /// Whether a wear on [wornOn] rescues the item (N6, I12): the gap of
  /// [thresholdDays]+ is measured from [previousWear] (a logged wear) or from
  /// `createdAt`, and never from the estimated `lastWornEstimate`.
  /// Feeds rescue XP, quests and the "30-day rescue" badge (Flow C).
  static bool isRescueEligible({
    required WardrobeItem item,
    required DateTime wornOn,
    DateTime? previousWear,
  }) =>
      throw UnimplementedError('TASK-003-S14');
}
