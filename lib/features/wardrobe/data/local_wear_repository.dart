import 'dart:convert';

import 'package:sqlite_async/sqlite_async.dart';

import '../../../core/errors/failures.dart';
import '../../../core/storage/object_id.dart';
import '../domain/wear_event.dart';
import 'wear_repository.dart';

/// [WearRepository] over the append-only `wear_events` table.
///
/// An event's ID is `deterministicObjectId([ownerId, wornDate, signature])`,
/// so the same Fit logged twice on one day is one row on every device
/// (TASK-005-S07).
class LocalWearRepository implements WearRepository {
  static const String _likeConfirm = 'LIKE_CONFIRM';

  final SqliteConnection _db;
  final String _ownerId;

  LocalWearRepository({required SqliteConnection db, required String ownerId})
      : _db = db,
        _ownerId = ownerId;

  /// The deterministic ID of [event] for [ownerId].
  static String eventId(String ownerId, WearEvent event) =>
      deterministicObjectId([ownerId, _date(event.wornDate), event.signature]);

  @override
  Future<bool> logWear(WearEvent event) async {
    final id = eventId(_ownerId, event);
    try {
      return await _db.writeTransaction((tx) async {
        // Check-then-insert in one transaction: PowerSync views have no
        // UNIQUE constraint and may not support INSERT OR IGNORE (BE-006).
        final existing = await tx
            .getOptional('SELECT 1 FROM wear_events WHERE id = ?', [id]);
        if (existing != null) return false;
        await tx.execute(
          'INSERT INTO wear_events(id, user_id, worn_date, candidate_id, '
          'source, signature, items, created_at) '
          'VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
          [
            id,
            _ownerId,
            _date(event.wornDate),
            event.candidateId,
            _likeConfirm,
            event.signature,
            jsonEncode([
              for (final itemId in event.itemIds) {'item_id': itemId},
            ]),
            DateTime.now().toIso8601String(),
          ],
        );
        return true;
      });
    } catch (error) {
      throw StorageFailure('Could not log the wear.', error);
    }
  }

  @override
  Future<Map<String, DateTime>> lastWornByItem() => _read(() async {
        final rows = await _db.getAll(
          "SELECT json_extract(j.value, '\$.item_id') AS item_id, "
          'max(e.worn_date) AS last_worn '
          'FROM wear_events e, json_each(e.items) j '
          'WHERE e.user_id = ? GROUP BY item_id',
          [_ownerId],
        );
        return {
          for (final row in rows)
            row['item_id'] as String:
                DateTime.parse(row['last_worn'] as String),
        };
      });

  @override
  Future<Map<String, int>> wearCountByItem() => _read(() async {
        final rows = await _db.getAll(
          "SELECT json_extract(j.value, '\$.item_id') AS item_id, "
          'count(*) AS wears '
          'FROM wear_events e, json_each(e.items) j '
          'WHERE e.user_id = ? GROUP BY item_id',
          [_ownerId],
        );
        return {
          for (final row in rows) row['item_id'] as String: row['wears'] as int,
        };
      });

  @override
  Future<List<WearEvent>> getEvents() => _read(() async {
        final rows = await _db.getAll(
          'SELECT worn_date, candidate_id, items FROM wear_events '
          'WHERE user_id = ? ORDER BY worn_date, created_at',
          [_ownerId],
        );
        return List.unmodifiable(rows.map((row) {
          final items = (jsonDecode(row['items'] as String) as List)
              .map((entry) => (entry as Map)['item_id'] as String)
              .toList();
          return WearEvent(
            wornDate: DateTime.parse(row['worn_date'] as String),
            itemIds: List.unmodifiable(items),
            candidateId: row['candidate_id'] as String?,
            source: WearSource.likeConfirm,
          );
        }));
      });

  /// Calendar date as `YYYY-MM-DD`.
  static String _date(DateTime day) => '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  static Future<T> _read<T>(Future<T> Function() read) async {
    try {
      return await read();
    } catch (error) {
      throw StorageFailure('Could not read your wear log.', error);
    }
  }
}
