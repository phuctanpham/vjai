import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the application clock. Override it in tests.
final clockProvider = Provider<Clock>((ref) {
  throw UnimplementedError('TASK-002-S08');
});

/// Source of the current time. Read time through this instead of
/// calling `DateTime.now()` so that date rules stay deterministic.
abstract class Clock {
  DateTime now();
}

/// Clock backed by the device time.
class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => throw UnimplementedError('TASK-002-S08');
}
