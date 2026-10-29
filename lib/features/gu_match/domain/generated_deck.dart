import 'package:flutter/foundation.dart';

import '../../wardrobe/domain/item_group.dart';
import 'outfit_candidate.dart';

/// A session's deck and, when it is short, the group that would unlock more.
@immutable
class GeneratedDeck {
  /// The session deck size (C11).
  static const int deckSize = 8;

  final List<OutfitCandidate> candidates;

  /// Set when fewer than [deckSize] Fits are possible.
  final ItemGroup? hintGroup;

  const GeneratedDeck({required this.candidates, this.hintGroup});

  /// e.g. "Index a pair of shoes to unlock more Fits"; null for a full deck.
  String? get missingHint => throw UnimplementedError('TASK-004-S12');
}
