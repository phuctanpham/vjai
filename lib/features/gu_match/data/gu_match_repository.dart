import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../wardrobe/data/wardrobe_repository.dart';
import '../../wardrobe/data/wear_repository.dart';
import '../../wardrobe/domain/wardrobe_item.dart';
import '../domain/generated_deck.dart';
import 'fake_candidate_generator.dart';
import '../domain/context_card.dart';
import '../domain/gu_match_session.dart';
import '../domain/interaction.dart';
import '../domain/outfit_candidate.dart';
import '../domain/slot_role.dart';
import '../domain/styling_context.dart';

/// Provider for GuMatchRepository. Phase 1: fixtures and the on-phone
/// rule-based generator over the Wardrobe repositories.
final guMatchRepositoryProvider = Provider<GuMatchRepository>((ref) {
  throw UnimplementedError('TASK-004-S01');
});

/// Contract for Gu Match operations.
abstract class GuMatchRepository {
  /// Non-archived wardrobe items; the same count as the Wardrobe total (I9).
  Future<int> readyItemCount();

  /// Creates a session. Throws `NoEligibleItemsFailure` when no item is usable.
  Future<GuMatchSession> startSession(StylingContext context);

  /// Emits context cards as their sources return, then closes. Kinds that
  /// never arrive are missing (AC-06.9).
  Stream<ContextCard> gatherContext(GuMatchSession session);

  /// Builds the session's deck from owned, non-archived items only (I6).
  Future<GeneratedDeck> buildDeck(GuMatchSession session);

  Future<void> recordInteraction(Interaction interaction);

  Future<List<WardrobeItem>> swapOptions(
    OutfitCandidate candidate,
    SlotRole slot,
  );

  Future<OutfitCandidate> swapItem(
    OutfitCandidate candidate,
    SlotRole slot,
    String itemId,
  );

  /// Logs the look as worn today. Returns false when it was already logged
  /// today (TAC-07.4).
  Future<bool> confirmWearing(OutfitCandidate candidate);
}

/// Phase 1 implementation. Decks come from [FakeCandidateGenerator], which
/// stays behind this interface (CHG-003 A-03).
///
/// Fixture cards (spec UC-06 path comparison, copy from T7 › G3 2b; labels
/// in chrome-nav caps):
/// - occasion, prompt-led: label "YOUR REQUEST", headline = occasion labels
///   joined by " · " (or "Your words"), detail = the prompt.
/// - occasion, zero-input: label "TODAY", headline "Hackathon Pitching Day",
///   detail "09:00–18:00 · Tokyo"; without a calendar event: headline
///   "No event found", detail "styling for an everyday day".
/// - weather: "WEATHER · TOKYO" · "16–19°C" ·
///   "10:00 17° · 13:00 RAIN 80% · 16:00 16°".
/// - rain: "RAIN" · "80%" · "AROUND 13:00".
/// - commute: "COMMUTE" · "Walking + train" ·
///   "Expected to travel between stations and walk to the venue".
///
/// Session IDs are `session_1`, `session_2`, … in creation order.
class MockGuMatchRepository implements GuMatchRepository {
  final FakeCandidateGenerator generator;

  /// Card kinds whose source fails in this fake.
  final Set<ContextCardKind> missingContextKinds;
  final bool hasCalendarEvent;

  /// Every interaction recorded, in order.
  final List<Interaction> interactions = [];

  MockGuMatchRepository({
    required WardrobeRepository wardrobeRepository,
    required WearRepository wearRepository,
    required Clock clock,
    this.generator = const FakeCandidateGenerator(),
    this.missingContextKinds = const {},
    this.hasCalendarEvent = true,
  });

  @override
  Future<int> readyItemCount() => throw UnimplementedError('TASK-004-S01');

  @override
  Future<GuMatchSession> startSession(StylingContext context) =>
      throw UnimplementedError('TASK-004-S02');

  @override
  Stream<ContextCard> gatherContext(GuMatchSession session) =>
      throw UnimplementedError('TASK-004-S03');

  @override
  Future<GeneratedDeck> buildDeck(GuMatchSession session) =>
      throw UnimplementedError('TASK-004-S04');

  @override
  Future<void> recordInteraction(Interaction interaction) =>
      throw UnimplementedError('TASK-004-S05');

  @override
  Future<List<WardrobeItem>> swapOptions(
    OutfitCandidate candidate,
    SlotRole slot,
  ) =>
      throw UnimplementedError('TASK-004-S09');

  @override
  Future<OutfitCandidate> swapItem(
    OutfitCandidate candidate,
    SlotRole slot,
    String itemId,
  ) =>
      throw UnimplementedError('TASK-004-S09');

  @override
  Future<bool> confirmWearing(OutfitCandidate candidate) =>
      throw UnimplementedError('TASK-004-S06');
}
