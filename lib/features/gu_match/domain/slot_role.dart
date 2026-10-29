import '../../wardrobe/domain/item_group.dart';

/// The role an item plays in a look (spec `candidate_items.slot_role`).
enum SlotRole {
  top,
  bottom,
  footwear,
  bag,
  hat,
  accessory,
}

extension SlotRoleGroup on SlotRole {
  /// The wardrobe group that may fill this slot.
  ItemGroup get group => throw UnimplementedError('TASK-004-S09');

  /// "Top", "Bottom", "Shoes", "Bag", "Hat", "Accessory" (Adjust sheet rows).
  String get label => throw UnimplementedError('TASK-004-S09');
}

/// The slot an item of [group] fills.
SlotRole slotRoleFor(ItemGroup group) =>
    throw UnimplementedError('TASK-004-S04');
