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
      '[TASK-003-S05] Flow A: photos → consent → scope → review → Archive',
      (tester) async {
    final wardrobe = MockWardrobeRepository(items: [
      wardrobeItem('old1',
          name: 'Black jeans', typeCode: 'JEANS', createdAt: daysBefore(4)),
      wardrobeItem('old2', name: 'White T-shirt', createdAt: daysBefore(9)),
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

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const GarbloApp(),
    ));
    await tester.pumpAndSettle();
    expect(container.read(pillarProvider), Pillar.add);

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
    expect(find.byKey(const ValueKey('pillar-page-wardrobe')), findsOneWidget);
    expect(find.text('5 PIECES'), findsOneWidget);
    expect(find.text('Violet shirt'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Violet shirt')).dy,
      lessThanOrEqualTo(tester.getTopLeft(find.text('Black jeans')).dy),
      reason: 'new items appear first (AC-03.8)',
    );
  });
}
