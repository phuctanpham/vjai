import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/core/media/photo_sanitizer.dart';

import '../../helpers/image_fixtures.dart';

const _sanitizer = PhotoSanitizer();

SanitizedPhoto _jpeg(Uint8List bytes) =>
    _sanitizer.sanitize(bytes, mimeType: 'image/jpeg');

SanitizedPhoto _png(Uint8List bytes) =>
    _sanitizer.sanitize(bytes, mimeType: 'image/png');

void main() {
  group('JPEG (CHG-005 P2-D10)', () {
    test('[TASK-007-S01] removes the EXIF APP1 with GPS', () {
      final input = jpegWithMetadata(xmp: false, icc: false, iptc: false);
      expect(containsAscii(input, gpsMarker), isTrue);

      final out = _jpeg(input).bytes;

      expect(containsAscii(out, gpsMarker), isFalse);
      expect(containsAscii(out, 'Exif'), isFalse);
      expect(jpegMarkers(out), isNot(contains(0xE1)));
    });

    test('[TASK-007-S01] removes the XMP APP1', () {
      final input = jpegWithMetadata(exif: false, icc: false, iptc: false);

      final out = _jpeg(input).bytes;

      expect(containsAscii(out, xmpMarker), isFalse);
      expect(containsAscii(out, 'ns.adobe.com/xap'), isFalse);
      expect(jpegMarkers(out), isNot(contains(0xE1)));
    });

    test('[TASK-007-S01] removes the APP13 (IPTC)', () {
      final input = jpegWithMetadata(exif: false, xmp: false, icc: false);

      final out = _jpeg(input).bytes;

      expect(containsAscii(out, iptcMarker), isFalse);
      expect(jpegMarkers(out), isNot(contains(0xED)));
    });

    test('[TASK-007-S01] keeps APP0 (JFIF)', () {
      final out = _jpeg(jpegWithMetadata()).bytes;

      expect(jpegMarkers(out).first, 0xE0);
      expect(containsAscii(out, 'JFIF'), isTrue);
    });

    test('[TASK-007-S01] keeps APP2 (ICC profile)', () {
      final out = _jpeg(jpegWithMetadata()).bytes;

      expect(jpegMarkers(out), contains(0xE2));
      expect(containsAscii(out, 'ICC_PROFILE'), isTrue);
      expect(containsAscii(out, iccMarker), isTrue);
    });

    test('[TASK-007-S01] copies the image segments unchanged', () {
      final input = jpegWithMetadata();

      final out = _jpeg(input).bytes;

      expect(out.sublist(0, 2), [0xFF, 0xD8]);
      expect(jpegMarkers(out), [0xE0, 0xE2, 0xDB, 0xC0, 0xC4, 0xDA]);
      expect(listEquals(jpegImageData(out), jpegImageData(input)), isTrue);
    });

    test('[TASK-007-S01] reads the orientation from big-endian EXIF', () {
      final result = _jpeg(jpegWithMetadata(orientation: 6));

      expect(result.orientation, 6);
      expect(result.mimeType, 'image/jpeg');
    });

    test('[TASK-007-S01] reads the orientation from little-endian EXIF', () {
      final result =
          _jpeg(jpegWithMetadata(orientation: 3, littleEndian: true));

      expect(result.orientation, 3);
    });

    test('[TASK-007-S01] orientation is 1 without EXIF', () {
      final result = _jpeg(jpegWithMetadata(exif: false));

      expect(result.orientation, 1);
    });
  });

  group('PNG (CHG-005 P2-D10)', () {
    test('[TASK-007-S02] removes tEXt', () {
      final out =
          _png(pngWithMetadata(ztxt: false, itxt: false, exif: false)).bytes;

      expect(pngChunkTypes(out), isNot(contains('tEXt')));
      expect(containsAscii(out, pngTextMarker), isFalse);
    });

    test('[TASK-007-S02] removes zTXt', () {
      final out =
          _png(pngWithMetadata(text: false, itxt: false, exif: false)).bytes;

      expect(pngChunkTypes(out), isNot(contains('zTXt')));
      expect(containsAscii(out, pngTextMarker), isFalse);
    });

    test('[TASK-007-S02] removes iTXt (XMP)', () {
      final out =
          _png(pngWithMetadata(text: false, ztxt: false, exif: false)).bytes;

      expect(pngChunkTypes(out), isNot(contains('iTXt')));
      expect(containsAscii(out, xmpMarker), isFalse);
    });

    test('[TASK-007-S02] removes eXIf and reads its orientation', () {
      final result = _png(pngWithMetadata(
          orientation: 8, text: false, ztxt: false, itxt: false));

      expect(pngChunkTypes(result.bytes), isNot(contains('eXIf')));
      expect(containsAscii(result.bytes, gpsMarker), isFalse);
      expect(result.orientation, 8);
      expect(result.mimeType, 'image/png');
    });

    test('[TASK-007-S02] keeps iCCP and the image chunks unchanged', () {
      final out = _png(pngWithMetadata()).bytes;

      expect(out.sublist(0, 8), pngSignature);
      expect(pngChunkTypes(out), ['IHDR', 'iCCP', 'IDAT', 'IEND']);
      expect(containsAscii(out, iccMarker), isTrue);
      expect(containsAscii(out, imageDataMarker), isTrue);
    });

    test('[TASK-007-S02] orientation is 1 without eXIf', () {
      expect(_png(pngWithMetadata(exif: false)).orientation, 1);
    });
  });

  group('Explicit failures', () {
    void expectFailure(Uint8List bytes, String mimeType) {
      expect(
        () => _sanitizer.sanitize(bytes, mimeType: mimeType),
        throwsA(isA<SanitizationFailure>().having((f) => f.message, 'message',
            "This photo couldn't be protected, so it wasn't added.")),
      );
    }

    test('[TASK-007-S04] HEIC is unsupported', () {
      expectFailure(heicBytes(), 'image/heic');
    });

    test('[TASK-007-S04] a JPEG without SOI is malformed', () {
      expectFailure(Uint8List.sublistView(jpegWithMetadata(), 2), 'image/jpeg');
    });

    test('[TASK-007-S04] a truncated JPEG segment is malformed', () {
      final full = jpegWithMetadata();
      expectFailure(Uint8List.sublistView(full, 0, 30), 'image/jpeg');
    });

    test('[TASK-007-S04] a PNG chunk running past the end is malformed', () {
      final full = pngWithMetadata();
      expectFailure(
          Uint8List.sublistView(full, 0, full.length - 20), 'image/png');
    });

    test('[TASK-007-S04] bytes that do not match the declared type fail', () {
      expectFailure(pngWithMetadata(), 'image/jpeg');
      expectFailure(jpegWithMetadata(), 'image/png');
    });

    test('[TASK-007-S04] empty input fails', () {
      expectFailure(Uint8List(0), 'image/jpeg');
    });

    test('[TASK-007-S04] input over 25 MB fails', () {
      final big = Uint8List(PhotoSanitizer.maxBytes + 1)
        ..setRange(0, 2, [0xFF, 0xD8]);
      expectFailure(big, 'image/jpeg');
    });
  });
}
