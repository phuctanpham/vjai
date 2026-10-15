import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/empty_view.dart';
import '../../../core/widgets/error_view.dart';
import 'discovery_state.dart';
import 'discovery_view_model.dart';
import 'widgets/discovery_layout.dart';

/// Main screen for discovering new profiles.
class DiscoveryView extends ConsumerWidget {
  const DiscoveryView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(discoveryViewModelProvider);
    final viewModel = ref.read(discoveryViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded, color: Colors.deepOrangeAccent),
            SizedBox(width: 8),
            Text('Garblo', fontWeight: FontWeight.bold),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reload profiles',
            onPressed: () => viewModel.retry(),
          ),
        ],
      ),
      body: _buildBody(context, state, viewModel),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DiscoveryState state,
    DiscoveryViewModel viewModel,
  ) {
    switch (state.status) {
      case DiscoveryStatus.initial:
      case DiscoveryStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case DiscoveryStatus.error:
        return ErrorView(
          message: state.errorMessage ?? 'An unexpected error occurred.',
          onRetry: () => viewModel.retry(),
        );

      case DiscoveryStatus.empty:
        return EmptyView(
          title: "You're all caught up!",
          message: 'No more profiles nearby right now. Check back later or expand your preferences.',
          icon: Icons.explore_off_outlined,
          actionLabel: 'Refresh Feed',
          onAction: () => viewModel.retry(),
        );

      case DiscoveryStatus.loaded:
        final currentProfile = state.currentProfile;
        if (currentProfile == null) {
          return EmptyView(
            title: "You're all caught up!",
            message: 'No more profiles nearby right now.',
            actionLabel: 'Refresh Feed',
            onAction: () => viewModel.retry(),
          );
        }

        return DiscoveryLayout(
          profile: currentProfile,
          remainingCount: state.profiles.length - state.currentIndex,
          onSwipe: (swipeType) => viewModel.swipe(swipeType),
        );
    }
  }
}

