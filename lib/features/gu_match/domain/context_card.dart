import 'package:flutter/foundation.dart';

/// The four context cards on 2b, in display order.
enum ContextCardKind {
  occasion,
  weather,
  rain,
  commute,
}

/// One context card. Its [label] tells where the context came from
/// ("Your request", "Today's event", "Weather", …).
@immutable
class ContextCard {
  final ContextCardKind kind;
  final String label;
  final String headline;
  final String? detail;

  /// True when the source failed, was denied or timed out (AC-06.9).
  final bool isMissing;

  const ContextCard({
    required this.kind,
    required this.label,
    required this.headline,
    this.detail,
    this.isMissing = false,
  });

  /// The card shown when its source did not return.
  factory ContextCard.missing(ContextCardKind kind) =>
      throw UnimplementedError('TASK-004-S10');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-004-S03');

  @override
  int get hashCode => throw UnimplementedError('TASK-004-S03');
}
