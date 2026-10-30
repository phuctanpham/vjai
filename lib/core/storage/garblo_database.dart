import 'package:sqlite_async/sqlite3_common.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../features/wardrobe/domain/item_type.dart';
import '../errors/failures.dart';
import 'phone_schema.dart';

/// Runs in every connection's isolate before the database file is opened,
/// e.g. to point `sqlite3` at SQLCipher on Android or at a host library in
/// tests. Must be a top-level or static function.
typedef BeforeOpen = void Function();

final RegExp _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// Opens each connection with `PRAGMA key` as its first statement, so the
/// app's SQLCipher build decrypts the file (CHG-005 P2-D1). Plain SQLite in
/// host tests ignores the pragma.
class GarbloOpenFactory extends DefaultSqliteOpenFactory {
  final String key;
  final BeforeOpen? beforeOpen;

  const GarbloOpenFactory({
    required super.path,
    required this.key,
    this.beforeOpen,
  });

  @override
  CommonDatabase openDB(SqliteOpenOptions options) {
    beforeOpen?.call();
    return super.openDB(options);
  }

  /// As the default, but disposes the connection when a setup pragma fails
  /// (e.g. "file is not a database"), so the file is not left locked.
  @override
  CommonDatabase open(SqliteOpenOptions options) {
    final db = openDB(options);
    try {
      for (final statement in pragmaStatements(options)) {
        // Pragmas do not honour busy_timeout; retry like the default.
        for (var tries = 0;; tries++) {
          try {
            db.execute(statement);
            break;
          } on SqliteException catch (e) {
            if (e.resultCode != SqlError.SQLITE_BUSY || tries >= 29) rethrow;
          }
        }
      }
      return db;
    } catch (_) {
      db.dispose();
      rethrow;
    }
  }

  @override
  List<String> pragmaStatements(SqliteOpenOptions options) {
    // The key is hex only, so it cannot break out of the pragma.
    if (!_hexKey.hasMatch(key)) {
      throw ArgumentError.value('<hidden>', 'key', 'Expected 64 hex digits');
    }
    return ["PRAGMA key = \"x'$key'\"", ...super.pragmaStatements(options)];
  }
}

/// Opens and migrates the local database.
class GarbloDatabase {
  const GarbloDatabase._();

  /// Opens [path] with [key] and migrates it to `PhoneSchema.version`.
  /// Throws a `StorageFailure` when the file cannot be opened or migrated;
  /// there is no in-memory fallback (TASK-005-S09).
  static Future<SqliteDatabase> open({
    required String path,
    required String key,
    BeforeOpen? beforeOpen,
  }) async {
    final db = SqliteDatabase.withFactory(
      GarbloOpenFactory(path: path, key: key, beforeOpen: beforeOpen),
    );
    try {
      // The primary connection opens eagerly; await it here so an open
      // error is caught instead of escaping as an unhandled error.
      await db.initialize();
      await _migrate(db);
      return db;
    } on StorageFailure {
      await _closeQuietly(db);
      rethrow;
    } catch (error) {
      await _closeQuietly(db);
      throw StorageFailure(
          "Garblo couldn't open your data on this phone.", error);
    }
  }

  /// The migrated schema version of [db].
  static Future<int> schemaVersion(SqliteConnection db) async {
    final row = await db.get('PRAGMA user_version');
    return row['user_version'] as int;
  }

  /// Every file SQLite keeps for [path] (database, WAL and shared memory).
  static List<String> filesFor(String path) => [path, '$path-wal', '$path-shm'];

  static Future<void> _migrate(SqliteDatabase db) async {
    await db.writeTransaction((tx) async {
      final row = await tx.get('PRAGMA user_version');
      final current = row['user_version'] as int;
      if (current > PhoneSchema.version) {
        throw const StorageFailure(
            'Your data was saved by a newer version of Garblo. '
            'Update the app to open it.');
      }
      if (current < 1) {
        for (final statement in PhoneSchema.createStatements()) {
          await tx.execute(statement);
        }
        for (final type in ItemTypeCatalog.all) {
          await tx.execute(
            'INSERT INTO item_types(id, type_code, group_code, label) '
            'VALUES (?, ?, ?, ?)',
            [type.code, type.code, type.group.name.toUpperCase(), type.label],
          );
        }
      }
      // Later versions add their steps here, each guarded by `current`.
      await tx.execute('PRAGMA user_version = ${PhoneSchema.version}');
    });
  }

  static Future<void> _closeQuietly(SqliteDatabase db) async {
    try {
      await db.close();
    } catch (_) {
      // The open already failed; the original error is reported.
    }
  }
}
