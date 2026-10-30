import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/errors/failures.dart';
import 'package:garblo/features/studio/data/studio_repository.dart';
import 'package:garblo/features/studio/domain/analysis_selection.dart';
import 'package:garblo/features/studio/domain/media_asset.dart';
import 'package:garblo/features/studio/domain/photo_storage.dart';
import 'package:garblo/features/studio/domain/privacy_consent.dart';
import 'package:garblo/features/studio/domain/review_draft.dart';
import 'package:garblo/features/studio/domain/upload_batch.dart';
import 'package:garblo/features/studio/presentation/studio_view_model.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/wardrobe_fixtures.dart';

/// Studio repository whose analysis is held open, recording every write.
class _HeldRepository extends MockStudioRepository {
  final Completer<void> hold = Completer<void>();
  final bool failAfterHold;
  final List<UploadBatch> savedBatches = [];

  _HeldRepository({this.failAfterHold = false})
      : super(fixtures: const {
          'test://a.jpg': [],
        });

  @override
  Future<ReviewDraft> analyze({
    required List<MediaAsset> assets,
    required AnalysisSelection selection,
  }) async {
    await hold.future;
    if (failAfterHold) throw const ServerFailure('gone');
    return super.analyze(assets: assets, selection: selection);
  }

  @override
  Future<PrivacyConsent?> activeConsent() async => null;

  @override
  Future<UploadBatch?> loadOpenBatch() async => null;

  @override
  Future<void> saveBatch(UploadBatch batch) async => savedBatches.add(batch);

  @override
  Future<PhotoStorageResult> storePhotos({
    required String batchId,
    required List<StagedPhoto> photos,
  }) async =>
      PhotoStorageResult(
          stored: [for (final p in photos) p.asset], failedAssetIds: const []);

  @override
  Future<void> discardBatch(String batchId) async {}
}

void main() {
  Future<StudioViewModel> scopeOpen(_HeldRepository repo) async {
    final vm = StudioViewModel(
      studioRepository: repo,
      wardrobeRepository: MockWardrobeRepository(),
      photoPicker: FakePhotoPicker([
        [jpg('a')],
      ]),
      clock: FixedClock(testToday),
    );
    await vm.pickPhotos();
    vm.setConsent(true);
    await vm.analyze();
    return vm;
  }

  test('[TASK-008-S07] an analysis finishing after the wipe writes nothing',
      () async {
    final repo = _HeldRepository();
    final vm = await scopeOpen(repo);
    final pending = vm.confirmScope();
    await Future<void>.delayed(Duration.zero);
    final writesBefore = repo.savedBatches.length;

    vm.dispose(); // "Delete all" restarts the app on a fresh store
    repo.hold.complete();

    await expectLater(pending, completes);
    expect(repo.savedBatches.length, writesBefore);
  });

  test('[TASK-008-S07] a failure after the wipe does not throw either',
      () async {
    final repo = _HeldRepository(failAfterHold: true);
    final vm = await scopeOpen(repo);
    final pending = vm.confirmScope();
    await Future<void>.delayed(Duration.zero);

    vm.dispose();
    repo.hold.complete();

    await expectLater(pending, completes);
  });
}
