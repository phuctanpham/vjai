import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/pillar.dart';
import '../router.dart';

/// Explicit destination for routes that do not exist.
class UnknownRouteView extends ConsumerWidget {
  final String? routeName;

  const UnknownRouteView({super.key, required this.routeName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Page not found',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'No page at ${routeName ?? '(none)'}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  ref.read(pillarProvider.notifier).select(Pillar.add);
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.initialRoute,
                    (_) => false,
                  );
                },
                child: const Text('Go to Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
