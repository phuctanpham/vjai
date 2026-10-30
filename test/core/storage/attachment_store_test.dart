import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/storage/attachment_store.dart';
import 'package:garblo/core/storage/object_id.dart';

import '../../helpers/fixed_clock.dart';
import '../../helpers/local_db.dart';

void main() {
  late Directory base;
  late Directory root;
  late FileAttachmentStore store;

  setUp(() async {
    base = await tempDir('attachments');
    root = Directory('${base.path}${Platform.pathSeparator}attachments');
    store = FileAttachmentStore(
      root: root,
      ids: ObjectIdGenerator(clock: FixedClock(testToday)),
    );
  });

  tearDown(() async {
    if (await base.exists()) await base.delete(recursive: true);
  });

  final bytes = Uint8List.fromList(List.generate(64, (i) => i));

  bool isInside(Directory dir, File file) =>
      File(file.absolute.path).parent.absolute.path ==
      Directory(dir.absolute.path).absolute.path;

  group('FileAttachmentStore', () {
    test('[TASK-007-S06] save returns an opaque ObjectId', () async {
      final id = await store.save(bytes);

      expect(isObjectId(id), isTrue);
      expect(await store.exists(id), isTrue);
      expect(await store.read(id), bytes);
    });

    test('[TASK-007-S06] files live directly under the private root', () async {
      final id = await store.save(bytes);

      final file = store.fileFor(id);
      expect(isInside(root, file), isTrue);
      expect(await file.exists(), isTrue);
    });

    test('[TASK-007-S06] IDs that are not ObjectIds cannot reach the disk',
        () async {
      for (final bad in [
        '../outside',
        '..${Platform.pathSeparator}outside',
        '/etc/passwd',
        r'C:\Windows\win.ini',
        '65f0c1a2b3c4d5e6f7a8b9c0/../../x',
        '',
      ]) {
        expect(() => store.fileFor(bad), throwsArgumentError, reason: bad);
        await expectLater(store.read(bad), throwsArgumentError, reason: bad);
        await expectLater(store.delete(bad), throwsArgumentError, reason: bad);
      }
    });

    test('[TASK-007-S06] an unknown ID does not exist', () async {
      expect(await store.exists('65f0c1a2b3c4d5e6f7a8b9c0'), isFalse);
    });

    test('[TASK-007-S06] listIds returns the stored IDs only', () async {
      final a = await store.save(bytes);
      final b = await store.save(bytes);

      expect(await store.listIds(), unorderedEquals([a, b]));
    });

    test('[TASK-007-S03] stores exactly the given bytes, with no side files',
        () async {
      final id = await store.save(bytes);

      final entries = await root.list(recursive: true).toList();
      expect(entries, hasLength(1));
      expect(await File(entries.single.path).readAsBytes(), bytes);
      expect(await store.listIds(), [id]);
    });

    test('[TASK-007-S07] delete removes one attachment', () async {
      final keep = await store.save(bytes);
      final drop = await store.save(bytes);

      await store.delete(drop);

      expect(await store.exists(drop), isFalse);
      expect(await store.exists(keep), isTrue);
    });

    test('[TASK-007-S07] deleting a missing attachment is not an error',
        () async {
      await store.delete('65f0c1a2b3c4d5e6f7a8b9c0');
    });

    test('[TASK-008-S04] deleteAll removes every attachment', () async {
      await store.save(bytes);
      await store.save(bytes);

      await store.deleteAll();

      expect(await store.listIds(), isEmpty);
      final leftovers =
          await root.exists() ? await root.list(recursive: true).toList() : [];
      expect(leftovers, isEmpty);
    });

    test('[TASK-008-S04] the store works again after deleteAll', () async {
      await store.save(bytes);
      await store.deleteAll();

      final id = await store.save(bytes);

      expect(await store.read(id), bytes);
    });
  });
}
