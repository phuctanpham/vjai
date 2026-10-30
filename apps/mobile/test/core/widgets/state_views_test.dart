import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/widgets/empty_view.dart';
import 'package:garblo/core/widgets/error_view.dart';
import 'package:garblo/core/widgets/loading_view.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('shared state views', () {
    testWidgets('[TASK-002-S05] loading view shows progress and no error copy',
        (tester) async {
      await tester.pumpWidget(
        _host(const LoadingView(message: 'Reading 3 photos…')),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Reading 3 photos…'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });

    testWidgets('[TASK-002-S05] empty and error views are distinguishable',
        (tester) async {
      await tester.pumpWidget(
        _host(const EmptyView(
          title: 'Your Archive is empty',
          message: 'Index Pieces to get started.',
        )),
      );
      expect(find.text('Your Archive is empty'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Something went wrong'), findsNothing);

      await tester.pumpWidget(
        _host(ErrorView(message: 'Storage failed.', onRetry: () {})),
      );
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
