import 'package:flutter/foundation.dart';

import '../../wardrobe/domain/wardrobe_item.dart';
import '../domain/context_card.dart';
import '../domain/gu_match_session.dart';
import '../domain/outfit_candidate.dart';
import '../domain/slot_role.dart';
import '../domain/styling_context.dart';

/// Status of loading the "{N} PIECES READY" count.
enum GuMatchStatus {
  initial,
  loading,
  loaded,

  /// No usable item (N = 0).
  empty,
  error,
}

/// Which Gu Match screen is showing.
enum GuMatchPhase {
  /// 1b styling studio.
  studio,

  /// 2b context analysis.
  analyzingContext,

  /// 3b deck.
  deck,

  /// Every card decided.
  endOfDeck,

  /// No complete Fit is possible (a top, bottom or shoes is missing).
  noFits,
}

/// State of one Gu Match flow (1b → 2b → 3b).
@immutable
class GuMatchState {
  final GuMatchStatus status;
  final int readyCount;
  final StylingContext context;
  final GuMatchPhase phase;
  final GuMatchSession? session;
  final Map<ContextCardKind, ContextCard> cards;
  final bool isContextComplete;
  final List<OutfitCandidate> deck;
  final int currentIndex;

  /// Shown for a short deck or no Fits, e.g.
  /// "Index a pair of shoes to unlock more Fits".
  final String? deckHint;
  final bool isWearPromptVisible;
  final bool isTryOnNoticeVisible;
  final bool isAdjustOpen;
  final SlotRole? adjustSlot;
  final List<WardrobeItem> swapOptions;
  final int likedCount;

  /// A decision or request is in flight; further taps are ignored.
  final bool isBusy;
  final String? errorMessage;

  const GuMatchState({
    required this.status,
    required this.readyCount,
    required this.context,
    required this.phase,
    required this.cards,
    required this.isContextComplete,
    required this.deck,
    required this.currentIndex,
    required this.isWearPromptVisible,
    required this.isTryOnNoticeVisible,
    required this.isAdjustOpen,
    required this.swapOptions,
    required this.likedCount,
    required this.isBusy,
    this.session,
    this.deckHint,
    this.adjustSlot,
    this.errorMessage,
  });

  factory GuMatchState.initial() => const GuMatchState(
        status: GuMatchStatus.initial,
        readyCount: 0,
        context: StylingContext(),
        phase: GuMatchPhase.studio,
        cards: {},
        isContextComplete: false,
        deck: [],
        currentIndex: 0,
        isWearPromptVisible: false,
        isTryOnNoticeVisible: false,
        isAdjustOpen: false,
        swapOptions: [],
        likedCount: 0,
        isBusy: false,
      );

  /// N ≥ 1, on the studio, nothing in flight.
  bool get canStart =>
      status == GuMatchStatus.loaded &&
      readyCount > 0 &&
      phase == GuMatchPhase.studio &&
      !isBusy;

  OutfitCandidate? get currentCandidate =>
      phase == GuMatchPhase.deck && currentIndex < deck.length
          ? deck[currentIndex]
          : null;

  /// "{k}/{N} FITS" (T7 › G4).
  String get hudLabel {
    final shown = deck.isEmpty ? 0 : (currentIndex + 1).clamp(1, deck.length);
    return '$shown/${deck.length} FITS';
  }

  /// "Reading your context…" until every card is in, then "Context read"
  /// (T7 › G3 2b).
  String get contextTitle =>
      isContextComplete ? 'Context read' : 'Reading your context…';

  GuMatchState copyWith({
    GuMatchStatus? status,
    int? readyCount,
    StylingContext? context,
    GuMatchPhase? phase,
    GuMatchSession? session,
    bool clearSession = false,
    Map<ContextCardKind, ContextCard>? cards,
    bool? isContextComplete,
    List<OutfitCandidate>? deck,
    int? currentIndex,
    String? deckHint,
    bool clearDeckHint = false,
    bool? isWearPromptVisible,
    bool? isTryOnNoticeVisible,
    bool? isAdjustOpen,
    SlotRole? adjustSlot,
    bool clearAdjustSlot = false,
    List<WardrobeItem>? swapOptions,
    int? likedCount,
    bool? isBusy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GuMatchState(
      status: status ?? this.status,
      readyCount: readyCount ?? this.readyCount,
      context: context ?? this.context,
      phase: phase ?? this.phase,
      session: clearSession ? null : (session ?? this.session),
      cards: cards ?? this.cards,
      isContextComplete: isContextComplete ?? this.isContextComplete,
      deck: deck ?? this.deck,
      currentIndex: currentIndex ?? this.currentIndex,
      deckHint: clearDeckHint ? null : (deckHint ?? this.deckHint),
      isWearPromptVisible: isWearPromptVisible ?? this.isWearPromptVisible,
      isTryOnNoticeVisible: isTryOnNoticeVisible ?? this.isTryOnNoticeVisible,
      isAdjustOpen: isAdjustOpen ?? this.isAdjustOpen,
      adjustSlot: clearAdjustSlot ? null : (adjustSlot ?? this.adjustSlot),
      swapOptions: swapOptions ?? this.swapOptions,
      likedCount: likedCount ?? this.likedCount,
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GuMatchState &&
          status == other.status &&
          readyCount == other.readyCount &&
          context == other.context &&
          phase == other.phase &&
          session == other.session &&
          mapEquals(cards, other.cards) &&
          isContextComplete == other.isContextComplete &&
          listEquals(deck, other.deck) &&
          currentIndex == other.currentIndex &&
          deckHint == other.deckHint &&
          isWearPromptVisible == other.isWearPromptVisible &&
          isTryOnNoticeVisible == other.isTryOnNoticeVisible &&
          isAdjustOpen == other.isAdjustOpen &&
          adjustSlot == other.adjustSlot &&
          listEquals(swapOptions, other.swapOptions) &&
          likedCount == other.likedCount &&
          isBusy == other.isBusy &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hashAll([
        status,
        readyCount,
        context,
        phase,
        session,
        Object.hashAllUnordered(
            cards.entries.map((e) => Object.hash(e.key, e.value))),
        isContextComplete,
        Object.hashAll(deck),
        currentIndex,
        deckHint,
        isWearPromptVisible,
        isTryOnNoticeVisible,
        isAdjustOpen,
        adjustSlot,
        Object.hashAll(swapOptions),
        likedCount,
        isBusy,
        errorMessage,
      ]);
}
