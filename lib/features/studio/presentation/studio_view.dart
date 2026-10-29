import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Add pillar host: 1a/2a tray, 3a scope sheet, analysis progress, 4a review.
/// After a completed save it switches to the Wardrobe pillar.
///
/// Copy follows spec T7 › G3/G4 (1a, 2a, 3a, 4a). Test contract:
/// thumbnails have the tooltip "Remove photo"; the 3a panel has the key
/// `ValueKey('analysis-scope-sheet')`; a failed save shows
/// "Couldn't index your Pieces." with "Try again" (derived from G4).
class StudioView extends ConsumerWidget {
  const StudioView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw UnimplementedError('TASK-003-S01');
  }
}
