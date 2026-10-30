import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';
import 'package:sqlite3/open.dart' as sqlite_open;

import '../core/errors/failures.dart';
import '../core/storage/attachment_store.dart';
import '../core/storage/install_identity.dart';
import '../core/storage/local_data_store.dart';
import '../core/storage/object_id.dart';
import '../core/storage/secure_store.dart';
import '../core/storage/storage_providers.dart';
import '../core/time/clock.dart';
import '../features/gu_match/data/gu_match_repository.dart';
import '../features/gu_match/data/local_gu_match_repository.dart';
import '../features/privacy/data/privacy_repository.dart';
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

/// The opened local store. [overridesFor] builds the provider overrides
/// that use it; they read the database when a scope is created, so after
/// "Delete all" a new scope runs on the fresh store (TASK-008-S05).
class LocalStoreSession {
  final List<Override> Function(void Function() onReset) overridesFor;

  const LocalStoreSession({required this.overridesFor});
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
  final store = LocalDataStore(
    databasePath: '${dir.path}${separator}garblo.db',
    attachments: attachments,
    identity: identity,
    beforeOpen: openSqlCipher,
  );
  await store.open();
  final owner = await identity.ownerId();
  if (demoSeedEnabled) {
    await seedDemoArchive(
      wardrobe: LocalWardrobeRepository(db: store.database, ownerId: owner),
      today: clock.now(),
    );
  }

  return LocalStoreSession(
    overridesFor: (onReset) => [
      localDatabaseProvider.overrideWith((ref) => store.database),
      ownerIdProvider.overrideWithValue(owner),
      attachmentStoreProvider.overrideWithValue(attachments),
      objectIdGeneratorProvider.overrideWithValue(ids),
      dataResetProvider.overrideWithValue(onReset),
      privacyRepositoryProvider.overrideWith((ref) => LocalPrivacyRepository(
          store: store, clock: ref.watch(clockProvider))),
      wardrobeRepositoryProvider.overrideWith((ref) => LocalWardrobeRepository(
          db: ref.watch(localDatabaseProvider), ownerId: owner)),
      wearRepositoryProvider.overrideWith((ref) => LocalWearRepository(
          db: ref.watch(localDatabaseProvider), ownerId: owner)),
      studioRepositoryProvider.overrideWith((ref) => LocalStudioRepository(
            db: ref.watch(localDatabaseProvider),
            ownerId: owner,
            attachments: attachments,
            ids: ids,
            clock: ref.watch(clockProvider),
          )),
      guMatchRepositoryProvider.overrideWith((ref) => LocalGuMatchRepository(
            db: ref.watch(localDatabaseProvider),
            ownerId: owner,
            wardrobeRepository: ref.watch(wardrobeRepositoryProvider),
            wearRepository: ref.watch(wearRepositoryProvider),
            clock: ref.watch(clockProvider),
            ids: ids,
          )),
    ],
  );
}

/// Opens the local store, then runs [GarbloApp] on it. Shows an explicit
/// error with "Try again" when storage cannot be opened (TASK-005-S09).
/// After "Delete all" it restarts the app on the fresh store (TASK-008-S05).
class GarbloBootstrap extends StatefulWidget {
  final Future<LocalStoreSession> Function() open;

  const GarbloBootstrap({super.key, this.open = openLocalStore});

  @override
  State<GarbloBootstrap> createState() => _GarbloBootstrapState();
}

class _GarbloBootstrapState extends State<GarbloBootstrap> {
  late Future<LocalStoreSession> _session = _open();

  /// Each restart gets a new scope, so every provider starts fresh.
  int _generation = 0;
  List<Override>? _overrides;

  /// The FutureBuilder reports the error; `ignore` keeps an error that
  /// arrives before it subscribes from counting as unhandled.
  Future<LocalStoreSession> _open() => widget.open()..ignore();

  void _retry() {
    setState(() {
      _session = _open();
    });
  }

  void _restart() {
    if (!mounted) return;
    setState(() {
      _generation++;
      _overrides = null;
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
            key: ValueKey(_generation),
            overrides: _overrides ??= session.overridesFor(_restart),
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
