import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Gu Match pillar host: 1b styling studio, 2b context analysis, 3b deck.
///
/// Copy follows spec T7 › G3 (1b, 2b, 3b) and G4: never "Like", no "I", no
/// emoji. Test contract: rail buttons have the tooltips "Pass",
/// "Add to Rotation", "Adjust", "Try on"; the try-on sheet reads
/// "Try-on is coming soon"; the wear prompt reads "Wearing this today?" with
/// "Wear today" and "Save for later"; the end of deck reads
/// "You added {n} Fits to Rotation" ("1 Fit") with "Change context" and
/// "Go to Archive" (derived from G4).
class GuMatchView extends ConsumerWidget {
  const GuMatchView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw UnimplementedError('TASK-004-S01');
  }
}
