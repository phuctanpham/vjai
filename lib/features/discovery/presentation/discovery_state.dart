import 'package:flutter/foundation.dart';
import '../domain/profile.dart';

/// Explicit status values for discovery view state.
enum DiscoveryStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// State representation for the Discovery feature.
@immutable
class DiscoveryState {
  final DiscoveryStatus status;
  final List<Profile> profiles;
  final int currentIndex;
  final String? errorMessage;

  const DiscoveryState({
    this.status = DiscoveryStatus.initial,
    this.profiles = const [],
    this.currentIndex = 0,
    this.errorMessage,
  });

  /// Factory for initial state.
  factory DiscoveryState.initial() => const DiscoveryState();

  /// Currently active profile to display.
  Profile? get currentProfile {
    if (currentIndex >= 0 && currentIndex < profiles.length) {
      return profiles[currentIndex];
    }
    return null;
  }

  /// Whether there are remaining profiles to browse.
  bool get hasMoreProfiles => currentIndex < profiles.length;

  /// Convenience status getters.
  bool get isInitial => status == DiscoveryStatus.initial;
  bool get isLoading => status == DiscoveryStatus.loading;
  bool get isLoaded => status == DiscoveryStatus.loaded;
  bool get isEmpty => status == DiscoveryStatus.empty;
  bool get isError => status == DiscoveryStatus.error;

  DiscoveryState copyWith({
    DiscoveryStatus? status,
    List<Profile>? profiles,
    int? currentIndex,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DiscoveryState(
      status: status ?? this.status,
      profiles: profiles ?? this.profiles,
      currentIndex: currentIndex ?? this.currentIndex,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiscoveryState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          listEquals(profiles, other.profiles) &&
          currentIndex == other.currentIndex &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      status.hashCode ^
      profiles.hashCode ^
      currentIndex.hashCode ^
      errorMessage.hashCode;

  @override
  String toString() {
    return 'DiscoveryState(status: $status, profiles: ${profiles.length}, index: $currentIndex, error: $errorMessage)';
  }
}

