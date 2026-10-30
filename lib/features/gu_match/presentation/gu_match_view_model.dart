import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/time/clock.dart';
import '../data/gu_match_repository.dart';
import '../domain/context_card.dart';
import '../domain/interaction.dart';
import '../domain/occasion.dart';
import '../domain/outfit_candidate.dart';
import '../domain/slot_role.dart';
import '../domain/swipe_status.dart';
import 'gu_match_state.dart';

/// Provider for GuMatchViewModel. Kept alive so Change context can pre-fill.
final guMatchViewModelProvider =
    StateNotifierProvider<GuMatchViewModel, GuMatchState>((ref) {
  return GuMatchViewModel(
    repository: ref.watch(guMatchRepositoryProvider),
    clock: ref.watch(clockProvider),
  )..load();
});

/// ViewModel for Flow B: studio, context analysis, deck. It drafts Fits from
/// the user's own Pieces; every decision is about a Fit, never a person.
class GuMatchViewModel extends StateNotifier<GuMatchState> {
  final GuMatchRepository _repository;
  final Clock _clock;

  /// When the current card was shown, for the interaction's dwell time.
  DateTime? _shownAt;

  GuMatchViewModel({
    required GuMatchRepository repository,
    required Clock clock,
  })  : _repository = repository,
        _clock = clock,
        super(GuMatchState.initial());

  /// Restores the studio draft and, when the latest session still has
  /// undecided Fits, reopens its deck at the first one (TASK-005-S03).
  Future<void> restore() async {
    await load();
    if (!mounted) return;
    try {
      final draft = await _repository.loadContextDraft();
      final snapshot = await _repository.loadLatestSession();
      if (!mounted) return;
      state = state.copyWith(context: draft);
      final fits = snapshot?.candidates ?? const <OutfitCandidate>[];
      final next =
          fits.indexWhere((c) => c.swipeStatus == SwipeStatus.pendingSwipe);
      if (snapshot == null || next < 0) return;
      _shownAt = _clock.now();
      state = state.copyWith(
        phase: GuMatchPhase.deck,
        session: snapshot.session,
        cards: {
          for (final kind in ContextCardKind.values)
            kind: ContextCard.missing(kind),
        },
        isContextComplete: true,
        deck: fits,
        currentIndex: next,
        likedCount: fits
            .where((c) =>
                c.swipeStatus == SwipeStatus.swipedRightLiked ||
                c.swipeStatus == SwipeStatus.savedToLookbook)
            .length,
      );
    } on Failure {
      // Nothing to restore: the studio opens fresh.
    }
  }

  /// Loads the ready count (loaded, or empty when N = 0).
  Future<void> load() async {
    state = state.copyWith(status: GuMatchStatus.loading, clearError: true);
    try {
      final count = await _repository.readyItemCount();
      if (!mounted) return;
      state = state.copyWith(
        status: count == 0 ? GuMatchStatus.empty : GuMatchStatus.loaded,
        readyCount: count,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        status: GuMatchStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  Future<void> retry() => load();

  void toggleOccasion(Occasion occasion) {
    if (state.phase != GuMatchPhase.studio) return;
    state = state.copyWith(context: state.context.toggle(occasion));
    _saveDraft();
  }

  void setPrompt(String prompt) {
    if (state.phase != GuMatchPhase.studio) return;
    state = state.copyWith(context: state.context.withPrompt(prompt));
    _saveDraft();
  }

  /// Keeps the chips and prompt between launches. Best effort.
  void _saveDraft() {
    unawaited(
        _repository.saveContextDraft(state.context).catchError((Object _) {}));
  }

  /// Starts a session, reveals context cards as they arrive, then builds the
  /// deck and opens it. Completes when the deck is showing. Ignored unless
  /// [GuMatchState.canStart].
  Future<void> startSwiping() async {
    if (!state.canStart) return;
    state = state.copyWith(isBusy: true, clearError: true);

    try {
      final session = await _repository.startSession(state.context);
      if (!mounted) return;
      state = state.copyWith(
        session: session,
        phase: GuMatchPhase.analyzingContext,
        cards: const {},
        isContextComplete: false,
        deck: const [],
        currentIndex: 0,
        likedCount: 0,
        clearDeckHint: true,
      );

      try {
        await for (final card in _repository.gatherContext(session)) {
          final cards = {...state.cards, card.kind: card};
          state = state.copyWith(
            cards: cards,
            isContextComplete: cards.length == ContextCardKind.values.length,
          );
        }
      } on Failure {
        // A failed source only degrades its own card (AC-06.9).
      }
      state = state.copyWith(
        cards: {
          for (final kind in ContextCardKind.values)
            kind: state.cards[kind] ?? ContextCard.missing(kind),
        },
        isContextComplete: true,
      );

      final deck = await _repository.buildDeck(session);
      if (!mounted) return;
      _shownAt = _clock.now();
      state = state.copyWith(
        phase:
            deck.candidates.isEmpty ? GuMatchPhase.noFits : GuMatchPhase.deck,
        deck: deck.candidates,
        deckHint: deck.missingHint,
        clearDeckHint: deck.missingHint == null,
        isBusy: false,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        phase: GuMatchPhase.studio,
        clearSession: true,
        isBusy: false,
        errorMessage: failure.message,
      );
    }
  }

  /// × or swipe left.
  Future<void> pass() async {
    final candidate = _decidable;
    if (candidate == null) return;
    state = state.copyWith(isBusy: true);
    await _record(candidate, CardAction.dismissPass);
    _setStatus(SwipeStatus.swipedLeftPassed);
    _advance();
  }

  /// "Add to Rotation" or swipe right (`CardAction.likeSave`): marks the Fit
  /// `swipedRightLiked` and asks "Wearing this today?".
  Future<void> like() async {
    final candidate = _decidable;
    if (candidate == null) return;
    state = state.copyWith(isBusy: true);
    await _record(candidate, CardAction.likeSave);
    _setStatus(SwipeStatus.swipedRightLiked);
    state = state.copyWith(
      likedCount: state.likedCount + 1,
      isWearPromptVisible: true,
      isBusy: false,
    );
  }

  /// "Wear today": logs the wear (once per Fit per day) and advances.
  Future<void> confirmWearing() async {
    final candidate = state.currentCandidate;
    if (candidate == null || !state.isWearPromptVisible || state.isBusy) {
      return;
    }
    state = state.copyWith(isBusy: true);
    try {
      // false means this Fit is already logged today: not an error.
      await _repository.confirmWearing(candidate);
    } on Failure catch (failure) {
      state = state.copyWith(isBusy: false, errorMessage: failure.message);
      return;
    }
    state = state.copyWith(isWearPromptVisible: false);
    _advance();
  }

  /// "Save for later": saves to the lookbook without a wear, and advances.
  Future<void> saveForLater() async {
    if (state.currentCandidate == null ||
        !state.isWearPromptVisible ||
        state.isBusy) {
      return;
    }
    _setStatus(SwipeStatus.savedToLookbook);
    state = state.copyWith(isWearPromptVisible: false);
    _advance();
  }

  /// Back to the studio with the context pre-filled.
  void changeContext() {
    state = state.copyWith(
      phase: GuMatchPhase.studio,
      clearSession: true,
      cards: const {},
      isContextComplete: false,
      deck: const [],
      currentIndex: 0,
      clearDeckHint: true,
      isWearPromptVisible: false,
      isTryOnNoticeVisible: false,
      isAdjustOpen: false,
      clearAdjustSlot: true,
      swapOptions: const [],
      isBusy: false,
      clearError: true,
    );
  }

  /// Phase 1: shows "Try-on is coming soon"; nothing is rendered.
  void tryOn() {
    if (state.currentCandidate == null) return;
    state = state.copyWith(isTryOnNoticeVisible: true);
  }

  void dismissTryOn() {
    state = state.copyWith(isTryOnNoticeVisible: false);
  }

  /// Opens the Adjust sheet (Pieces by slot, each with Swap).
  void openAdjust() {
    if (_decidable == null) return;
    state = state.copyWith(
      isAdjustOpen: true,
      clearAdjustSlot: true,
      swapOptions: const [],
    );
  }

  /// Loads the swap options for [slot].
  Future<void> chooseSwapSlot(SlotRole slot) async {
    final candidate = state.currentCandidate;
    if (candidate == null || !state.isAdjustOpen) return;
    final options = await _repository.swapOptions(candidate, slot);
    state = state.copyWith(adjustSlot: slot, swapOptions: options);
  }

  /// Swaps the chosen slot to [itemId]; the card stays undecided.
  Future<void> swap(String itemId) async {
    final candidate = state.currentCandidate;
    final slot = state.adjustSlot;
    if (candidate == null || slot == null || state.isBusy) return;

    final fromItemId =
        candidate.items.firstWhere((i) => i.slotRole == slot).itemId;
    state = state.copyWith(isBusy: true);
    try {
      final updated = await _repository.swapItem(candidate, slot, itemId);
      await _record(
        candidate,
        CardAction.customizeEdit,
        fromItemId: fromItemId,
        toItemId: itemId,
      );
      state = state.copyWith(
        deck: [
          for (final c in state.deck)
            c.candidateId == updated.candidateId ? updated : c,
        ],
      );
    } on ArgumentError {
      state = state.copyWith(errorMessage: "That Piece can't go in this slot.");
    }
    closeAdjust();
    state = state.copyWith(isBusy: false);
  }

  void closeAdjust() {
    state = state.copyWith(
      isAdjustOpen: false,
      clearAdjustSlot: true,
      swapOptions: const [],
    );
  }

  /// The current Fit when a pass or add can be decided now.
  OutfitCandidate? get _decidable {
    if (state.isBusy || state.isWearPromptVisible || state.isAdjustOpen) {
      return null;
    }
    return state.currentCandidate;
  }

  Future<void> _record(
    OutfitCandidate candidate,
    CardAction action, {
    String? fromItemId,
    String? toItemId,
  }) {
    final shownAt = _shownAt ?? _clock.now();
    final dwell = _clock.now().difference(shownAt).inMilliseconds;
    return _repository.recordInteraction(Interaction(
      candidateId: candidate.candidateId,
      action: action,
      dwellMs: dwell < 0 ? 0 : dwell,
      fromItemId: fromItemId,
      toItemId: toItemId,
    ));
  }

  /// Records the decision on the current Fit and saves it, so the deck
  /// resumes after a restart (TASK-005-S03). The save is issued at once.
  void _setStatus(SwipeStatus status) {
    final index = state.currentIndex;
    if (index < state.deck.length) {
      unawaited(_repository
          .updateSwipeStatus(state.deck[index].candidateId, status)
          .catchError((Object _) {}));
    }
    state = state.copyWith(
      deck: [
        for (var i = 0; i < state.deck.length; i++)
          i == index
              ? state.deck[i].copyWith(swipeStatus: status)
              : state.deck[i],
      ],
    );
  }

  void _advance() {
    final next = state.currentIndex + 1;
    _shownAt = _clock.now();
    state = state.copyWith(
      currentIndex: next,
      phase: next >= state.deck.length ? GuMatchPhase.endOfDeck : null,
      isBusy: false,
    );
  }
}
