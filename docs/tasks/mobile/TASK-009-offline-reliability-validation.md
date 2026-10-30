# TASK-009: Offline reliability and migration validation

> **Phase:** 2 · P2 Persistent offline app  
> **Status:** Green · merged ([report](../../reports/TASK-009-app-developer.md), [CHG-009](../../changes/CHG-009-phase-2-verification.md))  
> **Dependencies:** [TASK-005](TASK-005-local-persistence-foundation.md), [TASK-006](TASK-006-derived-queries-and-rules.md), [TASK-007](TASK-007-photo-privacy-pipeline.md), [TASK-008](TASK-008-device-integrations-and-data-rights.md)  
> **Source tasks:** P2-09

## Objective

Prove that the P2 app remains correct across airplane mode, process death,
app-kill during writes, restart, migration, and repeated user actions.

## Scope

- Add a deterministic offline test harness.
- Kill/restart tests around atomic saves and append-only wear writes.
- Restart tests for batches, sanitized assets, Pieces, wear events and Gu Match Fits (rewards and check-ins are deferred with Flow C).
- Migration tests across every schema version introduced in P2.
- Verify no duplicate wear events, Pieces or consents after
  replay.
- Run the 300 ms derived-query benchmark in CI where supported.
- Produce a P2 delivery report with evidence and known device limitations.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-009-S01 | The complete Phase 1 journey works with network access disabled | E2E |
| TASK-009-S02 | Killing the app during Save N items produces all or none | E2E |
| TASK-009-S03 | Restart restores all persisted flow state | E2E |
| TASK-009-S04 | Replaying a wear confirmation does not duplicate its event or rewards | E2E |
| TASK-009-S05 | Replaying "Index N Pieces" or a consent after a crash does not duplicate rows (deterministic IDs) | E2E |
| TASK-009-S06 | Every migration upgrades a prior database without data loss | Migration |
| TASK-009-S07 | Sanitized files and database rows remain consistent after restart | E2E |
| TASK-009-S08 | Offline error states are explicit and retryable | Widget/E2E |

## File confinement

Expected areas:

- `test/integration/`, `test/helpers/`, and CI test configuration.
- Minimal production hooks only when required to make lifecycle behavior
  injectable and testable.
- `docs/reports/` delivery report after implementation.

## Anti-scope

- No PowerSync or backend connectivity tests; those belong to Phase 3.
- No broad refactor of feature code that is not required for testability.
- No weakening of transaction, privacy, or explicit-error behavior to make
  tests pass.

## Acceptance criteria

- Offline, restart, app-kill, migration, and replay scenarios pass.
- Performance results are recorded against the P2 budgets.
- The full Flutter verification gates pass.
- The P2 report lists real device/emulator coverage and skipped checks.
- Phase 3 is not marked ready until P2 evidence is accepted.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | — | Created from T6 P2-09 as the Phase 2 verification gate. |
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | Tests after TASK-005…008; calendar, export, rewards and check-ins removed with the P2 deferrals; replay uses deterministic IDs. |
| 2026-10-30 | [CHG-009](../../changes/CHG-009-phase-2-verification.md) | Green: 20 tests on the local stack; consent replay, orphan sweep and Wear today error fixed (V-01…V-03). |
