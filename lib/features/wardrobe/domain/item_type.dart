import 'package:flutter/foundation.dart';

import 'item_group.dart';

/// A garment type such as Shirt or Sneakers. Each type belongs to one group.
@immutable
class ItemType {
  final String code;
  final ItemGroup group;
  final String label;

  const ItemType(
      {required this.code, required this.group, required this.label});

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S04');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S04');
}

/// The item-type lookup (spec T2 `item_types`). The group of an item is
/// always derived from its type, never stored separately (TAC-03.6).
///
/// Phase 1 codes (tests depend on these):
/// tops `SHIRT` Shirt, `T_SHIRT` T-shirt, `SWEATER` Sweater ·
/// bottoms `WIDE_LEG_TROUSERS` Wide-leg trousers, `JEANS` Jeans, `SKIRT` Skirt ·
/// shoes `SNEAKERS` Sneakers, `LOAFERS` Loafers ·
/// bags `TOTE_BAG` Tote bag, `CROSSBODY_BAG` Crossbody bag ·
/// hats `CAP` Cap, `BUCKET_HAT` Bucket hat ·
/// accessories `TIE` Tie, `SCARF` Scarf, `BELT` Belt.
class ItemTypeCatalog {
  const ItemTypeCatalog._();

  static List<ItemType> get all => throw UnimplementedError('TASK-003-S04');

  /// Returns the type for [code], or null when the code is unknown.
  static ItemType? byCode(String code) =>
      throw UnimplementedError('TASK-003-S04');

  /// Returns the group of [code]. Throws [ArgumentError] for unknown codes.
  static ItemGroup groupOf(String code) =>
      throw UnimplementedError('TASK-003-S04');

  static List<ItemType> typesIn(ItemGroup group) =>
      throw UnimplementedError('TASK-003-S04');
}
