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

  factory GuMatchState.initial() => throw UnimplementedError('TASK-004-S01');

  /// N ≥ 1, on the studio, nothing in flight.
  bool get canStart => throw UnimplementedError('TASK-004-S01');

  OutfitCandidate? get currentCandidate =>
      throw UnimplementedError('TASK-004-S05');

  /// "{k}/{N} FITS" (T7 › G4).
  String get hudLabel => throw UnimplementedError('TASK-004-S05');

  /// "Reading your context…" until every card is in, then "Context read"
  /// (T7 › G3 2b).
  String get contextTitle => throw UnimplementedError('TASK-004-S03');

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
  }) =>
      throw UnimplementedError('TASK-004-S01');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-004-S01');

  @override
  int get hashCode => throw UnimplementedError('TASK-004-S01');
}
