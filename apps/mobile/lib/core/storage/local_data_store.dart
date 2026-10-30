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

  /// Opens the database with the install's key, then removes photo files
  /// that no row references (CHG-009 V-02, TASK-009-S07).
  Future<SqliteDatabase> open() async {
    final key = await identity.databaseKey();
    final db = _database = await GarbloDatabase.open(
      path: databasePath,
      key: key,
      beforeOpen: beforeOpen,
    );
    await _removeOrphanAttachments(db);
    return db;
  }

  /// Files are written before their row and deleted after it, so a kill in
  /// between can only leave a file without a row, never a row without its
  /// file. Runs before the app uses the store, so no write is in flight.
  Future<void> _removeOrphanAttachments(SqliteDatabase db) async {
    try {
      final rows = await db.getAll(
        'SELECT attachment_id AS id FROM media_assets '
        'WHERE attachment_id IS NOT NULL '
        'UNION SELECT cutout_attachment_id FROM wardrobe_items '
        'WHERE cutout_attachment_id IS NOT NULL '
        'UNION SELECT cutout_attachment_id FROM extracted_items '
        'WHERE cutout_attachment_id IS NOT NULL',
      );
      final referenced = {for (final row in rows) row['id'] as String};
      for (final id in await attachments.listIds()) {
        if (!referenced.contains(id)) await attachments.delete(id);
      }
    } catch (_) {
      // Best effort: an orphan is retried at the next open and removed by
      // "Delete all"; it must not stop the app from opening.
    }
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
