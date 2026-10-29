import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/analysis_selection.dart';
import '../domain/extracted_item.dart';
import '../domain/media_asset.dart';
import '../domain/privacy_consent.dart';
import '../domain/review_draft.dart';

/// Provider for StudioRepository. Phase 1: fixture analysis, no network.
final studioRepositoryProvider = Provider<StudioRepository>((ref) {
  throw UnimplementedError('TASK-003-S11');
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
  Future<PrivacyConsent> recordConsent(PrivacyConsent consent) =>
      throw UnimplementedError('TASK-003-S01');

  @override
  Future<ReviewDraft> analyze({
    required List<MediaAsset> assets,
    required AnalysisSelection selection,
  }) =>
      throw UnimplementedError('TASK-003-S11');
}
