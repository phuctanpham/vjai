import 'package:flutter/foundation.dart';

/// Consent given before any analysis runs (AC-01.8, D3). Insert-only;
/// withdrawing sets [revokedAt] (UC-09).
@immutable
class PrivacyConsent {
  static const String studioVersion = 'v1.0_studio_body_ai';

  /// Row ID once stored (null for a consent not yet recorded).
  final String? id;
  final String version;
  final DateTime grantedAt;
  final bool includesBodyProcessing;
  final DateTime? revokedAt;

  const PrivacyConsent({
    required this.version,
    required this.grantedAt,
    this.includesBodyProcessing = false,
    this.id,
    this.revokedAt,
  });

  bool get isActive => revokedAt == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacyConsent &&
          id == other.id &&
          version == other.version &&
          grantedAt == other.grantedAt &&
          includesBodyProcessing == other.includesBodyProcessing &&
          revokedAt == other.revokedAt;

  @override
  int get hashCode =>
      Object.hash(id, version, grantedAt, includesBodyProcessing, revokedAt);
}
