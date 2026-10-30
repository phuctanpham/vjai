import 'package:flutter/material.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../../wardrobe/domain/item_group.dart';
import '../../domain/outfit_candidate.dart';
import '../../domain/slot_role.dart';
import '../../domain/visual_mode.dart';
import '../gu_match_state.dart';

/// Screen 3b, the Fit deck (spec T7 › G3): one Fit at a time, drafted from
/// the user's own Pieces. Rail buttons are the alternative to swiping.
class OutfitDeckPanel extends StatelessWidget {
  final GuMatchState state;
  final VoidCallback onPass;
  final VoidCallback onAddToRotation;
  final VoidCallback onAdjust;
  final VoidCallback onTryOn;
  final VoidCallback onChangeContext;
  final VoidCallback onWearToday;
  final VoidCallback onSaveForLater;
  final VoidCallback onDismissTryOn;
  final ValueChanged<SlotRole> onChooseSlot;
  final ValueChanged<String> onSwap;
  final VoidCallback onCloseAdjust;

  const OutfitDeckPanel({
    super.key,
    required this.state,
    required this.onPass,
    required this.onAddToRotation,
    required this.onAdjust,
    required this.onTryOn,
    required this.onChangeContext,
    required this.onWearToday,
    required this.onSaveForLater,
    required this.onDismissTryOn,
    required this.onChooseSlot,
    required this.onSwap,
    required this.onCloseAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final candidate = state.currentCandidate!;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -300) onPass();
              if (velocity > 300) onAddToRotation();
            },
            child: _FitCard(candidate: candidate),
          ),
        ),
        Positioned(
          top: 12,
          left: 12,
          right: 12,
          child: _Hud(label: state.hudLabel, onChangeContext: onChangeContext),
        ),
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: Center(
            child: _ActionRail(
              onPass: onPass,
              onAddToRotation: onAddToRotation,
              onAdjust: onAdjust,
              onTryOn: onTryOn,
            ),
          ),
        ),
        if (state.isWearPromptVisible)
          _BottomSheetPanel(
            children: [
              Text(
                'Wearing this today?',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              // A failed "Wear today" stays on the prompt so it can be
              // retried (TASK-009-S08).
              if (state.errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
              const SizedBox(height: 16),
              PrimaryButton(label: 'Wear today', onPressed: onWearToday),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: onSaveForLater,
                child: const Text('Save for later'),
              ),
            ],
          ),
        if (state.isTryOnNoticeVisible)
          _BottomSheetPanel(
            children: [
              Text(
                'Try-on is coming soon',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Seeing a Fit on your own photo needs the try-on service. '
                'Until then, decide with the Pieces shown here.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              PrimaryButton(label: 'OK', onPressed: onDismissTryOn),
            ],
          ),
        if (state.isAdjustOpen)
          _AdjustSheet(
            candidate: candidate,
            state: state,
            onChooseSlot: onChooseSlot,
            onSwap: onSwap,
            onClose: onCloseAdjust,
          ),
      ],
    );
  }
}

class _FitCard extends StatelessWidget {
  final OutfitCandidate candidate;

  const _FitCard({required this.candidate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surfaceContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 64, 80, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flat-lay collage of the Fit's Pieces (no images in Phase 1).
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final item in candidate.items)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.checkroom_outlined,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item.slotRole.label} · ${item.name}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            _Pill(label: candidate.visualMode.label),
            const SizedBox(height: 12),
            Text(candidate.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('${candidate.matchPct}% FIT',
                style: theme.textTheme.labelLarge),
            if (candidate.highlightReason != null) ...[
              const SizedBox(height: 4),
              Text(candidate.highlightReason!,
                  style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _Hud extends StatelessWidget {
  final String label;
  final VoidCallback onChangeContext;

  const _Hud({required this.label, required this.onChangeContext});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(label: label),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onChangeContext,
          child: const Text(
            'Change context',
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.86),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(label, style: theme.textTheme.labelSmall),
    );
  }
}

class _ActionRail extends StatelessWidget {
  final VoidCallback onPass;
  final VoidCallback onAddToRotation;
  final VoidCallback onAdjust;
  final VoidCallback onTryOn;

  const _ActionRail({
    required this.onPass,
    required this.onAddToRotation,
    required this.onAdjust,
    required this.onTryOn,
  });

  @override
  Widget build(BuildContext context) {
    Widget button(String tooltip, IconData icon, VoidCallback onPressed) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: IconButton.filledTonal(
            tooltip: tooltip,
            iconSize: 24,
            constraints: const BoxConstraints.tightFor(width: 52, height: 52),
            icon: Icon(icon),
            onPressed: onPressed,
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button('Pass', Icons.close_rounded, onPass),
        button('Add to Rotation', Icons.add_rounded, onAddToRotation),
        button('Adjust', Icons.tune_rounded, onAdjust),
        button('Try on', Icons.accessibility_new_rounded, onTryOn),
      ],
    );
  }
}

class _BottomSheetPanel extends StatelessWidget {
  final List<Widget> children;

  const _BottomSheetPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 8,
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ),
    );
  }
}

class _AdjustSheet extends StatelessWidget {
  final OutfitCandidate candidate;
  final GuMatchState state;
  final ValueChanged<SlotRole> onChooseSlot;
  final ValueChanged<String> onSwap;
  final VoidCallback onClose;

  const _AdjustSheet({
    required this.candidate,
    required this.state,
    required this.onChooseSlot,
    required this.onSwap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slot = state.adjustSlot;

    return _BottomSheetPanel(
      children: [
        Text('Adjust this Fit', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        if (slot == null)
          for (final item in candidate.items)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${item.slotRole.label} · ${item.name}'),
              trailing: TextButton(
                onPressed: () => onChooseSlot(item.slotRole),
                child: const Text('Swap'),
              ),
            )
        else if (state.swapOptions.isEmpty)
          Text(
            'No other ${slot.group.label.toLowerCase()} in your Archive',
            style: theme.textTheme.bodyMedium,
          )
        else
          for (final option in state.swapOptions)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(option.name),
              onTap: () => onSwap(option.itemId),
            ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onClose, child: const Text('Close')),
      ],
    );
  }
}
