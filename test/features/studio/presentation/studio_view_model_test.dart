import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/errors/failures.dart';
import 'package:garblo/core/media/photo_picker.dart';
import 'package:garblo/features/studio/data/studio_repository.dart';
import 'package:garblo/features/studio/domain/analysis_selection.dart';
import 'package:garblo/features/studio/domain/analysis_task.dart';
import 'package:garblo/features/studio/domain/batch_status.dart';
import 'package:garblo/features/studio/domain/last_worn.dart';
import 'package:garblo/features/studio/domain/media_asset.dart';
import 'package:garblo/features/studio/domain/privacy_consent.dart';
import 'package:garblo/features/studio/domain/review_draft.dart';
import 'package:garblo/features/studio/presentation/studio_view_model.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/domain/item_group.dart';
import 'package:garblo/features/wardrobe/domain/wardrobe_item.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/wardrobe_fixtures.dart';

/// Studio repository whose analysis completes only when the test says so.
class _ControlledStudioRepository extends MockStudioRepository {
  final List<Completer<ReviewDraft>> pending = [];

  @override
  Future<ReviewDraft> analyze({
    required List<MediaAsset> assets,
    required AnalysisSelection selection,
  }) {
    final completer = Completer<ReviewDraft>();
    pending.add(completer);
    return completer.future;
  }
}

/// Wardrobe repository that fails the first save, or holds saves open.
class _ScriptedWardrobeRepository extends MockWardrobeRepository {
  final bool failFirstSave;
  final Completer<void>? hold;
  int saveCalls = 0;

  _ScriptedWardrobeRepository({this.failFirstSave = false, this.hold});

  @override
  Future<void> saveItems(List<WardrobeItem> items) async {
    saveCalls++;
    if (hold != null) await hold!.future;
    if (failFirstSave && saveCalls == 1) {
      throw const StorageFailure('Could not save your items.');
    }
    return super.saveItems(items);
  }
}

void main() {
  late MockStudioRepository studio;
  late MockWardrobeRepository wardrobe;
  late FakePhotoPicker picker;

  StudioViewModel build({
    StudioRepository? studioRepository,
    WardrobeRepository? wardrobeRepository,
    List<List<PickedPhoto>>? picks,
  }) {
    picker = FakePhotoPicker(picks ?? [PresetPhotoPicker.presets]);
    return StudioViewModel(
      studioRepository: studioRepository ?? studio,
      wardrobeRepository: wardrobeRepository ?? wardrobe,
      photoPicker: picker,
      clock: FixedClock(testToday),
    );
  }

  /// Picks the three presets, consents and opens the scope sheet.
  Future<StudioViewModel> openSheet([StudioViewModel? existing]) async {
    final vm = existing ?? build();
    await vm.pickPhotos();
    vm.setConsent(true);
    await vm.analyze();
    return vm;
  }

  /// Runs the default analysis to the review state.
  Future<StudioViewModel> reviewing([StudioViewModel? existing]) async {
    final vm = await openSheet(existing);
    await vm.confirmScope();
    return vm;
  }

  setUp(() {
    studio = MockStudioRepository();
    wardrobe = MockWardrobeRepository();
  });

  group('tray and consent gate', () {
    test('[TASK-003-S01] starts as an empty draft with Analyze disabled', () {
      final vm = build();

      expect(vm.state.batchStatus, BatchStatus.draft);
      expect(vm.state.tray.isEmpty, isTrue);
      expect(vm.state.consentChecked, isFalse);
      expect(vm.state.canAnalyze, isFalse);
    });

    test('[TASK-003-S01] Analyze needs photos and consent (I1)', () async {
      final vm = build();

      vm.setConsent(true);
      expect(vm.state.canAnalyze, isFalse, reason: 'consent, no photos');

      vm.setConsent(false);
      await vm.pickPhotos();
      expect(vm.state.canAnalyze, isFalse, reason: 'photos, no consent');

      vm.setConsent(true);
      expect(vm.state.canAnalyze, isTrue);

      vm.setConsent(false);
      expect(vm.state.canAnalyze, isFalse);
    });

    test('[TASK-003-S01] consent stays checked when photos drop to 0 (AC-01.7)',
        () async {
      final vm = build(picks: [
        [jpg('tee')],
      ]);
      await vm.pickPhotos();
      vm.setConsent(true);

      vm.removePhoto(vm.state.tray.assets.single.assetId);

      expect(vm.state.consentChecked, isTrue);
      expect(vm.state.canAnalyze, isFalse);
    });

    test('[TASK-003-S01] Analyze records consent and opens the scope sheet',
        () async {
      final vm = await openSheet();

      expect(vm.state.batchStatus, BatchStatus.sanitizing);
      expect(vm.state.isScopeSheetOpen, isTrue);
      // The 1a consent reads "Process my photos, including body photos if
      // any", and the UC-01 submit contract sends includes_body_processing.
      expect(studio.recordedConsents, [
        PrivacyConsent(
          version: PrivacyConsent.studioVersion,
          grantedAt: testToday,
          includesBodyProcessing: true,
        ),
      ]);
      expect(vm.state.consent, studio.recordedConsents.single);
    });

    test('[TASK-003-S01] Analyze is ignored while the gate is closed',
        () async {
      final vm = build();
      await vm.pickPhotos();

      await vm.analyze();

      expect(vm.state.batchStatus, BatchStatus.draft);
      expect(studio.recordedConsents, isEmpty);
    });

    test('[TASK-003-S02] removing a photo keeps the others in order', () async {
      final vm = build();
      await vm.pickPhotos();
      final uris = vm.state.tray.assets.map((a) => a.uri).toList();

      vm.removePhoto(vm.state.tray.assets[1].assetId);

      expect(vm.state.tray.assets.map((a) => a.uri), [uris[0], uris[2]]);
    });

    test('[TASK-003-S02] removing the last photo returns to the empty state',
        () async {
      final vm = build(picks: [
        [jpg('tee')],
      ]);
      await vm.pickPhotos();

      vm.removePhoto(vm.state.tray.assets.single.assetId);

      expect(vm.state.tray.isEmpty, isTrue);
      expect(vm.state.batchStatus, BatchStatus.draft);
    });
  });

  group('picker limits', () {
    test(
        '[TASK-003-S09] the picker is asked for the remaining capacity (AC-01.2)',
        () async {
      final vm = build(picks: [
        [jpg('a'), jpg('b'), jpg('c')],
        [jpg('d')],
      ]);

      await vm.pickPhotos();
      await vm.pickPhotos();

      expect(picker.requestedMaxCounts, [10, 7]);
      expect(vm.state.tray.count, 4);
    });

    test('[TASK-003-S09] skipped files produce a notice', () async {
      final vm = build(picks: [
        [jpg('a'), heic('b')],
      ]);

      await vm.pickPhotos();

      expect(vm.state.tray.count, 1);
      expect(vm.state.notice,
          'Only JPG and PNG are supported. 1 file was skipped.');
    });

    test('[TASK-003-S09] photos over the limit produce a notice', () async {
      final vm = build(picks: [
        [for (var i = 0; i < 12; i++) jpg('p$i')],
      ]);

      await vm.pickPhotos();

      expect(vm.state.tray.count, 10);
      expect(vm.state.notice,
          "You can add up to 10 photos per batch. 2 weren't added.");
    });

    test('[TASK-003-S09] a full tray does not open the picker', () async {
      final vm = build(picks: [
        [for (var i = 0; i < 10; i++) jpg('p$i')],
        [jpg('extra')],
      ]);
      await vm.pickPhotos();

      await vm.pickPhotos();

      expect(picker.requestedMaxCounts, [10]);
      expect(vm.state.tray.count, 10);
    });
  });

  group('scope sheet', () {
    test('[TASK-003-S03] Reselect photos returns to DRAFT and keeps input',
        () async {
      final vm = await openSheet();
      final tray = vm.state.tray;

      vm.reselectPhotos();

      expect(vm.state.batchStatus, BatchStatus.draft);
      expect(vm.state.isScopeSheetOpen, isFalse);
      expect(vm.state.tray, tray);
      expect(vm.state.consentChecked, isTrue);
      expect(vm.state.canAnalyze, isTrue);

      vm.removePhoto(tray.assets.first.assetId);
      expect(vm.state.tray.count, 2, reason: 'tray is editable again');
    });

    test('[TASK-003-S10] OK is disabled and ignored with no task checked',
        () async {
      final vm = await openSheet();

      vm.toggleTask(AnalysisTask.outfitExtraction);
      expect(vm.state.canConfirmScope, isFalse);

      await vm.confirmScope();
      expect(vm.state.batchStatus, BatchStatus.sanitizing);
      expect(studio.analyzedAssets, isEmpty);
    });
  });

  group('analysis outcomes', () {
    test('[TASK-003-S11] analysis is in progress until results arrive',
        () async {
      final controlled = _ControlledStudioRepository();
      final vm = await openSheet(build(studioRepository: controlled));

      final running = vm.confirmScope();
      await pumpEventQueue();
      expect(vm.state.batchStatus, BatchStatus.aiProcessing);

      controlled.pending.single.complete(
        await MockStudioRepository().analyze(
          assets: vm.state.tray.assets,
          selection: AnalysisSelection.defaults(),
        ),
      );
      await running;
      expect(vm.state.batchStatus, BatchStatus.awaitingReview);
    });

    test('[TASK-003-S11] success opens review on the first item', () async {
      final vm = await reviewing();

      expect(vm.state.batchStatus, BatchStatus.awaitingReview);
      expect(vm.state.review!.items, hasLength(3));
      expect(vm.state.expandedIndex, 0);
      expect(vm.state.saveLabel, 'Index 3 Pieces');
    });

    test(
        '[TASK-003-S11] a partial result still reviews the Pieces that succeeded',
        () async {
      studio = MockStudioRepository(
        failingUris: {PresetPhotoPicker.presets[0].uri},
      );
      final vm = await reviewing();

      expect(vm.state.batchStatus, BatchStatus.awaitingReview);
      expect(vm.state.review!.outcome, AnalysisOutcome.partial);
      expect(vm.state.review!.items.map((i) => i.name),
          ['Wide-leg trousers', 'Cream sneakers']);
      expect(vm.state.review!.failureNote, "1 photo couldn't be read");
      expect(vm.state.saveLabel, 'Index 2 Pieces');
      expect(vm.state.canSave, isTrue);
    });

    test('[TASK-003-S11] all photos unreadable fails the batch and keeps input',
        () async {
      studio = MockStudioRepository(
        failingUris: PresetPhotoPicker.presets.map((p) => p.uri).toSet(),
      );
      final vm = await reviewing();

      expect(vm.state.batchStatus, BatchStatus.failed);
      expect(vm.state.errorMessage, "Couldn't read these photos.");
      expect(vm.state.review, isNull);
      expect(vm.state.tray.count, 3);
      expect(vm.state.consentChecked, isTrue);
    });

    test('[TASK-003-S11] Try again re-runs the analysis after a failure',
        () async {
      final controlled = _ControlledStudioRepository();
      final vm = await openSheet(build(studioRepository: controlled));
      final first = vm.confirmScope();
      await pumpEventQueue();
      controlled.pending.single.complete(
        const ReviewDraft(photoCount: 3, failedPhotoCount: 3, items: []),
      );
      await first;
      expect(vm.state.batchStatus, BatchStatus.failed);

      final retry = vm.retryAnalysis();
      await pumpEventQueue();
      expect(controlled.pending, hasLength(2));
      controlled.pending.last.complete(
        await MockStudioRepository().analyze(
          assets: vm.state.tray.assets,
          selection: AnalysisSelection.defaults(),
        ),
      );
      await retry;

      expect(vm.state.batchStatus, BatchStatus.awaitingReview);
      expect(vm.state.errorMessage, isNull);
    });

    test('[TASK-003-S11] Reselect photos after a failure returns to DRAFT',
        () async {
      studio = MockStudioRepository(
        failingUris: PresetPhotoPicker.presets.map((p) => p.uri).toSet(),
      );
      final vm = await reviewing();

      vm.reselectPhotos();

      expect(vm.state.batchStatus, BatchStatus.draft);
      expect(vm.state.tray.count, 3);
      expect(vm.state.consentChecked, isTrue);
      expect(vm.state.canAnalyze, isTrue);
    });

    test('[TASK-003-S11] an analysis error fails the batch visibly', () async {
      studio = MockStudioRepository(shouldFail: true);
      final vm = await reviewing();

      expect(vm.state.batchStatus, BatchStatus.failed);
      expect(vm.state.errorMessage, isNotNull);
    });

    test('[TASK-003-S11] zero items leaves nothing to save', () async {
      final vm = await reviewing(build(picks: [
        [jpg('landscape')],
      ]));

      expect(vm.state.batchStatus, BatchStatus.awaitingReview);
      expect(vm.state.review!.outcome, AnalysisOutcome.zeroItems);
      expect(vm.state.saveLabel, 'Nothing to index');
      expect(vm.state.canSave, isFalse);
    });
  });

  group('review', () {
    test('[TASK-003-S04] editing updates the draft and marks it modified',
        () async {
      final vm = await reviewing();

      vm.editItem(0, typeCode: 'T_SHIRT', material: 'Linen');

      final item = vm.state.review!.items[0];
      expect(item.value.typeCode, 'T_SHIRT');
      expect(item.value.material, 'Linen');
      expect(item.ai.material, 'Cotton');
      expect(item.userModified, isTrue);
      expect(item.group, ItemGroup.tops);
    });

    test('[TASK-003-S04] edits survive expanding another item (AC-03.4)',
        () async {
      final vm = await reviewing();
      vm.editItem(0, color: 'Navy');

      vm.expandItem(1);

      expect(vm.state.expandedIndex, 1);
      expect(vm.state.review!.items[0].value.color, 'Navy');
    });

    test('[TASK-003-S04] the type picker moves the item to its new group',
        () async {
      final vm = await reviewing();

      vm.editItem(2, typeCode: 'LOAFERS');

      expect(vm.state.review!.items[2].group, ItemGroup.shoes);
      vm.editItem(2, typeCode: 'TOTE_BAG');
      expect(vm.state.review!.items[2].group, ItemGroup.bags);
    });
  });

  group('save', () {
    test('[TASK-003-S05] saves every reviewed item and completes the batch',
        () async {
      wardrobe = MockWardrobeRepository(items: [
        wardrobeItem('old', createdAt: daysBefore(3)),
      ]);
      final vm = await reviewing();
      vm.editItem(0, material: 'Linen');

      await vm.save();

      expect(vm.state.batchStatus, BatchStatus.completed);
      final page = await wardrobe.getItems();
      expect(page.total, 4);
      final saved = page.items.take(3).toList();
      expect(saved.map((i) => i.name),
          ['Violet shirt', 'Wide-leg trousers', 'Cream sneakers']);
      expect(saved[0].material, 'Linen');
      expect(saved[0].typeCode, 'SHIRT');
      expect(saved[0].aiConfidence, 0.94);
      expect(saved[0].sourceAssetId, vm.state.tray.assets[0].assetId);
      expect(saved[0].createdAt, testToday);
      expect(saved[0].isArchived, isFalse);
    });

    test('[TASK-003-S05] a new batch reuses the recorded consent (D3)',
        () async {
      final vm = await reviewing(build(picks: [
        PresetPhotoPicker.presets,
        PresetPhotoPicker.presets,
      ]));
      await vm.save();

      vm.startNewBatch();

      expect(vm.state.batchStatus, BatchStatus.draft);
      expect(vm.state.tray.isEmpty, isTrue);
      expect(vm.state.review, isNull);
      expect(vm.state.consentChecked, isTrue);

      await vm.pickPhotos();
      await vm.analyze();
      expect(vm.state.isScopeSheetOpen, isTrue);
      expect(studio.recordedConsents, hasLength(1));
    });

    test('[TASK-003-S06] a failed save keeps the draft and offers retry',
        () async {
      final flaky = _ScriptedWardrobeRepository(failFirstSave: true);
      final vm = await reviewing(build(wardrobeRepository: flaky));
      vm.editItem(1, color: 'Black');

      await vm.save();

      expect(vm.state.batchStatus, BatchStatus.awaitingReview);
      expect(vm.state.isSaving, isFalse);
      expect(vm.state.errorMessage, isNotNull);
      expect(vm.state.review!.items[1].value.color, 'Black');
      expect((await flaky.getItems()).total, 0);

      await vm.save();

      expect(vm.state.batchStatus, BatchStatus.completed);
      expect(vm.state.errorMessage, isNull);
      expect((await flaky.getItems()).total, 3);
    });

    test('[TASK-003-S06] duplicate saves are ignored while saving', () async {
      final hold = Completer<void>();
      final slow = _ScriptedWardrobeRepository(hold: hold);
      final vm = await reviewing(build(wardrobeRepository: slow));

      final first = vm.save();
      await pumpEventQueue();
      expect(vm.state.isSaving, isTrue);
      expect(vm.state.canSave, isFalse);
      await vm.save();
      hold.complete();
      await first;

      expect(slow.saveCalls, 1);
      expect((await slow.getItems()).total, 3);
    });

    test('[TASK-003-S13] Last worn is saved as the item estimate (C3)',
        () async {
      final vm = await reviewing();

      vm.setLastWorn(0, const LastWornInput(LastWornOption.oneToThreeMonths));
      await vm.save();

      final shirt = (await wardrobe.getItems())
          .items
          .singleWhere((i) => i.name == 'Violet shirt');
      expect(shirt.lastWornEstimate, DateTime(2026, 9, 29));
      final trousers = (await wardrobe.getItems())
          .items
          .singleWhere((i) => i.name == 'Wide-leg trousers');
      expect(trousers.lastWornEstimate, isNull,
          reason: "Don't remember: dormancy falls back to the save date");
    });

    test('[TASK-003-S13] a future Last worn date is rejected (A-01)', () async {
      final vm = await reviewing();

      vm.setLastWorn(
        0,
        LastWornInput(LastWornOption.exactDate,
            exactDate: DateTime(2026, 11, 2)),
      );

      expect(vm.state.review!.items[0].lastWorn,
          const LastWornInput.dontRemember());
    });
  });
}
