import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Small key-value secrets store (database key, install owner ID).
abstract class SecureStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// [SecureStore] backed by the platform keychain / keystore.
class FlutterSecureStore implements SecureStore {
  FlutterSecureStore([FlutterSecureStorage? storage]);

  @override
  Future<String?> read(String key) => throw UnimplementedError('TASK-005-S10');

  @override
  Future<void> write(String key, String value) =>
      throw UnimplementedError('TASK-005-S10');

  @override
  Future<void> delete(String key) => throw UnimplementedError('TASK-005-S10');
}
