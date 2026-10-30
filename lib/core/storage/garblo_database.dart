import 'package:sqlite_async/sqlite3_common.dart';
import 'package:sqlite_async/sqlite_async.dart';

/// Runs in every connection's isolate before the database file is opened,
/// e.g. to point `sqlite3` at SQLCipher on Android or at a host library in
/// tests. Must be a top-level or static function.
typedef BeforeOpen = void Function();

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
  CommonDatabase openDB(SqliteOpenOptions options) =>
      throw UnimplementedError('TASK-005-S10');

  @override
  List<String> pragmaStatements(SqliteOpenOptions options) =>
      throw UnimplementedError('TASK-005-S10');
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
  }) =>
      throw UnimplementedError('TASK-005-S01');

  /// The migrated schema version of [db].
  static Future<int> schemaVersion(SqliteConnection db) =>
      throw UnimplementedError('TASK-005-S01');

  /// Every file SQLite keeps for [path] (database, WAL and shared memory).
  static List<String> filesFor(String path) =>
      throw UnimplementedError('TASK-008-S04');
}
