import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/discovery/data/discovery_repository.dart';
import 'package:garblo/features/discovery/domain/profile.dart';
import 'package:garblo/features/discovery/domain/swipe_type.dart';
import 'package:garblo/features/discovery/presentation/discovery_state.dart';
import 'package:garblo/features/discovery/presentation/discovery_view_model.dart';

void main() {
  const testProfile1 = Profile(
    id: 'test_1',
    name: 'User One',
    age: 24,
    bio: 'Bio one',
    occupation: 'Dev',
    distanceKm: 2,
  );

  const testProfile2 = Profile(
    id: 'test_2',
    name: 'User Two',
    age: 26,
    bio: 'Bio two',
    occupation: 'Designer',
    distanceKm: 5,
  );

  group('DiscoveryViewModel', () {
    test('loads profiles and enters loaded state on success', () async {
      final repo = MockDiscoveryRepository(
        delay: Duration.zero,
        customProfiles: [testProfile1, testProfile2],
      );

      final viewModel = DiscoveryViewModel(repo);

      // Wait for initial load
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.status, equals(DiscoveryStatus.loaded));
      expect(viewModel.state.profiles.length, equals(2));
      expect(viewModel.state.currentProfile, equals(testProfile1));
      expect(viewModel.state.hasMoreProfiles, isTrue);
    });

    test('transitions to empty state when repository returns empty list',
        () async {
      final repo = MockDiscoveryRepository(
        delay: Duration.zero,
        returnEmpty: true,
      );

      final viewModel = DiscoveryViewModel(repo);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.status, equals(DiscoveryStatus.empty));
      expect(viewModel.state.profiles, isEmpty);
      expect(viewModel.state.currentProfile, isNull);
    });

    test('transitions to error state when repository throws', () async {
      final repo = MockDiscoveryRepository(
        delay: Duration.zero,
        shouldFail: true,
      );

      final viewModel = DiscoveryViewModel(repo);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.status, equals(DiscoveryStatus.error));
      expect(viewModel.state.errorMessage, isNotNull);
    });

    test(
        'advances current index and becomes empty after last profile is swiped',
        () async {
      final repo = MockDiscoveryRepository(
        delay: Duration.zero,
        customProfiles: [testProfile1, testProfile2],
      );

      final viewModel = DiscoveryViewModel(repo);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.currentIndex, equals(0));
      expect(viewModel.state.currentProfile, equals(testProfile1));

      // Swipe first profile
      await viewModel.swipe(SwipeType.like);
      expect(viewModel.state.currentIndex, equals(1));
      expect(viewModel.state.currentProfile, equals(testProfile2));
      expect(viewModel.state.status, equals(DiscoveryStatus.loaded));

      // Swipe second (last) profile
      await viewModel.swipe(SwipeType.pass);
      expect(viewModel.state.currentIndex, equals(2));
      expect(viewModel.state.currentProfile, isNull);
      expect(viewModel.state.status, equals(DiscoveryStatus.empty));
    });

    test('retry reloads profiles from repository', () async {
      final repo = MockDiscoveryRepository(
        delay: Duration.zero,
        customProfiles: [testProfile1],
      );

      final viewModel = DiscoveryViewModel(repo);
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.status, equals(DiscoveryStatus.loaded));

      // Trigger retry
      final retryFuture = viewModel.retry();
      expect(viewModel.state.status, equals(DiscoveryStatus.loading));
      await retryFuture;
      expect(viewModel.state.status, equals(DiscoveryStatus.loaded));
    });
  });
}
