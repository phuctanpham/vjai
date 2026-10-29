import 'package:flutter/foundation.dart';

import '../../wardrobe/domain/item_group.dart';
import 'last_worn.dart';

/// The editable attributes of an extracted item.
@immutable
class ItemAttributes {
  final String typeCode;
  final String color;
  final String material;
  final String styleTag;

  const ItemAttributes({
    required this.typeCode,
    required this.color,
    required this.material,
    required this.styleTag,
  });

  ItemAttributes copyWith({
    String? typeCode,
    String? color,
    String? material,
    String? styleTag,
  }) =>
      throw UnimplementedError('TASK-003-S04');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S04');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S04');
}

/// An AI draft of a wardrobe item, editable during review (4a, D1).
/// The AI's original values are kept beside the user's edits (TAC-03.5).
@immutable
class ExtractedItem {
  final String draftId;
  final String assetId;
  final int slotIndex;

  /// Position of the item within its photo, from 1.
  final int itemIndex;
  final String name;

  /// AI confidence, 0..1. Edits never change it (AC-03.6).
  final double confidence;
  final ItemAttributes ai;
  final ItemAttributes value;
  final LastWornInput lastWorn;

  const ExtractedItem({
    required this.draftId,
    required this.assetId,
    required this.slotIndex,
    required this.itemIndex,
    required this.name,
    required this.confidence,
    required this.ai,
    required this.value,
    this.lastWorn = const LastWornInput.dontRemember(),
  });

  /// True only when a value differs from the AI's (TAC-03.5).
  bool get userModified => throw UnimplementedError('TASK-003-S04');

  /// Derived from the current type (TAC-03.6).
  ItemGroup get group => throw UnimplementedError('TASK-003-S04');

  /// Rounded percentage, e.g. 94 for 0.94.
  int get confidencePercent => throw UnimplementedError('TASK-003-S04');

  /// Applies user edits. Throws [ArgumentError] for an unknown type code.
  ExtractedItem edit({
    String? typeCode,
    String? color,
    String? material,
    String? styleTag,
  }) =>
      throw UnimplementedError('TASK-003-S04');

  ExtractedItem withLastWorn(LastWornInput lastWorn) =>
      throw UnimplementedError('TASK-003-S13');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S04');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S04');
}
