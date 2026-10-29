import 'package:flutter/foundation.dart';

import 'analysis_task.dart';

/// The analyses checked on the 3a sheet.
@immutable
class AnalysisSelection {
  final Set<AnalysisTask> tasks;

  const AnalysisSelection(this.tasks);

  /// Outfit on, pose and background off (AC-02.3).
  factory AnalysisSelection.defaults() =>
      throw UnimplementedError('TASK-003-S10');

  /// At least one task is checked (I4).
  bool get isValid => throw UnimplementedError('TASK-003-S10');

  bool contains(AnalysisTask task) => throw UnimplementedError('TASK-003-S10');

  AnalysisSelection toggle(AnalysisTask task) =>
      throw UnimplementedError('TASK-003-S10');

  @override
  bool operator ==(Object other) => throw UnimplementedError('TASK-003-S10');

  @override
  int get hashCode => throw UnimplementedError('TASK-003-S10');
}
