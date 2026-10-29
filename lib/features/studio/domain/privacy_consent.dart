import 'package:flutter/foundation.dart';

/// Consent given before any analysis runs (AC-01.8, D3). Insert-only.
@immutable
class PrivacyConsent {
  static const String studioVersion = 'v1.0_studio_body_ai';

  final String version;
  final DateTime grantedAt;
  final bool includesBodyProcessing;

  const PrivacyConsent({
    required this.version,
    required this.grantedAt,
    this.includesBodyProcessing = false,
  });

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S01');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S01');
}
