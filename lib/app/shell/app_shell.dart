import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App shell: header (wordmark, temperature, bell) and pillar navigation.
/// Uses a bottom navigation bar below 800 px and a navigation rail above.
/// Each pillar page is wrapped in `KeyedSubtree(key: ValueKey('pillar-page-<name>'))`.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw UnimplementedError('TASK-002-S03');
  }
}
