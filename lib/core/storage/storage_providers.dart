import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../time/clock.dart';
import 'attachment_store.dart';
import 'object_id.dart';

/// The open local database. `main()` opens it before `runApp` and overrides
/// this provider; reading it without that is a programming error.
final localDatabaseProvider = Provider<SqliteConnection>((ref) {
  throw StateError('Open the local database in main() before reading it.');
});

/// The install owner ID (CHG-005 P2-D9), overridden in `main()`.
final ownerIdProvider = Provider<String>((ref) {
  throw StateError('Read the install owner ID in main() before using it.');
});

/// Private attachments, overridden in `main()`.
final attachmentStoreProvider = Provider<AttachmentStore>((ref) {
  throw StateError('Create the attachment store in main() before using it.');
});

final objectIdGeneratorProvider = Provider<ObjectIdGenerator>((ref) {
  return ObjectIdGenerator(clock: ref.watch(clockProvider));
});

/// Restarts the app on a fresh store after "Delete all" (TASK-008-S05).
final dataResetProvider = Provider<void Function()>((ref) => () {});
