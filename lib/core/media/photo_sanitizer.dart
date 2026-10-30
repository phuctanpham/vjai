import 'package:flutter/foundation.dart';

import '../errors/failures.dart';

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

  SanitizedPhoto sanitize(Uint8List bytes, {required String mimeType}) =>
      throw UnimplementedError('TASK-007-S01');
}
