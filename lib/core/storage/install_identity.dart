import 'dart:math';

import 'object_id.dart';
import 'secure_store.dart';

/// Per-install secrets, created once and kept in secure storage
/// (CHG-005 P2-D9, P2-D12).
class InstallIdentity {
  static const String ownerIdKey = 'garblo.owner_id';
  static const String databaseKeyKey = 'garblo.database_key';

  final SecureStore _store;
  final ObjectIdGenerator _ids;
  final Random _random;

  InstallIdentity({
    required SecureStore store,
    required ObjectIdGenerator ids,
    Random? random,
  })  : _store = store,
        _ids = ids,
        _random = random ?? Random.secure();

  /// A random ObjectId, generated on first use and then reused. In P4 it
  /// becomes the anonymous identity's `sub` (BE-006).
  Future<String> ownerId() => _readOrCreate(ownerIdKey, _ids.next);

  /// The database key: 64 hex characters (32 random bytes), generated on
  /// first use and then reused.
  Future<String> databaseKey() => _readOrCreate(
        databaseKeyKey,
        () => [
          for (var i = 0; i < 32; i++)
            _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
        ].join(),
      );

  /// Forgets the database key ("Delete all"); the owner ID is kept.
  Future<void> deleteDatabaseKey() => _store.delete(databaseKeyKey);

  Future<String> _readOrCreate(String key, String Function() create) async {
    final existing = await _store.read(key);
    if (existing != null) return existing;
    final value = create();
    await _store.write(key, value);
    return value;
  }
}
