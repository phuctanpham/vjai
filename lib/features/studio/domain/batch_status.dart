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
  bool canTransitionTo(BatchStatus next) =>
      throw UnimplementedError('TASK-003-S12');
}
