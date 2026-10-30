import 'package:flutter/foundation.dart';

import '../domain/item_group.dart';
import '../domain/wardrobe_item.dart';

/// Explicit status values for the Archive screen.
enum WardrobeStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

/// State of the Archive catalog (5a).
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

  factory WardrobeState.initial() => const WardrobeState(
        status: WardrobeStatus.initial,
        items: [],
        total: 0,
        daysUnworn: {},
      );

  /// True when a group chip is active and it has no items.
  bool get isGroupEmpty =>
      status == WardrobeStatus.loaded && activeGroup != null && items.isEmpty;

  WardrobeState copyWith({
    WardrobeStatus? status,
    List<WardrobeItem>? items,
    int? total,
    ItemGroup? activeGroup,
    bool clearGroup = false,
    Map<String, int>? daysUnworn,
    String? nextCursor,
    bool clearCursor = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WardrobeState(
      status: status ?? this.status,
      items: items ?? this.items,
      total: total ?? this.total,
      activeGroup: clearGroup ? null : (activeGroup ?? this.activeGroup),
      daysUnworn: daysUnworn ?? this.daysUnworn,
      nextCursor: clearCursor ? null : (nextCursor ?? this.nextCursor),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WardrobeState &&
          status == other.status &&
          listEquals(items, other.items) &&
          total == other.total &&
          activeGroup == other.activeGroup &&
          mapEquals(daysUnworn, other.daysUnworn) &&
          nextCursor == other.nextCursor &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
        status,
        Object.hashAll(items),
        total,
        activeGroup,
        Object.hashAllUnordered(
            daysUnworn.entries.map((e) => Object.hash(e.key, e.value))),
        nextCursor,
        errorMessage,
      );
}
