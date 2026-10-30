/// Upload batch lifecycle (spec T2 state machine, Flow A).
enum BatchStatus {
  draft,
  sanitizing,
  queuedForAi,
  aiProcessing,
  awaitingReview,
  completed,
  failed,
  deletedByUser,
}

/// Allowed transitions. Skipped transitions are rejected (TAC-02.5).
extension BatchStatusTransitions on BatchStatus {
  static const Map<BatchStatus, Set<BatchStatus>> _allowed = {
    BatchStatus.draft: {BatchStatus.sanitizing, BatchStatus.deletedByUser},
    BatchStatus.sanitizing: {BatchStatus.draft, BatchStatus.queuedForAi},
    BatchStatus.queuedForAi: {BatchStatus.aiProcessing},
    BatchStatus.aiProcessing: {BatchStatus.awaitingReview, BatchStatus.failed},
    BatchStatus.awaitingReview: {
      BatchStatus.completed,
      BatchStatus.deletedByUser,
    },
    // CHG-003 A-02: Reselect photos (→ draft) or Try again (→ queued).
    BatchStatus.failed: {BatchStatus.draft, BatchStatus.queuedForAi},
    BatchStatus.completed: {BatchStatus.deletedByUser},
    BatchStatus.deletedByUser: {},
  };

  bool canTransitionTo(BatchStatus next) => _allowed[this]!.contains(next);
}
