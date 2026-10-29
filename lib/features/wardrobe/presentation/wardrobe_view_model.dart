import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/time/clock.dart';
import '../data/wardrobe_repository.dart';
import '../data/wear_repository.dart';
import '../domain/item_group.dart';
import 'wardrobe_state.dart';

/// Provider for WardrobeViewModel. Auto-disposed so that the Wardrobe
/// reloads each time its pillar is shown.
final wardrobeViewModelProvider =
    StateNotifierProvider.autoDispose<WardrobeViewModel, WardrobeState>((ref) {
  throw UnimplementedError('TASK-003-S07');
});

/// ViewModel for the Wardrobe catalog.
class WardrobeViewModel extends StateNotifier<WardrobeState> {
  WardrobeViewModel({
    required WardrobeRepository wardrobeRepository,
    required WearRepository wearRepository,
    required Clock clock,
  }) : super(WardrobeState.initial());

  /// Loads the first page for the active group and the dormancy values.
  Future<void> load() => throw UnimplementedError('TASK-003-S07');

  /// Switches the chip without a loading state (AC-04.3). Null = All.
  Future<void> selectGroup(ItemGroup? group) =>
      throw UnimplementedError('TASK-003-S07');

  /// Appends the next page, if any (AC-04.7).
  Future<void> loadMore() => throw UnimplementedError('TASK-003-S07');

  Future<void> retry() => throw UnimplementedError('TASK-003-S07');
}
