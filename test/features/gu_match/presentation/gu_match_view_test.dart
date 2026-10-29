import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/navigation/pillar.dart';
import 'package:garblo/core/time/clock.dart';
import 'package:garblo/features/gu_match/data/gu_match_repository.dart';
import 'package:garblo/features/gu_match/domain/context_card.dart';
import 'package:garblo/features/gu_match/domain/gu_match_session.dart';
import 'package:garblo/features/gu_match/presentation/gu_match_view.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';
import 'package:garblo/features/wardrobe/domain/wardrobe_item.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/layout.dart';
import '../../../helpers/wardrobe_fixtures.dart';

// Copy is from spec T7 › G3 (screens 1b, 2b, 3b) and G4.

final _closet = [
  wardrobeItem('violet',
      name: 'Violet shirt',
      typeCode: 'SHIRT',
      lastWornEstimate: daysBefore(41)),
  wardrobeItem('tee', name: 'White T-shirt', typeCode: 'T_SHIRT'),
  wardrobeItem('wide',
      name: 'Wide-leg trousers', typeCode: 'WIDE_LEG_TROUSERS'),
  wardrobeItem('jeans', name: 'Black jeans', typeCode: 'JEANS'),
  wardrobeItem('sneakers', name: 'Cream sneakers', typeCode: 'SNEAKERS'),
  wardrobeItem('loafers', name: 'Black loafers', typeCode: 'LOAFERS'),
];

class _StreamingRepository extends MockGuMatchRepository {
  final StreamController<ContextCard> controller;

  _StreamingRepository({
    required this.controller,
    required super.wardrobeRepository,
    required super.wearRepository,
    required super.clock,
  });

  @override
  Stream<ContextCard> gatherContext(GuMatchSession session) =>
      controller.stream;
}

late ProviderContainer _container;

Future<void> _pump(
  WidgetTester tester, {
  List<WardrobeItem>? items,
  GuMatchRepository Function(WardrobeRepository, WearRepository, Clock)? repo,
}) async {
  final wardrobe = MockWardrobeRepository(items: items ?? _closet);
  final wear = MockWearRepository();
  final clock = FixedClock(testToday);
  _container = ProviderContainer(overrides: [
    wardrobeRepositoryProvider.overrideWithValue(wardrobe),
    wearRepositoryProvider.overrideWithValue(wear),
    clockProvider.overrideWithValue(clock),
    if (repo != null)
      guMatchRepositoryProvider.overrideWithValue(repo(wardrobe, wear, clock)),
  ]);
  addTearDown(_container.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: _container,
    child: const MaterialApp(home: Scaffold(body: GuMatchView())),
  ));
  await tester.pumpAndSettle();
}

bool _enabled(WidgetTester tester, String label) => tester
    .widget<ButtonStyleButton>(find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    ))
    .enabled;

Future<void> _openDeck(WidgetTester tester) async {
  await tester.tap(find.text('Draft Fits'));
  await tester.pumpAndSettle();
}

void main() {
  group('GuMatchView', () {
    testBothLayouts('[TASK-004-S01] the studio shows the owned-only promise',
        (tester) async {
      await _pump(tester);

      expect(find.text('GU MATCH'), findsOneWidget);
      expect(find.text('What are you wearing today?'), findsOneWidget);
      expect(find.text('Pick a context. Garblo drafts only from your Archive.'),
          findsOneWidget);
      for (final chip in [
        'Work',
        'Coffee',
        'Afternoon rain',
        'Date',
        'Weekend outing',
      ]) {
        expect(find.text(chip), findsOneWidget, reason: chip);
      }
      expect(find.text('TELL GARBLO MORE'), findsOneWidget);
      expect(find.text('0/280'), findsOneWidget);
      expect(find.text('6 PIECES READY'), findsOneWidget);
      expect(find.text('No shopping. Drafts use only what you own.'),
          findsOneWidget);
      expect(_enabled(tester, 'Draft Fits'), isTrue);
    });

    testBothLayouts(
        '[TASK-004-S01] an empty Archive disables Draft Fits and links to Add',
        (tester) async {
      await _pump(tester, items: const []);

      expect(find.text('Index Pieces into your Archive first'), findsOneWidget);
      expect(_enabled(tester, 'Draft Fits'), isFalse);

      await tester.tap(find.text('Index Pieces'));
      await tester.pumpAndSettle();
      expect(_container.read(pillarProvider), Pillar.add);
    });

    testBothLayouts('[TASK-004-S03] context cards reveal before the deck opens',
        (tester) async {
      final controller = StreamController<ContextCard>();
      await _pump(tester,
          repo: (w, wear, c) => _StreamingRepository(
                controller: controller,
                wardrobeRepository: w,
                wearRepository: wear,
                clock: c,
              ));

      await tester.tap(find.text('Draft Fits'));
      await tester.pump();
      await tester.pump();
      expect(
          find.text('DRAFTING · CALENDAR, WEATHER & COMMUTE'), findsOneWidget);
      expect(find.text('Reading your context…'), findsOneWidget);

      controller.add(const ContextCard(
          kind: ContextCardKind.weather, label: 'WEATHER', headline: '29°C'));
      await tester.pump();
      expect(find.text('29°C'), findsOneWidget);
      expect(find.text('Reading your context…'), findsOneWidget);

      controller
        ..add(const ContextCard(
            kind: ContextCardKind.occasion,
            label: 'YOUR REQUEST',
            headline: 'Coffee'))
        ..add(const ContextCard(
            kind: ContextCardKind.rain, label: 'RAIN', headline: '40%'))
        ..add(const ContextCard(
            kind: ContextCardKind.commute,
            label: 'COMMUTE',
            headline: 'Motorbike'));
      await tester.pump();
      await tester.pump();
      expect(find.text('Context read'), findsOneWidget);

      await controller.close();
      await tester.pumpAndSettle();
      expect(find.text('1/8 FITS'), findsOneWidget);
    });

    testBothLayouts('[TASK-004-S05] the deck shows the Fit and Pass advances',
        (tester) async {
      await _pump(tester);
      await _openDeck(tester);

      expect(find.text('1/8 FITS'), findsOneWidget);
      expect(find.text('Change context'), findsOneWidget);
      expect(find.text('WARDROBE PHOTO'), findsOneWidget);
      expect(find.text('82% FIT'), findsOneWidget);
      expect(find.text('Benched 41 days · Violet shirt'), findsOneWidget);
      for (final action in ['Pass', 'Add to Rotation', 'Adjust', 'Try on']) {
        expect(find.byTooltip(action), findsOneWidget, reason: action);
      }
      expect(find.byTooltip('Like'), findsNothing, reason: 'never "Like" (G4)');

      await tester.tap(find.byTooltip('Pass'));
      await tester.pumpAndSettle();
      expect(find.text('2/8 FITS'), findsOneWidget);
    });

    testBothLayouts(
        '[TASK-004-S06] Add to Rotation asks about wearing and Wear today advances',
        (tester) async {
      await _pump(tester);
      await _openDeck(tester);

      await tester.tap(find.byTooltip('Add to Rotation'));
      await tester.pumpAndSettle();
      expect(find.text('Wearing this today?'), findsOneWidget);
      expect(find.text('Save for later'), findsOneWidget);

      await tester.tap(find.text('Wear today'));
      await tester.pumpAndSettle();
      expect(find.text('Wearing this today?'), findsNothing);
      expect(find.text('2/8 FITS'), findsOneWidget);
    });

    testBothLayouts('[TASK-004-S08] Try on is explicitly coming soon',
        (tester) async {
      await _pump(tester);
      await _openDeck(tester);

      await tester.tap(find.byTooltip('Try on'));
      await tester.pumpAndSettle();

      expect(find.text('Try-on is coming soon'), findsOneWidget);
      expect(find.text('TRY-ON'), findsNothing, reason: 'no false success');
      expect(find.text('1/8 FITS'), findsOneWidget);
    });

    testBothLayouts(
        '[TASK-004-S12] the end of a short deck offers the next steps',
        (tester) async {
      await _pump(tester, items: [_closet[0], _closet[2], _closet[4]]);
      await _openDeck(tester);
      expect(find.text('1/1 FITS'), findsOneWidget);

      await tester.tap(find.byTooltip('Pass'));
      await tester.pumpAndSettle();

      expect(find.text('You added 0 Fits to Rotation'), findsOneWidget);
      expect(find.text('Change context'), findsOneWidget);
      await tester.tap(find.text('Go to Archive'));
      await tester.pumpAndSettle();
      expect(_container.read(pillarProvider), Pillar.wardrobe);
    });
  });
}
