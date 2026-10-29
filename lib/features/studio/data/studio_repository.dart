import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../domain/analysis_selection.dart';
import '../domain/extracted_item.dart';
import '../domain/media_asset.dart';
import '../domain/privacy_consent.dart';
import '../domain/review_draft.dart';

/// Provider for StudioRepository. Phase 1: fixture analysis, no network.
/// The short delay lets the demo show the "Reading photos" state.
final studioRepositoryProvider = Provider<StudioRepository>((ref) {
  return MockStudioRepository(delay: const Duration(milliseconds: 600));
});

/// Contract for Studio (Add pillar) operations.
abstract class StudioRepository {
  /// Records the consent given before analysis. Insert-only (TAC-01.8).
  Future<PrivacyConsent> recordConsent(PrivacyConsent consent);

  /// Runs the selected analyses over [assets] and returns the review data,
  /// ordered by slot, then by position within the photo.
  Future<ReviewDraft> analyze({
    required List<MediaAsset> assets,
    required AnalysisSelection selection,
  });
}

/// One fixture item that the fake analysis returns for a photo.
@immutable
class StudioFixtureItem {
  final String name;
  final double confidence;
  final ItemAttributes attributes;

  const StudioFixtureItem({
    required this.name,
    required this.confidence,
    required this.attributes,
  });
}

/// Deterministic fake analysis (spec T6 P1: "fake extractor, fixture items").
/// Photos whose URI is in [failingUris] count as unreadable. Photos with no
/// fixture yield zero items.
class MockStudioRepository implements StudioRepository {
  /// Items per preset photo URI (see `PresetPhotoPicker.presets`):
  /// violet shirt → "Violet shirt" (SHIRT, 0.94), wide-leg trousers →
  /// "Wide-leg trousers" (WIDE_LEG_TROUSERS, 0.91), cream sneakers →
  /// "Cream sneakers" (SNEAKERS, 0.88).
  static const Map<String, List<StudioFixtureItem>> presetFixtures = {
    'preset://flatlay-violet-shirt.jpg': [
      StudioFixtureItem(
        name: 'Violet shirt',
        confidence: 0.94,
        attributes: ItemAttributes(
          typeCode: 'SHIRT',
          color: 'Violet',
          material: 'Cotton',
          styleTag: 'Street',
        ),
      ),
    ],
    'preset://flatlay-wide-leg-trousers.jpg': [
      StudioFixtureItem(
        name: 'Wide-leg trousers',
        confidence: 0.91,
        attributes: ItemAttributes(
          typeCode: 'WIDE_LEG_TROUSERS',
          color: 'Beige',
          material: 'Linen',
          styleTag: 'Everyday',
        ),
      ),
    ],
    'preset://flatlay-cream-sneakers.png': [
      StudioFixtureItem(
        name: 'Cream sneakers',
        confidence: 0.88,
        attributes: ItemAttributes(
          typeCode: 'SNEAKERS',
          color: 'Cream',
          material: 'Canvas',
          styleTag: 'Basic',
        ),
      ),
    ],
  };

  final Map<String, List<StudioFixtureItem>> fixtures;
  final Set<String> failingUris;

  /// When true, [analyze] throws a `ServerFailure`.
  final bool shouldFail;
  final Duration delay;

  /// Every consent passed to [recordConsent], in order.
  final List<PrivacyConsent> recordedConsents = [];

  /// The assets passed to each [analyze] call, in order.
  final List<List<MediaAsset>> analyzedAssets = [];

  MockStudioRepository({
    this.fixtures = presetFixtures,
    this.failingUris = const {},
    this.shouldFail = false,
    this.delay = Duration.zero,
  });

  @override
  Future<PrivacyConsent> recordConsent(PrivacyConsent consent) async {
    await _wait();
    recordedConsents.add(consent);
    return consent;
  }

  /// Only Pieces (outfit extraction) produces items. Pose and background
  /// analyses have no Phase 1 output; they would skip photos without a
  /// person (AC-02.7) once real models exist (AI-001).
  @override
  Future<ReviewDraft> analyze({
    required List<MediaAsset> assets,
    required AnalysisSelection selection,
  }) async {
    await _wait();
    analyzedAssets.add(List.unmodifiable(assets));
    if (shouldFail) {
      throw const ServerFailure('Garblo could not read these photos.');
    }

    final bySlot = [...assets]
      ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));
    final items = <ExtractedItem>[];
    var failed = 0;
    for (final asset in bySlot) {
      if (failingUris.contains(asset.uri)) {
        failed++;
        continue;
      }
      final found = fixtures[asset.uri] ?? const <StudioFixtureItem>[];
      for (var i = 0; i < found.length; i++) {
        items.add(ExtractedItem(
          draftId: 'draft_${asset.assetId}_${i + 1}',
          assetId: asset.assetId,
          slotIndex: asset.slotIndex,
          itemIndex: i + 1,
          name: found[i].name,
          confidence: found[i].confidence,
          ai: found[i].attributes,
          value: found[i].attributes,
        ));
      }
    }

    return ReviewDraft(
      photoCount: assets.length,
      failedPhotoCount: failed,
      items: List.unmodifiable(items),
    );
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
  }
}
