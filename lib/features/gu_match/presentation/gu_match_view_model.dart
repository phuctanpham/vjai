import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../data/gu_match_repository.dart';
import '../domain/occasion.dart';
import '../domain/slot_role.dart';
import 'gu_match_state.dart';

/// Provider for GuMatchViewModel. Kept alive so Change context can pre-fill.
final guMatchViewModelProvider =
    StateNotifierProvider<GuMatchViewModel, GuMatchState>((ref) {
  throw UnimplementedError('TASK-004-S01');
});

/// ViewModel for Flow B: studio, context analysis, deck.
class GuMatchViewModel extends StateNotifier<GuMatchState> {
  GuMatchViewModel({
    required GuMatchRepository repository,
    required Clock clock,
  }) : super(GuMatchState.initial());

  /// Loads the ready count (loaded, or empty when N = 0).
  Future<void> load() => throw UnimplementedError('TASK-004-S01');

  Future<void> retry() => throw UnimplementedError('TASK-004-S01');

  void toggleOccasion(Occasion occasion) =>
      throw UnimplementedError('TASK-004-S02');

  void setPrompt(String prompt) => throw UnimplementedError('TASK-004-S02');

  /// Starts a session, reveals context cards as they arrive, then builds the
  /// deck and opens it. Completes when the deck is showing. Ignored unless
  /// [GuMatchState.canStart].
  Future<void> startSwiping() => throw UnimplementedError('TASK-004-S03');

  /// × or swipe left.
  Future<void> pass() => throw UnimplementedError('TASK-004-S05');

  /// "Add to Rotation" or swipe right (`CardAction.likeSave`): marks the Fit
  /// `swipedRightLiked` and asks "Wearing this today?".
  Future<void> like() => throw UnimplementedError('TASK-004-S06');

  /// "Wear today": logs the wear (once per Fit per day) and advances.
  Future<void> confirmWearing() => throw UnimplementedError('TASK-004-S06');

  /// "Save for later": saves to the lookbook without a wear, and advances.
  Future<void> saveForLater() => throw UnimplementedError('TASK-004-S06');

  /// Back to the studio with the context pre-filled.
  void changeContext() => throw UnimplementedError('TASK-004-S07');

  /// Phase 1: shows "Try-on is coming soon"; nothing is rendered.
  void tryOn() => throw UnimplementedError('TASK-004-S08');

  void dismissTryOn() => throw UnimplementedError('TASK-004-S08');

  /// Opens the Adjust sheet (items by slot, each with Swap).
  void openAdjust() => throw UnimplementedError('TASK-004-S09');

  /// Loads the swap options for [slot].
  Future<void> chooseSwapSlot(SlotRole slot) =>
      throw UnimplementedError('TASK-004-S09');

  /// Swaps the chosen slot to [itemId]; the card stays undecided.
  Future<void> swap(String itemId) => throw UnimplementedError('TASK-004-S09');

  void closeAdjust() => throw UnimplementedError('TASK-004-S09');
}
