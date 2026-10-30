# CHG-009: Phase 2 verification (TASK-009) decisions

| Status | Source | Date |
|---|---|---|
| Done | Human request: complete Phase 1 and Phase 2 on `main` · [TASK-009](../tasks/mobile/TASK-009-offline-reliability-validation.md) red run | 2026-10-30 |

Status values: `Draft` → `Approved` (human) → `Done` (after merge).

## Problem

The TASK-009 red run (`a021130`) found three gaps in the green Phase 2 stack:

1. **Consent replay duplicates rows.** `recordConsent` took a random ObjectId, so
   replaying the same consent after a restart inserted a second row. TASK-009-S05
   requires deterministic IDs; CHG-005 P2-D8 had covered only wear events and Pieces.
2. **Orphan photo files survive a kill.** Every path writes a file before its
   row and deletes rows before files. That ordering is correct, but a kill in
   between leaves a sanitized photo on disk that no row references, and nothing
   removed it (TASK-009-S07).
3. **A failed "Wear today" was silent.** The deck never rendered
   `errorMessage`, and a successful retry did not clear it, so the message showed
   up later in the styling studio (TASK-009-S08).

## Decisions

| ID | Decision | Reason |
|---|---|---|
| V-01 | A consent ID is `deterministicObjectId([owner, version, grantedAt ISO-8601, includesBody])`. The insert is `INSERT … WHERE NOT EXISTS`, so a replay adds nothing and never touches an existing row, including a withdrawn one | Extends P2-D8 to consents; consents stay insert-only (TASK-008-S03) |
| V-02 | `LocalDataStore.open` deletes attachment files that no `media_assets.attachment_id`, `wardrobe_items.cutout_attachment_id` or `extracted_items.cutout_attachment_id` references. It runs before the app uses the store, and is best effort: a failure never blocks opening | The only inconsistency a kill can leave; privacy expects a discarded photo to be gone |
| V-03 | A "Wear today" attempt clears the previous error; a failure shows its message on the wear prompt, which stays open for the retry | Errors are explicit and retryable where they happen |
| V-04 | App-kill is tested with **crash images**: the database file and WAL copied while a write transaction is open (or just after it commits), then opened as a restart would. Real process kill on a device remains a device check (P2-D14) | `flutter test` cannot kill its own process; the on-disk state is what matters |
| V-05 | "E2E" scenarios run the full local stack below the widgets: SQLite file, attachment store, sanitizer, every Local repository and ViewModel. Widget journeys stay covered by TASK-003/004 tests; the S08 deck error also has a widget test in both layouts | Real database isolates do not run under the widget tester's fake async |
| V-06 | Migration tests keep one builder per prior schema version (`_priorVersions`), with a guard test that fails when `PhoneSchema.version` grows without one | Today only v0 → v1 exists; the guard makes v2 add its fixture |
| V-07 | CI runs the benchmark: `flutter test --run-skipped --tags benchmark` after the test step | TASK-009 scope: 300 ms budget in CI where supported |

## Product impact (APM)

| Affected | Change needed |
|---|---|
| [TASK-009](../tasks/mobile/TASK-009-offline-reliability-validation.md), [mobile README](../tasks/mobile/README.md) | Status: green and merged; Phase 2 complete |

## Engineering impact (ASEM)

| Affected | Change needed |
|---|---|
| [ci-cd.md](../policies/engineering/ci-cd.md) | CI runs the benchmark |
| [codebase-map.md](../policies/engineering/codebase-map.md) | `apps/mobile/test/integration/`, `apps/mobile/test/helpers/reliability.dart`, crash images |
| [CHG-005](CHG-005-phase-2-local-persistence.md) | TASK-009 code follow-up done |

## Test changes while going green

None. The 20 TASK-009 tests are unchanged between the red commit `a021130`
and the green commit `1589db7`; no existing test was edited.

## Code follow-up

| Role | Paths | Tests | Done |
|---|---|---|---|
| App Developer | `apps/mobile/lib/features/studio/data/local_studio_repository.dart`, `apps/mobile/lib/core/storage/local_data_store.dart`, `apps/mobile/lib/features/gu_match/presentation/gu_match_view_model.dart`, `apps/mobile/lib/features/gu_match/presentation/widgets/outfit_deck_panel.dart`, `.github/workflows/android-apk.yml` | `apps/mobile/test/integration/`, `apps/mobile/test/helpers/{local_db,reliability}.dart` | [x] |
| Backend Developer | None | None | — |

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | — | Created from the TASK-009 red run; approved by the human with the Phase 2 completion request |
| 2026-10-30 | — | Done: merged to `main` with Phase 2 (PR 4) |
| 2026-10-30 | [CHG-010](CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
