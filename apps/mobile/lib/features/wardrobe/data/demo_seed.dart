import '../../../core/storage/object_id.dart';
import '../domain/wardrobe_item.dart';
import 'wardrobe_repository.dart';

/// Whether the build loads the demo Archive
/// (`--dart-define=GARBLO_DEMO_SEED=true`, CHG-005 P2-D5).
const bool demoSeedEnabled = bool.fromEnvironment('GARBLO_DEMO_SEED');

/// Adds the 9 demo Pieces (the same as `MockWardrobeRepository.seeded`) when
/// the Archive is empty. Returns how many were added.
Future<int> seedDemoArchive({
  required WardrobeRepository wardrobe,
  required DateTime today,
}) async {
  if (await wardrobe.countEligible() > 0) return 0;
  final demo = await MockWardrobeRepository.seeded(today).getEligibleItems();
  final items = [
    for (final item in demo)
      WardrobeItem(
        // ObjectIds like every other row; stable so a re-seed is a no-op.
        itemId: deterministicObjectId(['demo-seed', item.itemId]),
        name: item.name,
        typeCode: item.typeCode,
        color: item.color,
        material: item.material,
        styleTag: item.styleTag,
        createdAt: item.createdAt,
        lastWornEstimate: item.lastWornEstimate,
      ),
  ];
  await wardrobe.saveItems(items);
  return items.length;
}
