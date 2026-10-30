import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/media/image_mime.dart';

import '../../helpers/image_fixtures.dart';

void main() {
  group('sniffImageMime', () {
    test('[TASK-007-S04] detects JPEG and PNG from the bytes', () {
      expect(sniffImageMime(jpegWithMetadata()), 'image/jpeg');
      expect(sniffImageMime(pngWithMetadata()), 'image/png');
    });

    test('[TASK-007-S04] detects HEIC so it can be rejected', () {
      expect(sniffImageMime(heicBytes()), 'image/heic');
    });

    test('[TASK-007-S04] detects GIF', () {
      expect(sniffImageMime(Uint8List.fromList(ascii.encode('GIF89a....'))),
          'image/gif');
    });

    test('[TASK-007-S04] unknown or short input is null', () {
      expect(sniffImageMime(Uint8List(0)), isNull);
      expect(sniffImageMime(Uint8List.fromList([0xFF])), isNull);
      expect(sniffImageMime(Uint8List.fromList(ascii.encode('hello world'))),
          isNull);
    });
  });
}
