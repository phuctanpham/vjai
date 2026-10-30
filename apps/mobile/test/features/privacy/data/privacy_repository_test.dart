import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/storage/attachment_store.dart';
import 'package:garblo/core/storage/install_identity.dart';
import 'package:garblo/core/storage/local_data_store.dart';
import 'package:garblo/core/storage/object_id.dart';
import 'package:garblo/features/privacy/data/privacy_repository.dart';
import 'package:garblo/features/privacy/domain/erasure_counts.dart';
import 'package:garblo/features/studio/data/local_studio_repository.dart';
import 'package:garblo/features/studio/domain/privacy_consent.dart';
import 'package:garblo/features/wardrobe/data/local_wardrobe_repository.dart';

import '../../../helpers/fixed_clock.dart';
import '../../../helpers/local_db.dart';
import '../../../helpers/wardrobe_fixtures.dart';

const _owner = '65f0c1a2b3c4d5e6f7a8b9c0';

void main() {
  late Directory base;
  late LocalDataStore store;
  late FileAttachmentStore attachments;
  late ObjectIdGenerator ids;
  late LocalPrivacyRepository privacy;
  final clock = FixedClock(testToday);
  late String bodyAttachment;
  late String flatLayAttachment;

  LocalStudioRepository studio() => LocalStudioRepository(
        db: store.database,
        ownerId: _owner,
        attachments: attachments,
        ids: ids,
        clock: clock,
      );

  setUp(() async {
    base = await tempDir('privacy');
    ids = ObjectIdGenerator(clock: clock);
    attachments = FileAttachmentStore(
      root: Directory('${base.path}${Platform.pathSeparator}attachments'),
      ids: ids,
    );
    store = LocalDataStore(
      databasePath: '${base.path}${Platform.pathSeparator}garblo.db',
      attachments: attachments,
      identity: InstallIdentity(store: FakeSecureStore(), ids: ids),
      beforeOpen: useHostSqlite,
    );
    await store.open();
    privacy = LocalPrivacyRepository(store: store, clock: clock);

    await LocalWardrobeRepository(db: store.database, ownerId: _owner)
        .saveItems([wardrobeItem('tee'), wardrobeItem('jeans')]);
    await studio().recordConsent(PrivacyConsent(
      version: PrivacyConsent.studioVersion,
      grantedAt: testToday,
      includesBodyProcessing: true,
    ));
    bodyAttachment = await attachments.save(Uint8List.fromList([1]));
    flatLayAttachment = await attachments.save(Uint8List.fromList([2]));
    final batch = ids.next();
    Future<void> asset(int slot, String? attachment, int person) =>
        store.database.execute(
          'INSERT INTO media_assets(id, user_id, batch_id, slot_index, '
          'attachment_id, contains_person, removed) VALUES (?, ?, ?, ?, ?, ?, 0)',
          [ids.next(), _owner, batch, slot, attachment, person],
        );
    await asset(1, bodyAttachment, 1);
    await asset(2, flatLayAttachment, 0);
    await asset(3, null, 0);
  });

  tearDown(() async {
    try {
      await store.database.close();
    } catch (_) {}
    if (await base.exists()) await base.delete(recursive: true);
  });

  test('[TASK-008-S02] counts what each action would remove', () async {
    expect(
      await privacy.counts(),
      const ErasureCounts(photos: 3, pieces: 2, bodyPhotos: 1, tryOnImages: 0),
    );
  });

  test('[TASK-008-S02] counting removes nothing', () async {
    await privacy.counts();

    expect(await attachments.listIds(), hasLength(2));
    expect(await studio().activeConsent(), isNotNull);
  });

  test('[TASK-008-S03] withdrawing sets revoked_at and keeps the Pieces',
      () async {
    await privacy.withdrawBodyConsent();

    final consent = await store.database.get('SELECT revoked_at FROM consents');
    expect(consent['revoked_at'], isNotNull);
    expect(DateTime.parse(consent['revoked_at'] as String), testToday);
    expect(await studio().activeConsent(), isNull,
        reason: 'the Studio asks for consent again');
    final pieces =
        await LocalWardrobeRepository(db: store.database, ownerId: _owner)
            .countEligible();
    expect(pieces, 2);
  });

  test('[TASK-008-S03] withdrawing deletes body photos and their files only',
      () async {
    await privacy.withdrawBodyConsent();

    expect(await attachments.exists(bodyAttachment), isFalse);
    expect(await attachments.exists(flatLayAttachment), isTrue);
    final rows =
        await store.database.getAll('SELECT contains_person FROM media_assets');
    expect(rows.map((r) => r['contains_person']), everyElement(0));
    expect(
      await privacy.counts(),
      const ErasureCounts(photos: 2, pieces: 2, bodyPhotos: 0, tryOnImages: 0),
    );
  });

  test('[TASK-008-S03] the consent row is kept (insert-only), not deleted',
      () async {
    await privacy.withdrawBodyConsent();

    final rows = await store.database.getAll('SELECT id FROM consents');
    expect(rows, hasLength(1));
  });

  test('[TASK-008-S04] delete all leaves nothing to count', () async {
    await privacy.deleteAll();

    expect(await privacy.counts(), ErasureCounts.none);
    expect(await attachments.listIds(), isEmpty);
  });
}
