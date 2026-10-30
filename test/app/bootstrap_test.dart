import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/app/bootstrap.dart';
import 'package:garblo/app/shell/pillar_pages.dart';
import 'package:garblo/core/navigation/pillar.dart';
import 'package:garblo/core/errors/failures.dart';

import '../helpers/layout.dart';

void main() {
  restartTests();

  testWidgets(
      '[TASK-005-S09] a store that cannot be opened shows an error, '
      'never the app', (tester) async {
    useMobileLayout(tester);
    var attempts = 0;

    await tester.pumpWidget(GarbloBootstrap(open: () async {
      attempts++;
      throw const StorageFailure(
          "Garblo couldn't open your data on this phone.");
    }));
    await tester.pumpAndSettle();

    expect(find.text("Garblo couldn't open your data on this phone."),
        findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
  });
}

void restartTests() {
  testWidgets('[TASK-008-S05] delete all restarts the app on a fresh scope',
      (tester) async {
    useMobileLayout(tester);
    var scopes = 0;
    late void Function() reset;
    final pages = {
      for (final pillar in Pillar.values)
        pillar: (BuildContext _) => Text('page:${pillar.name}'),
    };

    await tester.pumpWidget(GarbloBootstrap(
      open: () async => LocalStoreSession(overridesFor: (onReset) {
        scopes++;
        reset = onReset;
        return [pillarPagesProvider.overrideWithValue(pages)];
      }),
    ));
    await tester.pumpAndSettle();
    expect(scopes, 1);
    expect(find.text('page:add'), findsOneWidget);

    reset();
    await tester.pumpAndSettle();

    expect(scopes, 2);
    expect(find.text('page:add'), findsOneWidget);
  });
}
