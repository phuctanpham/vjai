import 'dart:math' as math;

import '../../wardrobe/domain/item_group.dart';
import '../../wardrobe/domain/wardrobe_item.dart';
import '../domain/generated_deck.dart';
import '../domain/occasion.dart';
import '../domain/outfit_candidate.dart';
import '../domain/slot_role.dart';
import '../domain/styling_context.dart';
import '../domain/swipe_status.dart';
import '../domain/visual_mode.dart';

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
  static const int _baseMatchPct = 70;
  static const int _maxMatchPct = 95;

  /// The groups a Fit needs, in slot order.
  static const List<ItemGroup> _fitGroups = [
    ItemGroup.tops,
    ItemGroup.bottoms,
    ItemGroup.shoes,
  ];

  const FakeCandidateGenerator();

  GeneratedDeck generate({
    required String sessionId,
    required List<WardrobeItem> items,
    required Map<String, int> daysUnworn,
    required StylingContext context,
  }) {
    int days(WardrobeItem item) => daysUnworn[item.itemId] ?? 0;
    final byGroup = {
      for (final group in _fitGroups)
        group: items.where((i) => !i.isArchived && i.group == group).toList()
          ..sort((a, b) => a.itemId.compareTo(b.itemId)),
    };

    final looks = [
      for (final top in byGroup[ItemGroup.tops]!)
        for (final bottom in byGroup[ItemGroup.bottoms]!)
          for (final shoes in byGroup[ItemGroup.shoes]!)
            [
              for (final (slot, item) in [
                (SlotRole.top, top),
                (SlotRole.bottom, bottom),
                (SlotRole.footwear, shoes),
              ])
                CandidateItem(
                  slotRole: slot,
                  itemId: item.itemId,
                  name: item.name,
                  daysUnworn: days(item),
                ),
            ],
    ]..sort((a, b) {
        final byDormancy = _maxDays(b).compareTo(_maxDays(a));
        if (byDormancy != 0) return byDormancy;
        for (var i = 0; i < a.length; i++) {
          final byId = a[i].itemId.compareTo(b[i].itemId);
          if (byId != 0) return byId;
        }
        return 0;
      });

    final candidates = [
      for (final (index, look) in looks.take(GeneratedDeck.deckSize).indexed)
        OutfitCandidate(
          candidateId: '${sessionId}_cand_${index + 1}',
          deckOrder: index + 1,
          title: _title(look, items, context),
          matchPct: scoreLook(look),
          highlightReason: _highlightReason(look),
          visualMode: VisualMode.collageFlatlay,
          swipeStatus: SwipeStatus.pendingSwipe,
          items: List.unmodifiable(look),
        ),
    ];

    return GeneratedDeck(
      candidates: List.unmodifiable(candidates),
      hintGroup:
          looks.length < GeneratedDeck.deckSize ? _hintGroup(byGroup) : null,
    );
  }

  /// Match % for a Fit's items.
  int scoreLook(List<CandidateItem> items) => math.min(
        _maxMatchPct,
        _baseMatchPct + (0.3 * _maxDays(items)).round(),
      );

  /// Other owned, non-archived Pieces that can fill [slot] (AC-08.3).
  List<WardrobeItem> swapOptions({
    required OutfitCandidate candidate,
    required SlotRole slot,
    required List<WardrobeItem> items,
  }) {
    final inFit = candidate.items.map((i) => i.itemId).toSet();
    return items
        .where((i) =>
            !i.isArchived && i.group == slot.group && !inFit.contains(i.itemId))
        .toList()
      ..sort((a, b) => a.itemId.compareTo(b.itemId));
  }

  /// Replaces the Piece in [slot] and recalculates match % and reason.
  /// Throws [ArgumentError] unless [replacement] is one of [items], is not
  /// archived, and belongs to the slot's group (TAC-08.6).
  OutfitCandidate swap({
    required OutfitCandidate candidate,
    required SlotRole slot,
    required WardrobeItem replacement,
    required List<WardrobeItem> items,
    required int replacementDaysUnworn,
  }) {
    final owned = items.any((i) => i.itemId == replacement.itemId);
    if (!owned) {
      throw ArgumentError.value(
          replacement.itemId, 'replacement', 'Not in the Archive');
    }
    if (replacement.isArchived) {
      throw ArgumentError.value(
          replacement.itemId, 'replacement', 'Archived Piece');
    }
    if (replacement.group != slot.group) {
      throw ArgumentError.value(
          replacement.itemId, 'replacement', 'Wrong group for ${slot.name}');
    }

    final look = [
      for (final item in candidate.items)
        item.slotRole == slot
            ? CandidateItem(
                slotRole: slot,
                itemId: replacement.itemId,
                name: replacement.name,
                daysUnworn: replacementDaysUnworn,
              )
            : item,
    ];
    final reason = _highlightReason(look);
    return candidate.copyWith(
      items: List.unmodifiable(look),
      matchPct: scoreLook(look),
      highlightReason: reason,
      clearHighlight: reason == null,
    );
  }

  static int _maxDays(List<CandidateItem> items) =>
      items.fold(0, (most, item) => math.max(most, item.daysUnworn));

  static String? _highlightReason(List<CandidateItem> look) {
    CandidateItem? mostBenched;
    for (final item in look) {
      if (mostBenched == null || item.daysUnworn > mostBenched.daysUnworn) {
        mostBenched = item;
      }
    }
    if (mostBenched == null || mostBenched.daysUnworn < dormancyReasonDays) {
      return null;
    }
    return 'Benched ${mostBenched.daysUnworn} days · ${mostBenched.name}';
  }

  /// Template title, e.g. "Violet for coffee" (LLM naming is P5, AI-003).
  static String _title(
    List<CandidateItem> look,
    List<WardrobeItem> items,
    StylingContext context,
  ) {
    final topId = look.first.itemId;
    final color = items.firstWhere((i) => i.itemId == topId).color;
    if (context.occasions.isEmpty) return '$color for every day';
    final occasion = Occasion.values.firstWhere(context.occasions.contains);
    return '$color for ${occasion.label.toLowerCase()}';
  }

  static ItemGroup _hintGroup(Map<ItemGroup, List<WardrobeItem>> byGroup) {
    var hint = _fitGroups.first;
    for (final group in _fitGroups) {
      if (byGroup[group]!.length < byGroup[hint]!.length) hint = group;
    }
    return hint;
  }
}
