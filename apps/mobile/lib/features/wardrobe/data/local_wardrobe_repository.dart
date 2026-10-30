import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite3_common.dart' show Row;
import 'package:sqlite_async/sqlite_async.dart';

import '../../../core/errors/failures.dart';
import '../domain/item_group.dart';
import '../domain/item_type.dart';
import '../domain/wardrobe_item.dart';
import 'wardrobe_repository.dart';

/// [WardrobeRepository] over the local `wardrobe_items` table (phone schema
/// v1). Saves are one write transaction; an item whose ID already exists is
/// skipped, so a retried save cannot duplicate (CHG-005 P2-D8).
class LocalWardrobeRepository implements WardrobeRepository {
  final SqliteConnection _db;
  final String _ownerId;
  final Future<void> Function(int index)? _onInsert;

  LocalWardrobeRepository({
    required SqliteConnection db,
    required String ownerId,
    @visibleForTesting Future<void> Function(int index)? onInsert,
  })  : _db = db,
        _ownerId = ownerId,
        _onInsert = onInsert;

  /// Newest first. Within one save, `updated_at` carries the review order
  /// (see [saveItems]), so equal `created_at` values keep it.
  static const String _order = 'ORDER BY created_at DESC, updated_at, id';

  @override
  Future<WardrobePage> getItems({ItemGroup? group, String? cursor}) =>
      _guard(() async {
        final offset = cursor == null ? 0 : int.parse(cursor);
        final (filter, args) = _groupFilter(group);
        final rows = await _db.getAll(
          'SELECT * FROM wardrobe_items '
          'WHERE user_id = ? AND archived = 0$filter $_order LIMIT ? OFFSET ?',
          [_ownerId, ...args, WardrobeRepository.pageSize + 1, offset],
        );
        final total = await _count();
        final more = rows.length > WardrobeRepository.pageSize;
        final page = rows.take(WardrobeRepository.pageSize).map(_fromRow);
        return WardrobePage(
          items: List.unmodifiable(page),
          total: total,
          nextCursor: more ? '${offset + WardrobeRepository.pageSize}' : null,
        );
      });

  @override
  Future<int> countEligible() => _guard(_count);

  @override
  Future<List<WardrobeItem>> getEligibleItems() => _guard(() async {
        final rows = await _db.getAll(
          'SELECT * FROM wardrobe_items WHERE user_id = ? AND archived = 0 '
          '$_order',
          [_ownerId],
        );
        return List.unmodifiable(rows.map(_fromRow));
      });

  @override
  Future<void> saveItems(List<WardrobeItem> items) async {
    if (items.isEmpty) return;
    final savedAt = DateTime.now();
    try {
      await _db.writeTransaction((tx) async {
        for (var i = 0; i < items.length; i++) {
          await _onInsert?.call(i);
          final item = items[i];
          final existing = await tx.getOptional(
              'SELECT 1 FROM wardrobe_items WHERE id = ?', [item.itemId]);
          if (existing != null) continue;
          await tx.execute(
            'INSERT INTO wardrobe_items(id, user_id, name, type_code, color, '
            'material, style_tag, ai_confidence, source_asset_id, '
            'last_worn_estimate, archived, created_at, updated_at) '
            'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              item.itemId,
              _ownerId,
              item.name,
              item.typeCode,
              item.color,
              item.material,
              item.styleTag,
              item.aiConfidence,
              item.sourceAssetId,
              item.lastWornEstimate?.toIso8601String(),
              item.isArchived ? 1 : 0,
              item.createdAt.toIso8601String(),
              // One microsecond apart, in review order.
              savedAt.add(Duration(microseconds: i)).toIso8601String(),
            ],
          );
        }
      });
    } on Failure {
      rethrow;
    } catch (error) {
      throw StorageFailure('Could not save your Pieces.', error);
    }
  }

  Future<int> _count() async {
    final row = await _db.get(
      'SELECT count(*) AS n FROM wardrobe_items '
      'WHERE user_id = ? AND archived = 0',
      [_ownerId],
    );
    return row['n'] as int;
  }

  static (String, List<Object?>) _groupFilter(ItemGroup? group) {
    if (group == null) return ('', const []);
    final codes = [for (final t in ItemTypeCatalog.typesIn(group)) t.code];
    if (codes.isEmpty) return (' AND 0', const []);
    final marks = List.filled(codes.length, '?').join(', ');
    return (' AND type_code IN ($marks)', codes);
  }

  static WardrobeItem _fromRow(Row row) {
    final lastWorn = row['last_worn_estimate'] as String?;
    return WardrobeItem(
      itemId: row['id'] as String,
      name: row['name'] as String,
      typeCode: row['type_code'] as String,
      color: row['color'] as String,
      material: row['material'] as String,
      styleTag: row['style_tag'] as String,
      aiConfidence: (row['ai_confidence'] as num?)?.toDouble(),
      sourceAssetId: row['source_asset_id'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      lastWornEstimate: lastWorn == null ? null : DateTime.parse(lastWorn),
      isArchived: row['archived'] == 1,
    );
  }

  static Future<T> _guard<T>(Future<T> Function() read) async {
    try {
      return await read();
    } on Failure {
      rethrow;
    } catch (error) {
      throw StorageFailure('Could not load your Archive.', error);
    }
  }
}
