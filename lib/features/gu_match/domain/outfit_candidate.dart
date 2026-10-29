import 'package:flutter/foundation.dart';

import 'slot_role.dart';
import 'swipe_status.dart';
import 'visual_mode.dart';

/// One owned Piece placed in a Fit.
@immutable
class CandidateItem {
  final SlotRole slotRole;
  final String itemId;
  final String name;
  final int daysUnworn;

  const CandidateItem({
    required this.slotRole,
    required this.itemId,
    required this.name,
    required this.daysUnworn,
  });

  Map<String, dynamic> toJson() => {
        'slot_role': slotRole.name.toUpperCase(),
        'item_id': itemId,
        'name': name,
        'days_unworn': daysUnworn,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CandidateItem &&
          slotRole == other.slotRole &&
          itemId == other.itemId &&
          name == other.name &&
          daysUnworn == other.daysUnworn;

  @override
  int get hashCode => Object.hash(slotRole, itemId, name, daysUnworn);
}

/// One Fit on the 3b deck, drafted only from the user's own Pieces. Carries
/// no commerce fields (AC-07.10, TAC-07.6).
@immutable
class OutfitCandidate {
  final String candidateId;

  /// 1-based position in the deck.
  final int deckOrder;
  final String title;

  /// How well the Fit suits the day, 0..100 (shown as "82% FIT").
  final int matchPct;

  /// At most one reason, e.g. "Benched 41 days · Violet shirt" (T7 › G3 3b).
  final String? highlightReason;
  final VisualMode visualMode;
  final SwipeStatus swipeStatus;
  final List<CandidateItem> items;

  const OutfitCandidate({
    required this.candidateId,
    required this.deckOrder,
    required this.title,
    required this.matchPct,
    required this.visualMode,
    required this.swipeStatus,
    required this.items,
    this.highlightReason,
  });

  OutfitCandidate copyWith({
    int? matchPct,
    String? highlightReason,
    bool clearHighlight = false,
    SwipeStatus? swipeStatus,
    List<CandidateItem>? items,
  }) {
    return OutfitCandidate(
      candidateId: candidateId,
      deckOrder: deckOrder,
      title: title,
      matchPct: matchPct ?? this.matchPct,
      highlightReason:
          clearHighlight ? null : (highlightReason ?? this.highlightReason),
      visualMode: visualMode,
      swipeStatus: swipeStatus ?? this.swipeStatus,
      items: items ?? this.items,
    );
  }

  /// Wire shape (snake_case, as in the spec's candidates API contract).
  Map<String, dynamic> toJson() => {
        'candidate_id': candidateId,
        'deck_order': deckOrder,
        'title': title,
        'match_pct': matchPct,
        'highlight_reason': highlightReason,
        'visual_mode': visualMode.wireName,
        'visual_label': visualMode.label,
        'swipe_status': swipeStatus.name,
        'items': [for (final item in items) item.toJson()],
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutfitCandidate &&
          candidateId == other.candidateId &&
          deckOrder == other.deckOrder &&
          title == other.title &&
          matchPct == other.matchPct &&
          highlightReason == other.highlightReason &&
          visualMode == other.visualMode &&
          swipeStatus == other.swipeStatus &&
          listEquals(items, other.items);

  @override
  int get hashCode => Object.hash(candidateId, deckOrder, title, matchPct,
      highlightReason, visualMode, swipeStatus, Object.hashAll(items));
}
