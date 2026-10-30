import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/app/app.dart';
import 'package:garblo/app/router.dart';
import 'package:garblo/app/shell/pillar_pages.dart';
import 'package:garblo/core/navigation/pillar.dart';
import 'package:garblo/features/privacy/data/privacy_repository.dart';
import 'package:garblo/features/privacy/presentation/privacy_view.dart';

import '../helpers/layout.dart';
import '../helpers/privacy_fakes.dart';

final Map<Pillar, WidgetBuilder> _testPages = {
  for (final pillar in Pillar.values)
    pillar: (_) => Center(child: Text('page:${pillar.name}')),
};

void main() {
  List<Override> overrides() => [
        pillarPagesProvider.overrideWithValue(_testPages),
        privacyRepositoryProvider.overrideWithValue(FakePrivacyRepository()),
      ];

  testBothLayouts('[TASK-008-S08] the header avatar opens Privacy & data',
      (tester) async {
    await tester.pumpWidget(
        ProviderScope(overrides: overrides(), child: const GarbloApp()));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Privacy & data'), findsOneWidget);
    expect(find.byType(PrivacyView), findsNothing);

    await tester.tap(find.byTooltip('Privacy & data'));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyView), findsOneWidget);
    expect(find.text('Privacy & data'), findsWidgets);
  });

  testWidgets('[TASK-008-S08] /privacy is a route', (tester) async {
    useMobileLayout(tester);
    await tester.pumpWidget(ProviderScope(
      overrides: overrides(),
      child: const MaterialApp(
        onGenerateRoute: AppRouter.onGenerateRoute,
        initialRoute: '/privacy',
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyView), findsOneWidget);
  });

  testBothLayouts(
      '[TASK-008-S08] back from Privacy & data returns to the shell',
      (tester) async {
    await tester.pumpWidget(
        ProviderScope(overrides: overrides(), child: const GarbloApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Privacy & data'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyView), findsNothing);
    expect(find.text('page:add'), findsOneWidget);
  });
}
