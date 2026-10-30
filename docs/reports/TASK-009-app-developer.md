# TASK-009 · app-developer report

| Date | Status | Commits |
|---|---|---|
| 2026-10-30 | Complete | Red: `a021130`. Green: `1589db7`. Decisions: [CHG-009](../changes/CHG-009-phase-2-verification.md) |

Item: [TASK-009](../tasks/mobile/TASK-009-offline-reliability-validation.md), the Phase 2 verification gate. Contracts: [CHG-005](../changes/CHG-005-phase-2-local-persistence.md), [CHG-006](../changes/CHG-006-phase-2-green-decisions.md), [CHG-009](../changes/CHG-009-phase-2-verification.md).

## Changed files
| Path | Purpose |
|---|---|
| `apps/mobile/test/integration/offline_reliability_test.dart` | S01–S08 on the full local stack: network-off journey, crash images, replay, restart, migrations, file/row consistency, retryable errors |
| `apps/mobile/test/integration/offline_error_view_test.dart` | S08 widget test: a failed "Wear today" is shown on the prompt, both layouts |
| `apps/mobile/test/helpers/local_db.dart` | `TestDatabase.crashImage()`: database + WAL copied as a kill leaves them |
| `apps/mobile/test/helpers/reliability.dart` | `withoutNetwork` (refuses sockets and HTTP, counts attempts), `FlakyWardrobeRepository`, `FlakyWearRepository` |
| `apps/mobile/lib/features/studio/data/local_studio_repository.dart` | Deterministic, insert-if-absent consent (V-01) |
| `apps/mobile/lib/core/storage/local_data_store.dart` | Orphan attachment sweep on open (V-02) |
| `apps/mobile/lib/features/gu_match/presentation/gu_match_view_model.dart`, `widgets/outfit_deck_panel.dart` | "Wear today" error shown on the prompt and cleared on retry (V-03) |
| `.github/workflows/android-apk.yml` | Benchmark step (V-07) |

## Scenario coverage
| Scenario | Tests | Result |
|---|---|---|
| TASK-009-S01 offline journey | Flow A save → Archive → Gu Match like → Wear today with every socket and HTTP client refused; 0 connection attempts | pass |
| TASK-009-S02 kill during Save N | crash image mid-transaction has 0 Pieces; just after commit has all; killed "Index N Pieces" restarts on the same review and saves once | pass |
| TASK-009-S03 restart restores all | one restart restores the open review, consent, Gu Match deck position, Archive and wear log together | pass |
| TASK-009-S04 wear replay | confirming the same Fit after a restart returns "already logged", one event | pass |
| TASK-009-S05 replay | "Index N Pieces" replayed after a crash adds no row; consent replayed after a restart adds no row; a replay never undoes a withdrawal | pass |
| TASK-009-S06 migrations | a fixture exists for every prior version; v0 → current keeps every row; a current database with rows in every table reopens unchanged | pass |
| TASK-009-S07 files and rows | after a restart files and rows match one to one and contain no GPS, XMP or PNG text; an orphan file is removed when the store opens | pass |
| TASK-009-S08 offline errors | failed "Index N Pieces", "Wear today", Archive load and Gu Match load each show an explicit message and succeed once on retry; deck widget shows the "Wear today" error in both layouts | pass |

Rewards and check-ins in S04 are deferred with Flow C (CHG-005 P2-D2).

## TDD evidence
- **Red** (`a021130`): `flutter test test/integration` → 14 passed, 6 failed. Failures: consent replay gets a new random ID and a second row (2); an orphan photo file survives the store opening (1); a successful "Wear today" retry keeps the old error (1); the deck shows no error after a failed "Wear today" (2, mobile and desktop). The 14 passing tests are characterization of behaviour TASK-005…008 already deliver (crash atomicity, restart, migrations, sanitized files, load retries).
- **Green** (`1589db7`): `flutter test` → **481 passed, 0 failed, 1 skipped** (461 before + 20 TASK-009).
- **Benchmark** (`flutter test --run-skipped --tags benchmark`): **132 ms** on the Windows host for 500 Pieces and 3,000 wear events (budget 300 ms).

## Gates
| Gate | Result |
|---|---|
| format | pass (`dart format --output=none --set-exit-if-changed .`, 0 changed) |
| analyze | pass (0 issues) |
| tests | pass (481 passed, 1 skipped benchmark) |
| benchmark | pass (132 ms ≤ 300 ms) |
| backend | skipped: no backend change |

## Deviations from plan
- The file confinement allows "minimal production hooks"; the red run instead found three defects, fixed with the smallest changes and recorded as CHG-009 V-01…V-03.
- "E2E" runs below the widget layer on the real local stack (V-05). App-kill uses crash images (V-04).

## Device checks (not in `flutter test`, still to run)
| Check | Task |
|---|---|
| Real process kill during "Index N Pieces" and "Wear today" on Android and iOS | TASK-009 |
| Airplane mode end to end on a device | TASK-009 |
| SQLCipher: the database file is unreadable without the key | TASK-005 |
| Gallery picking and HEIC rejection on each platform | TASK-007 |
| Delete all within 5 s on a phone; benchmark on a mid-range Android phone | TASK-008, TASK-006 |

## Doc issues
None blocking. P3 must keep V-02's sweep in step with PowerSync attachment queues (BE-006).

## Lesson candidates
- A repository that is idempotent through deterministic IDs in one table (wear events) was not in another (consents). Candidate rule: every synced insert names its ID rule in CHG-005's table.
