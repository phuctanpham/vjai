import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/item_group.dart';
import '../domain/wardrobe_item.dart';

/// Provider for WardrobeRepository. Phase 1: seeded in-memory items.
final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  throw UnimplementedError('TASK-003-S07');
});

/// One page of wardrobe items.
@immutable
class WardrobePage {
  final List<WardrobeItem> items;

  /// Count of all non-archived items, independent of the group filter.
  final int total;
  final String? nextCursor;

  const WardrobePage({
    required this.items,
    required this.total,
    this.nextCursor,
  });
}

/// Contract for wardrobe data operations.
abstract class WardrobeRepository {
  static const int pageSize = 20;

  /// Non-archived items, newest first, optionally filtered by [group],
  /// [pageSize] at a time.
  Future<WardrobePage> getItems({ItemGroup? group, String? cursor});

  /// Count of non-archived items. Same number as the Wardrobe total (I9).
  Future<int> countEligible();

  /// All non-archived items, for styling.
  Future<List<WardrobeItem>> getEligibleItems();

  /// Inserts every item or none (TAC-03.2). Throws a `Failure` on error.
  Future<void> saveItems(List<WardrobeItem> items);
}

/// In-memory implementation of WardrobeRepository.
class MockWardrobeRepository implements WardrobeRepository {
  final bool failOnLoad;

  /// When set, saving throws a `StorageFailure` after inserting this many
  /// items of the batch, and the batch is rolled back.
  final int? failSaveAfter;
  final Duration delay;

  MockWardrobeRepository({
    List<WardrobeItem> items = const [],
    this.failOnLoad = false,
    this.failSaveAfter,
    this.delay = Duration.zero,
  });

  /// Nine demo items, including a White T-shirt unworn for 41 days.
  factory MockWardrobeRepository.seeded(DateTime today) =>
      throw UnimplementedError('TASK-003-S07');

  @override
  Future<WardrobePage> getItems({ItemGroup? group, String? cursor}) =>
      throw UnimplementedError('TASK-003-S07');

  @override
  Future<int> countEligible() => throw UnimplementedError('TASK-004-S01');

  @override
  Future<List<WardrobeItem>> getEligibleItems() =>
      throw UnimplementedError('TASK-004-S04');

  @override
  Future<void> saveItems(List<WardrobeItem> items) =>
      throw UnimplementedError('TASK-003-S05');
}
