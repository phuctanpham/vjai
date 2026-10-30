import 'package:flutter/foundation.dart';

import '../../wardrobe/domain/item_group.dart';
import '../../wardrobe/domain/item_type.dart';
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
  }) {
    return ItemAttributes(
      typeCode: typeCode ?? this.typeCode,
      color: color ?? this.color,
      material: material ?? this.material,
      styleTag: styleTag ?? this.styleTag,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemAttributes &&
          typeCode == other.typeCode &&
          color == other.color &&
          material == other.material &&
          styleTag == other.styleTag;

  @override
  int get hashCode => Object.hash(typeCode, color, material, styleTag);
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
  bool get userModified => ai != value;

  /// Derived from the current type (TAC-03.6).
  ItemGroup get group => ItemTypeCatalog.groupOf(value.typeCode);

  /// Rounded percentage, e.g. 94 for 0.94.
  int get confidencePercent => (confidence * 100).round();

  /// Applies user edits. Throws [ArgumentError] for an unknown type code.
  ExtractedItem edit({
    String? typeCode,
    String? color,
    String? material,
    String? styleTag,
  }) {
    if (typeCode != null && ItemTypeCatalog.byCode(typeCode) == null) {
      throw ArgumentError.value(typeCode, 'typeCode', 'Unknown item type');
    }
    return _copy(
      value: value.copyWith(
        typeCode: typeCode,
        color: color,
        material: material,
        styleTag: styleTag,
      ),
    );
  }

  ExtractedItem withLastWorn(LastWornInput lastWorn) =>
      _copy(lastWorn: lastWorn);

  ExtractedItem _copy({ItemAttributes? value, LastWornInput? lastWorn}) {
    return ExtractedItem(
      draftId: draftId,
      assetId: assetId,
      slotIndex: slotIndex,
      itemIndex: itemIndex,
      name: name,
      confidence: confidence,
      ai: ai,
      value: value ?? this.value,
      lastWorn: lastWorn ?? this.lastWorn,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExtractedItem &&
          draftId == other.draftId &&
          assetId == other.assetId &&
          slotIndex == other.slotIndex &&
          itemIndex == other.itemIndex &&
          name == other.name &&
          confidence == other.confidence &&
          ai == other.ai &&
          value == other.value &&
          lastWorn == other.lastWorn;

  @override
  int get hashCode => Object.hash(draftId, assetId, slotIndex, itemIndex, name,
      confidence, ai, value, lastWorn);
}
