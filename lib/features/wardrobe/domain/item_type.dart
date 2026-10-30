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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemType &&
          code == other.code &&
          group == other.group &&
          label == other.label;

  @override
  int get hashCode => Object.hash(code, group, label);
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

  static const List<ItemType> all = [
    ItemType(code: 'SHIRT', group: ItemGroup.tops, label: 'Shirt'),
    ItemType(code: 'T_SHIRT', group: ItemGroup.tops, label: 'T-shirt'),
    ItemType(code: 'SWEATER', group: ItemGroup.tops, label: 'Sweater'),
    ItemType(
      code: 'WIDE_LEG_TROUSERS',
      group: ItemGroup.bottoms,
      label: 'Wide-leg trousers',
    ),
    ItemType(code: 'JEANS', group: ItemGroup.bottoms, label: 'Jeans'),
    ItemType(code: 'SKIRT', group: ItemGroup.bottoms, label: 'Skirt'),
    ItemType(code: 'SNEAKERS', group: ItemGroup.shoes, label: 'Sneakers'),
    ItemType(code: 'LOAFERS', group: ItemGroup.shoes, label: 'Loafers'),
    ItemType(code: 'TOTE_BAG', group: ItemGroup.bags, label: 'Tote bag'),
    ItemType(
      code: 'CROSSBODY_BAG',
      group: ItemGroup.bags,
      label: 'Crossbody bag',
    ),
    ItemType(code: 'CAP', group: ItemGroup.hats, label: 'Cap'),
    ItemType(code: 'BUCKET_HAT', group: ItemGroup.hats, label: 'Bucket hat'),
    ItemType(code: 'TIE', group: ItemGroup.accessories, label: 'Tie'),
    ItemType(code: 'SCARF', group: ItemGroup.accessories, label: 'Scarf'),
    ItemType(code: 'BELT', group: ItemGroup.accessories, label: 'Belt'),
  ];

  /// Returns the type for [code], or null when the code is unknown.
  static ItemType? byCode(String code) {
    for (final type in all) {
      if (type.code == code) return type;
    }
    return null;
  }

  /// Returns the group of [code]. Throws [ArgumentError] for unknown codes.
  static ItemGroup groupOf(String code) {
    final type = byCode(code);
    if (type == null) {
      throw ArgumentError.value(code, 'code', 'Unknown item type');
    }
    return type.group;
  }

  static List<ItemType> typesIn(ItemGroup group) =>
      all.where((t) => t.group == group).toList();
}
