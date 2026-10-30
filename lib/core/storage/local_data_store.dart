import 'dart:io';

import 'package:sqlite_async/sqlite_async.dart';

import 'attachment_store.dart';
import 'garblo_database.dart';
import 'install_identity.dart';

/// Owns the local database file and the attachments folder, so the whole
/// store can be wiped and reopened fresh (UC-09, CHG-005 P2-D12).
class LocalDataStore {
  final String databasePath;
  final AttachmentStore attachments;
  final InstallIdentity identity;
  final BeforeOpen? beforeOpen;

  SqliteDatabase? _database;

  LocalDataStore({
    required this.databasePath,
    required this.attachments,
    required this.identity,
    this.beforeOpen,
  });

  /// The open database. Valid after [open] or [wipe].
  SqliteDatabase get database =>
      _database ?? (throw StateError('Open the local data store first.'));

  /// Opens the database with the install's key.
  Future<SqliteDatabase> open() async {
    final key = await identity.databaseKey();
    return _database = await GarbloDatabase.open(
      path: databasePath,
      key: key,
      beforeOpen: beforeOpen,
    );
  }

  /// Closes the database, deletes its files and every attachment, forgets
  /// the database key, then reopens a fresh database (TASK-008-S04…S06).
  /// The owner ID is kept: "Delete my data" is not "Delete account".
  Future<SqliteDatabase> wipe() async {
    await _database?.close();
    _database = null;
    for (final path in GarbloDatabase.filesFor(databasePath)) {
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
    await attachments.deleteAll();
    await identity.deleteDatabaseKey();
    return open();
  }
}
