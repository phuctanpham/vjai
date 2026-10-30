import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/wardrobe/data/demo_seed.dart';
import 'package:garblo/features/wardrobe/data/local_wardrobe_repository.dart';
import 'package:garblo/features/wardrobe/data/wardrobe_repository.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/local_db.dart';

const _owner = '65f0c1a2b3c4d5e6f7a8b9c0';

void main() {
  late TestDatabase t;

  setUp(() async => t = await TestDatabase.open());
  tearDown(() async => t.dispose());

  test('[TASK-005-S11] the demo seed is off unless the build enables it', () {
    expect(demoSeedEnabled, isFalse);
  });

  test('[TASK-005-S11] a fresh install has an empty Archive', () async {
    final repo = LocalWardrobeRepository(db: t.db, ownerId: _owner);

    expect(await repo.countEligible(), 0);
    expect((await repo.getItems()).items, isEmpty);
  });

  test('[TASK-005-S11] the seed adds the 9 demo Pieces to an empty Archive',
      () async {
    final repo = LocalWardrobeRepository(db: t.db, ownerId: _owner);

    final added = await seedDemoArchive(wardrobe: repo, today: testToday);

    expect(added, 9);
    final demo = await MockWardrobeRepository.seeded(testToday).getItems();
    final seeded = await repo.getItems();
    expect(seeded.total, 9);
    expect(seeded.items.map((i) => i.name), demo.items.map((i) => i.name));
  });

  test('[TASK-005-S11] seeding twice or into a used Archive adds nothing',
      () async {
    final repo = LocalWardrobeRepository(db: t.db, ownerId: _owner);

    await seedDemoArchive(wardrobe: repo, today: testToday);
    final again = await seedDemoArchive(wardrobe: repo, today: testToday);

    expect(again, 0);
    expect(await repo.countEligible(), 9);
  });
}
