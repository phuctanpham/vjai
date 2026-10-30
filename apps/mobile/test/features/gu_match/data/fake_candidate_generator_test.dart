import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/gu_match/data/fake_candidate_generator.dart';
import 'package:garblo/features/gu_match/domain/generated_deck.dart';
import 'package:garblo/features/gu_match/domain/outfit_candidate.dart';
import 'package:garblo/features/gu_match/domain/slot_role.dart';
import 'package:garblo/features/gu_match/domain/styling_context.dart';
import 'package:garblo/features/gu_match/domain/swipe_status.dart';
import 'package:garblo/features/gu_match/domain/visual_mode.dart';
import 'package:garblo/features/wardrobe/domain/item_group.dart';
import 'package:garblo/features/wardrobe/domain/wardrobe_item.dart';

import '../../../helpers/wardrobe_fixtures.dart';

// [fake-generator] Phase 1 stand-in (CHG-003 A-03), not a product rule.
// It sits behind GuMatchRepository and is replaced in P4/P5. The product
// rules it must keep (I6 owned-only, TAC-08.6 swaps, AC-07.10 no commerce)
// carry their scenario IDs so the real generator inherits the same checks.

const _generator = FakeCandidateGenerator();

final _violet = wardrobeItem('violet', name: 'Violet shirt', typeCode: 'SHIRT');
final _tee = wardrobeItem('tee', name: 'White T-shirt', typeCode: 'T_SHIRT');
final _wide = wardrobeItem('wide',
    name: 'Wide-leg trousers', typeCode: 'WIDE_LEG_TROUSERS');
final _jeans = wardrobeItem('jeans', name: 'Black jeans', typeCode: 'JEANS');
final _sneakers =
    wardrobeItem('sneakers', name: 'Cream sneakers', typeCode: 'SNEAKERS');
final _loafers =
    wardrobeItem('loafers', name: 'Black loafers', typeCode: 'LOAFERS');
final _tote = wardrobeItem('tote', name: 'Canvas tote', typeCode: 'TOTE_BAG');
final _archived =
    wardrobeItem('old', name: 'Old shirt', typeCode: 'SHIRT', isArchived: true);

final _closet = [
  _violet,
  _tee,
  _wide,
  _jeans,
  _sneakers,
  _loafers,
  _tote,
  _archived,
];

const _days = {
  'violet': 41,
  'tee': 5,
  'wide': 12,
  'jeans': 3,
  'sneakers': 6,
  'loafers': 2,
  'tote': 1,
  'old': 90,
};

GeneratedDeck _generate(
  List<WardrobeItem> items, {
  Map<String, int> days = _days,
}) =>
    _generator.generate(
      sessionId: 'session_1',
      items: items,
      daysUnworn: days,
      context: const StylingContext(),
    );

Set<String> _ids(OutfitCandidate c) => c.items.map((i) => i.itemId).toSet();

OutfitCandidate _fitWith(GeneratedDeck deck, List<String> ids) =>
    deck.candidates.firstWhere((c) => _ids(c).containsAll(ids));

void main() {
  group('[fake-generator] generate', () {
    test(
        '[TASK-004-S04][fake-generator] Fits use only owned, non-archived Pieces (I6)',
        () {
      final deck = _generate(_closet);
      final allowed = _closet.where((i) => !i.isArchived).map((i) => i.itemId);

      expect(deck.candidates, isNotEmpty);
      for (final candidate in deck.candidates) {
        expect(allowed, containsAll(_ids(candidate)));
        expect(_ids(candidate), isNot(contains('old')));
      }
    });

    test(
        '[TASK-004-S04][fake-generator] a Fit is one top, one bottom and one pair of shoes',
        () {
      for (final candidate in _generate(_closet).candidates) {
        final slots = candidate.items.map((i) => i.slotRole).toList()
          ..sort((a, b) => a.index.compareTo(b.index));
        expect(slots, [SlotRole.top, SlotRole.bottom, SlotRole.footwear]);
      }
    });

    test(
        '[TASK-004-S04][fake-generator] the same input always gives the same deck',
        () {
      expect(_generate(_closet).candidates, _generate(_closet).candidates);
    });

    test('[TASK-004-S04][fake-generator] a deck holds at most 8 Fits (C11)',
        () {
      final bigCloset = [
        ..._closet,
        wardrobeItem('sweater', typeCode: 'SWEATER'),
        wardrobeItem('skirt', typeCode: 'SKIRT'),
      ];

      final candidates = _generate(bigCloset).candidates;

      expect(candidates, hasLength(GeneratedDeck.deckSize));
      expect(candidates.map((c) => c.deckOrder), [1, 2, 3, 4, 5, 6, 7, 8]);
      expect(candidates.map((c) => c.candidateId).toSet(), hasLength(8));
    });

    test(
        '[TASK-004-S04][fake-generator] Fits start undecided with an honest image label',
        () {
      for (final candidate in _generate(_closet).candidates) {
        expect(candidate.swipeStatus, SwipeStatus.pendingSwipe);
        expect(candidate.visualMode, VisualMode.collageFlatlay);
        expect(candidate.visualMode.label, 'WARDROBE PHOTO');
        expect(candidate.title, isNotEmpty);
      }
    });

    test(
        '[TASK-004-S04][fake-generator] cards carry no commerce fields (AC-07.10)',
        () {
      final json = _generate(_closet).candidates.first.toJson();

      expect(json.keys, containsAll(['candidate_id', 'match_pct', 'items']));
      for (final key in ['price', 'shop_url', 'buy_url', 'product_url']) {
        expect(json.containsKey(key), isFalse, reason: key);
      }
    });

    test('[TASK-004-S04][fake-generator] the most benched Fit comes first', () {
      expect(_ids(_generate(_closet).candidates.first), contains('violet'));
    });
  });

  group('[fake-generator] highlight reason', () {
    test(
        '[TASK-004-S11][fake-generator] names the Piece benched 41 days (AC-07.4)',
        () {
      final first = _generate(_closet).candidates.first;

      expect(first.highlightReason, 'Benched 41 days · Violet shirt');
    });

    test(
        '[TASK-004-S11][fake-generator] names the most benched Piece of the Fit',
        () {
      final deck = _generate(_closet, days: {..._days, 'sneakers': 50});

      expect(_fitWith(deck, ['violet', 'sneakers']).highlightReason,
          'Benched 50 days · Cream sneakers');
    });

    test(
        '[TASK-004-S11][fake-generator] Fits without a 30-day Piece have no reason',
        () {
      final fresh = _fitWith(_generate(_closet), ['tee', 'jeans', 'loafers']);

      expect(fresh.highlightReason, isNull);
    });
  });

  group('[fake-generator] match % (CHG-003 A-03)', () {
    test(
        '[TASK-004-S09][fake-generator] 70 + round(0.3 × most-benched days), capped at 95',
        () {
      final deck = _generate(_closet);

      expect(deck.candidates.first.matchPct, 82, reason: '41 days (spec demo)');
      expect(_fitWith(deck, ['tee', 'jeans', 'loafers']).matchPct, 72,
          reason: '5 days → 70 + round(1.5)');
      expect(
        _generate(_closet, days: {..._days, 'violet': 400})
            .candidates
            .first
            .matchPct,
        95,
      );
    });
  });

  group('[fake-generator] swap (UC-08)', () {
    late OutfitCandidate fit;

    setUp(() =>
        fit = _fitWith(_generate(_closet), ['violet', 'wide', 'sneakers']));

    test(
        '[TASK-004-S09][fake-generator] options are other owned Pieces of the same group',
        () {
      final options = _generator.swapOptions(
        candidate: fit,
        slot: SlotRole.footwear,
        items: _closet,
      );

      expect(options.map((i) => i.itemId), ['loafers']);
      expect(options.every((i) => i.group == ItemGroup.shoes), isTrue);
    });

    test('[TASK-004-S09][fake-generator] archived Pieces are never offered',
        () {
      final options = _generator.swapOptions(
        candidate: fit,
        slot: SlotRole.top,
        items: _closet,
      );

      expect(options.map((i) => i.itemId), ['tee']);
    });

    test(
        '[TASK-004-S09][fake-generator] swapping recalculates match % and reason',
        () {
      final swapped = _generator.swap(
        candidate: fit,
        slot: SlotRole.top,
        replacement: _tee,
        items: _closet,
        replacementDaysUnworn: 5,
      );

      expect(_ids(swapped), {'tee', 'wide', 'sneakers'});
      expect(swapped.matchPct, 74, reason: '12 days → 70 + round(3.6)');
      expect(swapped.highlightReason, isNull);
      expect(swapped.swipeStatus, SwipeStatus.pendingSwipe);
      expect(swapped.candidateId, fit.candidateId);
    });

    test(
        '[TASK-004-S09][fake-generator] swaps outside the rules are rejected (TAC-08.6)',
        () {
      final stranger = wardrobeItem('stranger', typeCode: 'LOAFERS');

      expect(
        () => _generator.swap(
            candidate: fit,
            slot: SlotRole.footwear,
            replacement: _jeans,
            items: _closet,
            replacementDaysUnworn: 3),
        throwsA(isA<ArgumentError>()),
        reason: 'wrong group',
      );
      expect(
        () => _generator.swap(
            candidate: fit,
            slot: SlotRole.top,
            replacement: _archived,
            items: _closet,
            replacementDaysUnworn: 90),
        throwsA(isA<ArgumentError>()),
        reason: 'archived',
      );
      expect(
        () => _generator.swap(
            candidate: fit,
            slot: SlotRole.footwear,
            replacement: stranger,
            items: _closet,
            replacementDaysUnworn: 0),
        throwsA(isA<ArgumentError>()),
        reason: 'not owned',
      );
    });
  });

  group('[fake-generator] short decks', () {
    test(
        '[TASK-004-S12][fake-generator] no shoes means no Fit and a shoes hint',
        () {
      final deck = _generate([_violet, _wide]);

      expect(deck.candidates, isEmpty);
      expect(deck.hintGroup, ItemGroup.shoes);
      expect(deck.missingHint, 'Index a pair of shoes to unlock more Fits');
    });

    test(
        '[TASK-004-S12][fake-generator] a short deck has a hint; a full one does not',
        () {
      final short = _generate([_violet, _wide, _sneakers]);
      expect(short.candidates, hasLength(1));
      expect(short.missingHint, isNotNull);

      expect(_generate(_closet).missingHint, isNull);
    });
  });
}
