import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../errors/failures.dart';
import 'image_mime.dart';

/// A photo with its metadata removed, ready to store.
@immutable
class SanitizedPhoto {
  final Uint8List bytes;
  final String mimeType;

  /// EXIF orientation (1–8) read before stripping; 1 when absent.
  final int orientation;

  const SanitizedPhoto({
    required this.bytes,
    required this.mimeType,
    required this.orientation,
  });
}

/// The photo could not be sanitized; nothing may be stored for it.
class SanitizationFailure extends Failure {
  const SanitizationFailure([
    super.message = "This photo couldn't be protected, so it wasn't added.",
    super.cause,
  ]);
}

/// Lossless, in-house metadata stripping (CHG-005 P2-D10). The image data is
/// copied unchanged; no re-encoding.
///
/// - JPEG: removes every APP1 segment (EXIF and XMP) and APP13; keeps APP0
///   (JFIF), APP2 (ICC profile) and all image segments.
/// - PNG: removes `tEXt`, `zTXt`, `iTXt` and `eXIf`; keeps `iCCP` and the
///   image chunks.
/// - Reads the EXIF orientation (JPEG APP1 or PNG `eXIf`) before stripping.
/// - Throws [SanitizationFailure] for unsupported types (e.g. HEIC),
///   malformed files and files over [maxBytes].
class PhotoSanitizer {
  static const int maxBytes = 25 * 1024 * 1024;

  const PhotoSanitizer();

  SanitizedPhoto sanitize(Uint8List bytes, {required String mimeType}) {
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const SanitizationFailure();
    }
    // The declared type must match the content (TASK-007-S04).
    final sniffed = sniffImageMime(bytes);
    if (sniffed != mimeType) throw const SanitizationFailure();
    try {
      return switch (sniffed) {
        'image/jpeg' => _jpeg(bytes),
        'image/png' => _png(bytes),
        _ => throw const SanitizationFailure(),
      };
    } on SanitizationFailure {
      rethrow;
    } catch (error) {
      throw SanitizationFailure(
          "This photo couldn't be protected, so it wasn't added.", error);
    }
  }

  static const int _app1 = 0xE1;
  static const int _app13 = 0xED;
  static const int _sos = 0xDA;
  static const int _eoi = 0xD9;

  SanitizedPhoto _jpeg(Uint8List bytes) {
    final out = BytesBuilder(copy: false)..add(const [0xFF, 0xD8]);
    var orientation = 1;
    var i = 2;
    while (true) {
      if (i + 2 > bytes.length || bytes[i] != 0xFF) {
        throw const SanitizationFailure();
      }
      final marker = bytes[i + 1];
      if (marker == 0xFF) {
        i++; // fill byte
        continue;
      }
      if (marker == _eoi) throw const SanitizationFailure(); // no image data
      final standalone = marker == 0x01 || (marker >= 0xD0 && marker <= 0xD7);
      if (standalone) {
        out.add(Uint8List.sublistView(bytes, i, i + 2));
        i += 2;
        continue;
      }
      if (i + 4 > bytes.length) throw const SanitizationFailure();
      final length = (bytes[i + 2] << 8) | bytes[i + 3];
      final end = i + 2 + length;
      if (length < 2 || end > bytes.length) throw const SanitizationFailure();
      if (marker == _sos) {
        // Entropy-coded data and everything after it are copied as is.
        out.add(Uint8List.sublistView(bytes, i));
        break;
      }
      if (marker == _app1) {
        final payload = Uint8List.sublistView(bytes, i + 4, end);
        if (_startsWith(payload, const [0x45, 0x78, 0x69, 0x66, 0, 0])) {
          orientation = _tiffOrientation(Uint8List.sublistView(payload, 6));
        }
      } else if (marker != _app13) {
        out.add(Uint8List.sublistView(bytes, i, end));
      }
      i = end;
    }
    return SanitizedPhoto(
        bytes: out.takeBytes(),
        mimeType: 'image/jpeg',
        orientation: orientation);
  }

  static const Set<String> _pngDropped = {'tEXt', 'zTXt', 'iTXt', 'eXIf'};

  SanitizedPhoto _png(Uint8List bytes) {
    final out = BytesBuilder(copy: false)
      ..add(Uint8List.sublistView(bytes, 0, 8));
    var orientation = 1;
    var i = 8;
    var first = true;
    while (true) {
      if (i + 12 > bytes.length) throw const SanitizationFailure();
      final length = (bytes[i] << 24) |
          (bytes[i + 1] << 16) |
          (bytes[i + 2] << 8) |
          bytes[i + 3];
      final type = String.fromCharCodes(bytes, i + 4, i + 8);
      final end = i + 12 + length;
      if (length < 0 || end > bytes.length) throw const SanitizationFailure();
      if (first && type != 'IHDR') throw const SanitizationFailure();
      first = false;
      if (type == 'eXIf') {
        orientation =
            _tiffOrientation(Uint8List.sublistView(bytes, i + 8, end - 4));
      }
      if (!_pngDropped.contains(type)) {
        out.add(Uint8List.sublistView(bytes, i, end));
      }
      i = end;
      if (type == 'IEND') break;
    }
    return SanitizedPhoto(
        bytes: out.takeBytes(),
        mimeType: 'image/png',
        orientation: orientation);
  }

  /// Orientation (tag 0x0112) from a TIFF block, or 1 when absent or invalid.
  static int _tiffOrientation(Uint8List tiff) {
    if (tiff.length < 8) return 1;
    final bool little;
    if (tiff[0] == 0x49 && tiff[1] == 0x49) {
      little = true;
    } else if (tiff[0] == 0x4D && tiff[1] == 0x4D) {
      little = false;
    } else {
      return 1;
    }
    int u16(int at) => little
        ? tiff[at] | (tiff[at + 1] << 8)
        : (tiff[at] << 8) | tiff[at + 1];
    int u32(int at) =>
        little ? u16(at) | (u16(at + 2) << 16) : (u16(at) << 16) | u16(at + 2);

    final ifd = u32(4);
    if (ifd + 2 > tiff.length) return 1;
    final count = u16(ifd);
    for (var n = 0; n < count; n++) {
      final entry = ifd + 2 + n * 12;
      if (entry + 12 > tiff.length) return 1;
      if (u16(entry) == 0x0112 && u16(entry + 2) == 3) {
        final value = u16(entry + 8);
        return value >= 1 && value <= 8 ? value : 1;
      }
    }
    return 1;
  }

  static bool _startsWith(Uint8List bytes, List<int> prefix) {
    if (bytes.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[i] != prefix[i]) return false;
    }
    return true;
  }
}
