import 'package:flutter/foundation.dart';

import 'slot_role.dart';
import 'swipe_status.dart';
import 'visual_mode.dart';

/// One owned item placed in a look.
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

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-004-S04');

  @override
  int get hashCode => throw UnimplementedError('TASK-004-S04');
}

/// One look on the 3b deck. Carries no commerce fields (AC-07.10, TAC-07.6).
@immutable
class OutfitCandidate {
  final String candidateId;

  /// 1-based position in the deck.
  final int deckOrder;
  final String title;

  /// 0..100.
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
  }) =>
      throw UnimplementedError('TASK-004-S05');

  /// Wire shape (snake_case, as in the spec's candidates API contract).
  Map<String, dynamic> toJson() => throw UnimplementedError('TASK-004-S04');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-004-S04');

  @override
  int get hashCode => throw UnimplementedError('TASK-004-S04');
}
