import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/errors/failures.dart';
import 'package:garblo/core/media/photo_picker.dart';
import 'package:garblo/features/studio/data/studio_repository.dart';
import 'package:garblo/features/studio/domain/analysis_selection.dart';
import 'package:garblo/features/studio/domain/extracted_item.dart';
import 'package:garblo/features/studio/domain/media_asset.dart';
import 'package:garblo/features/studio/domain/photo_tray.dart';
import 'package:garblo/features/studio/domain/privacy_consent.dart';
import 'package:garblo/features/studio/domain/review_draft.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/wardrobe_fixtures.dart';

List<MediaAsset> _stage(List<PickedPhoto> photos) =>
    PhotoTray.empty().add(photos).tray.assets;

void main() {
  late List<MediaAsset> presets;

  setUp(() => presets = _stage(PresetPhotoPicker.presets));

  group('MockStudioRepository.analyze', () {
    test(
        '[TASK-003-S11] preset photos yield one fixture item each, ordered by slot',
        () async {
      final repo = MockStudioRepository();

      final draft = await repo.analyze(
        assets: presets,
        selection: AnalysisSelection.defaults(),
      );

      expect(draft.outcome, AnalysisOutcome.success);
      expect(draft.photoCount, 3);
      expect(draft.items.map((i) => i.name),
          ['Violet shirt', 'Wide-leg trousers', 'Cream sneakers']);
      expect(draft.items.map((i) => i.slotIndex), [1, 2, 3]);
      final shirt = draft.items.first;
      expect(shirt.confidence, 0.94);
      expect(shirt.value, shirt.ai);
      expect(shirt.userModified, isFalse);
      expect(shirt.assetId, presets.first.assetId);
    });

    test('[TASK-003-S11] one photo may yield several items (C2)', () async {
      const attrs = ItemAttributes(
        typeCode: 'T_SHIRT',
        color: 'White',
        material: 'Cotton',
        styleTag: 'Basic',
      );
      final repo = MockStudioRepository(fixtures: {
        'test://outfit.jpg': const [
          StudioFixtureItem(
              name: 'White T-shirt', confidence: 0.9, attributes: attrs),
          StudioFixtureItem(name: 'Jeans', confidence: 0.8, attributes: attrs),
          StudioFixtureItem(name: 'Belt', confidence: 0.7, attributes: attrs),
        ],
      });

      final draft = await repo.analyze(
        assets: _stage([jpg('outfit')]),
        selection: AnalysisSelection.defaults(),
      );

      expect(draft.items, hasLength(3));
      expect(draft.items.map((i) => i.itemIndex), [1, 2, 3]);
      expect(draft.items.map((i) => i.draftId).toSet(), hasLength(3));
      expect(draft.bannerText, 'FROM 1 PHOTO · 3 PIECES');
    });

    test('[TASK-003-S11] an unreadable photo gives a partial result', () async {
      final repo = MockStudioRepository(
        failingUris: {PresetPhotoPicker.presets[1].uri},
      );

      final draft = await repo.analyze(
        assets: presets,
        selection: AnalysisSelection.defaults(),
      );

      expect(draft.outcome, AnalysisOutcome.partial);
      expect(draft.failedPhotoCount, 1);
      expect(
          draft.items.map((i) => i.name), ['Violet shirt', 'Cream sneakers']);
    });

    test('[TASK-003-S11] every photo unreadable means all failed', () async {
      final repo = MockStudioRepository(
        failingUris: PresetPhotoPicker.presets.map((p) => p.uri).toSet(),
      );

      final draft = await repo.analyze(
        assets: presets,
        selection: AnalysisSelection.defaults(),
      );

      expect(draft.outcome, AnalysisOutcome.allFailed);
      expect(draft.items, isEmpty);
    });

    test('[TASK-003-S11] photos without clothes give zero items', () async {
      final repo = MockStudioRepository();

      final draft = await repo.analyze(
        assets: _stage([jpg('landscape')]),
        selection: AnalysisSelection.defaults(),
      );

      expect(draft.outcome, AnalysisOutcome.zeroItems);
    });

    test('[TASK-003-S08] analysis receives only the staged assets', () async {
      final repo = MockStudioRepository();
      final staged =
          _stage([PresetPhotoPicker.presets[0], PresetPhotoPicker.presets[2]]);

      final draft = await repo.analyze(
        assets: staged,
        selection: AnalysisSelection.defaults(),
      );

      expect(repo.analyzedAssets, [staged]);
      final stagedIds = staged.map((a) => a.assetId).toSet();
      expect(draft.items.every((i) => stagedIds.contains(i.assetId)), isTrue);
    });

    test('an unexpected error surfaces as a Failure', () async {
      final repo = MockStudioRepository(shouldFail: true);

      expect(
        repo.analyze(assets: presets, selection: AnalysisSelection.defaults()),
        throwsA(isA<Failure>()),
      );
    });
  });

  group('MockStudioRepository.recordConsent', () {
    test('[TASK-003-S01] consent is recorded with its version and time',
        () async {
      final repo = MockStudioRepository();
      final consent = PrivacyConsent(
        version: PrivacyConsent.studioVersion,
        grantedAt: testToday,
      );

      final recorded = await repo.recordConsent(consent);

      expect(recorded, consent);
      expect(repo.recordedConsents, [consent]);
    });
  });
}
