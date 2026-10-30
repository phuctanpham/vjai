import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/app/app.dart';
import 'package:garblo/app/shell/app_shell.dart';
import 'package:garblo/app/shell/coming_soon_view.dart';
import 'package:garblo/app/shell/pillar_pages.dart';
import 'package:garblo/core/navigation/pillar.dart';

import '../helpers/layout.dart';

/// Spec T7 › G4: nav labels in chrome-nav caps.
const _pillarLabels = ['ADD', 'ARCHIVE', 'GU MATCH', 'IMPACT', 'COMMUNITY'];

/// Placeholder pages so shell tests do not depend on feature screens.
final Map<Pillar, WidgetBuilder> _testPages = {
  for (final pillar in Pillar.values)
    pillar: (_) => Center(child: Text('page:${pillar.name}')),
};

Widget _shell() => ProviderScope(
      overrides: [pillarPagesProvider.overrideWithValue(_testPages)],
      child: const MaterialApp(home: AppShell()),
    );

Finder _navLabel(Type navType, String label) => find.descendant(
      of: find.byType(navType),
      matching: find.text(label),
    );

void main() {
  group('AppShell', () {
    testWidgets('[TASK-002-S01] app starts on the Add pillar', (tester) async {
      useMobileLayout(tester);

      await tester.pumpWidget(ProviderScope(
        overrides: [pillarPagesProvider.overrideWithValue(_testPages)],
        child: const GarbloApp(),
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(const ValueKey('pillar-page-add')), findsOneWidget);
      expect(find.text('page:add'), findsOneWidget);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        0,
      );
    });

    testWidgets('[TASK-002-S01] tapping a pillar switches the page',
        (tester) async {
      useMobileLayout(tester);
      await tester.pumpWidget(_shell());
      await tester.pumpAndSettle();

      await tester.tap(_navLabel(NavigationBar, 'ARCHIVE'));
      await tester.pumpAndSettle();

      expect(find.text('page:wardrobe'), findsOneWidget);
      expect(find.text('page:add'), findsNothing);
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
    });

    testWidgets(
        '[TASK-002-S03] mobile shell uses a bottom navigation bar with 5 pillars',
        (tester) async {
      useMobileLayout(tester);
      await tester.pumpWidget(_shell());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      for (final label in _pillarLabels) {
        expect(_navLabel(NavigationBar, label), findsOneWidget, reason: label);
      }
      // T7 › G1/G2: bottom nav is 64 high (plus the bottom safe area).
      expect(
          tester.widget<NavigationBar>(find.byType(NavigationBar)).height, 64);
    });

    testWidgets(
        '[TASK-002-S04] desktop shell uses a navigation rail with 5 pillars',
        (tester) async {
      useDesktopLayout(tester);
      await tester.pumpWidget(_shell());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      for (final label in _pillarLabels) {
        expect(_navLabel(NavigationRail, label), findsOneWidget, reason: label);
      }

      await tester.tap(_navLabel(NavigationRail, 'GU MATCH'));
      await tester.pumpAndSettle();
      expect(find.text('page:guMatch'), findsOneWidget);
    });

    testBothLayouts('header shows wordmark, temperature and bell',
        (tester) async {
      await tester.pumpWidget(_shell());
      await tester.pumpAndSettle();

      expect(find.text('garblo'), findsOneWidget);
      expect(find.text('29°'), findsOneWidget);
      expect(find.byTooltip('Notifications'), findsOneWidget);
    });

    testWidgets('pillarProvider switches the page from outside the shell',
        (tester) async {
      useMobileLayout(tester);
      await tester.pumpWidget(_shell());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(AppShell)),
      );
      container.read(pillarProvider.notifier).select(Pillar.guMatch);
      await tester.pumpAndSettle();

      expect(find.text('page:guMatch'), findsOneWidget);
    });
  });

  group('default pillar pages', () {
    Future<void> pumpDefaultPage(WidgetTester tester, Pillar pillar) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final builder = container.read(pillarPagesProvider)[pillar]!;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(home: Scaffold(body: Builder(builder: builder))),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('[TASK-002-S07] Impact shows its coming-soon state',
        (tester) async {
      await pumpDefaultPage(tester, Pillar.impact);

      expect(find.byType(ComingSoonView), findsOneWidget);
      expect(find.text('Your impact report is coming soon'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });

    testWidgets('[TASK-002-S07] Community shows its coming-soon state',
        (tester) async {
      await pumpDefaultPage(tester, Pillar.community);

      expect(find.byType(ComingSoonView), findsOneWidget);
      expect(find.text('Coming soon'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });
  });
}
