import 'package:sqlite_async/sqlite_async.dart';

import '../../../core/storage/object_id.dart';
import '../../../core/time/clock.dart';
import '../../wardrobe/data/wardrobe_repository.dart';
import '../../wardrobe/data/wear_repository.dart';
import '../../wardrobe/domain/wardrobe_item.dart';
import '../domain/context_card.dart';
import '../domain/generated_deck.dart';
import '../domain/gu_match_session.dart';
import '../domain/gu_match_snapshot.dart';
import '../domain/interaction.dart';
import '../domain/outfit_candidate.dart';
import '../domain/slot_role.dart';
import '../domain/styling_context.dart';
import '../domain/swipe_status.dart';
import 'fake_candidate_generator.dart';
import 'gu_match_repository.dart';

/// [GuMatchRepository] that persists sessions, Fits, decisions and
/// interactions in `gu_match_sessions`, `outfit_candidates` and
/// `interactions`, and the studio draft in the local-only `session_draft`.
/// Decks still come from [FakeCandidateGenerator]; the phone writes them in
/// P2 and P3, the server from P4 (BE-004). Context cards stay fixtures.
class LocalGuMatchRepository implements GuMatchRepository {
  LocalGuMatchRepository({
    required SqliteConnection db,
    required String ownerId,
    required WardrobeRepository wardrobeRepository,
    required WearRepository wearRepository,
    required Clock clock,
    required ObjectIdGenerator ids,
    FakeCandidateGenerator generator = const FakeCandidateGenerator(),
  });

  @override
  Future<int> readyItemCount() => throw UnimplementedError('TASK-005-S03');

  @override
  Future<GuMatchSession> startSession(StylingContext context) =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Stream<ContextCard> gatherContext(GuMatchSession session) =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<GeneratedDeck> buildDeck(GuMatchSession session) =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<void> recordInteraction(Interaction interaction) =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<List<WardrobeItem>> swapOptions(
    OutfitCandidate candidate,
    SlotRole slot,
  ) =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<OutfitCandidate> swapItem(
    OutfitCandidate candidate,
    SlotRole slot,
    String itemId,
  ) =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<bool> confirmWearing(OutfitCandidate candidate) =>
      throw UnimplementedError('TASK-005-S07');

  @override
  Future<void> updateSwipeStatus(String candidateId, SwipeStatus status) =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<GuMatchSnapshot?> loadLatestSession() =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<void> saveContextDraft(StylingContext context) =>
      throw UnimplementedError('TASK-005-S03');

  @override
  Future<StylingContext> loadContextDraft() =>
      throw UnimplementedError('TASK-005-S03');
}
