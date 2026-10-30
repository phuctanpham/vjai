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

/// [AttachmentStore] in an app-private directory, one file per attachment.
class FileAttachmentStore implements AttachmentStore {
  final Directory root;

  FileAttachmentStore({required this.root, required ObjectIdGenerator ids});

  /// The file for [attachmentId], always inside [root]. Throws
  /// [ArgumentError] for an ID that is not an ObjectId.
  File fileFor(String attachmentId) => throw UnimplementedError('TASK-007-S06');

  @override
  Future<String> save(Uint8List bytes) =>
      throw UnimplementedError('TASK-007-S06');

  @override
  Future<Uint8List> read(String attachmentId) =>
      throw UnimplementedError('TASK-007-S06');

  @override
  Future<bool> exists(String attachmentId) =>
      throw UnimplementedError('TASK-007-S06');

  @override
  Future<void> delete(String attachmentId) =>
      throw UnimplementedError('TASK-007-S07');

  @override
  Future<void> deleteAll() => throw UnimplementedError('TASK-008-S04');

  @override
  Future<List<String>> listIds() => throw UnimplementedError('TASK-007-S06');
}
