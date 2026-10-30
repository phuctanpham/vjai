import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/time/clock.dart';
import '../data/wardrobe_repository.dart';
import '../data/wear_repository.dart';
import '../domain/dormancy.dart';
import '../domain/item_group.dart';
import '../domain/wardrobe_item.dart';
import 'wardrobe_state.dart';

/// Provider for WardrobeViewModel. Auto-disposed so that the Archive
/// reloads each time its pillar is shown.
final wardrobeViewModelProvider =
    StateNotifierProvider.autoDispose<WardrobeViewModel, WardrobeState>((ref) {
  return WardrobeViewModel(
    wardrobeRepository: ref.watch(wardrobeRepositoryProvider),
    wearRepository: ref.watch(wearRepositoryProvider),
    clock: ref.watch(clockProvider),
  )..load();
});

/// ViewModel for the Archive catalog.
class WardrobeViewModel extends StateNotifier<WardrobeState> {
  final WardrobeRepository _wardrobeRepository;
  final WearRepository _wearRepository;
  final Clock _clock;

  WardrobeViewModel({
    required WardrobeRepository wardrobeRepository,
    required WearRepository wearRepository,
    required Clock clock,
  })  : _wardrobeRepository = wardrobeRepository,
        _wearRepository = wearRepository,
        _clock = clock,
        super(WardrobeState.initial());

  /// Loads the first page for the active group and the dormancy values.
  Future<void> load() async {
    state = state.copyWith(status: WardrobeStatus.loading, clearError: true);
    await _showGroup(state.activeGroup);
  }

  /// Switches the chip without a loading state (AC-04.3). Null = All.
  Future<void> selectGroup(ItemGroup? group) => _showGroup(group);

  /// Appends the next page, if any (AC-04.7).
  Future<void> loadMore() async {
    final cursor = state.nextCursor;
    if (cursor == null || state.status != WardrobeStatus.loaded) return;

    try {
      final page = await _wardrobeRepository.getItems(
        group: state.activeGroup,
        cursor: cursor,
      );
      final days = await _daysUnworn(page.items);
      state = state.copyWith(
        items: [...state.items, ...page.items],
        total: page.total,
        daysUnworn: {...state.daysUnworn, ...days},
        nextCursor: page.nextCursor,
        clearCursor: page.nextCursor == null,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        status: WardrobeStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  Future<void> retry() => load();

  Future<void> _showGroup(ItemGroup? group) async {
    try {
      final page = await _wardrobeRepository.getItems(group: group);
      final days = await _daysUnworn(page.items);
      state = WardrobeState(
        status: page.total == 0 ? WardrobeStatus.empty : WardrobeStatus.loaded,
        items: page.items,
        total: page.total,
        activeGroup: group,
        daysUnworn: days,
        nextCursor: page.nextCursor,
      );
    } on Failure catch (failure) {
      state = state.copyWith(
        status: WardrobeStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  Future<Map<String, int>> _daysUnworn(List<WardrobeItem> items) async {
    final lastWorn = await _wearRepository.lastWornByItem();
    final today = _clock.now();
    return {
      for (final item in items)
        item.itemId: DormancyRules.daysUnworn(
          item: item,
          today: today,
          lastWear: lastWorn[item.itemId],
        ),
    };
  }
}
