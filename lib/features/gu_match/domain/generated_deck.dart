import 'package:flutter/foundation.dart';

import '../../wardrobe/domain/item_group.dart';
import 'outfit_candidate.dart';

/// A session's deck of Fits and, when it is short, the group that would
/// unlock more.
@immutable
class GeneratedDeck {
  /// The session deck size (C11).
  static const int deckSize = 8;

  final List<OutfitCandidate> candidates;

  /// Set when fewer than [deckSize] Fits are possible.
  final ItemGroup? hintGroup;

  const GeneratedDeck({required this.candidates, this.hintGroup});

  /// e.g. "Index a pair of shoes to unlock more Fits"; null for a full deck.
  String? get missingHint => switch (hintGroup) {
        null => null,
        ItemGroup.shoes => 'Index a pair of shoes to unlock more Fits',
        ItemGroup.tops => 'Index a top to unlock more Fits',
        ItemGroup.bottoms => 'Index a pair of bottoms to unlock more Fits',
        final group =>
          'Index more ${group.label.toLowerCase()} to unlock more Fits',
      };
}
