import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/media/photo_picker.dart';
import 'package:garblo/core/navigation/pillar.dart';
import 'package:garblo/core/time/clock.dart';
import 'package:garblo/features/studio/data/studio_repository.dart';
import 'package:garblo/features/studio/presentation/studio_view.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/layout.dart';
import '../../../helpers/wardrobe_fixtures.dart';

// Copy is from spec T7 › G3 (screens 1a, 2a, 3a, 4a) and G4.

/// Key of the 3a scope sheet panel.
const _sheetKey = ValueKey('analysis-scope-sheet');

late ProviderContainer _container;

Future<void> _pump(
  WidgetTester tester, {
  StudioRepository? studio,
  WardrobeRepository? wardrobe,
}) async {
  _container = ProviderContainer(overrides: [
    studioRepositoryProvider
        .overrideWithValue(studio ?? MockStudioRepository()),
    wardrobeRepositoryProvider
        .overrideWithValue(wardrobe ?? MockWardrobeRepository()),
    photoPickerProvider
        .overrideWithValue(FakePhotoPicker([PresetPhotoPicker.presets])),
    clockProvider.overrideWithValue(FixedClock(testToday)),
  ]);
  addTearDown(_container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: _container,
    child: const MaterialApp(home: Scaffold(body: StudioView())),
  ));
  await tester.pumpAndSettle();
}

Finder _button(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );

/// Whether the button showing [label] is enabled.
bool _enabled(WidgetTester tester, String label) =>
    tester.widget<ButtonStyleButton>(_button(label)).enabled;

Future<void> _stageAndConsent(WidgetTester tester) async {
  await tester.tap(find.text('Tap to add photos'));
  await tester.pumpAndSettle();
  await tester.tap(find.byType(Checkbox));
  await tester.pumpAndSettle();
}

Future<void> _openReview(WidgetTester tester) async {
  await _stageAndConsent(tester);
  await tester.tap(find.text('Analyze with Garblo'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Read photos'));
  await tester.pumpAndSettle();
}

void main() {
  group('StudioView', () {
    testBothLayouts('[TASK-003-S01] the empty Add screen gates Analyze',
        (tester) async {
      await _pump(tester);

      expect(find.text('STUDIO / 01'), findsOneWidget);
      expect(find.text('Index Pieces'), findsOneWidget);
      expect(find.text('Garments, poses or backgrounds. Mix them freely.'),
          findsOneWidget);
      expect(find.text('Tap to add photos'), findsOneWidget);
      expect(find.text('JPG, PNG · UP TO 10 PER BATCH'), findsOneWidget);
      expect(find.text('Private by default'), findsOneWidget);
      expect(find.text('Process my photos, including body photos if any'),
          findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      expect(_enabled(tester, 'Analyze with Garblo'), isFalse);
      // T7 › G2: primary button height 48.
      expect(tester.getSize(_button('Analyze with Garblo')).height, 48);
    });

    testBothLayouts('[TASK-003-S01] photos plus consent enable Analyze',
        (tester) async {
      await _pump(tester);

      await tester.tap(find.text('Tap to add photos'));
      await tester.pumpAndSettle();
      expect(find.text('3 PHOTOS SELECTED'), findsOneWidget);
      expect(find.byTooltip('Remove photo'), findsNWidgets(3));
      expect(_enabled(tester, 'Analyze with Garblo'), isFalse);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      expect(_enabled(tester, 'Analyze with Garblo'), isTrue);
    });

    testBothLayouts(
        '[TASK-003-S03] Reselect photos closes the sheet and keeps input',
        (tester) async {
      await _pump(tester);
      await _stageAndConsent(tester);

      await tester.tap(find.text('Analyze with Garblo'));
      await tester.pumpAndSettle();
      expect(find.byKey(_sheetKey), findsOneWidget);
      expect(find.text('What should Garblo read?'), findsOneWidget);
      expect(
        find.descendant(
            of: find.byKey(_sheetKey),
            matching: find.byTooltip('Remove photo')),
        findsNothing,
        reason: 'the sheet strip is read-only (AC-02.2)',
      );

      await tester.tap(find.text('Reselect photos'));
      await tester.pumpAndSettle();

      expect(find.byKey(_sheetKey), findsNothing);
      expect(find.text('3 PHOTOS SELECTED'), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    });

    testBothLayouts(
        '[TASK-003-S10] Pieces is the default and Read photos needs a task',
        (tester) async {
      await _pump(tester);
      await _stageAndConsent(tester);
      await tester.tap(find.text('Analyze with Garblo'));
      await tester.pumpAndSettle();

      expect(find.text('Pieces'), findsOneWidget);
      expect(find.text('SEPARATE GARMENTS, READ ATTRIBUTES'), findsOneWidget);
      expect(find.text('Pose'), findsOneWidget);
      expect(find.text('Background'), findsOneWidget);
      expect(find.text('ONLY WHEN A PERSON IS IN THE PHOTO'), findsNWidgets(2));
      expect(_enabled(tester, 'Read photos'), isTrue);

      await tester.tap(find.text('Pieces'));
      await tester.pumpAndSettle();
      expect(_enabled(tester, 'Read photos'), isFalse);
    });

    testBothLayouts(
        '[TASK-003-S04] review shows the AI result and accepts a correction',
        (tester) async {
      await _pump(tester);
      await _openReview(tester);

      expect(find.text('Review Pieces'), findsOneWidget);
      expect(find.text('FROM 3 PHOTOS · 3 PIECES'), findsOneWidget);
      expect(find.text('Check before indexing'), findsOneWidget);
      expect(find.text('PIECE 1/3'), findsOneWidget);
      expect(find.text('Violet shirt'), findsOneWidget);
      expect(find.text('94% CONFIDENCE'), findsOneWidget);
      for (final field in [
        'Type',
        'Colour',
        'Material',
        'Style',
        'Last worn'
      ]) {
        expect(find.text(field), findsOneWidget, reason: field);
      }
      expect(find.text('Index 3 Pieces'), findsOneWidget);

      await tester.tap(find.text('Type'));
      await tester.pumpAndSettle();
      expect(find.text('Accessories'), findsWidgets,
          reason: 'types are grouped, including Accessories');
      await tester.tap(find.text('T-shirt').last);
      await tester.pumpAndSettle();

      expect(find.text('T-shirt'), findsOneWidget);
      expect(find.text('94% CONFIDENCE'), findsOneWidget,
          reason: 'edits keep the AI score (AC-03.6)');
    });

    testBothLayouts(
        '[TASK-003-S11] a partial result reviews the Pieces that succeeded',
        (tester) async {
      await _pump(
        tester,
        studio: MockStudioRepository(
          failingUris: {PresetPhotoPicker.presets[0].uri},
        ),
      );
      await _openReview(tester);

      expect(find.text("1 photo couldn't be read"), findsOneWidget);
      expect(find.text('PIECE 1/2'), findsOneWidget);
      // Shown twice: as the Piece name and as its Type value.
      expect(find.text('Wide-leg trousers'), findsWidgets);
      expect(find.text('Index 2 Pieces'), findsOneWidget);
    });

    testBothLayouts(
        '[TASK-003-S06] a failed save keeps the review and offers Try again',
        (tester) async {
      await _pump(tester, wardrobe: MockWardrobeRepository(failSaveAfter: 0));
      await _openReview(tester);

      await tester.tap(find.text('Index 3 Pieces'));
      await tester.pumpAndSettle();

      expect(find.text("Couldn't index your Pieces."), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Violet shirt'), findsOneWidget);
      expect(_container.read(pillarProvider), Pillar.add);
    });

    testBothLayouts(
        '[TASK-003-S05] a successful save switches to the Archive pillar',
        (tester) async {
      final wardrobe = MockWardrobeRepository();
      await _pump(tester, wardrobe: wardrobe);
      await _openReview(tester);

      await tester.tap(find.text('Index 3 Pieces'));
      await tester.pumpAndSettle();

      expect(_container.read(pillarProvider), Pillar.wardrobe);
      expect((await wardrobe.getItems()).total, 3);
      expect(find.text('Tap to add photos'), findsOneWidget,
          reason: 'the Add pillar is ready for a new batch');
    });
  });
}
