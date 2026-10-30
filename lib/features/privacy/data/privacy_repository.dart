import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_data_store.dart';
import '../../../core/time/clock.dart';
import '../domain/erasure_counts.dart';

/// Provider for PrivacyRepository, overridden in `main()` with the local
/// store.
final privacyRepositoryProvider = Provider<PrivacyRepository>((ref) {
  throw StateError('Create the privacy repository in main() before using it.');
});

/// UC-09 on the phone: counts, withdraw body-photo consent, delete all.
abstract class PrivacyRepository {
  Future<ErasureCounts> counts();

  /// Sets `revoked_at` on active consents and deletes body-reference photos
  /// and try-on images; Pieces stay (AC-09.3).
  Future<void> withdrawBodyConsent();

  /// Deletes every photo, Piece, wear event, batch, consent and Gu Match
  /// history on this phone (AC-09.4, local part).
  Future<void> deleteAll();
}

/// [PrivacyRepository] over the [LocalDataStore].
class LocalPrivacyRepository implements PrivacyRepository {
  LocalPrivacyRepository({required LocalDataStore store, required Clock clock});

  @override
  Future<ErasureCounts> counts() => throw UnimplementedError('TASK-008-S02');

  @override
  Future<void> withdrawBodyConsent() =>
      throw UnimplementedError('TASK-008-S03');

  @override
  Future<void> deleteAll() => throw UnimplementedError('TASK-008-S04');
}
