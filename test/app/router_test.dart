import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/app/router.dart';
import 'package:garblo/app/shell/app_shell.dart';
import 'package:garblo/app/shell/pillar_pages.dart';
import 'package:garblo/app/shell/unknown_route_view.dart';
import 'package:garblo/core/navigation/pillar.dart';
import 'package:garblo/features/discovery/presentation/discovery_view.dart';

import '../helpers/layout.dart';

final Map<Pillar, WidgetBuilder> _testPages = {
  for (final pillar in Pillar.values)
    pillar: (_) => Center(child: Text('page:${pillar.name}')),
};

Widget _app(String initialRoute) => ProviderScope(
      overrides: [pillarPagesProvider.overrideWithValue(_testPages)],
      child: MaterialApp(
        initialRoute: initialRoute,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );

void main() {
  group('AppRouter', () {
    testWidgets(
        '[TASK-002-S02] unknown route renders the not-found destination',
        (tester) async {
      useMobileLayout(tester);
      await tester.pumpWidget(_app('/does-not-exist'));
      await tester.pumpAndSettle();

      expect(find.byType(UnknownRouteView), findsOneWidget);
      expect(find.text('Page not found'), findsOneWidget);
      expect(find.textContaining('/does-not-exist'), findsOneWidget);
    });

    testWidgets('[TASK-002-S02] not-found destination returns to Add',
        (tester) async {
      useMobileLayout(tester);
      await tester.pumpWidget(_app('/does-not-exist'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Go to Add'));
      await tester.pumpAndSettle();

      expect(find.byType(UnknownRouteView), findsNothing);
      expect(find.byType(AppShell), findsOneWidget);
      expect(find.byKey(const ValueKey('pillar-page-add')), findsOneWidget);
    });

    testWidgets('the dating discovery route is no longer reachable',
        (tester) async {
      useMobileLayout(tester);
      await tester.pumpWidget(_app('/discovery'));
      await tester.pumpAndSettle();

      expect(find.byType(DiscoveryView), findsNothing);
      expect(find.byType(UnknownRouteView), findsOneWidget);
    });
  });
}
