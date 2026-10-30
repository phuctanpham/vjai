import 'dart:ffi';
import 'dart:io';

import 'package:garblo/core/storage/garblo_database.dart';
import 'package:garblo/core/storage/secure_store.dart';
import 'package:sqlite3/open.dart' as sqlite_open;
import 'package:sqlite_async/sqlite_async.dart';

/// Points `sqlite3` at the host library. On Windows the DLL lives outside the
/// repo (ci-cd.md): `GARBLO_SQLITE3_DLL` or `F:\tools\sqlite\sqlite3.dll`.
/// Linux and macOS use the system library. Top-level so it can run in the
/// database isolates (`BeforeOpen`).
void useHostSqlite() {
  if (Platform.isLinux) {
    // CI images may ship only the runtime library, without the dev symlink.
    sqlite_open.open.overrideFor(sqlite_open.OperatingSystem.linux, () {
      try {
        return DynamicLibrary.open('libsqlite3.so');
      } on ArgumentError {
        return DynamicLibrary.open('libsqlite3.so.0');
      }
    });
    return;
  }
  if (!Platform.isWindows) return;
  final dll = Platform.environment['GARBLO_SQLITE3_DLL'] ??
      r'F:\tools\sqlite\sqlite3.dll';
  sqlite_open.open.overrideFor(
    sqlite_open.OperatingSystem.windows,
    () => DynamicLibrary.open(dll),
  );
}

/// A Garblo database in a temporary directory, opened through
/// `GarbloDatabase.open` so every test exercises the real migrations.
class TestDatabase {
  static const String testKey =
      '00112233445566778899aabbccddeeff00112233445566778899aabbccddeeff';

  final Directory dir;
  final String path;
  SqliteDatabase db;

  TestDatabase._(this.dir, this.path, this.db);

  static Future<TestDatabase> open() async {
    final dir = await Directory.systemTemp.createTemp('garblo_test_');
    final path = '${dir.path}${Platform.pathSeparator}garblo.db';
    final db = await GarbloDatabase.open(
      path: path,
      key: testKey,
      beforeOpen: useHostSqlite,
    );
    return TestDatabase._(dir, path, db);
  }

  /// Closes and opens the same file again, like an app restart.
  Future<SqliteDatabase> reopen() async {
    await db.close();
    db = await GarbloDatabase.open(
      path: path,
      key: testKey,
      beforeOpen: useHostSqlite,
    );
    return db;
  }

  /// What a killed app leaves on disk at this moment: the database file and
  /// its WAL, copied while this connection stays open (even mid-transaction),
  /// then opened as the restarted app would open them. The shared-memory
  /// index is left out; SQLite rebuilds it from the WAL, as after a crash.
  Future<TestDatabase> crashImage() async {
    final dir = await Directory.systemTemp.createTemp('garblo_crash_');
    final copy = '${dir.path}${Platform.pathSeparator}garblo.db';
    for (final suffix in ['', '-wal']) {
      final file = File('$path$suffix');
      if (await file.exists()) await file.copy('$copy$suffix');
    }
    final db = await GarbloDatabase.open(
      path: copy,
      key: testKey,
      beforeOpen: useHostSqlite,
    );
    return TestDatabase._(dir, copy, db);
  }

  Future<void> dispose() async {
    try {
      await db.close();
    } catch (_) {
      // Already closed by the test (e.g. after a wipe).
    }
    if (await dir.exists()) await dir.delete(recursive: true);
  }
}

/// A temporary directory removed after the test.
Future<Directory> tempDir(String prefix) =>
    Directory.systemTemp.createTemp('garblo_${prefix}_');

/// In-memory [SecureStore] for tests.
class FakeSecureStore implements SecureStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
