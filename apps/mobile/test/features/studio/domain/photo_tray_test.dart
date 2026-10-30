import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/studio/domain/photo_tray.dart';

import '../../../helpers/wardrobe_fixtures.dart';

void main() {
  group('PhotoTray', () {
    test('[TASK-003-S02] stages photos in pick order with unique slots', () {
      final result =
          PhotoTray.empty().add([jpg('tee'), jpg('pants'), png('shoes')]);

      final tray = result.tray;
      expect(tray.count, 3);
      expect(tray.assets.map((a) => a.uri),
          ['test://tee.jpg', 'test://pants.jpg', 'test://shoes.png']);
      expect(tray.assets.map((a) => a.slotIndex), [1, 2, 3]);
      expect(tray.assets.map((a) => a.assetId).toSet(), hasLength(3));
      expect(result.rejectedCount, 0);
      expect(result.overLimitCount, 0);
    });

    test('[TASK-003-S02] removing one photo keeps the others in order', () {
      final tray =
          PhotoTray.empty().add([jpg('tee'), jpg('pants'), png('shoes')]).tray;
      final second = tray.assets[1].assetId;

      final after = tray.remove(second);

      expect(after.count, 2);
      expect(after.assets.map((a) => a.uri),
          ['test://tee.jpg', 'test://shoes.png']);
    });

    test('[TASK-003-S02] removing the last photo leaves an empty tray', () {
      final tray = PhotoTray.empty().add([jpg('tee')]).tray;

      final after = tray.remove(tray.assets.single.assetId);

      expect(after.isEmpty, isTrue);
      expect(after.count, 0);
      expect(after.assets, isEmpty);
    });

    test('[TASK-003-S02] slots stay within 1..10 and unique after re-adding',
        () {
      var tray = PhotoTray.empty().add([jpg('a'), jpg('b'), jpg('c')]).tray;
      tray = tray.remove(tray.assets[0].assetId);
      tray = tray.add([jpg('d')]).tray;

      final slots = tray.assets.map((a) => a.slotIndex).toList();
      expect(slots.toSet(), hasLength(slots.length));
      expect(slots.every((s) => s >= 1 && s <= PhotoTray.maxPhotos), isTrue);
      expect(tray.assets.map((a) => a.assetId).toSet(), hasLength(3));
    });

    test('[TASK-003-S09] only JPG and PNG are staged', () {
      final result =
          PhotoTray.empty().add([jpg('tee'), heic('live'), png('shoes')]);

      expect(result.tray.count, 2);
      expect(result.rejectedCount, 1);
      expect(
          result.tray.assets
              .every((a) => PhotoTray.acceptedMimeTypes.contains(a.mimeType)),
          isTrue);
    });

    test('[TASK-003-S09] at most 10 photos; the first ones are kept', () {
      final picked = [for (var i = 1; i <= 12; i++) jpg('p$i')];

      final result = PhotoTray.empty().add(picked);

      expect(result.tray.count, 10);
      expect(result.overLimitCount, 2);
      expect(result.tray.isFull, isTrue);
      expect(result.tray.remainingCapacity, 0);
      expect(result.tray.assets.first.uri, 'test://p1.jpg');
      expect(result.tray.assets.last.uri, 'test://p10.jpg');
    });

    test('[TASK-003-S09] remaining capacity accounts for staged photos', () {
      final tray = PhotoTray.empty().add([jpg('a'), jpg('b'), jpg('c')]).tray;

      expect(tray.remainingCapacity, 7);
      expect(tray.isFull, isFalse);

      final result = tray.add([for (var i = 0; i < 9; i++) jpg('x$i')]);
      expect(result.tray.count, 10);
      expect(result.overLimitCount, 2);
    });

    test('value equality and hashCode follow asset contents', () {
      final a = PhotoTray.empty().add([jpg('tee')]).tray;
      final b = PhotoTray.empty().add([jpg('tee')]).tray;

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == PhotoTray.empty().add([jpg('other')]).tray, isFalse);
    });
  });
}
