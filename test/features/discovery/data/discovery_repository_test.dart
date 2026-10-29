import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/discovery/data/discovery_repository.dart';
import 'package:garblo/features/discovery/domain/swipe_type.dart';

void main() {
  group('MockDiscoveryRepository', () {
    test('getProfiles returns sample profiles on success', () async {
      final repository = MockDiscoveryRepository(delay: Duration.zero);
      final profiles = await repository.getProfiles();

      expect(profiles, isNotEmpty);
      expect(profiles.length, equals(5));
      expect(profiles.first.name, equals('Alex Chen'));
    });

    test('getProfiles returns empty list when returnEmpty is true', () async {
      final repository = MockDiscoveryRepository(
        delay: Duration.zero,
        returnEmpty: true,
      );
      final profiles = await repository.getProfiles();

      expect(profiles, isEmpty);
    });

    test('getProfiles throws exception when shouldFail is true', () async {
      final repository = MockDiscoveryRepository(
        delay: Duration.zero,
        shouldFail: true,
      );

      expect(
        () => repository.getProfiles(),
        throwsA(isA<Exception>()),
      );
    });

    test('recordSwipe succeeds without throwing when not configured to fail',
        () async {
      final repository = MockDiscoveryRepository(delay: Duration.zero);

      await expectLater(
        repository.recordSwipe(profileId: 'usr_01', swipeType: SwipeType.like),
        completes,
      );
    });

    test('recordSwipe throws when shouldFail is true', () async {
      final repository = MockDiscoveryRepository(
        delay: Duration.zero,
        shouldFail: true,
      );

      expect(
        () => repository.recordSwipe(
            profileId: 'usr_01', swipeType: SwipeType.pass),
        throwsA(isA<Exception>()),
      );
    });
  });
}
