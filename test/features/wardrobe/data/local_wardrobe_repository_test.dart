import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/errors/failures.dart';
import 'package:garblo/features/wardrobe/data/local_wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';

import '../../../helpers/contracts/wardrobe_repository_contract.dart';
import '../../../helpers/local_db.dart';
import '../../../helpers/wardrobe_fixtures.dart';

const _owner = '65f0c1a2b3c4d5e6f7a8b9c0';

void main() {
  wardrobeRepositoryContract(
    'MockWardrobeRepository',
    (items) async => MockWardrobeRepository(items: items),
  );

  TestDatabase? contractDb;
  wardrobeRepositoryContract(
    'LocalWardrobeRepository',
    (items) async {
      contractDb = await TestDatabase.open();
      final repo = LocalWardrobeRepository(db: contractDb!.db, ownerId: _owner);
      await repo.saveItems(items);
      return repo;
    },
    cleanUp: () async {
      await contractDb?.dispose();
      contractDb = null;
    },
  );

  group('LocalWardrobeRepository', () {
    late TestDatabase t;

    setUp(() async => t = await TestDatabase.open());
    tearDown(() async => t.dispose());

    final batch = [
      wardrobeItem('65f0c1a2b3c4d5e6f7a8b901', typeCode: 'SHIRT'),
      wardrobeItem('65f0c1a2b3c4d5e6f7a8b902', typeCode: 'JEANS'),
      wardrobeItem('65f0c1a2b3c4d5e6f7a8b903', typeCode: 'SNEAKERS'),
    ];

    test('[TASK-005-S04] indexing N Pieces writes N rows for the owner',
        () async {
      final repo = LocalWardrobeRepository(db: t.db, ownerId: _owner);

      await repo.saveItems(batch);

      final rows = await t.db.getAll(
          'SELECT id, typeof(id) AS id_type, user_id, archived FROM wardrobe_items');
      expect(rows, hasLength(3));
      for (final row in rows) {
        expect(row['id_type'], 'text');
        expect(row['user_id'], _owner);
        expect(row['archived'], 0);
      }
    });

    test('[TASK-005-S04] repeating the same save adds nothing', () async {
      final repo = LocalWardrobeRepository(db: t.db, ownerId: _owner);

      await repo.saveItems(batch);
      await repo.saveItems(batch);

      final count = await t.db.get('SELECT count(*) AS n FROM wardrobe_items');
      expect(count['n'], 3);
      expect(await repo.countEligible(), 3);
    });

    test('[TASK-005-S05] a failure part-way leaves no Piece rows', () async {
      final repo = LocalWardrobeRepository(
        db: t.db,
        ownerId: _owner,
        onInsert: (index) async {
          if (index == 2) throw StateError('disk full');
        },
      );

      await expectLater(repo.saveItems(batch), throwsA(isA<StorageFailure>()));

      final count = await t.db.get('SELECT count(*) AS n FROM wardrobe_items');
      expect(count['n'], 0);
    });

    test('[TASK-005-S05] a failed save keeps the existing Archive', () async {
      await LocalWardrobeRepository(db: t.db, ownerId: _owner)
          .saveItems([wardrobeItem('65f0c1a2b3c4d5e6f7a8b9aa')]);
      final failing = LocalWardrobeRepository(
        db: t.db,
        ownerId: _owner,
        onInsert: (index) async {
          if (index == 1) throw StateError('disk full');
        },
      );

      await expectLater(
          failing.saveItems(batch), throwsA(isA<StorageFailure>()));

      expect(await failing.countEligible(), 1);
    });

    test('[TASK-005-S03] the Archive survives closing and reopening', () async {
      await LocalWardrobeRepository(db: t.db, ownerId: _owner).saveItems(batch);

      final reopened = await t.reopen();
      final repo = LocalWardrobeRepository(db: reopened, ownerId: _owner);

      final page = await repo.getItems();
      expect(page.items, batch);
      expect(page.total, 3);
    });

    test("[TASK-005-S08] another owner's rows are not listed", () async {
      await LocalWardrobeRepository(db: t.db, ownerId: 'someone_else')
          .saveItems([wardrobeItem('65f0c1a2b3c4d5e6f7a8b9bb')]);

      final repo = LocalWardrobeRepository(db: t.db, ownerId: _owner);

      expect(await repo.countEligible(), 0);
      expect((await repo.getItems()).items, isEmpty);
    });
  });
}
