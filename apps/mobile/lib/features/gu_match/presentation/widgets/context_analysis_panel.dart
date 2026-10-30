import 'package:flutter/material.dart';

import '../../domain/context_card.dart';
import '../gu_match_state.dart';

/// Screen 2b "Reading your context" (spec T7 › G3): four cards in fixed
/// order, each filled as its source returns. Garblo never says "I".
class ContextAnalysisPanel extends StatelessWidget {
  final GuMatchState state;

  const ContextAnalysisPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'DRAFTING · CALENDAR, WEATHER & COMMUTE',
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(state.contextTitle, style: theme.textTheme.headlineMedium),
          if (state.isContextComplete) ...[
            const SizedBox(height: 4),
            Text(
              'Based on your schedule, weather, location and commute habits',
              style: theme.textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 16),
          for (final kind in ContextCardKind.values) ...[
            _ContextCardView(card: state.cards[kind]),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _ContextCardView extends StatelessWidget {
  /// Null while its source has not returned: shown as a skeleton.
  final ContextCard? card;

  const _ContextCardView({required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = this.card;

    if (card == null) {
      return Container(
        height: 88,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.label, style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            Text(
              card.headline,
              style: theme.textTheme.titleMedium?.copyWith(
                color:
                    card.isMissing ? theme.colorScheme.onSurfaceVariant : null,
              ),
            ),
            if (card.detail != null) ...[
              const SizedBox(height: 4),
              Text(card.detail!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
