import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../../wardrobe/data/wardrobe_repository.dart';
import '../../wardrobe/data/wear_repository.dart';
import '../../wardrobe/domain/dormancy.dart';
import '../../wardrobe/domain/wardrobe_item.dart';
import '../../wardrobe/domain/wear_event.dart';
import '../domain/context_card.dart';
import '../domain/generated_deck.dart';
import '../domain/gu_match_failures.dart';
import '../domain/gu_match_session.dart';
import '../domain/interaction.dart';
import '../domain/occasion.dart';
import '../domain/outfit_candidate.dart';
import '../domain/session_path.dart';
import '../domain/gu_match_snapshot.dart';
import '../domain/slot_role.dart';
import '../domain/styling_context.dart';
import '../domain/swipe_status.dart';
import 'fake_candidate_generator.dart';

/// Provider for GuMatchRepository. Phase 1: fixtures and the on-phone
/// rule-based generator over the Archive repositories.
final guMatchRepositoryProvider = Provider<GuMatchRepository>((ref) {
  return MockGuMatchRepository(
    wardrobeRepository: ref.watch(wardrobeRepositoryProvider),
    wearRepository: ref.watch(wearRepositoryProvider),
    clock: ref.watch(clockProvider),
  );
});

/// Contract for Gu Match operations: drafting Fits (outfits) from the user's
/// own Pieces for the day ahead.
abstract class GuMatchRepository {
  /// Non-archived Pieces; the same count as the Archive total (I9).
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

  /// Logs the Fit as worn today. Returns false when it was already logged
  /// today (TAC-07.4).
  Future<bool> confirmWearing(OutfitCandidate candidate);

  /// Persists a decision on a Fit (pass, add to rotation, save for later).
  Future<void> updateSwipeStatus(String candidateId, SwipeStatus status);

  /// The latest session with its Fits and decisions, or null
  /// (TASK-005-S03).
  Future<GuMatchSnapshot?> loadLatestSession();

  /// Keeps the studio chips and prompt between launches (local-only
  /// `session_draft`).
  Future<void> saveContextDraft(StylingContext context);

  Future<StylingContext> loadContextDraft();
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
  final WardrobeRepository _wardrobeRepository;
  final WearRepository _wearRepository;
  final Clock _clock;
  final FakeCandidateGenerator generator;

  /// Card kinds whose source fails in this fake.
  final Set<ContextCardKind> missingContextKinds;
  final bool hasCalendarEvent;

  /// Every interaction recorded, in order.
  final List<Interaction> interactions = [];

  int _sessionCount = 0;

  // The latest session, its deck with decisions, and the studio draft.
  GuMatchSession? _session;
  List<OutfitCandidate> _deck = const [];
  StylingContext _draft = const StylingContext();

  MockGuMatchRepository({
    required WardrobeRepository wardrobeRepository,
    required WearRepository wearRepository,
    required Clock clock,
    this.generator = const FakeCandidateGenerator(),
    this.missingContextKinds = const {},
    this.hasCalendarEvent = true,
  })  : _wardrobeRepository = wardrobeRepository,
        _wearRepository = wearRepository,
        _clock = clock;

  @override
  Future<int> readyItemCount() => _wardrobeRepository.countEligible();

  @override
  Future<GuMatchSession> startSession(StylingContext context) async {
    final eligible = await _wardrobeRepository.countEligible();
    if (eligible == 0) throw const NoEligibleItemsFailure();
    _sessionCount++;
    _deck = const [];
    return _session = GuMatchSession(
      sessionId: 'session_$_sessionCount',
      path: context.path,
      occasions: context.occasions,
      prompt: context.prompt,
      eligibleItemCount: eligible,
    );
  }

  @override
  Stream<ContextCard> gatherContext(GuMatchSession session) {
    final cards = [
      _occasionCard(session),
      const ContextCard(
        kind: ContextCardKind.weather,
        label: 'WEATHER · TOKYO',
        headline: '16–19°C',
        detail: '10:00 17° · 13:00 RAIN 80% · 16:00 16°',
      ),
      const ContextCard(
        kind: ContextCardKind.rain,
        label: 'RAIN',
        headline: '80%',
        detail: 'AROUND 13:00',
      ),
      const ContextCard(
        kind: ContextCardKind.commute,
        label: 'COMMUTE',
        headline: 'Walking + train',
        detail: 'Expected to travel between stations and walk to the venue',
      ),
    ];
    return Stream.fromIterable(
      cards.where((card) => !missingContextKinds.contains(card.kind)),
    );
  }

  @override
  Future<GeneratedDeck> buildDeck(GuMatchSession session) async {
    final items = await _wardrobeRepository.getEligibleItems();
    final deck = generator.generate(
      sessionId: session.sessionId,
      items: items,
      daysUnworn: await _daysUnworn(items),
      context: session.context,
    );
    if (_session?.sessionId == session.sessionId) _deck = deck.candidates;
    return deck;
  }

  @override
  Future<void> recordInteraction(Interaction interaction) async {
    interactions.add(interaction);
  }

  @override
  Future<List<WardrobeItem>> swapOptions(
    OutfitCandidate candidate,
    SlotRole slot,
  ) async {
    final items = await _wardrobeRepository.getEligibleItems();
    return generator.swapOptions(
        candidate: candidate, slot: slot, items: items);
  }

  @override
  Future<OutfitCandidate> swapItem(
    OutfitCandidate candidate,
    SlotRole slot,
    String itemId,
  ) async {
    final items = await _wardrobeRepository.getEligibleItems();
    final replacement = items.where((i) => i.itemId == itemId).firstOrNull;
    if (replacement == null) {
      throw ArgumentError.value(itemId, 'itemId', 'Not in the Archive');
    }
    final days = await _daysUnworn([replacement]);
    return generator.swap(
      candidate: candidate,
      slot: slot,
      replacement: replacement,
      items: items,
      replacementDaysUnworn: days[itemId] ?? 0,
    );
  }

  @override
  Future<bool> confirmWearing(OutfitCandidate candidate) {
    return _wearRepository.logWear(WearEvent.forLook(
      wornOn: _clock.now(),
      itemIds: [for (final item in candidate.items) item.itemId],
      candidateId: candidate.candidateId,
    ));
  }

  @override
  Future<void> updateSwipeStatus(String candidateId, SwipeStatus status) async {
    _deck = [
      for (final c in _deck)
        c.candidateId == candidateId ? c.copyWith(swipeStatus: status) : c,
    ];
  }

  @override
  Future<GuMatchSnapshot?> loadLatestSession() async {
    final session = _session;
    if (session == null) return null;
    return GuMatchSnapshot(
        session: session, candidates: List.unmodifiable(_deck));
  }

  @override
  Future<void> saveContextDraft(StylingContext context) async =>
      _draft = context;

  @override
  Future<StylingContext> loadContextDraft() async => _draft;

  ContextCard _occasionCard(GuMatchSession session) {
    if (session.path == SessionPath.promptLed) {
      final chips = Occasion.values
          .where(session.occasions.contains)
          .map((o) => o.label)
          .join(' · ');
      return ContextCard(
        kind: ContextCardKind.occasion,
        label: 'YOUR REQUEST',
        headline: chips.isEmpty ? 'Your words' : chips,
        detail: session.prompt.trim().isEmpty ? null : session.prompt,
      );
    }
    if (!hasCalendarEvent) {
      return const ContextCard(
        kind: ContextCardKind.occasion,
        label: 'TODAY',
        headline: 'No event found',
        detail: 'styling for an everyday day',
      );
    }
    return const ContextCard(
      kind: ContextCardKind.occasion,
      label: 'TODAY',
      headline: 'Hackathon Pitching Day',
      detail: '09:00–18:00 · Tokyo',
    );
  }

  Future<Map<String, int>> _daysUnworn(List<WardrobeItem> items) async {
    final lastWorn = await _wearRepository.lastWornByItem();
    final today = _clock.now();
    return {
      for (final item in items)
        item.itemId: DormancyRules.daysUnworn(
          item: item,
          today: today,
          lastWear: lastWorn[item.itemId],
        ),
    };
  }
}
