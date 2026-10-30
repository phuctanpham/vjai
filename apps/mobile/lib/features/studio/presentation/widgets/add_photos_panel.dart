import 'package:flutter/material.dart';

import '../../../../core/widgets/primary_button.dart';
import '../../domain/media_asset.dart';
import '../../domain/photo_tray.dart';
import '../studio_state.dart';

/// Screens 1a (empty) and 2a (staged), spec T7 › G3.
class AddPhotosPanel extends StatelessWidget {
  final StudioState state;
  final VoidCallback onPick;
  final ValueChanged<String> onRemove;
  final ValueChanged<bool> onConsentChanged;
  final VoidCallback onAnalyze;

  const AddPhotosPanel({
    super.key,
    required this.state,
    required this.onPick,
    required this.onRemove,
    required this.onConsentChanged,
    required this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STUDIO / 01', style: theme.textTheme.labelSmall),
                const SizedBox(height: 8),
                Text('Index Pieces', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  'Garments, poses or backgrounds. Mix them freely.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                if (state.tray.isEmpty)
                  _Dropzone(onTap: onPick)
                else
                  _PhotoTrayView(
                    tray: state.tray,
                    onAdd: onPick,
                    onRemove: onRemove,
                  ),
                if (state.notice != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    state.notice!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _ConsentCard(
                  checked: state.consentChecked,
                  onChanged: onConsentChanged,
                ),
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
            label: 'Analyze with Garblo',
            onPressed: state.canAnalyze ? onAnalyze : null,
          ),
        ),
      ],
    );
  }
}

class _Dropzone extends StatelessWidget {
  final VoidCallback onTap;

  const _Dropzone({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outline, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_photo_alternate_outlined, size: 24),
            const SizedBox(height: 8),
            Text('Tap to add photos', style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text('JPG, PNG · UP TO 10 PER BATCH',
                style: theme.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _PhotoTrayView extends StatelessWidget {
  final PhotoTray tray;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  const _PhotoTrayView({
    required this.tray,
    required this.onAdd,
    required this.onRemove,
  });

  String get _counter {
    if (tray.isFull) return '${tray.count} PHOTOS SELECTED · MAXIMUM REACHED';
    return tray.count == 1
        ? '1 PHOTO SELECTED'
        : '${tray.count} PHOTOS SELECTED';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final tile = (constraints.maxWidth - 16) / 3;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_counter, style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final asset in tray.assets)
                  _RemovableTile(
                    asset: asset,
                    size: tile,
                    onRemove: () => onRemove(asset.assetId),
                  ),
                if (!tray.isFull)
                  SizedBox.square(
                    dimension: tile,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      onPressed: onAdd,
                      child: const Text('Add'),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _RemovableTile extends StatelessWidget {
  final MediaAsset asset;
  final double size;
  final VoidCallback onRemove;

  const _RemovableTile({
    required this.asset,
    required this.size,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        children: [
          Positioned.fill(child: PhotoThumbnail(asset: asset)),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Remove photo',
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder thumbnail: Phase 1 photos are fixtures, so no image is drawn.
class PhotoThumbnail extends StatelessWidget {
  final MediaAsset asset;

  const PhotoThumbnail({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(1),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ConsentCard extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;

  const _ConsentCard({required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CHG-003 Q-01: the EXIF/blur line waits for P2 sanitizing.
            Text('Private by default', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Checkbox(
                  value: checked,
                  onChanged: (value) => onChanged(value ?? false),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Process my photos, including body photos if any',
                    style: theme.textTheme.bodyMedium,
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
