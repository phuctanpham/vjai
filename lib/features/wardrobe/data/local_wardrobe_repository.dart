import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../domain/item_group.dart';
import '../domain/wardrobe_item.dart';
import 'wardrobe_repository.dart';

/// [WardrobeRepository] over the local `wardrobe_items` table (phone schema
/// v1). Saves are one write transaction; an item whose ID already exists is
/// skipped, so a retried save cannot duplicate (CHG-005 P2-D8).
class LocalWardrobeRepository implements WardrobeRepository {
  LocalWardrobeRepository({
    required SqliteConnection db,
    required String ownerId,
    @visibleForTesting Future<void> Function(int index)? onInsert,
  });

  @override
  Future<WardrobePage> getItems({ItemGroup? group, String? cursor}) =>
      throw UnimplementedError('TASK-005-S08');

  @override
  Future<int> countEligible() => throw UnimplementedError('TASK-005-S08');

  @override
  Future<List<WardrobeItem>> getEligibleItems() =>
      throw UnimplementedError('TASK-005-S08');

  @override
  Future<void> saveItems(List<WardrobeItem> items) =>
      throw UnimplementedError('TASK-005-S04');
}
