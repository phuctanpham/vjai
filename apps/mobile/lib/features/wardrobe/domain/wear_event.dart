import 'package:flutter/foundation.dart';

/// Where a wear was confirmed. Phase 1 only has the Gu Match flow.
enum WearSource {
  likeConfirm,
}

/// One confirmed wear of a set of items on a date. Append-only: last worn
/// and wear counts are derived from these events, never edited.
@immutable
class WearEvent {
  /// Calendar date of the wear (time of day is zero).
  final DateTime wornDate;
  final List<String> itemIds;
  final String? candidateId;
  final WearSource source;

  const WearEvent({
    required this.wornDate,
    required this.itemIds,
    required this.source,
    this.candidateId,
  });

  /// Builds the event for a worn Fit, normalising [wornOn] to its date.
  factory WearEvent.forLook({
    required DateTime wornOn,
    required List<String> itemIds,
    String? candidateId,
  }) {
    return WearEvent(
      wornDate: DateTime(wornOn.year, wornOn.month, wornOn.day),
      itemIds: List.unmodifiable(itemIds),
      candidateId: candidateId,
      source: WearSource.likeConfirm,
    );
  }

  /// Identifies the Fit independent of item order. One event per
  /// (date, signature) (TAC-07.4).
  String get signature => ([...itemIds]..sort()).join(',');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WearEvent &&
          wornDate == other.wornDate &&
          listEquals(itemIds, other.itemIds) &&
          candidateId == other.candidateId &&
          source == other.source;

  @override
  int get hashCode =>
      Object.hash(wornDate, Object.hashAll(itemIds), candidateId, source);
}
