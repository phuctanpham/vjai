import 'dart:convert';

import 'package:sqlite_async/sqlite3_common.dart' show Row;
import 'package:sqlite_async/sqlite_async.dart';

import '../../../core/errors/failures.dart';
import '../../../core/storage/object_id.dart';
import '../../../core/time/clock.dart';
import '../../wardrobe/data/wardrobe_repository.dart';
import '../../wardrobe/data/wear_repository.dart';
import '../../wardrobe/domain/wardrobe_item.dart';
import '../domain/context_card.dart';
import '../domain/generated_deck.dart';
import '../domain/gu_match_failures.dart';
import '../domain/gu_match_session.dart';
import '../domain/gu_match_snapshot.dart';
import '../domain/interaction.dart';
import '../domain/occasion.dart';
import '../domain/outfit_candidate.dart';
import '../domain/session_path.dart';
import '../domain/slot_role.dart';
import '../domain/styling_context.dart';
import '../domain/swipe_status.dart';
import '../domain/visual_mode.dart';
import 'fake_candidate_generator.dart';
import 'gu_match_repository.dart';

/// [GuMatchRepository] that persists sessions, Fits, decisions and
/// interactions in `gu_match_sessions`, `outfit_candidates` and
/// `interactions`, and the studio draft in the local-only `session_draft`.
/// Decks still come from [FakeCandidateGenerator]; the phone writes them in
/// P2 and P3, the server from P4 (BE-004). Context cards stay fixtures.
class LocalGuMatchRepository implements GuMatchRepository {
  final SqliteConnection _db;
  final String _ownerId;
  final WardrobeRepository _wardrobe;
  final Clock _clock;
  final ObjectIdGenerator _ids;

  /// Fixture context, generation, swaps and wear logging (unchanged fakes).
  final MockGuMatchRepository _fake;

  LocalGuMatchRepository({
    required SqliteConnection db,
    required String ownerId,
    required WardrobeRepository wardrobeRepository,
    required WearRepository wearRepository,
    required Clock clock,
    required ObjectIdGenerator ids,
    FakeCandidateGenerator generator = const FakeCandidateGenerator(),
  })  : _db = db,
        _ownerId = ownerId,
        _wardrobe = wardrobeRepository,
        _clock = clock,
        _ids = ids,
        _fake = MockGuMatchRepository(
          wardrobeRepository: wardrobeRepository,
          wearRepository: wearRepository,
          clock: clock,
          generator: generator,
        );

  @override
  Future<int> readyItemCount() => _wardrobe.countEligible();

  @override
  Future<GuMatchSession> startSession(StylingContext context) async {
    final eligible = await _wardrobe.countEligible();
    if (eligible == 0) throw const NoEligibleItemsFailure();
    final session = GuMatchSession(
      sessionId: _ids.next(),
      path: context.path,
      occasions: context.occasions,
      prompt: context.prompt,
      eligibleItemCount: eligible,
    );
    await _guard('Could not start Gu Match.', () {
      return _db.writeTransaction((tx) async {
        // Only the newest session is "recent" (restored after a restart).
        await tx.execute(
          'UPDATE gu_match_sessions SET recent = 0 '
          'WHERE user_id = ? AND recent = 1',
          [_ownerId],
        );
        await tx.execute(
          'INSERT INTO gu_match_sessions(id, user_id, path, occasions, '
          'raw_prompt, eligible_item_count, owned_only, deck_size, recent, '
          'created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?)',
          [
            session.sessionId,
            _ownerId,
            session.path.name,
            _occasionsJson(session.occasions),
            session.prompt,
            session.eligibleItemCount,
            session.ownedOnly ? 1 : 0,
            session.deckSize,
            _clock.now().toIso8601String(),
          ],
        );
      });
    });
    return session;
  }

  @override
  Stream<ContextCard> gatherContext(GuMatchSession session) =>
      _fake.gatherContext(session);

  @override
  Future<GeneratedDeck> buildDeck(GuMatchSession session) async {
    final generated = await _fake.buildDeck(session);
    // Fits get ObjectIds so they never collide across sessions.
    final candidates = [
      for (final c in generated.candidates)
        OutfitCandidate(
          candidateId: _ids.next(),
          deckOrder: c.deckOrder,
          title: c.title,
          matchPct: c.matchPct,
          highlightReason: c.highlightReason,
          visualMode: c.visualMode,
          swipeStatus: c.swipeStatus,
          items: c.items,
        ),
    ];
    final now = _clock.now().toIso8601String();
    await _guard('Could not save the Fits.', () {
      return _db.writeTransaction((tx) async {
        for (final c in candidates) {
          await tx.execute(
            'INSERT INTO outfit_candidates(id, user_id, session_id, '
            'deck_order, title, match_pct, highlight_reason, visual_mode, '
            'swipe_status, items, created_at) '
            'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              c.candidateId,
              _ownerId,
              session.sessionId,
              c.deckOrder,
              c.title,
              c.matchPct,
              c.highlightReason,
              c.visualMode.wireName,
              c.swipeStatus.name,
              _itemsJson(c.items),
              now,
            ],
          );
        }
      });
    });
    return GeneratedDeck(
      candidates: List.unmodifiable(candidates),
      hintGroup: generated.hintGroup,
    );
  }

  @override
  Future<void> recordInteraction(Interaction interaction) =>
      _guard('Could not record the decision.', () async {
        final fit = await _db.getOptional(
          'SELECT session_id FROM outfit_candidates WHERE id = ?',
          [interaction.candidateId],
        );
        await _db.execute(
          'INSERT INTO interactions(id, user_id, session_id, candidate_id, '
          'action, dwell_ms, from_item_id, to_item_id, created_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          [
            _ids.next(),
            _ownerId,
            fit?['session_id'],
            interaction.candidateId,
            interaction.action.name,
            interaction.dwellMs,
            interaction.fromItemId,
            interaction.toItemId,
            _clock.now().toIso8601String(),
          ],
        );
      });

  @override
  Future<List<WardrobeItem>> swapOptions(
    OutfitCandidate candidate,
    SlotRole slot,
  ) =>
      _fake.swapOptions(candidate, slot);

  @override
  Future<OutfitCandidate> swapItem(
    OutfitCandidate candidate,
    SlotRole slot,
    String itemId,
  ) async {
    final swapped = await _fake.swapItem(candidate, slot, itemId);
    await _guard('Could not save the swap.', () {
      return _db.execute(
        'UPDATE outfit_candidates SET items = ?, match_pct = ?, '
        'highlight_reason = ? WHERE id = ? AND user_id = ?',
        [
          _itemsJson(swapped.items),
          swapped.matchPct,
          swapped.highlightReason,
          swapped.candidateId,
          _ownerId,
        ],
      );
    });
    return swapped;
  }

  @override
  Future<bool> confirmWearing(OutfitCandidate candidate) =>
      _fake.confirmWearing(candidate);

  @override
  Future<void> updateSwipeStatus(String candidateId, SwipeStatus status) =>
      _guard('Could not save the decision.', () {
        return _db.execute(
          'UPDATE outfit_candidates SET swipe_status = ? '
          'WHERE id = ? AND user_id = ?',
          [status.name, candidateId, _ownerId],
        );
      });

  @override
  Future<GuMatchSnapshot?> loadLatestSession() =>
      _guard('Could not restore Gu Match.', () async {
        final row = await _db.getOptional(
          'SELECT * FROM gu_match_sessions WHERE user_id = ? AND recent = 1 '
          'ORDER BY created_at DESC LIMIT 1',
          [_ownerId],
        );
        if (row == null) return null;
        final sessionId = row['id'] as String;
        final fits = await _db.getAll(
          'SELECT * FROM outfit_candidates WHERE session_id = ? '
          'ORDER BY deck_order',
          [sessionId],
        );
        return GuMatchSnapshot(
          session: GuMatchSession(
            sessionId: sessionId,
            path: SessionPath.values.byName(row['path'] as String),
            occasions: _occasionsFrom(row['occasions'] as String),
            prompt: row['raw_prompt'] as String,
            eligibleItemCount: row['eligible_item_count'] as int,
            ownedOnly: row['owned_only'] == 1,
            deckSize: row['deck_size'] as int,
          ),
          candidates: List.unmodifiable(fits.map(_candidateFrom)),
        );
      });

  @override
  Future<void> saveContextDraft(StylingContext context) =>
      _guard('Could not keep your request.', () {
        return _db.writeTransaction((tx) async {
          await tx.execute("DELETE FROM session_draft WHERE id = 'current'");
          await tx.execute(
            "INSERT INTO session_draft(id, occasions, prompt) "
            "VALUES ('current', ?, ?)",
            [_occasionsJson(context.occasions), context.prompt],
          );
        });
      });

  @override
  Future<StylingContext> loadContextDraft() =>
      _guard('Could not restore your request.', () async {
        final row = await _db.getOptional(
            "SELECT occasions, prompt FROM session_draft WHERE id = 'current'");
        if (row == null) return const StylingContext();
        return StylingContext(
          occasions: _occasionsFrom(row['occasions'] as String),
          prompt: row['prompt'] as String,
        );
      });

  static String _occasionsJson(Set<Occasion> occasions) => jsonEncode([
        for (final o in Occasion.values)
          if (occasions.contains(o)) o.name,
      ]);

  static Set<Occasion> _occasionsFrom(String json) => {
        for (final name in jsonDecode(json) as List)
          Occasion.values.byName(name as String),
      };

  static String _itemsJson(List<CandidateItem> items) => jsonEncode([
        for (final item in items)
          {
            'slot_role': item.slotRole.name,
            'item_id': item.itemId,
            'name': item.name,
            'days_unworn': item.daysUnworn,
          },
      ]);

  static OutfitCandidate _candidateFrom(Row row) => OutfitCandidate(
        candidateId: row['id'] as String,
        deckOrder: row['deck_order'] as int,
        title: row['title'] as String,
        matchPct: row['match_pct'] as int,
        highlightReason: row['highlight_reason'] as String?,
        visualMode: VisualMode.values
            .firstWhere((m) => m.wireName == row['visual_mode']),
        swipeStatus: SwipeStatus.values.byName(row['swipe_status'] as String),
        items: List.unmodifiable([
          for (final item in jsonDecode(row['items'] as String) as List)
            CandidateItem(
              slotRole: SlotRole.values.byName(item['slot_role'] as String),
              itemId: item['item_id'] as String,
              name: item['name'] as String,
              daysUnworn: item['days_unworn'] as int,
            ),
        ]),
      );

  static Future<T> _guard<T>(String message, Future<T> Function() run) async {
    try {
      return await run();
    } on Failure {
      rethrow;
    } catch (error) {
      throw StorageFailure(message, error);
    }
  }
}
