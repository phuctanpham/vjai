import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/navigation/pillar.dart';
import 'pillar_pages.dart';

/// App shell: header (wordmark, temperature, bell) and pillar navigation.
/// Uses a bottom navigation bar below 800 px and a navigation rail above.
/// Each pillar page is wrapped in `KeyedSubtree(key: ValueKey('pillar-page-<name>'))`.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  static const _icons = {
    Pillar.add: Icons.add_a_photo_outlined,
    Pillar.wardrobe: Icons.checkroom_outlined,
    Pillar.guMatch: Icons.auto_awesome_outlined,
    Pillar.impact: Icons.eco_outlined,
    Pillar.community: Icons.groups_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pillar = ref.watch(pillarProvider);
    final pages = ref.watch(pillarPagesProvider);
    final controller = ref.read(pillarProvider.notifier);

    final page = KeyedSubtree(
      key: ValueKey('pillar-page-${pillar.name}'),
      child: Builder(builder: pages[pillar]!),
    );
    void onSelected(int index) => controller.select(Pillar.values[index]);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (!Breakpoints.isDesktop(constraints.maxWidth)) {
          return Scaffold(
            appBar: const _ShellHeader(),
            body: page,
            bottomNavigationBar: NavigationBar(
              height: 64,
              selectedIndex: pillar.index,
              onDestinationSelected: onSelected,
              destinations: [
                for (final p in Pillar.values)
                  NavigationDestination(icon: Icon(_icons[p]), label: p.label),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: const _ShellHeader(),
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: pillar.index,
                onDestinationSelected: onSelected,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final p in Pillar.values)
                    NavigationRailDestination(
                      icon: Icon(_icons[p]),
                      label: Text(p.label),
                    ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: page),
            ],
          ),
        );
      },
    );
  }
}

/// Solid header (spec T1 Z0): garblo wordmark, static weather, bell.
class _ShellHeader extends StatelessWidget implements PreferredSizeWidget {
  const _ShellHeader();

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      toolbarHeight: 56,
      title: Text(
        'garblo',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text('29°', style: theme.textTheme.labelMedium),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Notifications',
          icon: const Icon(Icons.notifications_none_rounded),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
