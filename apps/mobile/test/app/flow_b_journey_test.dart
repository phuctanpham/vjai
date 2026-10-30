import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/app/app.dart';
import 'package:garblo/core/media/photo_picker.dart';
import 'package:garblo/core/navigation/pillar.dart';
import 'package:garblo/core/time/clock.dart';
import 'package:garblo/features/studio/data/studio_repository.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';

import '../helpers/fixed_clock.dart';
import '../helpers/layout.dart';
import '../helpers/wardrobe_fixtures.dart';

void main() {
  testBothLayouts(
      '[TASK-004-S01] the ready count follows the Archive across pillars (I9)',
      (tester) async {
    final wardrobe = MockWardrobeRepository(items: [
      wardrobeItem('tee', name: 'White T-shirt', createdAt: daysBefore(9)),
      wardrobeItem('jeans',
          name: 'Black jeans', typeCode: 'JEANS', createdAt: daysBefore(4)),
    ]);
    final container = ProviderContainer(overrides: [
      studioRepositoryProvider.overrideWithValue(MockStudioRepository()),
      wardrobeRepositoryProvider.overrideWithValue(wardrobe),
      wearRepositoryProvider.overrideWithValue(MockWearRepository()),
      photoPickerProvider
          .overrideWithValue(FakePhotoPicker([PresetPhotoPicker.presets])),
      clockProvider.overrideWithValue(FixedClock(testToday)),
    ]);
    addTearDown(container.dispose);
    Future<void> openPillar(Pillar pillar) async {
      container.read(pillarProvider.notifier).select(pillar);
      await tester.pumpAndSettle();
    }

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const GarbloApp(),
    ));
    await tester.pumpAndSettle();

    // Gu Match before indexing: 2 Pieces, no shoes yet.
    await openPillar(Pillar.guMatch);
    expect(find.text('2 PIECES READY'), findsOneWidget);

    // Flow A: index the 3 preset Pieces; the app lands on the Archive.
    await openPillar(Pillar.add);
    await tester.tap(find.text('Tap to add photos'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analyze with Garblo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Read photos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Index 3 Pieces'));
    await tester.pumpAndSettle();
    expect(container.read(pillarProvider), Pillar.wardrobe);
    expect(find.text('5 PIECES'), findsOneWidget);

    // Draft a Fit opens Gu Match with the same count as the Archive.
    await tester.tap(find.text('Draft a Fit'));
    await tester.pumpAndSettle();
    expect(container.read(pillarProvider), Pillar.guMatch);
    expect(find.text('5 PIECES READY'), findsOneWidget);

    // 2 tops × 2 bottoms × 1 pair of shoes → a short deck of 4 Fits.
    await tester.tap(find.text('Draft Fits'));
    await tester.pumpAndSettle();
    expect(find.text('1/4 FITS'), findsOneWidget);
  });
}
