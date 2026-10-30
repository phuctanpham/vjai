import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart' as sqlite_open;

import '../core/errors/failures.dart';
import '../core/storage/attachment_store.dart';
import '../core/storage/garblo_database.dart';
import '../core/storage/install_identity.dart';
import '../core/storage/object_id.dart';
import '../core/storage/secure_store.dart';
import '../core/storage/storage_providers.dart';
import '../core/time/clock.dart';
import '../features/gu_match/data/gu_match_repository.dart';
import '../features/gu_match/data/local_gu_match_repository.dart';
import '../features/studio/data/local_studio_repository.dart';
import '../features/studio/data/studio_repository.dart';
import '../features/wardrobe/data/demo_seed.dart';
import '../features/wardrobe/data/local_wardrobe_repository.dart';
import '../features/wardrobe/data/local_wear_repository.dart';
import '../features/wardrobe/data/wardrobe_repository.dart';
import '../features/wardrobe/data/wear_repository.dart';
import 'app.dart';

/// Points `sqlite3` at SQLCipher in every database isolate (CHG-005 P2-D1).
/// iOS and macOS link SQLCipher into the process, which is the default.
void openSqlCipher() {
  if (Platform.isAndroid) {
    sqlite_open.open
        .overrideFor(sqlite_open.OperatingSystem.android, openCipherOnAndroid);
  }
}

/// The opened local store and the provider overrides that use it.
class LocalStoreSession {
  /// Closes the database (before a restart on a fresh store).
  final Future<void> Function() close;
  final List<Override> overrides;

  const LocalStoreSession({required this.close, required this.overrides});
}

/// Opens the encrypted database before the app runs and swaps the in-memory
/// repositories for the local ones (TASK-005). Fails with a
/// [StorageFailure]; there is no in-memory fallback.
Future<LocalStoreSession> openLocalStore() async {
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
  const clock = SystemClock();
  final ids = ObjectIdGenerator(clock: clock);
  final identity = InstallIdentity(store: FlutterSecureStore(), ids: ids);
  final dir = await getApplicationSupportDirectory();
  final separator = Platform.pathSeparator;
  final attachments = FileAttachmentStore(
    root: Directory('${dir.path}${separator}attachments'),
    ids: ids,
  );
  final db = await GarbloDatabase.open(
    path: '${dir.path}${separator}garblo.db',
    key: await identity.databaseKey(),
    beforeOpen: openSqlCipher,
  );
  final owner = await identity.ownerId();
  final wardrobe = LocalWardrobeRepository(db: db, ownerId: owner);
  final wear = LocalWearRepository(db: db, ownerId: owner);
  if (demoSeedEnabled) {
    await seedDemoArchive(wardrobe: wardrobe, today: clock.now());
  }

  return LocalStoreSession(
    close: db.close,
    overrides: [
      localDatabaseProvider.overrideWithValue(db),
      ownerIdProvider.overrideWithValue(owner),
      attachmentStoreProvider.overrideWithValue(attachments),
      objectIdGeneratorProvider.overrideWithValue(ids),
      wardrobeRepositoryProvider.overrideWithValue(wardrobe),
      wearRepositoryProvider.overrideWithValue(wear),
      studioRepositoryProvider.overrideWith((ref) => LocalStudioRepository(
            db: db,
            ownerId: owner,
            attachments: attachments,
            ids: ids,
            clock: ref.watch(clockProvider),
          )),
      guMatchRepositoryProvider.overrideWith((ref) => LocalGuMatchRepository(
            db: db,
            ownerId: owner,
            wardrobeRepository: wardrobe,
            wearRepository: wear,
            clock: ref.watch(clockProvider),
            ids: ids,
          )),
    ],
  );
}

/// Opens the local store, then runs [GarbloApp] on it. Shows an explicit
/// error with "Try again" when storage cannot be opened (TASK-005-S09).
class GarbloBootstrap extends StatefulWidget {
  final Future<LocalStoreSession> Function() open;

  const GarbloBootstrap({super.key, this.open = openLocalStore});

  @override
  State<GarbloBootstrap> createState() => _GarbloBootstrapState();
}

class _GarbloBootstrapState extends State<GarbloBootstrap> {
  late Future<LocalStoreSession> _session = _open();

  /// The FutureBuilder reports the error; `ignore` keeps an error that
  /// arrives before it subscribes from counting as unhandled.
  Future<LocalStoreSession> _open() => widget.open()..ignore();

  void _retry() {
    setState(() {
      _session = _open();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LocalStoreSession>(
      future: _session,
      builder: (context, snapshot) {
        final session = snapshot.data;
        if (session != null) {
          return ProviderScope(
            overrides: session.overrides,
            child: const GarbloApp(),
          );
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          return StorageErrorApp(
            message: error is Failure
                ? error.message
                : "Garblo couldn't open your data on this phone.",
            onRetry: _retry,
          );
        }
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}

/// Shown instead of the app when the local store cannot be opened.
class StorageErrorApp extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const StorageErrorApp(
      {super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                      onPressed: onRetry, child: const Text('Try again')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
