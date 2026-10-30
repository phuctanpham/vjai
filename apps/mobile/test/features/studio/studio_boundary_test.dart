import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Imports that would let photo data leave the phone. Phase 1 has no
/// approved external service, so Flow A must not reach any of them.
const _networkImports = [
  'dart:io',
  'dart:html',
  'package:http/',
  'package:dio/',
  'networking/api_client.dart',
];

List<File> _dartFiles(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) return const [];
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();
}

void main() {
  test('[TASK-003-S08] Flow A code imports no networking (I3/I5 stand-in)', () {
    final files = [
      ..._dartFiles('lib/features/studio'),
      ..._dartFiles('lib/features/wardrobe'),
      ..._dartFiles('lib/core/media'),
    ];
    expect(files, isNotEmpty);

    final offenders = [
      for (final file in files)
        for (final line in file.readAsLinesSync())
          if (line.trimLeft().startsWith('import') &&
              _networkImports.any(line.contains))
            '${file.path}: ${line.trim()}',
    ];

    expect(offenders, isEmpty);
  });
}
