import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/errors/failures.dart';
import 'package:garblo/features/gu_match/data/gu_match_repository.dart';
import 'package:garblo/features/gu_match/domain/context_card.dart';
import 'package:garblo/features/gu_match/domain/gu_match_failures.dart';
import 'package:garblo/features/gu_match/domain/gu_match_session.dart';
import 'package:garblo/features/gu_match/domain/interaction.dart';
import 'package:garblo/features/gu_match/domain/occasion.dart';
import 'package:garblo/features/gu_match/domain/session_path.dart';
import 'package:garblo/features/gu_match/domain/slot_role.dart';
import 'package:garblo/features/gu_match/domain/styling_context.dart';
import 'package:garblo/features/gu_match/domain/swipe_status.dart';
import 'package:garblo/features/gu_match/presentation/gu_match_state.dart';
import 'package:garblo/features/gu_match/presentation/gu_match_view_model.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';
import 'package:garblo/features/wardrobe/domain/wardrobe_item.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/wardrobe_fixtures.dart';

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

const _card = {
  ContextCardKind.occasion: ContextCard(
      kind: ContextCardKind.occasion,
      label: 'YOUR REQUEST',
      headline: 'Coffee'),
  ContextCardKind.weather: ContextCard(
      kind: ContextCardKind.weather, label: 'WEATHER', headline: '29 °C'),
  ContextCardKind.rain:
      ContextCard(kind: ContextCardKind.rain, label: 'RAIN', headline: '40%'),
  ContextCardKind.commute: ContextCard(
      kind: ContextCardKind.commute, label: 'COMMUTE', headline: 'Motorbike'),
};

/// Gu Match repository with scriptable failures, a controllable context
/// stream and interactions that can be held open.
class _ScriptedRepository extends MockGuMatchRepository {
  final StreamController<ContextCard>? contextStream;
  final Completer<void>? holdInteractions;
  final bool failFirstCount;
  final bool startFailsWithNoItems;
  int countCalls = 0;

  _ScriptedRepository({
    required super.wardrobeRepository,
    required super.wearRepository,
    required super.clock,
    this.contextStream,
    this.holdInteractions,
    this.failFirstCount = false,
    this.startFailsWithNoItems = false,
  });

  @override
  Future<int> readyItemCount() async {
    countCalls++;
    if (failFirstCount && countCalls == 1) {
      throw const StorageFailure('Could not read your wardrobe.');
    }
    return super.readyItemCount();
  }

  @override
  Future<GuMatchSession> startSession(StylingContext context) async {
    if (startFailsWithNoItems) throw const NoEligibleItemsFailure();
    return super.startSession(context);
  }

  @override
  Stream<ContextCard> gatherContext(GuMatchSession session) =>
      contextStream?.stream ?? super.gatherContext(session);

  @override
  Future<void> recordInteraction(Interaction interaction) async {
    if (holdInteractions != null) await holdInteractions!.future;
    return super.recordInteraction(interaction);
  }
}

void main() {
  late MockWardrobeRepository wardrobe;
  late MockWearRepository wear;
  late MockGuMatchRepository repo;
  final clock = FixedClock(testToday);

  MockGuMatchRepository mockRepo({
    Set<ContextCardKind> missing = const {},
    bool hasCalendarEvent = true,
  }) =>
      MockGuMatchRepository(
        wardrobeRepository: wardrobe,
        wearRepository: wear,
        clock: clock,
        missingContextKinds: missing,
        hasCalendarEvent: hasCalendarEvent,
      );

  _ScriptedRepository scripted({
    StreamController<ContextCard>? contextStream,
    Completer<void>? holdInteractions,
    bool failFirstCount = false,
    bool startFailsWithNoItems = false,
  }) =>
      _ScriptedRepository(
        wardrobeRepository: wardrobe,
        wearRepository: wear,
        clock: clock,
        contextStream: contextStream,
        holdInteractions: holdInteractions,
        failFirstCount: failFirstCount,
        startFailsWithNoItems: startFailsWithNoItems,
      );

  GuMatchViewModel build([GuMatchRepository? repository]) =>
      GuMatchViewModel(repository: repository ?? repo, clock: clock);

  Future<GuMatchViewModel> inDeck({
    GuMatchRepository? repository,
    void Function(GuMatchViewModel vm)? setContext,
  }) async {
    final vm = build(repository);
    await vm.load();
    setContext?.call(vm);
    await vm.startSwiping();
    return vm;
  }

  void useCloset(List<WardrobeItem> items) {
    wardrobe = MockWardrobeRepository(items: items);
    repo = mockRepo();
  }

  setUp(() {
    wear = MockWearRepository();
    useCloset(_closet);
  });

  group('studio', () {
    test('[TASK-004-S01] the ready count equals the Wardrobe total (I9)',
        () async {
      useCloset([
        ..._closet,
        wardrobeItem('old', typeCode: 'SHIRT', isArchived: true),
      ]);
      final vm = build();
      final statuses = <GuMatchStatus>[];
      vm.addListener((s) => statuses.add(s.status), fireImmediately: false);

      await vm.load();

      expect(statuses.first, GuMatchStatus.loading);
      expect(vm.state.status, GuMatchStatus.loaded);
      expect(vm.state.readyCount, await wardrobe.countEligible());
      expect(vm.state.readyCount, 6);
      expect(vm.state.canStart, isTrue);
    });

    test('[TASK-004-S01] an empty wardrobe cannot start styling', () async {
      useCloset(const []);
      final vm = build();
      await vm.load();

      expect(vm.state.status, GuMatchStatus.empty);
      expect(vm.state.canStart, isFalse);

      await vm.startSwiping();
      expect(vm.state.phase, GuMatchPhase.studio);
      expect(vm.state.session, isNull);
    });

    test(
        '[TASK-004-S01] a NO_ELIGIBLE_ITEMS answer stays on the studio with a message',
        () async {
      final vm = build(scripted(startFailsWithNoItems: true));
      await vm.load();

      await vm.startSwiping();

      expect(vm.state.phase, GuMatchPhase.studio);
      expect(vm.state.errorMessage, 'Index Pieces into your Archive first.');
    });

    test('a count failure shows the error state and retry recovers', () async {
      final vm = build(scripted(failFirstCount: true));

      await vm.load();
      expect(vm.state.status, GuMatchStatus.error);
      expect(vm.state.errorMessage, isNotNull);

      await vm.retry();
      expect(vm.state.status, GuMatchStatus.loaded);
    });

    test('[TASK-004-S02] chips and prompt build the context', () async {
      final vm = build();
      await vm.load();

      vm.toggleOccasion(Occasion.coffee);
      vm.toggleOccasion(Occasion.afternoonRain);
      vm.setPrompt('x' * 300);

      expect(vm.state.context.occasions,
          {Occasion.coffee, Occasion.afternoonRain});
      expect(vm.state.context.prompt, hasLength(280));
    });

    test('[TASK-004-S02] chips or text start a prompt-led session', () async {
      final vm = await inDeck(setContext: (vm) {
        vm.toggleOccasion(Occasion.coffee);
        vm.setPrompt('coffee with friends, light rain');
      });

      expect(vm.state.session!.path, SessionPath.promptLed);
      expect(vm.state.session!.occasions, {Occasion.coffee});
      expect(vm.state.session!.prompt, 'coffee with friends, light rain');
      expect(vm.state.session!.ownedOnly, isTrue);
      expect(vm.state.session!.eligibleItemCount, 6);
    });

    test('[TASK-004-S02] no input starts a zero-input session', () async {
      final vm = await inDeck();

      expect(vm.state.session!.path, SessionPath.zeroInput);
    });
  });

  group('context analysis', () {
    test('[TASK-004-S03] cards appear as they arrive; the title waits for all',
        () async {
      final stream = StreamController<ContextCard>();
      final vm = build(scripted(contextStream: stream));
      await vm.load();

      final running = vm.startSwiping();
      await pumpEventQueue();
      expect(vm.state.phase, GuMatchPhase.analyzingContext);
      expect(vm.state.cards, isEmpty);
      expect(vm.state.contextTitle, 'Reading your context…');

      stream.add(_card[ContextCardKind.weather]!);
      await pumpEventQueue();
      expect(vm.state.cards.keys, [ContextCardKind.weather]);
      expect(vm.state.isContextComplete, isFalse);

      stream
        ..add(_card[ContextCardKind.occasion]!)
        ..add(_card[ContextCardKind.rain]!)
        ..add(_card[ContextCardKind.commute]!);
      await pumpEventQueue();
      expect(vm.state.isContextComplete, isTrue);
      expect(vm.state.contextTitle, 'Context read');

      await stream.close();
      await running;
      expect(vm.state.phase, GuMatchPhase.deck, reason: 'opens without a tap');
    });

    test('[TASK-004-S03] prompt-led context starts with YOUR REQUEST',
        () async {
      final vm = await inDeck(setContext: (vm) => vm.setPrompt('energetic'));

      final occasion = vm.state.cards[ContextCardKind.occasion]!;
      expect(occasion.label, 'YOUR REQUEST');
      expect(occasion.detail, contains('energetic'));
    });

    test("[TASK-004-S03] zero-input context starts with today's event",
        () async {
      final vm = await inDeck();

      final occasion = vm.state.cards[ContextCardKind.occasion]!;
      expect(occasion.label, 'TODAY');
      expect(occasion.headline, 'Hackathon Pitching Day');
      expect(vm.state.cards, hasLength(4));
    });

    test('[TASK-004-S10] a failed source degrades only its card', () async {
      repo = mockRepo(missing: {ContextCardKind.weather});
      final vm = await inDeck();

      expect(vm.state.cards[ContextCardKind.weather]!.isMissing, isTrue);
      expect(vm.state.cards[ContextCardKind.rain]!.isMissing, isFalse);
      expect(vm.state.isContextComplete, isTrue);
      expect(vm.state.phase, GuMatchPhase.deck);
      expect(vm.state.deck, isNotEmpty);
    });

    test('[TASK-004-S10] sources that never return are shown as missing',
        () async {
      final stream = StreamController<ContextCard>();
      final vm = build(scripted(contextStream: stream));
      await vm.load();

      final running = vm.startSwiping();
      stream.add(_card[ContextCardKind.occasion]!);
      await stream.close();
      await running;

      expect(vm.state.cards[ContextCardKind.occasion]!.isMissing, isFalse);
      for (final kind in [
        ContextCardKind.weather,
        ContextCardKind.rain,
        ContextCardKind.commute,
      ]) {
        expect(vm.state.cards[kind]!.isMissing, isTrue, reason: '$kind');
      }
      expect(vm.state.phase, GuMatchPhase.deck);
    });

    test(
        '[TASK-004-S10] no event and no calendar still builds a deck (AC-06.10)',
        () async {
      repo = mockRepo(hasCalendarEvent: false);
      final vm = await inDeck();

      expect(
          vm.state.cards[ContextCardKind.occasion]!.headline, 'No event found');
      expect(vm.state.deck, isNotEmpty);
    });
  });

  group('deck', () {
    test('[TASK-004-S04] the deck holds owned Fits and starts at 1/8',
        () async {
      final vm = await inDeck();

      expect(vm.state.deck, hasLength(8));
      expect(vm.state.currentIndex, 0);
      expect(vm.state.hudLabel, '1/8 FITS');
      final owned = _closet.map((i) => i.itemId).toSet();
      for (final look in vm.state.deck) {
        expect(owned, containsAll(look.items.map((i) => i.itemId)));
      }
    });

    test('[TASK-004-S05] Pass marks the Fit, logs it and advances', () async {
      final vm = await inDeck();
      final first = vm.state.currentCandidate!;

      await vm.pass();

      expect(vm.state.deck[0].swipeStatus, SwipeStatus.swipedLeftPassed);
      expect(vm.state.currentIndex, 1);
      expect(vm.state.hudLabel, '2/8 FITS');
      final logged = repo.interactions.single;
      expect(logged.candidateId, first.candidateId);
      expect(logged.action, CardAction.dismissPass);
      expect(logged.dwellMs, greaterThanOrEqualTo(0));
    });

    test('[TASK-004-S05] a second tap while a decision is in flight is ignored',
        () async {
      final hold = Completer<void>();
      final slow = scripted(holdInteractions: hold);
      final vm = await inDeck(repository: slow);

      final first = vm.pass();
      await pumpEventQueue();
      expect(vm.state.isBusy, isTrue);
      await vm.pass();
      hold.complete();
      await first;

      expect(vm.state.currentIndex, 1);
      expect(slow.interactions, hasLength(1));
    });

    test(
        '[TASK-004-S06] Add to Rotation asks "Wearing this today?" without advancing',
        () async {
      final vm = await inDeck();

      await vm.like();

      expect(vm.state.deck[0].swipeStatus, SwipeStatus.swipedRightLiked);
      expect(vm.state.isWearPromptVisible, isTrue);
      expect(vm.state.currentIndex, 0);
      expect(vm.state.likedCount, 1);
      expect(repo.interactions.single.action, CardAction.likeSave);
    });

    test('[TASK-004-S06] Wear today logs one wear event and advances',
        () async {
      final vm = await inDeck();
      final look = vm.state.currentCandidate!;
      await vm.like();

      await vm.confirmWearing();

      final events = await wear.getEvents();
      expect(events, hasLength(1));
      expect(events.single.itemIds.toSet(),
          look.items.map((i) => i.itemId).toSet());
      expect(events.single.wornDate, DateTime(2026, 10, 29));
      expect(events.single.candidateId, look.candidateId);
      expect(vm.state.isWearPromptVisible, isFalse);
      expect(vm.state.currentIndex, 1);
    });

    test('[TASK-004-S06] Save for later saves to the lookbook with no wear',
        () async {
      final vm = await inDeck();
      await vm.like();

      await vm.saveForLater();

      expect(vm.state.deck[0].swipeStatus, SwipeStatus.savedToLookbook);
      expect(await wear.getEvents(), isEmpty);
      expect(vm.state.currentIndex, 1);
      expect(vm.state.likedCount, 1);
    });

    test(
        '[TASK-004-S06] Pass and Add to Rotation wait for the wear prompt answer',
        () async {
      final vm = await inDeck();
      await vm.like();

      await vm.pass();
      await vm.like();

      expect(vm.state.currentIndex, 0);
      expect(repo.interactions, hasLength(1));
    });

    test(
        '[TASK-004-S06] the same Fit worn twice today is logged once (TAC-07.4)',
        () async {
      final vm = await inDeck();
      final worn =
          vm.state.currentCandidate!.items.map((i) => i.itemId).toSet();
      await vm.like();
      await vm.confirmWearing();

      // Wearing resets dormancy, so the new deck may order Fits differently:
      // pass until the same Fit comes up (the 2×2×2 closet deals all 8).
      vm.changeContext();
      await vm.startSwiping();
      while (!vm.state.currentCandidate!.items
          .map((i) => i.itemId)
          .toSet()
          .containsAll(worn)) {
        await vm.pass();
      }
      await vm.like();
      await vm.confirmWearing();

      expect(await wear.getEvents(), hasLength(1));
    });

    test(
        '[TASK-004-S07] Change context returns pre-filled and deals a new deck',
        () async {
      final vm = await inDeck(setContext: (vm) {
        vm.toggleOccasion(Occasion.date);
        vm.setPrompt('dinner');
      });
      final firstSession = vm.state.session!.sessionId;
      await vm.pass();

      vm.changeContext();

      expect(vm.state.phase, GuMatchPhase.studio);
      expect(vm.state.context.occasions, {Occasion.date});
      expect(vm.state.context.prompt, 'dinner');
      expect(vm.state.deck, isEmpty);

      await vm.startSwiping();
      expect(vm.state.session!.sessionId, isNot(firstSession));
      expect(vm.state.currentIndex, 0);
      expect(
          vm.state.deck.every((c) => c.swipeStatus == SwipeStatus.pendingSwipe),
          isTrue);
    });

    test('[TASK-004-S08] Try on shows coming soon and changes nothing',
        () async {
      final vm = await inDeck();
      final before = vm.state.currentCandidate;

      vm.tryOn();

      expect(vm.state.isTryOnNoticeVisible, isTrue);
      expect(vm.state.currentCandidate, before);
      expect(repo.interactions, isEmpty);

      vm.dismissTryOn();
      expect(vm.state.isTryOnNoticeVisible, isFalse);
    });

    test(
        '[TASK-004-S09] Adjust swaps an owned item and keeps the card undecided',
        () async {
      final vm = await inDeck();
      final look = vm.state.currentCandidate!;
      final oldShoe =
          look.items.singleWhere((i) => i.slotRole == SlotRole.footwear).itemId;

      vm.openAdjust();
      expect(vm.state.isAdjustOpen, isTrue);
      await vm.chooseSwapSlot(SlotRole.footwear);
      final options = vm.state.swapOptions.map((i) => i.itemId).toList();
      expect(options, isNot(contains(oldShoe)));
      expect(options, isNotEmpty);

      await vm.swap(options.first);

      final swapped = vm.state.currentCandidate!;
      expect(swapped.candidateId, look.candidateId);
      expect(swapped.items.map((i) => i.itemId), contains(options.first));
      expect(swapped.swipeStatus, SwipeStatus.pendingSwipe);
      expect(vm.state.currentIndex, 0);
      expect(vm.state.isAdjustOpen, isFalse);
      final logged = repo.interactions.single;
      expect(logged.action, CardAction.customizeEdit);
      expect(logged.fromItemId, oldShoe);
      expect(logged.toItemId, options.first);
    });

    test('[TASK-004-S12] deciding every card ends the deck with a summary',
        () async {
      final vm = await inDeck();

      for (var i = 0; i < 8; i++) {
        if (i.isEven) {
          await vm.like();
          await vm.saveForLater();
        } else {
          await vm.pass();
        }
      }

      expect(vm.state.phase, GuMatchPhase.endOfDeck);
      expect(vm.state.likedCount, 4);
    });

    test('[TASK-004-S12] a short deck shows its real total and a hint',
        () async {
      useCloset([_closet[0], _closet[2], _closet[4]]);
      final vm = await inDeck();

      expect(vm.state.deck, hasLength(1));
      expect(vm.state.hudLabel, '1/1 FITS');
      expect(vm.state.deckHint, isNotNull);
    });

    test(
        '[TASK-004-S12] no complete Fit shows the no-Fits state with the missing group',
        () async {
      useCloset([_closet[0], _closet[2]]);
      final vm = await inDeck();

      expect(vm.state.deck, isEmpty);
      expect(vm.state.phase, GuMatchPhase.noFits);
      expect(vm.state.deckHint, 'Index a pair of shoes to unlock more Fits');
    });
  });
}
