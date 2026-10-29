import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the active pillar. Features switch pillars through it.
final pillarProvider = StateNotifierProvider<PillarController, Pillar>((ref) {
  throw UnimplementedError('TASK-002-S01');
});

/// The five top-level destinations of the app shell.
enum Pillar {
  add,
  wardrobe,
  guMatch,
  impact,
  community,
}

/// User-facing pillar labels, spec T7 › G4:
/// ADD · ARCHIVE · GU MATCH · IMPACT · COMMUNITY.
extension PillarLabel on Pillar {
  String get label => throw UnimplementedError('TASK-002-S03');
}

/// Holds the active pillar.
class PillarController extends StateNotifier<Pillar> {
  PillarController([super.initial = Pillar.add]);

  void select(Pillar pillar) => throw UnimplementedError('TASK-002-S01');
}
