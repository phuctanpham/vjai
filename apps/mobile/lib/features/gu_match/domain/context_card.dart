import 'package:flutter/foundation.dart';

/// The four context cards on 2b, in display order.
enum ContextCardKind {
  occasion,
  weather,
  rain,
  commute,
}

/// One context card. Its [label] tells where the context came from
/// ("YOUR REQUEST", "TODAY", "WEATHER", …).
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

  /// The card shown when its source did not return: it says what is
  /// missing, and the flow carries on without it.
  factory ContextCard.missing(ContextCardKind kind) {
    final (label, headline) = switch (kind) {
      ContextCardKind.occasion => ('TODAY', 'Calendar not connected'),
      ContextCardKind.weather => ('WEATHER', 'Weather unavailable'),
      ContextCardKind.rain => ('RAIN', 'Rain forecast unavailable'),
      ContextCardKind.commute => ('COMMUTE', 'Commute unknown'),
    };
    return ContextCard(
      kind: kind,
      label: label,
      headline: headline,
      isMissing: true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContextCard &&
          kind == other.kind &&
          label == other.label &&
          headline == other.headline &&
          detail == other.detail &&
          isMissing == other.isMissing;

  @override
  int get hashCode => Object.hash(kind, label, headline, detail, isMissing);
}
