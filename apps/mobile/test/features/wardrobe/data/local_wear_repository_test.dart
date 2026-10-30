import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/storage/object_id.dart';
import 'package:garblo/features/wardrobe/data/local_wear_repository.dart';
import 'package:garblo/features/wardrobe/data/wear_repository.dart';
import 'package:garblo/features/wardrobe/domain/wear_event.dart';

import '../../../helpers/contracts/wear_repository_contract.dart';
import '../../../helpers/fixed_clock.dart';
import '../../../helpers/local_db.dart';

const _owner = '65f0c1a2b3c4d5e6f7a8b9c0';

void main() {
  wearRepositoryContract(
      'MockWearRepository', () async => MockWearRepository());

  TestDatabase? contractDb;
  wearRepositoryContract(
    'LocalWearRepository',
    () async {
      contractDb = await TestDatabase.open();
      return LocalWearRepository(db: contractDb!.db, ownerId: _owner);
    },
    cleanUp: () async {
      await contractDb?.dispose();
      contractDb = null;
    },
  );

  group('LocalWearRepository', () {
    late TestDatabase t;

    setUp(() async => t = await TestDatabase.open());
    tearDown(() async => t.dispose());

    final fit = WearEvent.forLook(
      wornOn: testToday,
      itemIds: const ['violet', 'wide', 'sneakers'],
      candidateId: 'cand_1',
    );

    test('[TASK-005-S07] the event ID is hashed from owner, date and signature',
        () {
      final id = LocalWearRepository.eventId(_owner, fit);

      expect(isObjectId(id), isTrue);
      expect(
          id,
          deterministicObjectId(
              [_owner, '2026-10-29', 'sneakers,violet,wide']));
      expect(LocalWearRepository.eventId('another_owner', fit), isNot(id));
    });

    test('[TASK-005-S07] confirming the same Fit twice on a day is one row',
        () async {
      final repo = LocalWearRepository(db: t.db, ownerId: _owner);
      final again = WearEvent.forLook(
        wornOn: testToday.add(const Duration(hours: 6)),
        itemIds: const ['wide', 'sneakers', 'violet'],
        candidateId: 'cand_9',
      );

      expect(await repo.logWear(fit), isTrue);
      expect(await repo.logWear(again), isFalse);

      final rows = await t.db.getAll(
          'SELECT id, user_id, worn_date, signature, candidate_id FROM wear_events');
      expect(rows, hasLength(1));
      expect(rows.single['id'], LocalWearRepository.eventId(_owner, fit));
      expect(rows.single['user_id'], _owner);
      expect(rows.single['worn_date'], '2026-10-29');
      expect(rows.single['signature'], fit.signature);
      expect(rows.single['candidate_id'], 'cand_1');
    });

    test('[TASK-005-S07] concurrent confirms still leave one row', () async {
      final repo = LocalWearRepository(db: t.db, ownerId: _owner);

      final results = await Future.wait([
        repo.logWear(fit),
        repo.logWear(fit),
        repo.logWear(fit),
      ]);

      expect(results.where((added) => added), hasLength(1));
      final count = await t.db.get('SELECT count(*) AS n FROM wear_events');
      expect(count['n'], 1);
    });

    test('[TASK-005-S03] wear events survive closing and reopening', () async {
      await LocalWearRepository(db: t.db, ownerId: _owner).logWear(fit);

      final reopened = await t.reopen();
      final repo = LocalWearRepository(db: reopened, ownerId: _owner);

      expect(await repo.getEvents(), [fit]);
      expect(await repo.logWear(fit), isFalse);
    });
  });
}
