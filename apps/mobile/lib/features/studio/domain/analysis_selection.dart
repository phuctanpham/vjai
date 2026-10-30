import 'package:flutter/foundation.dart';

import 'analysis_task.dart';

/// The analyses checked on the 3a sheet.
@immutable
class AnalysisSelection {
  final Set<AnalysisTask> tasks;

  const AnalysisSelection(this.tasks);

  /// Pieces (outfit) on, pose and background off (AC-02.3).
  factory AnalysisSelection.defaults() =>
      const AnalysisSelection({AnalysisTask.outfitExtraction});

  /// At least one task is checked (I4).
  bool get isValid => tasks.isNotEmpty;

  bool contains(AnalysisTask task) => tasks.contains(task);

  AnalysisSelection toggle(AnalysisTask task) => AnalysisSelection(
        contains(task) ? ({...tasks}..remove(task)) : {...tasks, task},
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalysisSelection && setEquals(tasks, other.tasks);

  @override
  int get hashCode => Object.hashAllUnordered(tasks);
}
