import 'package:flutter/foundation.dart';

import 'item_group.dart';

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
  ItemGroup get group => throw UnimplementedError('TASK-003-S07');

  WardrobeItem copyWith({
    String? name,
    String? typeCode,
    String? color,
    String? material,
    String? styleTag,
    DateTime? lastWornEstimate,
    bool? isArchived,
  }) =>
      throw UnimplementedError('TASK-003-S07');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S07');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S07');
}
