import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
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

/// [PrivacyRepository] over the [LocalDataStore]. Counts cover this phone's
/// data; Phase 2 has no try-on images yet, so that count is 0.
class LocalPrivacyRepository implements PrivacyRepository {
  final LocalDataStore _store;
  final Clock _clock;

  LocalPrivacyRepository({required LocalDataStore store, required Clock clock})
      : _store = store,
        _clock = clock;

  @override
  Future<ErasureCounts> counts() async {
    try {
      final db = _store.database;
      final row = await db.get(
        'SELECT '
        '(SELECT count(*) FROM media_assets WHERE removed = 0) AS photos, '
        '(SELECT count(*) FROM media_assets '
        ' WHERE removed = 0 AND contains_person = 1) AS body_photos, '
        '(SELECT count(*) FROM wardrobe_items) AS pieces',
      );
      return ErasureCounts(
        photos: row['photos'] as int,
        pieces: row['pieces'] as int,
        bodyPhotos: row['body_photos'] as int,
        tryOnImages: 0,
      );
    } catch (error) {
      throw StorageFailure("Couldn't read your data.", error);
    }
  }

  @override
  Future<void> withdrawBodyConsent() async {
    final files = <String>[];
    try {
      await _store.database.writeTransaction((tx) async {
        // Consents are insert-only: withdrawing sets revoked_at.
        await tx.execute(
          'UPDATE consents SET revoked_at = ? WHERE revoked_at IS NULL',
          [_clock.now().toIso8601String()],
        );
        final body = await tx.getAll(
            'SELECT id, attachment_id FROM media_assets WHERE contains_person = 1');
        for (final row in body) {
          final file = row['attachment_id'] as String?;
          if (file != null) files.add(file);
          await tx.execute(
              'DELETE FROM ai_processing_jobs WHERE asset_id = ?', [row['id']]);
          await tx
              .execute('DELETE FROM media_assets WHERE id = ?', [row['id']]);
        }
      });
    } catch (error) {
      throw StorageFailure("Couldn't withdraw your consent.", error);
    }
    for (final file in files) {
      await _store.attachments.delete(file);
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _store.wipe();
    } catch (error) {
      throw StorageFailure("Couldn't delete your data. Try again.", error);
    }
  }
}
