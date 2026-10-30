import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/navigation/pillar.dart';
import 'package:garblo/core/time/clock.dart';
import 'package:garblo/core/widgets/error_view.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';
import 'package:garblo/features/wardrobe/presentation/wardrobe_view.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/layout.dart';
import '../../../helpers/wardrobe_fixtures.dart';

final _items = [
  wardrobeItem('tee',
      name: 'White T-shirt',
      typeCode: 'T_SHIRT',
      styleTag: 'Basic',
      createdAt: daysBefore(60),
      lastWornEstimate: daysBefore(41)),
  wardrobeItem('shirt',
      name: 'Short-sleeve shirt',
      typeCode: 'SHIRT',
      styleTag: 'Everyday',
      createdAt: daysBefore(5)),
  wardrobeItem('jeans',
      name: 'Black jeans', typeCode: 'JEANS', createdAt: daysBefore(2)),
];

late ProviderContainer _container;

Future<void> _pump(WidgetTester tester, {WardrobeRepository? wardrobe}) async {
  _container = ProviderContainer(overrides: [
    wardrobeRepositoryProvider
        .overrideWithValue(wardrobe ?? MockWardrobeRepository(items: _items)),
    wearRepositoryProvider.overrideWithValue(MockWearRepository()),
    clockProvider.overrideWithValue(FixedClock(testToday)),
  ]);
  addTearDown(_container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: _container,
    child: const MaterialApp(home: Scaffold(body: WardrobeView())),
  ));
  await tester.pumpAndSettle();
}

int _gridColumns(WidgetTester tester) {
  final grid = tester.widget<GridView>(find.byType(GridView));
  return (grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount)
      .crossAxisCount;
}

void main() {
  group('WardrobeView', () {
    testBothLayouts('[TASK-003-S07] shows the header, chips and saved items',
        (tester) async {
      await _pump(tester);

      expect(find.text('YOUR ARCHIVE'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('3 PIECES'), findsOneWidget);
      for (final chip in [
        'All',
        'Tops',
        'Bottoms',
        'Shoes',
        'Bags',
        'Hats',
        'Accessories',
      ]) {
        expect(find.text(chip), findsOneWidget, reason: chip);
      }
      expect(find.text('White T-shirt'), findsOneWidget);
      expect(find.text('Tops · Basic'), findsOneWidget);
      expect(find.text('Tops · Everyday'), findsOneWidget);
      expect(find.text('Draft a Fit'), findsOneWidget);
    });

    testWidgets('[TASK-003-S07] mobile grid has 2 flush columns (T7 G1)',
        (tester) async {
      useMobileLayout(tester);
      await _pump(tester);

      expect(_gridColumns(tester), 2);
    });

    testWidgets('[TASK-003-S07] desktop grid has 3 columns (T7 G1)',
        (tester) async {
      useDesktopLayout(tester);
      await _pump(tester);

      expect(_gridColumns(tester), 3);
    });

    testBothLayouts(
        '[TASK-003-S07] a chip filters the grid and keeps the total',
        (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Bottoms'));
      await tester.pumpAndSettle();

      expect(find.text('Black jeans'), findsOneWidget);
      expect(find.text('White T-shirt'), findsNothing);
      expect(find.text('3 PIECES'), findsOneWidget);
    });

    testBothLayouts('[TASK-003-S07] an empty group explains itself',
        (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Bags'));
      await tester.pumpAndSettle();

      expect(find.text('No bags yet'), findsOneWidget);
      expect(find.text('Index Pieces'), findsOneWidget);
    });

    testBothLayouts(
        '[TASK-003-S07] an empty wardrobe hides the FAB and links to Add',
        (tester) async {
      await _pump(tester, wardrobe: MockWardrobeRepository());

      expect(find.text('Your Archive is empty'), findsOneWidget);
      expect(find.text('Draft a Fit'), findsNothing);

      await tester.tap(find.text('Index Pieces'));
      await tester.pumpAndSettle();
      expect(_container.read(pillarProvider), Pillar.add);
    });

    testBothLayouts('[TASK-003-S07] Draft a Fit opens Gu Match',
        (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Draft a Fit'));
      await tester.pumpAndSettle();

      expect(_container.read(pillarProvider), Pillar.guMatch);
    });

    testBothLayouts('[TASK-003-S13] only items unworn 30+ days carry a badge',
        (tester) async {
      await _pump(tester);

      expect(find.text('▲ BENCHED · 41 DAYS'), findsOneWidget);
      expect(find.textContaining('BENCHED'), findsOneWidget);
    });

    testBothLayouts('a load failure shows the error view with retry',
        (tester) async {
      await _pump(tester,
          wardrobe: MockWardrobeRepository(items: _items, failOnLoad: true));

      expect(find.byType(ErrorView), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
