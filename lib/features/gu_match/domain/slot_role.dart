import '../../wardrobe/domain/item_group.dart';

/// The role a Piece plays in a Fit (spec `candidate_items.slot_role`).
enum SlotRole {
  top,
  bottom,
  footwear,
  bag,
  hat,
  accessory,
}

extension SlotRoleGroup on SlotRole {
  /// The Archive group that may fill this slot.
  ItemGroup get group => switch (this) {
        SlotRole.top => ItemGroup.tops,
        SlotRole.bottom => ItemGroup.bottoms,
        SlotRole.footwear => ItemGroup.shoes,
        SlotRole.bag => ItemGroup.bags,
        SlotRole.hat => ItemGroup.hats,
        SlotRole.accessory => ItemGroup.accessories,
      };

  /// "Top", "Bottom", "Shoes", "Bag", "Hat", "Accessory" (Adjust sheet rows).
  String get label => switch (this) {
        SlotRole.top => 'Top',
        SlotRole.bottom => 'Bottom',
        SlotRole.footwear => 'Shoes',
        SlotRole.bag => 'Bag',
        SlotRole.hat => 'Hat',
        SlotRole.accessory => 'Accessory',
      };
}

/// The slot a Piece of [group] fills.
SlotRole slotRoleFor(ItemGroup group) =>
    SlotRole.values.firstWhere((slot) => slot.group == group);
