import 'dart:math';

import 'object_id.dart';
import 'secure_store.dart';

/// Per-install secrets, created once and kept in secure storage
/// (CHG-005 P2-D9, P2-D12).
class InstallIdentity {
  static const String ownerIdKey = 'garblo.owner_id';
  static const String databaseKeyKey = 'garblo.database_key';

  InstallIdentity({
    required SecureStore store,
    required ObjectIdGenerator ids,
    Random? random,
  });

  /// A random ObjectId, generated on first use and then reused. In P4 it
  /// becomes the anonymous identity's `sub` (BE-006).
  Future<String> ownerId() => throw UnimplementedError('TASK-005-S10');

  /// The database key: 64 hex characters (32 random bytes), generated on
  /// first use and then reused.
  Future<String> databaseKey() => throw UnimplementedError('TASK-005-S10');

  /// Forgets the database key ("Delete all"); the owner ID is kept.
  Future<void> deleteDatabaseKey() => throw UnimplementedError('TASK-008-S04');
}
