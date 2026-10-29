import 'package:flutter/foundation.dart';

import '../domain/item_group.dart';
import '../domain/wardrobe_item.dart';

/// Explicit status values for the Wardrobe screen.
enum WardrobeStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// State of the Wardrobe catalog (5a).
@immutable
class WardrobeState {
  final WardrobeStatus status;

  /// Items shown for [activeGroup], newest first.
  final List<WardrobeItem> items;

  /// All non-archived items, independent of [activeGroup].
  final int total;

  /// Null means the virtual "All" chip.
  final ItemGroup? activeGroup;

  /// Days unworn per item ID, from the dormancy rule.
  final Map<String, int> daysUnworn;
  final String? nextCursor;
  final String? errorMessage;

  const WardrobeState({
    required this.status,
    required this.items,
    required this.total,
    required this.daysUnworn,
    this.activeGroup,
    this.nextCursor,
    this.errorMessage,
  });

  factory WardrobeState.initial() => throw UnimplementedError('TASK-003-S07');

  /// True when a group chip is active and it has no items.
  bool get isGroupEmpty => throw UnimplementedError('TASK-003-S07');

  WardrobeState copyWith({
    WardrobeStatus? status,
    List<WardrobeItem>? items,
    int? total,
    ItemGroup? activeGroup,
    bool clearGroup = false,
    Map<String, int>? daysUnworn,
    String? nextCursor,
    String? errorMessage,
    bool clearError = false,
  }) =>
      throw UnimplementedError('TASK-003-S07');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S07');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S07');
}
