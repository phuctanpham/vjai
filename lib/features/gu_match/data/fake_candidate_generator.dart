import '../../wardrobe/domain/wardrobe_item.dart';
import '../domain/generated_deck.dart';
import '../domain/outfit_candidate.dart';
import '../domain/slot_role.dart';
import '../domain/styling_context.dart';

/// Phase 1 stand-in for the deck generator (spec T6 P1, CHG-003 A-03).
/// Not a product rule: it sits behind `GuMatchRepository` and is replaced by
/// the server's rule-based generator in P4 and the ranked generator in P5.
///
/// A Fit is one top + one bottom + one pair of shoes, from non-archived
/// Pieces only (I6). Fits are ordered most-dormant first, then by item IDs,
/// so the same input always gives the same deck, at most
/// [GeneratedDeck.deckSize]. Match % is
/// `70 + round(0.3 × days unworn of the least-recently-worn Piece)`, capped
/// at 95 (41 days → 82%, the spec demo). Images are flat-lay collages
/// (`VisualMode.collageFlatlay`, "WARDROBE PHOTO"). Items missing from
/// `daysUnworn` count as 0 days. Candidate IDs are `<sessionId>_cand_<order>`.
/// The highlight reason, for a Piece benched 30+ days, is
/// "Benched {d} days · {Piece name}" (T7 › G3 3b). A short deck hints at the
/// missing group, else at the smallest of tops, bottoms and shoes.
class FakeCandidateGenerator {
  static const int dormancyReasonDays = 30;

  const FakeCandidateGenerator();

  GeneratedDeck generate({
    required String sessionId,
    required List<WardrobeItem> items,
    required Map<String, int> daysUnworn,
    required StylingContext context,
  }) =>
      throw UnimplementedError('TASK-004-S04');

  /// Match % for a Fit's items.
  int scoreLook(List<CandidateItem> items) =>
      throw UnimplementedError('TASK-004-S09');

  /// Other owned, non-archived Pieces that can fill [slot] (AC-08.3).
  List<WardrobeItem> swapOptions({
    required OutfitCandidate candidate,
    required SlotRole slot,
    required List<WardrobeItem> items,
  }) =>
      throw UnimplementedError('TASK-004-S09');

  /// Replaces the Piece in [slot] and recalculates match % and reason.
  /// Throws [ArgumentError] unless [replacement] is one of [items], is not
  /// archived, and belongs to the slot's group (TAC-08.6).
  OutfitCandidate swap({
    required OutfitCandidate candidate,
    required SlotRole slot,
    required WardrobeItem replacement,
    required List<WardrobeItem> items,
    required int replacementDaysUnworn,
  }) =>
      throw UnimplementedError('TASK-004-S09');
}
