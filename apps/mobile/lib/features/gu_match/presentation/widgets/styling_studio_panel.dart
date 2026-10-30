import 'package:flutter/material.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../domain/occasion.dart';
import '../../domain/styling_context.dart';
import '../gu_match_state.dart';

/// Screen 1b, the Gu Match studio (spec T7 › G3): the user describes the day,
/// and Garblo drafts Fits only from the Pieces they own.
class StylingStudioPanel extends StatefulWidget {
  final GuMatchState state;
  final ValueChanged<Occasion> onToggleOccasion;
  final ValueChanged<String> onPromptChanged;
  final VoidCallback onStart;
  final VoidCallback onIndexPieces;

  const StylingStudioPanel({
    super.key,
    required this.state,
    required this.onToggleOccasion,
    required this.onPromptChanged,
    required this.onStart,
    required this.onIndexPieces,
  });

  @override
  State<StylingStudioPanel> createState() => _StylingStudioPanelState();
}

class _StylingStudioPanelState extends State<StylingStudioPanel> {
  // Pre-filled from the kept context, so Change context returns with the
  // same text (AC-05.9).
  late final TextEditingController _prompt =
      TextEditingController(text: widget.state.context.prompt);

  @override
  void dispose() {
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = widget.state;
    final count = state.readyCount;
    final ready = count == 1 ? '1 PIECE READY' : '$count PIECES READY';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome_outlined,
                      size: 20,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 8),
                    Text('GU MATCH', style: theme.textTheme.labelSmall),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'What are you wearing today?',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick a context. Garblo drafts only from your Archive.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final occasion in Occasion.values)
                      FilterChip(
                        label: Text(occasion.label),
                        selected: state.context.occasions.contains(occasion),
                        onSelected: (_) => widget.onToggleOccasion(occasion),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _prompt,
                  minLines: 3,
                  maxLines: 4,
                  maxLength: StylingContext.maxPromptLength,
                  onChanged: widget.onPromptChanged,
                  decoration: const InputDecoration(
                    labelText: 'TELL GARBLO MORE',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ready, style: theme.textTheme.labelMedium),
                      const SizedBox(height: 4),
                      Text(
                        'No shopping. Drafts use only what you own.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (count == 0) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Index Pieces into your Archive first',
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: widget.onIndexPieces,
                    child: const Text('Index Pieces'),
                  ),
                ],
                if (state.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: PrimaryButton(
            label: 'Draft Fits',
            onPressed: state.canStart ? widget.onStart : null,
          ),
        ),
      ],
    );
  }
}
