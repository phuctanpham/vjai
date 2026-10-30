import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/storage/install_identity.dart';
import 'package:garblo/core/storage/object_id.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/local_db.dart';

void main() {
  late FakeSecureStore store;

  InstallIdentity identity() => InstallIdentity(
        store: store,
        ids: ObjectIdGenerator(clock: FixedClock(testToday)),
      );

  setUp(() => store = FakeSecureStore());

  group('InstallIdentity', () {
    test(
        '[TASK-005-S10] the owner ID is a random ObjectId, kept in secure storage',
        () async {
      final owner = await identity().ownerId();

      expect(isObjectId(owner), isTrue);
      expect(store.values[InstallIdentity.ownerIdKey], owner);
    });

    test('[TASK-005-S10] the owner ID is created once and reused', () async {
      final first = await identity().ownerId();
      final again = await identity().ownerId();

      expect(again, first);
    });

    test('[TASK-005-S10] two installs get different owner IDs', () async {
      final a = await identity().ownerId();
      store = FakeSecureStore();
      final b = await identity().ownerId();

      expect(a, isNot(b));
    });

    test('[TASK-005-S10] the database key is 64 hex characters, created once',
        () async {
      final key = await identity().databaseKey();
      final again = await identity().databaseKey();

      expect(key, matches(RegExp(r'^[0-9a-f]{64}$')));
      expect(again, key);
      expect(store.values[InstallIdentity.databaseKeyKey], key);
    });

    test('[TASK-005-S10] keys differ between installs', () async {
      final a = await identity().databaseKey();
      store = FakeSecureStore();
      final b = await identity().databaseKey();

      expect(a, isNot(b));
    });

    test('[TASK-008-S04] deleting the database key keeps the owner ID',
        () async {
      final id = identity();
      final owner = await id.ownerId();
      final oldKey = await id.databaseKey();

      await id.deleteDatabaseKey();

      expect(store.values.containsKey(InstallIdentity.databaseKeyKey), isFalse);
      expect(await identity().ownerId(), owner);
      expect(await identity().databaseKey(), isNot(oldKey));
    });
  });
}
