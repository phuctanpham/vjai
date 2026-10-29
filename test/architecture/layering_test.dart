import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Wardrobe-direction features guarded by the layering rules
/// (architecture.md §2, §3).
const _features = ['studio', 'wardrobe', 'gu_match'];

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

/// Collects "<file>: <import>" for every import that matches [isViolation].
List<String> _violations(
  Iterable<File> files,
  bool Function(String import) isViolation,
) =>
    [
      for (final file in files)
        for (final import in _imports(file))
          if (isViolation(import)) '${file.path}: $import',
    ];

void main() {
  group('layering rules', () {
    test('[TASK-002-S06] every wardrobe-direction feature has all three layers',
        () {
      for (final feature in _features) {
        for (final layer in ['domain', 'data', 'presentation']) {
          expect(
            _dartFiles('lib/features/$feature/$layer'),
            isNotEmpty,
            reason: 'lib/features/$feature/$layer',
          );
        }
      }
    });

    test('[TASK-002-S06] views and widgets never import data sources', () {
      final presentation = [
        for (final feature in _features)
          ..._dartFiles('lib/features/$feature/presentation'),
      ].where((f) => !_name(f).endsWith('_view_model.dart'));

      expect(_violations(presentation, (i) => i.contains('/data/')), isEmpty);
    });

    test('[TASK-002-S06] view models and states never import widgets or IO',
        () {
      final logic = [
        for (final feature in _features)
          ..._dartFiles('lib/features/$feature/presentation'),
      ].where((f) =>
          _name(f).endsWith('_view_model.dart') ||
          _name(f).endsWith('_state.dart'));

      expect(
        _violations(
          logic,
          (i) =>
              i == 'package:flutter/material.dart' ||
              i == 'package:flutter/widgets.dart' ||
              i == 'dart:io' ||
              i == 'dart:html',
        ),
        isEmpty,
      );
    });

    test('[TASK-002-S06] domain stays free of Flutter UI, Riverpod and data',
        () {
      final domain = [
        for (final feature in _features)
          ..._dartFiles('lib/features/$feature/domain'),
      ];

      expect(
        _violations(
          domain,
          (i) =>
              i.contains('/data/') ||
              i.contains('/presentation/') ||
              i == 'package:flutter/material.dart' ||
              i == 'package:flutter/widgets.dart' ||
              i.startsWith('package:flutter_riverpod'),
        ),
        isEmpty,
      );
    });

    test('[TASK-002-S06] no feature imports another feature\'s presentation',
        () {
      final offenders = <String>[];
      for (final feature in _features) {
        final files = _dartFiles('lib/features/$feature');
        offenders.addAll(_violations(files, (i) {
          final match = RegExp(r'features/(\w+)/presentation/').firstMatch(i) ??
              RegExp(r'^\.\./\.\./(\w+)/presentation/').firstMatch(i);
          return match != null && match.group(1) != feature;
        }));
      }

      expect(offenders, isEmpty);
    });

    test('[TASK-002-S06] no Platform.isX checks in wardrobe-direction code',
        () {
      final offenders = [
        for (final feature in _features)
          for (final file in _dartFiles('lib/features/$feature'))
            if (file.readAsStringSync().contains('Platform.is')) file.path,
        for (final file in _dartFiles('lib/app/shell'))
          if (file.readAsStringSync().contains('Platform.is')) file.path,
      ];

      expect(offenders, isEmpty);
    });
  });
}
