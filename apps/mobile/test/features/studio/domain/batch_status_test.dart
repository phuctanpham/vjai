import 'package:flutter_test/flutter_test.dart';
import 'package:garblo/features/studio/domain/batch_status.dart';

void main() {
  const allowed = <(BatchStatus, BatchStatus)>{
    (BatchStatus.draft, BatchStatus.sanitizing),
    (BatchStatus.sanitizing, BatchStatus.draft),
    (BatchStatus.sanitizing, BatchStatus.queuedForAi),
    (BatchStatus.queuedForAi, BatchStatus.aiProcessing),
    (BatchStatus.aiProcessing, BatchStatus.awaitingReview),
    (BatchStatus.aiProcessing, BatchStatus.failed),
    (BatchStatus.awaitingReview, BatchStatus.completed),
    // CHG-003 A-02: Reselect photos and Try again after all photos failed.
    (BatchStatus.failed, BatchStatus.draft),
    (BatchStatus.failed, BatchStatus.queuedForAi),
    // UC-09 erasure.
    (BatchStatus.draft, BatchStatus.deletedByUser),
    (BatchStatus.awaitingReview, BatchStatus.deletedByUser),
    (BatchStatus.completed, BatchStatus.deletedByUser),
  };

  group('BatchStatus state machine', () {
    test('[TASK-003-S12] every spec transition is allowed', () {
      for (final (from, to) in allowed) {
        expect(from.canTransitionTo(to), isTrue, reason: '$from → $to');
      }
    });

    test('[TASK-003-S12] every other transition is rejected', () {
      for (final from in BatchStatus.values) {
        for (final to in BatchStatus.values) {
          if (allowed.contains((from, to))) continue;
          expect(from.canTransitionTo(to), isFalse, reason: '$from → $to');
        }
      }
    });

    test('[TASK-003-S12] review cannot be reached without analysis', () {
      expect(BatchStatus.draft.canTransitionTo(BatchStatus.awaitingReview),
          isFalse);
      expect(BatchStatus.sanitizing.canTransitionTo(BatchStatus.awaitingReview),
          isFalse);
      expect(BatchStatus.queuedForAi.canTransitionTo(BatchStatus.completed),
          isFalse);
    });
  });
}
