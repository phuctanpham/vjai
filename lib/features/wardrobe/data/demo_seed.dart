import 'wardrobe_repository.dart';

/// Whether the build loads the demo Archive
/// (`--dart-define=GARBLO_DEMO_SEED=true`, CHG-005 P2-D5).
const bool demoSeedEnabled = bool.fromEnvironment('GARBLO_DEMO_SEED');

/// Adds the 9 demo Pieces (the same as `MockWardrobeRepository.seeded`) when
/// the Archive is empty. Returns how many were added.
Future<int> seedDemoArchive({
  required WardrobeRepository wardrobe,
  required DateTime today,
}) =>
    throw UnimplementedError('TASK-005-S11');
