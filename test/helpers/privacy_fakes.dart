import 'dart:async';

import 'package:garblo/core/errors/failures.dart';
import 'package:garblo/features/privacy/data/privacy_repository.dart';
import 'package:garblo/features/privacy/domain/erasure_counts.dart';

/// Counts shown in the privacy tests: 12 photos, 9 Pieces, 2 body photos.
const sampleCounts =
    ErasureCounts(photos: 12, pieces: 9, bodyPhotos: 2, tryOnImages: 0);

/// Records calls; can fail or hold the deletion open.
class FakePrivacyRepository implements PrivacyRepository {
  ErasureCounts current;
  final bool failCounts;
  final bool failDelete;
  Completer<void>? hold;
  int withdrawCalls = 0;
  int deleteCalls = 0;

  FakePrivacyRepository({
    this.current = sampleCounts,
    this.failCounts = false,
    this.failDelete = false,
    this.hold,
  });

  @override
  Future<ErasureCounts> counts() async {
    if (failCounts) throw const StorageFailure('Could not read your data.');
    return current;
  }

  @override
  Future<void> withdrawBodyConsent() async {
    withdrawCalls++;
    await hold?.future;
    current = ErasureCounts(
        photos: current.photos - current.bodyPhotos,
        pieces: current.pieces,
        bodyPhotos: 0,
        tryOnImages: 0);
  }

  @override
  Future<void> deleteAll() async {
    deleteCalls++;
    await hold?.future;
    if (failDelete) throw const StorageFailure('Could not delete.');
    current = ErasureCounts.none;
  }
}
