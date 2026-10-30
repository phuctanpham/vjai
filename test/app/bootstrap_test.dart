import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/app/bootstrap.dart';
import 'package:garblo/core/errors/failures.dart';

import '../helpers/layout.dart';

void main() {
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
