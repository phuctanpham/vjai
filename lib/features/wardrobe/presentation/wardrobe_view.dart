import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/breakpoints.dart';
import '../../../core/navigation/pillar.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/loading_view.dart';
import '../../../core/widgets/primary_button.dart';
import '../domain/item_group.dart';
import 'wardrobe_state.dart';
import 'wardrobe_view_model.dart';
import 'widgets/wardrobe_item_card.dart';

/// Archive (5a), copy from spec T7 › G3/G4: "YOUR ARCHIVE" · "Archive" ·
/// "{N} PIECES", group chips, flush grid (2 columns below 800, 3 at or above,
/// T7 › G1), "▲ BENCHED · {d} DAYS" status, "Draft a Fit" FAB (sparkles
/// icon, no emoji). Empty: "Your Archive is empty" + "Index Pieces";
/// empty group: "No bags yet" + "Index Pieces" (derived from G4).
class WardrobeView extends ConsumerWidget {
  const WardrobeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wardrobeViewModelProvider);
    final vm = ref.read(wardrobeViewModelProvider.notifier);
    void goTo(Pillar pillar) =>
        ref.read(pillarProvider.notifier).select(pillar);

    return switch (state.status) {
      WardrobeStatus.initial || WardrobeStatus.loading => const LoadingView(),
      WardrobeStatus.error => ErrorView(
          message: state.errorMessage ?? 'Could not load your Archive.',
          onRetry: vm.retry,
        ),
      WardrobeStatus.empty => EmptyView(
          icon: Icons.checkroom_outlined,
          title: 'Your Archive is empty',
          message: 'Index Pieces to start drafting Fits from what you own.',
          actionLabel: 'Index Pieces',
          onAction: () => goTo(Pillar.add),
        ),
      WardrobeStatus.loaded => _ArchiveContent(
          state: state,
          onSelectGroup: vm.selectGroup,
          onLoadMore: vm.loadMore,
          onIndexPieces: () => goTo(Pillar.add),
          onDraftFit: () => goTo(Pillar.guMatch),
        ),
    };
  }
}

class _ArchiveContent extends StatelessWidget {
  final WardrobeState state;
  final ValueChanged<ItemGroup?> onSelectGroup;
  final VoidCallback onLoadMore;
  final VoidCallback onIndexPieces;
  final VoidCallback onDraftFit;

  const _ArchiveContent({
    required this.state,
    required this.onSelectGroup,
    required this.onLoadMore,
    required this.onIndexPieces,
    required this.onDraftFit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = state.total == 1 ? '1 PIECE' : '${state.total} PIECES';

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = Breakpoints.isDesktop(constraints.maxWidth) ? 3 : 2;

        return Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('YOUR ARCHIVE', style: theme.textTheme.labelSmall),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('Archive',
                              style: theme.textTheme.headlineMedium),
                          const Spacer(),
                          Text(count, style: theme.textTheme.labelMedium),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: state.activeGroup == null,
                        onSelected: (_) => onSelectGroup(null),
                      ),
                      for (final group in ItemGroup.values)
                        ChoiceChip(
                          label: Text(group.label),
                          selected: state.activeGroup == group,
                          onSelected: (_) => onSelectGroup(group),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.isGroupEmpty
                      ? _EmptyGroup(
                          group: state.activeGroup!,
                          onIndexPieces: onIndexPieces,
                        )
                      : NotificationListener<ScrollEndNotification>(
                          onNotification: (notification) {
                            final metrics = notification.metrics;
                            if (metrics.pixels >= metrics.maxScrollExtent) {
                              onLoadMore();
                            }
                            return false;
                          },
                          child: GridView.builder(
                            padding: const EdgeInsets.only(bottom: 96),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              childAspectRatio: 195 / 300,
                            ),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return WardrobeItemCard(
                                item: item,
                                daysUnworn: state.daysUnworn[item.itemId] ?? 0,
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 16,
              child: Center(
                child: PrimaryButton(
                  label: 'Draft a Fit',
                  icon: Icons.auto_awesome_outlined,
                  expand: false,
                  onPressed: onDraftFit,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyGroup extends StatelessWidget {
  final ItemGroup group;
  final VoidCallback onIndexPieces;

  const _EmptyGroup({required this.group, required this.onIndexPieces});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No ${group.label.toLowerCase()} yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: onIndexPieces,
            child: const Text('Index Pieces'),
          ),
        ],
      ),
    );
  }
}
