import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/time/clock.dart';
import 'package:garblo/features/gu_match/data/gu_match_repository.dart';
import 'package:garblo/features/gu_match/presentation/gu_match_view.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/layout.dart';
import '../helpers/reliability.dart';
import '../helpers/wardrobe_fixtures.dart';

final _closet = [
  wardrobeItem('violet', name: 'Violet shirt', typeCode: 'SHIRT'),
  wardrobeItem('tee', name: 'White T-shirt', typeCode: 'T_SHIRT'),
  wardrobeItem('wide',
      name: 'Wide-leg trousers', typeCode: 'WIDE_LEG_TROUSERS'),
  wardrobeItem('jeans', name: 'Black jeans', typeCode: 'JEANS'),
  wardrobeItem('sneakers', name: 'Cream sneakers', typeCode: 'SNEAKERS'),
  wardrobeItem('loafers', name: 'Black loafers', typeCode: 'LOAFERS'),
];

void main() {
  testBothLayouts(
      '[TASK-009-S08] a failed "Wear today" shows its error on the prompt and '
      'succeeds on retry', (tester) async {
    final wardrobe = MockWardrobeRepository(items: _closet);
    final wear = FlakyWearRepository(MockWearRepository(), failWrites: 1);
    final clock = FixedClock(testToday);
    final container = ProviderContainer(overrides: [
      wardrobeRepositoryProvider.overrideWithValue(wardrobe),
      wearRepositoryProvider.overrideWithValue(wear),
      clockProvider.overrideWithValue(clock),
      guMatchRepositoryProvider.overrideWithValue(MockGuMatchRepository(
          wardrobeRepository: wardrobe, wearRepository: wear, clock: clock)),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: Scaffold(body: GuMatchView())),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Draft Fits'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add to Rotation'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Wear today'));
    await tester.pumpAndSettle();

    expect(find.text('Could not log the wear.'), findsOneWidget);
    expect(find.text('Wearing this today?'), findsOneWidget);
    expect(find.text('1/8 FITS'), findsOneWidget);

    await tester.tap(find.text('Wear today'));
    await tester.pumpAndSettle();

    expect(find.text('Could not log the wear.'), findsNothing);
    expect(find.text('Wearing this today?'), findsNothing);
    expect(find.text('2/8 FITS'), findsOneWidget);
    expect(await wear.getEvents(), hasLength(1));
  });
}
