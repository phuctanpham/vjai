import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/storage/object_id.dart';
import 'package:garblo/features/gu_match/data/local_gu_match_repository.dart';
import 'package:garblo/features/gu_match/domain/interaction.dart';
import 'package:garblo/features/gu_match/domain/occasion.dart';
import 'package:garblo/features/gu_match/domain/session_path.dart';
import 'package:garblo/features/gu_match/domain/styling_context.dart';
import 'package:garblo/features/gu_match/domain/swipe_status.dart';
import 'package:garblo/features/wardrobe/data/local_wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/local_wear_repository.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/local_db.dart';
import '../../../helpers/wardrobe_fixtures.dart';

const _owner = '65f0c1a2b3c4d5e6f7a8b9c0';

final _closet = [
  wardrobeItem('violet',
      name: 'Violet shirt',
      typeCode: 'SHIRT',
      lastWornEstimate: daysBefore(41)),
  wardrobeItem('tee', name: 'White T-shirt', typeCode: 'T_SHIRT'),
  wardrobeItem('wide',
      name: 'Wide-leg trousers', typeCode: 'WIDE_LEG_TROUSERS'),
  wardrobeItem('jeans', name: 'Black jeans', typeCode: 'JEANS'),
  wardrobeItem('sneakers', name: 'Cream sneakers', typeCode: 'SNEAKERS'),
  wardrobeItem('loafers', name: 'Black loafers', typeCode: 'LOAFERS'),
];

const _coffee = StylingContext(occasions: {Occasion.coffee}, prompt: 'Rain');

void main() {
  late TestDatabase t;
  final clock = FixedClock(testToday);

  LocalGuMatchRepository repoOn(SqliteConnection db) => LocalGuMatchRepository(
        db: db,
        ownerId: _owner,
        wardrobeRepository: LocalWardrobeRepository(db: db, ownerId: _owner),
        wearRepository: LocalWearRepository(db: db, ownerId: _owner),
        clock: clock,
        ids: ObjectIdGenerator(clock: clock),
      );

  setUp(() async {
    t = await TestDatabase.open();
    await LocalWardrobeRepository(db: t.db, ownerId: _owner).saveItems(_closet);
  });
  tearDown(() async => t.dispose());

  group('Sessions and Fits', () {
    test('[TASK-005-S03] the ready count is the Archive count (I9)', () async {
      expect(await repoOn(t.db).readyItemCount(), _closet.length);
    });

    test('[TASK-005-S03] a session is stored with an ObjectId', () async {
      final session = await repoOn(t.db).startSession(_coffee);

      expect(isObjectId(session.sessionId), isTrue);
      expect(session.path, SessionPath.promptLed);
      final row = await t.db.get(
          'SELECT user_id, path, occasions, raw_prompt, eligible_item_count, '
          'recent FROM gu_match_sessions WHERE id = ?',
          [session.sessionId]);
      expect(row['user_id'], _owner);
      expect(row['raw_prompt'], 'Rain');
      expect(row['eligible_item_count'], _closet.length);
      expect(row['recent'], 1);
    });

    test('[TASK-005-S03] the deck is stored in order with ObjectId Fits',
        () async {
      final repo = repoOn(t.db);
      final session = await repo.startSession(_coffee);

      final deck = await repo.buildDeck(session);

      expect(deck.candidates, isNotEmpty);
      expect(deck.candidates.every((c) => isObjectId(c.candidateId)), isTrue);
      final rows = await t.db.getAll(
          'SELECT id, deck_order, swipe_status FROM outfit_candidates '
          'WHERE session_id = ? ORDER BY deck_order',
          [session.sessionId]);
      expect(
          rows.map((r) => r['id']), deck.candidates.map((c) => c.candidateId));
    });

    test(
        '[TASK-005-S03] Fits with their decisions survive closing and '
        'reopening', () async {
      final repo = repoOn(t.db);
      final session = await repo.startSession(_coffee);
      final deck = await repo.buildDeck(session);
      final first = deck.candidates[0];
      final second = deck.candidates[1];
      await repo.updateSwipeStatus(
          first.candidateId, SwipeStatus.swipedRightLiked);
      await repo.updateSwipeStatus(
          second.candidateId, SwipeStatus.swipedLeftPassed);

      final reopened = await t.reopen();
      final snapshot = await repoOn(reopened).loadLatestSession();

      expect(snapshot, isNotNull);
      expect(snapshot!.session, session);
      expect(snapshot.candidates.map((c) => c.candidateId),
          deck.candidates.map((c) => c.candidateId));
      expect(snapshot.candidates[0].swipeStatus, SwipeStatus.swipedRightLiked);
      expect(snapshot.candidates[1].swipeStatus, SwipeStatus.swipedLeftPassed);
      expect(snapshot.candidates.skip(2).map((c) => c.swipeStatus).toSet(),
          anyOf(isEmpty, {SwipeStatus.pendingSwipe}));
      expect(snapshot.candidates[0].items, first.items);
    });

    test('[TASK-005-S03] a swapped Piece is restored', () async {
      final repo = repoOn(t.db);
      final session = await repo.startSession(_coffee);
      final deck = await repo.buildDeck(session);
      final candidate = deck.candidates.first;
      final slot = candidate.items.first.slotRole;
      final options = await repo.swapOptions(candidate, slot);
      expect(options, isNotEmpty);

      final swapped =
          await repo.swapItem(candidate, slot, options.first.itemId);
      final snapshot = await repo.loadLatestSession();

      expect(snapshot!.candidates.first.items, swapped.items);
    });

    test('[TASK-005-S03] only the latest session is restored', () async {
      final repo = repoOn(t.db);
      final older = await repo.startSession(_coffee);
      await repo.buildDeck(older);
      clock.fixed = testToday.add(const Duration(minutes: 5));
      final newer = await repo
          .startSession(const StylingContext(occasions: {Occasion.work}));
      await repo.buildDeck(newer);
      clock.fixed = testToday;

      final snapshot = await repo.loadLatestSession();

      expect(snapshot!.session.sessionId, newer.sessionId);
      final recent = await t.db
          .getAll('SELECT id FROM gu_match_sessions WHERE recent = 1');
      expect(recent.map((r) => r['id']), [newer.sessionId]);
    });

    test('[TASK-005-S03] no session yet means nothing to restore', () async {
      expect(await repoOn(t.db).loadLatestSession(), isNull);
    });

    test('[TASK-005-S03] interactions are stored against the session',
        () async {
      final repo = repoOn(t.db);
      final session = await repo.startSession(_coffee);
      final deck = await repo.buildDeck(session);
      final fit = deck.candidates.first;

      await repo.recordInteraction(Interaction(
        candidateId: fit.candidateId,
        action: CardAction.likeSave,
        dwellMs: 1200,
      ));

      final row = await t.db
          .get('SELECT user_id, session_id, candidate_id, action, dwell_ms '
              'FROM interactions');
      expect(row['user_id'], _owner);
      expect(row['session_id'], session.sessionId);
      expect(row['candidate_id'], fit.candidateId);
      expect(row['dwell_ms'], 1200);
    });
  });

  group('Wear', () {
    test('[TASK-005-S07] confirming the same Fit twice today is one wear event',
        () async {
      final repo = repoOn(t.db);
      final session = await repo.startSession(_coffee);
      final fit = (await repo.buildDeck(session)).candidates.first;

      expect(await repo.confirmWearing(fit), isTrue);
      expect(await repo.confirmWearing(fit), isFalse);

      final rows =
          await t.db.getAll('SELECT candidate_id, source FROM wear_events');
      expect(rows, hasLength(1));
      expect(rows.single['candidate_id'], fit.candidateId);
    });
  });

  group('Studio draft (local-only)', () {
    test('[TASK-005-S03] chips and prompt survive closing and reopening',
        () async {
      await repoOn(t.db).saveContextDraft(const StylingContext(
          occasions: {Occasion.work, Occasion.afternoonRain},
          prompt: 'Pitch day'));

      final reopened = await t.reopen();

      expect(
        await repoOn(reopened).loadContextDraft(),
        const StylingContext(
            occasions: {Occasion.work, Occasion.afternoonRain},
            prompt: 'Pitch day'),
      );
      final rows = await reopened.getAll('SELECT id FROM session_draft');
      expect(rows.map((r) => r['id']), ['current']);
    });

    test('[TASK-005-S03] an empty draft by default', () async {
      expect(await repoOn(t.db).loadContextDraft(), const StylingContext());
    });

    test('[TASK-005-S03] saving the draft again replaces it', () async {
      final repo = repoOn(t.db);

      await repo.saveContextDraft(_coffee);
      await repo.saveContextDraft(const StylingContext());

      expect(await repo.loadContextDraft(), const StylingContext());
      final count = await t.db.get('SELECT count(*) AS n FROM session_draft');
      expect(count['n'], 1);
    });
  });
}
