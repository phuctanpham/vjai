import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/networking/api_client.dart';
import '../core/storage/local_storage.dart';

/// Provider for core ApiClient instance.
final apiClientProvider = Provider<ApiClient>((ref) {
  return const MockApiClient();
});

/// Provider for core LocalStorage instance.
final localStorageProvider = Provider<LocalStorage>((ref) {
  return InMemoryLocalStorage();
});
