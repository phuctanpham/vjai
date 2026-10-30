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

  LocalDataStore({
    required this.databasePath,
    required this.attachments,
    required this.identity,
    this.beforeOpen,
  });

  /// The open database. Valid after [open] or [wipe].
  SqliteDatabase get database => throw UnimplementedError('TASK-008-S05');

  /// Opens the database with the install's key.
  Future<SqliteDatabase> open() => throw UnimplementedError('TASK-008-S05');

  /// Closes the database, deletes its files and every attachment, forgets
  /// the database key, then reopens a fresh database (TASK-008-S04…S06).
  Future<SqliteDatabase> wipe() => throw UnimplementedError('TASK-008-S04');
}
