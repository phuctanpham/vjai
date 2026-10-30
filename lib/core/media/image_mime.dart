import 'dart:typed_data';

/// The image MIME type from the file's leading bytes: `image/jpeg`,
/// `image/png`, `image/heic`, `image/gif`, or null when unknown. File names
/// and extensions are not trusted (TASK-007-S04).
String? sniffImageMime(Uint8List bytes) =>
    throw UnimplementedError('TASK-007-S04');
