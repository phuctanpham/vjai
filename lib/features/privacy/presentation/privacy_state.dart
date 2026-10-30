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

  factory PrivacyState.initial() => const PrivacyState(
        status: PrivacyStatus.initial,
        step: PrivacyStep.overview,
        counts: ErasureCounts.none,
      );

  bool get isConfirming =>
      step == PrivacyStep.confirmWithdraw ||
      step == PrivacyStep.confirmDeleteAll;

  PrivacyState copyWith({
    PrivacyStatus? status,
    PrivacyStep? step,
    ErasureCounts? counts,
    String? errorMessage,
    bool clearError = false,
  }) =>
      PrivacyState(
        status: status ?? this.status,
        step: step ?? this.step,
        counts: counts ?? this.counts,
        errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrivacyState &&
          status == other.status &&
          step == other.step &&
          counts == other.counts &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, step, counts, errorMessage);
}
