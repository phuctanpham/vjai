import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mobile layout surface (< 800 px wide), as required by tdd.md.
void useMobileLayout(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Desktop layout surface (>= 800 px wide), as required by tdd.md.
void useDesktopLayout(WidgetTester tester) {
  tester.view.physicalSize = const Size(1280, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Runs [body] once per layout class, naming each test with its layout.
void testBothLayouts(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets('$description (mobile)', (tester) async {
    useMobileLayout(tester);
    await body(tester);
  });
  testWidgets('$description (desktop)', (tester) async {
    useDesktopLayout(tester);
    await body(tester);
  });
}
