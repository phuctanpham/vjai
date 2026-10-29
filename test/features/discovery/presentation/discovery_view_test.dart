import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/widgets/empty_view.dart';
import 'package:garblo/core/widgets/error_view.dart';
import 'package:garblo/features/discovery/data/discovery_repository.dart';
import 'package:garblo/features/discovery/domain/profile.dart';
import 'package:garblo/features/discovery/presentation/discovery_view.dart';
import 'package:garblo/features/discovery/presentation/widgets/profile_card.dart';

void main() {
  const testProfile = Profile(
    id: 'test_alex',
    name: 'Alex Chen',
    age: 27,
    bio: 'Software engineer & photographer',
    occupation: 'Mobile Architect',
    distanceKm: 4,
    interests: ['Coding', 'Cycling'],
  );

  Widget createSubject({
    required DiscoveryRepository repository,
  }) {
    return ProviderScope(
      overrides: [
        discoveryRepositoryProvider.overrideWithValue(repository),
      ],
      child: const MaterialApp(
        home: DiscoveryView(),
      ),
    );
  }

  group('DiscoveryView rendering', () {
    testWidgets('renders loading state initially', (tester) async {
      final repo = MockDiscoveryRepository(
        delay: const Duration(seconds: 10),
      );

      await tester.pumpWidget(createSubject(repository: repo));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders profile card and controls when loaded', (tester) async {
      final repo = MockDiscoveryRepository(
        delay: Duration.zero,
        customProfiles: [testProfile],
      );

      await tester.pumpWidget(createSubject(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileCard), findsOneWidget);
      expect(find.text('Alex Chen'), findsAtLeastNWidgets(1));
      expect(find.text('27'), findsAtLeastNWidgets(1));
      expect(find.byTooltip('Pass'), findsOneWidget);
      expect(find.byTooltip('Like'), findsOneWidget);
    });

    testWidgets('renders EmptyView when repository returns no profiles', (tester) async {
      final repo = MockDiscoveryRepository(
        delay: Duration.zero,
        returnEmpty: true,
      );

      await tester.pumpWidget(createSubject(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyView), findsOneWidget);
      expect(find.text("You're all caught up!"), findsOneWidget);
      expect(find.text('Refresh Feed'), findsOneWidget);
    });

    testWidgets('renders ErrorView when repository fails and allows retry', (tester) async {
      final repo = MockDiscoveryRepository(
        delay: Duration.zero,
        shouldFail: true,
      );

      await tester.pumpWidget(createSubject(repository: repo));
      await tester.pumpAndSettle();

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('renders desktop layout with sidebar on wide screens', (tester) async {
      // Set desktop screen size
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final repo = MockDiscoveryRepository(
        delay: Duration.zero,
        customProfiles: [testProfile],
      );

      await tester.pumpWidget(createSubject(repository: repo));
      await tester.pumpAndSettle();

      // Desktop layout verification
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('Matches'), findsOneWidget);
      expect(find.text('About Alex Chen'), findsOneWidget);
    });
  });
}
