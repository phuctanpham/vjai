import 'package:flutter/foundation.dart';

import 'item_group.dart';
import 'item_type.dart';

/// A garment the user owns. Field names follow the spec T4 phone schema.
@immutable
class WardrobeItem {
  final String itemId;
  final String name;
  final String typeCode;
  final String color;
  final String material;
  final String styleTag;
  final double? aiConfidence;
  final String? sourceAssetId;
  final DateTime createdAt;

  /// Estimated last-worn date from the review "Last worn" field (C3).
  final DateTime? lastWornEstimate;
  final bool isArchived;

  const WardrobeItem({
    required this.itemId,
    required this.name,
    required this.typeCode,
    required this.color,
    required this.material,
    required this.styleTag,
    required this.createdAt,
    this.aiConfidence,
    this.sourceAssetId,
    this.lastWornEstimate,
    this.isArchived = false,
  });

  /// Derived from [typeCode] through the item-type catalog.
  ItemGroup get group => ItemTypeCatalog.groupOf(typeCode);

  WardrobeItem copyWith({
    String? name,
    String? typeCode,
    String? color,
    String? material,
    String? styleTag,
    DateTime? lastWornEstimate,
    bool? isArchived,
  }) {
    return WardrobeItem(
      itemId: itemId,
      name: name ?? this.name,
      typeCode: typeCode ?? this.typeCode,
      color: color ?? this.color,
      material: material ?? this.material,
      styleTag: styleTag ?? this.styleTag,
      aiConfidence: aiConfidence,
      sourceAssetId: sourceAssetId,
      createdAt: createdAt,
      lastWornEstimate: lastWornEstimate ?? this.lastWornEstimate,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WardrobeItem &&
          itemId == other.itemId &&
          name == other.name &&
          typeCode == other.typeCode &&
          color == other.color &&
          material == other.material &&
          styleTag == other.styleTag &&
          aiConfidence == other.aiConfidence &&
          sourceAssetId == other.sourceAssetId &&
          createdAt == other.createdAt &&
          lastWornEstimate == other.lastWornEstimate &&
          isArchived == other.isArchived;

  @override
  int get hashCode => Object.hash(
        itemId,
        name,
        typeCode,
        color,
        material,
        styleTag,
        aiConfidence,
        sourceAssetId,
        createdAt,
        lastWornEstimate,
        isArchived,
      );

  @override
  String toString() => 'WardrobeItem($itemId, $name, $typeCode)';
}
