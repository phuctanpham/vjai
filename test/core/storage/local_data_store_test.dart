import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/storage/attachment_store.dart';
import 'package:garblo/core/storage/garblo_database.dart';
import 'package:garblo/core/storage/install_identity.dart';
import 'package:garblo/core/storage/local_data_store.dart';
import 'package:garblo/core/storage/object_id.dart';
import 'package:garblo/core/storage/phone_schema.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/local_db.dart';

void main() {
  late Directory base;
  late FakeSecureStore secrets;
  late InstallIdentity identity;
  late FileAttachmentStore attachments;
  late LocalDataStore store;
  late String dbPath;

  setUp(() async {
    base = await tempDir('store');
    secrets = FakeSecureStore();
    final ids = ObjectIdGenerator(clock: FixedClock(testToday));
    identity = InstallIdentity(store: secrets, ids: ids);
    attachments = FileAttachmentStore(
      root: Directory('${base.path}${Platform.pathSeparator}attachments'),
      ids: ids,
    );
    dbPath = '${base.path}${Platform.pathSeparator}garblo.db';
    store = LocalDataStore(
      databasePath: dbPath,
      attachments: attachments,
      identity: identity,
      beforeOpen: useHostSqlite,
    );
  });

  tearDown(() async {
    try {
      await store.database.close();
    } catch (_) {
      // Not opened or already closed.
    }
    if (await base.exists()) await base.delete(recursive: true);
  });

  List<String> syncedTables() => [
        for (final table in PhoneSchema.tables)
          if (!table.localOnly && table.name != 'item_types') table.name,
      ];

  Future<void> fill() async {
    final db = store.database;
    for (final table in syncedTables()) {
      await db.execute(
          "INSERT INTO $table(id, user_id) VALUES ('65f0c1a2b3c4d5e6f7a8b9c0', 'owner')");
    }
    await db.execute(
        "INSERT INTO session_draft(id, occasions, prompt) VALUES ('current', '[]', 'x')");
    await attachments.save(Uint8List.fromList([1, 2, 3]));
    await attachments.save(Uint8List.fromList([4, 5, 6]));
  }

  Future<int> rowsIn(String table) async {
    final row = await store.database.get('SELECT count(*) AS n FROM $table');
    return row['n'] as int;
  }

  test('[TASK-008-S05] open uses the install key and migrates', () async {
    final db = await store.open();

    expect(identical(db, store.database), isTrue);
    expect(await GarbloDatabase.schemaVersion(db), PhoneSchema.version);
    expect(secrets.values[InstallIdentity.databaseKeyKey], isNotNull);
  });

  test('[TASK-008-S04] delete all removes every row, attachment and the key',
      () async {
    await store.open();
    await fill();
    final oldKey = secrets.values[InstallIdentity.databaseKeyKey];
    final owner = await identity.ownerId();

    await store.wipe();

    for (final table in [...syncedTables(), 'session_draft']) {
      expect(await rowsIn(table), 0, reason: table);
    }
    expect(await attachments.listIds(), isEmpty);
    expect(secrets.values[InstallIdentity.databaseKeyKey], isNot(oldKey));
    expect(await identity.ownerId(), owner,
        reason: 'Delete my data is not Delete account');
  });

  test('[TASK-008-S04] the old database handle is closed by the wipe',
      () async {
    final old = await store.open();

    final fresh = await store.wipe();

    expect(identical(old, fresh), isFalse);
    expect(old.closed, isTrue);
    expect(identical(store.database, fresh), isTrue);
  });

  test('[TASK-008-S04] no WAL or shared-memory file of the old data remains',
      () async {
    await store.open();
    await fill();
    final before = {
      for (final path in GarbloDatabase.filesFor(dbPath))
        if (File(path).existsSync()) path: File(path).lengthSync(),
    };
    expect(before, isNotEmpty);

    await store.wipe();
    await store.database.close();

    final leftovers = await base
        .list()
        .where((e) => e is File)
        .map((e) => e.path)
        .where((p) => !GarbloDatabase.filesFor(dbPath).contains(p))
        .toList();
    expect(leftovers, isEmpty);
    final reopened = await GarbloDatabase.open(
        path: dbPath,
        key: secrets.values[InstallIdentity.databaseKeyKey]!,
        beforeOpen: useHostSqlite);
    final rows = await reopened.get('SELECT count(*) AS n FROM wardrobe_items');
    expect(rows['n'], 0);
    await reopened.close();
  });

  test('[TASK-008-S05] the reopened database is empty and usable', () async {
    await store.open();
    await fill();

    final fresh = await store.wipe();

    expect(await GarbloDatabase.schemaVersion(fresh), PhoneSchema.version);
    await fresh.execute(
        "INSERT INTO consents(id, user_id) VALUES ('65f0c1a2b3c4d5e6f7a8b9c1', 'owner')");
    expect(await rowsIn('consents'), 1);
    final id = await attachments.save(Uint8List.fromList([7]));
    expect(await attachments.exists(id), isTrue);
  });

  test('[TASK-008-S06] the wipe is complete and takes at most 5 s on the host',
      () async {
    await store.open();
    await fill();
    for (var i = 0; i < 20; i++) {
      await attachments.save(Uint8List(64 * 1024));
    }

    final watch = Stopwatch()..start();
    await store.wipe();
    watch.stop();

    expect(watch.elapsed, lessThanOrEqualTo(const Duration(seconds: 5)));
    for (final table in syncedTables()) {
      expect(await rowsIn(table), 0, reason: table);
    }
    expect(await attachments.listIds(), isEmpty);
  });
}
