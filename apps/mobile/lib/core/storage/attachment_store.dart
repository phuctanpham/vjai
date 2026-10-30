import 'dart:io';
import 'dart:typed_data';

import 'object_id.dart';

/// Private file storage for photos, referenced by opaque attachment IDs
/// (TASK-007). Callers must pass already-sanitized bytes.
abstract class AttachmentStore {
  /// Stores [bytes] and returns a new attachment ID (an ObjectId).
  Future<String> save(Uint8List bytes);
  Future<Uint8List> read(String attachmentId);
  Future<bool> exists(String attachmentId);
  Future<void> delete(String attachmentId);
  Future<void> deleteAll();
  Future<List<String>> listIds();
}

/// [AttachmentStore] in an app-private directory, one file per attachment,
/// named by its ID only (no original file name or extension).
class FileAttachmentStore implements AttachmentStore {
  final Directory root;
  final ObjectIdGenerator _ids;

  FileAttachmentStore({required this.root, required ObjectIdGenerator ids})
      : _ids = ids;

  /// The file for [attachmentId], always inside [root]. Throws
  /// [ArgumentError] for an ID that is not an ObjectId.
  File fileFor(String attachmentId) {
    if (!isObjectId(attachmentId)) {
      throw ArgumentError.value(
          attachmentId, 'attachmentId', 'Not an attachment ID');
    }
    return File('${root.path}${Platform.pathSeparator}$attachmentId');
  }

  @override
  Future<String> save(Uint8List bytes) async {
    await root.create(recursive: true);
    final id = _ids.next();
    final file = fileFor(id);
    // Write then rename, so a crash never leaves a half-written photo.
    final partial = File('${file.path}.partial');
    await partial.writeAsBytes(bytes, flush: true);
    await partial.rename(file.path);
    return id;
  }

  @override
  Future<Uint8List> read(String attachmentId) async =>
      fileFor(attachmentId).readAsBytes();

  @override
  Future<bool> exists(String attachmentId) async =>
      fileFor(attachmentId).exists();

  @override
  Future<void> delete(String attachmentId) async {
    final file = fileFor(attachmentId);
    if (await file.exists()) await file.delete();
  }

  @override
  Future<void> deleteAll() async {
    if (await root.exists()) await root.delete(recursive: true);
  }

  @override
  Future<List<String>> listIds() async {
    if (!await root.exists()) return const [];
    return [
      await for (final entry in root.list())
        if (entry is File && isObjectId(entry.uri.pathSegments.last))
          entry.uri.pathSegments.last,
    ];
  }
}
