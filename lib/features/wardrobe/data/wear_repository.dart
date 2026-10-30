import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failures.dart';
import '../domain/wear_event.dart';

/// Provider for WearRepository. Phase 1: in-memory.
final wearRepositoryProvider = Provider<WearRepository>((ref) {
  return MockWearRepository();
});

/// Contract for append-only wear events.
abstract class WearRepository {
  /// Appends [event]. Returns false, without writing, when an event with the
  /// same date and signature already exists (TAC-07.4).
  Future<bool> logWear(WearEvent event);

  /// Latest worn date per item ID.
  Future<Map<String, DateTime>> lastWornByItem();

  Future<List<WearEvent>> getEvents();
}

/// In-memory implementation of WearRepository.
class MockWearRepository implements WearRepository {
  final bool failOnLog;
  final List<WearEvent> _events;

  MockWearRepository(
      {List<WearEvent> events = const [], this.failOnLog = false})
      : _events = List.of(events);

  @override
  Future<bool> logWear(WearEvent event) async {
    if (failOnLog) throw const StorageFailure('Could not log the wear.');
    final duplicate = _events.any(
      (e) => e.wornDate == event.wornDate && e.signature == event.signature,
    );
    if (duplicate) return false;
    _events.add(event);
    return true;
  }

  @override
  Future<Map<String, DateTime>> lastWornByItem() async {
    final lastWorn = <String, DateTime>{};
    for (final event in _events) {
      for (final itemId in event.itemIds) {
        final previous = lastWorn[itemId];
        if (previous == null || event.wornDate.isAfter(previous)) {
          lastWorn[itemId] = event.wornDate;
        }
      }
    }
    return lastWorn;
  }

  @override
  Future<List<WearEvent>> getEvents() async => List.unmodifiable(_events);
}
