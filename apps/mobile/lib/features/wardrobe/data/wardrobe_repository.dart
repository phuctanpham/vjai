import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../../../core/time/clock.dart';
import '../domain/item_group.dart';
import '../domain/wardrobe_item.dart';

/// Provider for WardrobeRepository. Phase 1: seeded in-memory items.
final wardrobeRepositoryProvider = Provider<WardrobeRepository>((ref) {
  return MockWardrobeRepository.seeded(ref.watch(clockProvider).now());
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

  /// Count of non-archived items. Same number as the Archive total (I9).
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

  /// Items in insertion order; later inserts win ties on `createdAt`.
  final List<WardrobeItem> _items;

  MockWardrobeRepository({
    List<WardrobeItem> items = const [],
    this.failOnLoad = false,
    this.failSaveAfter,
    this.delay = Duration.zero,
  }) : _items = List.of(items);

  /// Nine demo items, including a White T-shirt unworn for 41 days.
  factory MockWardrobeRepository.seeded(DateTime today) {
    DateTime daysAgo(int days) =>
        DateTime(today.year, today.month, today.day - days, 9);
    WardrobeItem seed(
      String id,
      String name,
      String typeCode,
      String color,
      String material,
      String style, {
      required int savedDaysAgo,
      int? lastWornDaysAgo,
    }) =>
        WardrobeItem(
          itemId: 'seed_$id',
          name: name,
          typeCode: typeCode,
          color: color,
          material: material,
          styleTag: style,
          createdAt: daysAgo(savedDaysAgo),
          lastWornEstimate:
              lastWornDaysAgo == null ? null : daysAgo(lastWornDaysAgo),
        );

    return MockWardrobeRepository(items: [
      seed('01', 'White T-shirt', 'T_SHIRT', 'White', 'Cotton', 'Basic',
          savedDaysAgo: 60, lastWornDaysAgo: 41),
      seed('02', 'Short-sleeve shirt', 'SHIRT', 'Blue', 'Linen', 'Everyday',
          savedDaysAgo: 5),
      seed('03', 'Black jeans', 'JEANS', 'Black', 'Denim', 'Everyday',
          savedDaysAgo: 20, lastWornDaysAgo: 3),
      seed('04', 'Pleated skirt', 'SKIRT', 'Navy', 'Wool', 'Smart',
          savedDaysAgo: 18, lastWornDaysAgo: 9),
      seed('05', 'Black loafers', 'LOAFERS', 'Black', 'Leather', 'Smart',
          savedDaysAgo: 30, lastWornDaysAgo: 2),
      seed('06', 'White sneakers', 'SNEAKERS', 'White', 'Canvas', 'Basic',
          savedDaysAgo: 25, lastWornDaysAgo: 6),
      seed('07', 'Canvas tote', 'TOTE_BAG', 'Natural', 'Canvas', 'Everyday',
          savedDaysAgo: 12, lastWornDaysAgo: 1),
      seed('08', 'Bucket hat', 'BUCKET_HAT', 'Olive', 'Cotton', 'Street',
          savedDaysAgo: 8),
      seed('09', 'Silk tie', 'TIE', 'Burgundy', 'Silk', 'Smart',
          savedDaysAgo: 15, lastWornDaysAgo: 14),
    ]);
  }

  @override
  Future<WardrobePage> getItems({ItemGroup? group, String? cursor}) async {
    await _wait();
    if (failOnLoad) {
      throw const StorageFailure('Could not load your Archive.');
    }

    final eligible = _eligibleNewestFirst();
    final filtered = group == null
        ? eligible
        : eligible.where((i) => i.group == group).toList();
    final start = cursor == null ? 0 : int.parse(cursor);
    final end = (start + WardrobeRepository.pageSize).clamp(0, filtered.length);

    return WardrobePage(
      items: filtered.sublist(start.clamp(0, filtered.length), end),
      total: eligible.length,
      nextCursor: end < filtered.length ? '$end' : null,
    );
  }

  @override
  Future<int> countEligible() async {
    await _wait();
    if (failOnLoad) {
      throw const StorageFailure('Could not load your Archive.');
    }
    return _items.where((i) => !i.isArchived).length;
  }

  @override
  Future<List<WardrobeItem>> getEligibleItems() async {
    await _wait();
    if (failOnLoad) {
      throw const StorageFailure('Could not load your Archive.');
    }
    return _eligibleNewestFirst();
  }

  @override
  Future<void> saveItems(List<WardrobeItem> items) async {
    await _wait();
    // Write into a copy and swap it in only when every item is in, so a
    // failure part-way leaves the Archive unchanged (TAC-03.2).
    final staged = List.of(_items);
    for (var i = 0; i < items.length; i++) {
      if (failSaveAfter != null && i >= failSaveAfter!) {
        throw const StorageFailure('Could not save your Pieces.');
      }
      staged.add(items[i]);
    }
    _items
      ..clear()
      ..addAll(staged);
  }

  /// Non-archived items, newest `createdAt` first. Ties keep the order in
  /// which the items were saved, so a saved batch stays in review order.
  List<WardrobeItem> _eligibleNewestFirst() {
    final indexed = [
      for (var i = 0; i < _items.length; i++)
        if (!_items[i].isArchived) (index: i, item: _items[i]),
    ];
    indexed.sort((a, b) {
      final byDate = b.item.createdAt.compareTo(a.item.createdAt);
      return byDate != 0 ? byDate : a.index.compareTo(b.index);
    });
    return [for (final entry in indexed) entry.item];
  }

  Future<void> _wait() async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
  }
}
