import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small key-value secrets store (database key, install owner ID).
abstract class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// [SecureStore] backed by the platform keychain / keystore.
class FlutterSecureStore implements SecureStore {
  final FlutterSecureStorage _storage;

  FlutterSecureStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}
