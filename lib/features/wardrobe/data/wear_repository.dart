import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/wear_event.dart';

/// Provider for WearRepository. Phase 1: in-memory.
final wearRepositoryProvider = Provider<WearRepository>((ref) {
  throw UnimplementedError('TASK-004-S06');
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

  MockWearRepository(
      {List<WearEvent> events = const [], this.failOnLog = false});

  @override
  Future<bool> logWear(WearEvent event) =>
      throw UnimplementedError('TASK-004-S06');

  @override
  Future<Map<String, DateTime>> lastWornByItem() =>
      throw UnimplementedError('TASK-003-S13');

  @override
  Future<List<WearEvent>> getEvents() =>
      throw UnimplementedError('TASK-004-S06');
}
