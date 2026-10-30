# TASK-006: Derived wear values in SQL

> **Phase:** 2 · P2 Persistent offline app  
> **Status:** Tests written (red) on `phase-2/persistence-tdd`  
> **Dependencies:** [TASK-005](TASK-005-local-persistence-foundation.md) · [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md)  
> **Source tasks:** P2-03 (must-have parts) · spec T4 › Derived values (R2) · I8, I12, N6, TAC-04.2

## Objective

Derive last worn, wear count, dormancy and rescue eligibility from the
append-only `wear_events` table with SQL (`json_each`), and prove the results
match the Phase 1 golden fixtures. No counters are stored (R2).

## Scope

- Last worn and wear count per Piece from `wear_events.items` via `json_each`.
- Dormancy (BENCHED at ≥ 30 days) from those values plus `last_worn_estimate`
  and `created_at`, using the shared `DormancyRules` (same golden fixtures).
- When a wear is logged, each item gets a **provisional** `gap_days` and
  `rescue_eligible` in the event's `items` JSON, measured from the previous
  logged wear or the save date, never from the estimate (N6, I12). The server
  recomputes them from P4 (BE-003).
- A benchmark with 500 Pieces and 3,000 wear events, tagged `benchmark`.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-006-S01 | SQL last worn, wear count and days unworn match the Phase 1 golden fixtures | SQL/unit |
| TASK-006-S02 | The BENCHED boundary is 29 days → none, 30 days → benched, by calendar date | SQL/unit |
| TASK-006-S03 | A logged wear stores provisional `gap_days`/`rescue_eligible`; an estimated Last worn never makes it eligible | SQL/unit |
| TASK-006-S04 | The same Fit in a different item order has the same signature and event | SQL/unit |
| TASK-006-S08 | Archive dormancy for 500 Pieces and 3,000 wear events completes within 300 ms on the host (device number recorded separately) | Benchmark |

S05–S07 of the first draft (rewear rate, four-week rhythm, Impact empty state)
are deferred with Flow C (CHG-005 P2-D2).

## Test plan

| Scenario | Level | Test file | Test name prefix |
|---|---|---|---|
| S01–S04 | SQL/unit | test/features/wardrobe/data/local_wear_queries_test.dart | [TASK-006-S0x] |
| S08 | Benchmark | test/features/wardrobe/data/wear_benchmark_test.dart | [TASK-006-S08] (tag `benchmark`) |

## File confinement

- `lib/features/wardrobe/data/local_wear_repository.dart`,
  `lib/features/wardrobe/data/local_wardrobe_repository.dart`
- `lib/features/wardrobe/domain/dormancy.dart` (only if a shared rule needs a
  date-string helper)
- `test/features/wardrobe/data/**`, `dart_test.yaml` (benchmark tag)

## Anti-scope

- No rewards, XP, rank, new-look or rewear-rate metrics (Flow C).
- No change to the Phase 1 fake generator.
- No hard-coded "today"; use the injectable `Clock`.

## Acceptance criteria

- SQL results equal the in-memory results on the shared golden fixtures.
- The estimate rule (N6) is proven at the storage level.
- The benchmark number is recorded in the delivery report, not assumed.
- Flutter verification gates pass.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | — | Created from T6 P2-03 and the T2+ derived metric definitions. |
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | Must-have only: Impact metrics deferred; provisional gap_days/rescue_eligible; benchmark tag; test plan. |
