# BE-016: Shared wear rules on the server — dormancy, gap days, rescue eligibility

> **Owner:** Backend Developer  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval  
> **Track / priority:** M · **8**  
> **Blocked by:** [BE-012](BE-012-mock-write-handler.md); golden fixtures from [TASK-012](../mobile/TASK-012-shared-golden-fixtures.md)  
> **Source:** UC-04 TAC-04.2 · I8, N6, I12 · Flow Spec v2.8 T3 › Shared rules; T4 › Derived values · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §7 WD-03…WD-08 · [BE-003](BE-003-wardrobe-and-wear-api.md) contract table

## Why

The spec requires one rules library that "runs on both phone and server and is
tested against the same fixtures". The phone has `DormancyRules` and stores
**provisional** `gap_days` and `rescue_eligible` on each wear event; the server
recomputes them, and its values replace the phone's. This logic has no database
or AI in it, so it can be written now and reused unchanged by the real platform
(BE-003, the rewards worker P4-B08).

## Scope

- `backend/app/rules/wear.py`, pure functions:
  `days_unworn(item, wear_events, today)`: days since the latest of (logged wear,
  `last_worn_estimate`), else since `created_at` (I8). `is_dormant(...)`: ≥ 30.
  `gap_days(item_id, worn_date, prior_events, item)` and `rescue_eligible(...)`:
  the gap is measured from a **logged** wear or the save date, **never** from the
  estimate (N6, I12).
- Side effect on `wear_events` PUT: compute authoritative `gap_days` and
  `rescue_eligible` per item and write them back into the event's `items` JSON
  (server-written correction of an insert-only row; the phone overwrites its
  provisional values on sync).
- Golden parity: the tests read the same fixture file as the Dart
  `dormancy_test.dart` (including `[TASK-003-S14]`) and `[TASK-006-S03]`.

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| BE-016-S01 | Every golden dormancy case gives the Dart test's expected days and badge | `tests/rules/test_wear_rules.py` |
| BE-016-S02 | A wear 41 days after the last logged wear is a rescue; the same gap measured only from the estimate is not | `tests/rules/test_wear_rules.py` |
| BE-016-S03 | A wear-event PUT whose provisional `rescue_eligible` is wrong is corrected in the feed; a correct one gets no extra change | `tests/test_wear_effects.py` |
| BE-016-S04 | Two events on the same date with the same signature (same deterministic ID) are stored once (TAC-07.4) | `tests/test_wear_effects.py` |
| BE-016-S05 | No rule reads the clock; `today` is always an argument | `tests/rules/test_wear_rules.py` |

## Allowed files

`backend/app/rules/`, `backend/app/workers/wear.py`, `backend/app/sync/effects.py`
(registration), `backend/tests/rules/`, `backend/tests/test_wear_effects.py`, report.

## Anti-scope

No XP, streaks, quests or impact metrics (Flow C). No editable counters (R2).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created |
