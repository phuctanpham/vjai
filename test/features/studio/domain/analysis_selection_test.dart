import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/studio/domain/analysis_selection.dart';
import 'package:garblo/features/studio/domain/analysis_task.dart';

void main() {
  group('AnalysisSelection', () {
    test(
        '[TASK-003-S10] outfit is checked by default; pose and background are not',
        () {
      final selection = AnalysisSelection.defaults();

      expect(selection.contains(AnalysisTask.outfitExtraction), isTrue);
      expect(selection.contains(AnalysisTask.poseEstimation), isFalse);
      expect(selection.contains(AnalysisTask.backgroundAnalysis), isFalse);
      expect(selection.isValid, isTrue);
    });

    test('[TASK-003-S10] a selection with no task is invalid', () {
      final none =
          AnalysisSelection.defaults().toggle(AnalysisTask.outfitExtraction);

      expect(none.tasks, isEmpty);
      expect(none.isValid, isFalse);
    });

    test('[TASK-003-S10] toggling adds and removes a task', () {
      final withPose =
          AnalysisSelection.defaults().toggle(AnalysisTask.poseEstimation);
      expect(withPose.tasks,
          {AnalysisTask.outfitExtraction, AnalysisTask.poseEstimation});

      final back = withPose.toggle(AnalysisTask.poseEstimation);
      expect(back, AnalysisSelection.defaults());
    });

    test('value equality and hashCode follow the task set', () {
      const a = AnalysisSelection({
        AnalysisTask.outfitExtraction,
        AnalysisTask.backgroundAnalysis,
      });
      const b = AnalysisSelection({
        AnalysisTask.backgroundAnalysis,
        AnalysisTask.outfitExtraction,
      });

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
