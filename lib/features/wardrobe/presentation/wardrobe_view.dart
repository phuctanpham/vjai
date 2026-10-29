import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Archive (5a), copy from spec T7 › G3/G4: "YOUR ARCHIVE" · "Archive" ·
/// "{N} PIECES", group chips, flush grid (2 columns below 800, 3 at or above,
/// T7 › G1), "▲ BENCHED · {d} DAYS" status, "Draft a Fit" FAB (sparkles
/// icon, no emoji). Empty: "Your Archive is empty" + "Index Pieces";
/// empty group: "No bags yet" + "Index Pieces" (derived from G4).
class WardrobeView extends ConsumerWidget {
  const WardrobeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    throw UnimplementedError('TASK-003-S07');
  }
}
