import 'package:flutter/foundation.dart';

import '../domain/erasure_counts.dart';

/// Loading the counts.
enum PrivacyStatus { initial, loading, loaded, error }

/// Where the user is on the Privacy & data page.
enum PrivacyStep {
  overview,
  confirmWithdraw,
  confirmDeleteAll,
  working,
  withdrawn,
  deleted,
}

@immutable
class PrivacyState {
  final PrivacyStatus status;
  final PrivacyStep step;
  final ErasureCounts counts;
  final String? errorMessage;

  const PrivacyState({
    required this.status,
    required this.step,
    required this.counts,
    this.errorMessage,
  });

  factory PrivacyState.initial() => throw UnimplementedError('TASK-008-S02');

  PrivacyState copyWith({
    PrivacyStatus? status,
    PrivacyStep? step,
    ErasureCounts? counts,
    String? errorMessage,
    bool clearError = false,
  }) =>
      throw UnimplementedError('TASK-008-S02');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-008-S02');

  @override
  int get hashCode => throw UnimplementedError('TASK-008-S02');
}
