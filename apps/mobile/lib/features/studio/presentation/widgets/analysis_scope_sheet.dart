import 'package:flutter/material.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../domain/analysis_task.dart';
import '../studio_state.dart';
import 'add_photos_panel.dart';

/// Screen 3a "What should Garblo read?", spec T7 › G3. A decision sheet over
/// the dimmed tray; the left button rolls back, the right one commits.
class AnalysisScopeSheet extends StatelessWidget {
  final StudioState state;
  final ValueChanged<AnalysisTask> onToggle;
  final VoidCallback onReselect;
  final VoidCallback onConfirm;

  const AnalysisScopeSheet({
    super.key,
    required this.state,
    required this.onToggle,
    required this.onReselect,
    required this.onConfirm,
  });

  static const _options = [
    (
      task: AnalysisTask.outfitExtraction,
      title: 'Pieces',
      note: 'SEPARATE GARMENTS, READ ATTRIBUTES',
    ),
    (
      task: AnalysisTask.poseEstimation,
      title: 'Pose',
      note: 'ONLY WHEN A PERSON IS IN THE PHOTO',
    ),
    (
      task: AnalysisTask.backgroundAnalysis,
      title: 'Background',
      note: 'ONLY WHEN A PERSON IS IN THE PHOTO',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 8,
      color: theme.colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('What should Garblo read?', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            SizedBox(
              height: 64,
              child: Row(
                children: [
                  for (final asset in state.tray.assets.take(5)) ...[
                    SizedBox.square(
                      dimension: 64,
                      child: PhotoThumbnail(asset: asset),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            for (final option in _options)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: state.selection.contains(option.task),
                onChanged: (_) => onToggle(option.task),
                title: Text(option.title),
                subtitle: Text(option.note, style: theme.textTheme.labelSmall),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onReselect,
                    child: const Text('Reselect photos'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: PrimaryButton(
                    label: 'Read photos',
                    onPressed: state.canConfirmScope ? onConfirm : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
