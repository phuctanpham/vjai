import 'package:sqlite_async/sqlite_async.dart';

import '../domain/wear_event.dart';
import 'wear_repository.dart';

/// [WearRepository] over the append-only `wear_events` table.
///
/// An event's ID is `deterministicObjectId([ownerId, wornDate, signature])`,
/// so the same Fit logged twice on one day is one row on every device
/// (TASK-005-S07). Each event's `items` JSON holds provisional `gap_days`
/// and `rescue_eligible` per item, measured from the previous logged wear or
/// the save date, never from the Last-worn estimate (N6, TASK-006-S03).
class LocalWearRepository implements WearRepository {
  LocalWearRepository({required SqliteConnection db, required String ownerId});

  /// The deterministic ID of [event] for [ownerId].
  static String eventId(String ownerId, WearEvent event) =>
      throw UnimplementedError('TASK-005-S07');

  @override
  Future<bool> logWear(WearEvent event) =>
      throw UnimplementedError('TASK-005-S07');

  @override
  Future<Map<String, DateTime>> lastWornByItem() =>
      throw UnimplementedError('TASK-006-S01');

  @override
  Future<Map<String, int>> wearCountByItem() =>
      throw UnimplementedError('TASK-006-S01');

  @override
  Future<List<WearEvent>> getEvents() =>
      throw UnimplementedError('TASK-005-S03');
}
