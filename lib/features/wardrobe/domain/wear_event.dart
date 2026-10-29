import 'package:flutter/foundation.dart';

/// Where a wear was confirmed. Phase 1 only has the Gu Match like flow.
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

  /// Builds the event for a worn look, normalising [wornOn] to its date.
  factory WearEvent.forLook({
    required DateTime wornOn,
    required List<String> itemIds,
    String? candidateId,
  }) =>
      throw UnimplementedError('TASK-004-S06');

  /// Identifies the look independent of item order. One event per
  /// (date, signature) (TAC-07.4).
  String get signature => throw UnimplementedError('TASK-004-S06');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-004-S06');

  @override
  int get hashCode => throw UnimplementedError('TASK-004-S06');
}
