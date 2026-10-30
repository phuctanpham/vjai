import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/discovery_repository.dart';
import '../domain/swipe_type.dart';
import 'discovery_state.dart';

/// Provider for DiscoveryViewModel.
final discoveryViewModelProvider =
    StateNotifierProvider<DiscoveryViewModel, DiscoveryState>((ref) {
  final repository = ref.watch(discoveryRepositoryProvider);
  return DiscoveryViewModel(repository);
});

/// ViewModel / Notifier managing discovery state and user actions.
class DiscoveryViewModel extends StateNotifier<DiscoveryState> {
  final DiscoveryRepository _repository;

  DiscoveryViewModel(this._repository) : super(DiscoveryState.initial()) {
    loadProfiles();
  }

  /// Loads profiles from the repository.
  Future<void> loadProfiles() async {
    state = state.copyWith(
      status: DiscoveryStatus.loading,
      clearError: true,
    );

    try {
      final profiles = await _repository.getProfiles();
      if (profiles.isEmpty) {
        state = state.copyWith(
          status: DiscoveryStatus.empty,
          profiles: const [],
          currentIndex: 0,
        );
      } else {
        state = state.copyWith(
          status: DiscoveryStatus.loaded,
          profiles: profiles,
          currentIndex: 0,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: DiscoveryStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Records a swipe interaction and advances the card index.
  Future<void> swipe(SwipeType swipeType) async {
    final current = state.currentProfile;
    if (current == null) return;

    final nextIndex = state.currentIndex + 1;
    final isDepleted = nextIndex >= state.profiles.length;

    // Optimistically update the UI to the next card or empty state
    state = state.copyWith(
      currentIndex: nextIndex,
      status: isDepleted ? DiscoveryStatus.empty : DiscoveryStatus.loaded,
    );

    try {
      await _repository.recordSwipe(
        profileId: current.id,
        swipeType: swipeType,
      );
    } catch (e) {
      // Swipes fail gracefully without blocking the user flow
    }
  }

  /// Retries loading profiles after an error.
  Future<void> retry() => loadProfiles();
}
