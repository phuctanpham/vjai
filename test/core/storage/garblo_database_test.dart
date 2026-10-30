import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/errors/failures.dart';
import 'package:garblo/core/storage/garblo_database.dart';
import 'package:garblo/core/storage/phone_schema.dart';
import 'package:garblo/features/wardrobe/domain/item_type.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../helpers/local_db.dart';

void main() {
  group('GarbloDatabase.open', () {
    late TestDatabase t;

    setUp(() async => t = await TestDatabase.open());
    tearDown(() async => t.dispose());

    test('[TASK-005-S01] a fresh file migrates from 0 to the current version',
        () async {
      expect(await GarbloDatabase.schemaVersion(t.db), PhoneSchema.version);
      final userVersion = await t.db.get('PRAGMA user_version');
      expect(userVersion['user_version'], PhoneSchema.version);

      final tables = await t.db
          .getAll("SELECT name FROM sqlite_master WHERE type = 'table'");
      expect(tables.map((r) => r['name']),
          containsAll(PhoneSchema.tables.map((s) => s.name)));
    });

    test('[TASK-005-S01] the item-type catalog is seeded locally', () async {
      final rows = await t.db
          .getAll('SELECT id, type_code, group_code, label FROM item_types');

      expect(rows.map((r) => r['type_code']).toSet(),
          ItemTypeCatalog.all.map((type) => type.code).toSet());
      for (final type in ItemTypeCatalog.all) {
        final row = rows.singleWhere((r) => r['type_code'] == type.code);
        expect(row['id'], type.code);
        expect(row['group_code'], type.group.name.toUpperCase());
        expect(row['label'], type.label);
      }
    });

    test('[TASK-005-S01] reopening keeps rows and does not migrate again',
        () async {
      await t.db.execute(
        "INSERT INTO consents(id, user_id, version, includes_body, granted_at)"
        " VALUES ('65f0c1a2b3c4d5e6f7a8b9c0', 'owner', 'v1', 1, '2026-10-29')",
      );

      final reopened = await t.reopen();

      final rows = await reopened.getAll('SELECT id FROM consents');
      expect(rows, hasLength(1));
      final types = await reopened.get('SELECT count(*) AS n FROM item_types');
      expect(types['n'], ItemTypeCatalog.all.length);
      expect(await GarbloDatabase.schemaVersion(reopened), PhoneSchema.version);
    });

    test('[TASK-005-S01] a write transaction that throws rolls back', () async {
      await expectLater(
        t.db.writeTransaction((tx) async {
          await tx.execute(
            "INSERT INTO consents(id, user_id, version) VALUES ('a', 'o', 'v1')",
          );
          throw StateError('boom');
        }),
        throwsStateError,
      );

      final rows = await t.db.getAll('SELECT id FROM consents');
      expect(rows, isEmpty);
    });
  });

  group('GarbloOpenFactory', () {
    test('[TASK-005-S10] PRAGMA key is the first statement of every connection',
        () {
      const key = TestDatabase.testKey;
      const factory = GarbloOpenFactory(path: 'unused.db', key: key);

      for (final options in const [
        SqliteOpenOptions(primaryConnection: true, readOnly: false),
        SqliteOpenOptions(primaryConnection: false, readOnly: true),
      ]) {
        final statements = factory.pragmaStatements(options);
        expect(statements.first, "PRAGMA key = \"x'$key'\"");
      }
    });
  });

  group('GarbloDatabase failures', () {
    late Directory dir;

    setUp(() async => dir = await tempDir('db_fail'));
    tearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    test('[TASK-005-S09] a file that is not a database is a StorageFailure',
        () async {
      final path = '${dir.path}${Platform.pathSeparator}garblo.db';
      await File(path).writeAsString('this is not a database, ' * 100);

      await expectLater(
        GarbloDatabase.open(
            path: path, key: TestDatabase.testKey, beforeOpen: useHostSqlite),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('[TASK-005-S09] a newer schema than the app knows is a StorageFailure',
        () async {
      final path = '${dir.path}${Platform.pathSeparator}garblo.db';
      final first = await GarbloDatabase.open(
          path: path, key: TestDatabase.testKey, beforeOpen: useHostSqlite);
      await first.execute('PRAGMA user_version = ${PhoneSchema.version + 1}');
      await first.close();

      await expectLater(
        GarbloDatabase.open(
            path: path, key: TestDatabase.testKey, beforeOpen: useHostSqlite),
        throwsA(isA<StorageFailure>()),
      );
    });

    test('[TASK-005-S09] an unreachable path is a StorageFailure', () async {
      final path = [dir.path, 'missing', 'nested', 'garblo.db']
          .join(Platform.pathSeparator);

      await expectLater(
        GarbloDatabase.open(
            path: path, key: TestDatabase.testKey, beforeOpen: useHostSqlite),
        throwsA(isA<StorageFailure>()),
      );
    });
  });

  group('GarbloDatabase.filesFor', () {
    test('[TASK-008-S04] lists the database, WAL and shared-memory files', () {
      expect(GarbloDatabase.filesFor('/data/garblo.db'), [
        '/data/garblo.db',
        '/data/garblo.db-wal',
        '/data/garblo.db-shm',
      ]);
    });
  });
}
