import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Features whose state is persisted in Phase 2.
const _features = ['studio', 'wardrobe', 'gu_match', 'privacy'];

final _importPattern =
    RegExp(r'''^\s*import\s+['"]([^'"]+)['"]''', multiLine: true);

List<File> _dartFiles(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
}

List<String> _imports(File file) => _importPattern
    .allMatches(file.readAsStringSync())
    .map((m) => m.group(1)!)
    .toList();

String _name(File file) => file.uri.pathSegments.last;

bool _isStorage(String import) =>
    import.startsWith('package:sqlite_async') ||
    import.startsWith('package:sqlite3') ||
    import.startsWith('package:sqlcipher_flutter_libs') ||
    import.startsWith('package:flutter_secure_storage') ||
    import.contains('core/storage/') ||
    RegExp(r'data/local_[a-z_]+\.dart$').hasMatch(import);

List<String> _violations(Iterable<File> files, bool Function(String) bad) => [
      for (final file in files)
        for (final import in _imports(file))
          if (bad(import)) '${file.path}: $import',
    ];

void main() {
  group('storage boundary (TASK-005-S08)', () {
    test('[TASK-005-S08] no widget imports storage', () {
      final widgets = [
        for (final feature in _features)
          ..._dartFiles('lib/features/$feature/presentation'),
        ..._dartFiles('lib/app/shell'),
        ..._dartFiles('lib/core/widgets'),
      ].where((f) => !_name(f).endsWith('_view_model.dart'));

      expect(_violations(widgets, _isStorage), isEmpty);
    });

    test('[TASK-005-S08] ViewModels restore through repositories only', () {
      final viewModels = [
        for (final feature in _features)
          ..._dartFiles('lib/features/$feature/presentation'),
      ].where((f) => _name(f).endsWith('_view_model.dart'));

      // Provider wiring and IDs are allowed; databases and tables are not.
      bool bad(String import) =>
          _isStorage(import) &&
          !import.endsWith('core/storage/storage_providers.dart') &&
          !import.endsWith('core/storage/object_id.dart');

      expect(_violations(viewModels, bad), isEmpty);
    });

    test('[TASK-005-S08] domain code has no storage or SQL', () {
      final domain = [
        for (final feature in _features)
          ..._dartFiles('lib/features/$feature/domain'),
      ];

      // SQL is written in capitals in this codebase; prose such as
      // "Reselect photos" must not match.
      final sql = RegExp(
          r'\bSELECT\b[\s\S]*?\bFROM\b|\bINSERT\s+INTO\b|\bCREATE\s+TABLE\b');
      expect(_violations(domain, _isStorage), isEmpty);
      for (final file in domain) {
        expect(sql.hasMatch(file.readAsStringSync()), isFalse,
            reason: file.path);
      }
    });

    test('[TASK-005-S08] only core/storage opens the database', () {
      final all = _dartFiles('lib').where(
          (f) => !f.path.replaceAll(r'\', '/').contains('lib/core/storage/'));
      final opens = [
        for (final file in all)
          if (file.readAsStringSync().contains('SqliteDatabase(')) file.path,
      ];

      expect(opens, isEmpty);
    });
  });
}
