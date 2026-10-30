# TASK-005: Local persistence foundation

> **Phase:** 2 · P2 Persistent offline app  
> **Status:** Tests written (red) on `phase-2/persistence-tdd`  
> **Dependencies:** Phase 1 merged (#2); [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md)  
> **Source tasks:** P2-01, P2-02, P2-05 (must-have parts) · spec T4 › Phone schema, Write path, R2, R8

## Objective

Replace the Phase 1 in-memory repositories with local SQLite (SQLCipher in the
app) behind the same interfaces. The schema follows the T4 phone schema and the
PowerSync table rules, so P3 swaps the database object, not the repositories.

## Scope

- `sqlite_async` database opened through a Garblo open factory that issues
  `PRAGMA key` first (CHG-005 P2-D1); migrations from version 0 to 1.
- Phone schema v1 as a declarative contract (`phone_schema.dart`), following
  the PowerSync rules: `id TEXT PRIMARY KEY`, `TEXT`/`INTEGER`/`REAL` columns,
  no foreign keys, no UNIQUE constraints, plain indexes; only the local-only
  `session_draft` table uses SQL constraints (P2-D7). Tables and columns are
  listed in CHG-005.
- In-house ObjectIds (P2-D11) and deterministic IDs for idempotent writes
  (P2-D8): wear events from owner + date + signature; wardrobe items from
  their review draft ID. Writes check the ID inside the write transaction.
- Install identity in secure storage: the database key and a random owner ID,
  each created once per install (P2-D9).
- Local repositories: `LocalWardrobeRepository`, `LocalWearRepository`,
  `LocalStudioRepository` (open batch, tray, consent, review draft edits),
  `LocalGuMatchRepository` (sessions, Fits, decisions, interactions, studio
  draft). The fake analysis and fake Fit generator are unchanged.
- Batch, asset, draft, session and Fit IDs are ObjectIds, so rows never
  collide across batches or sessions (the Phase 1 `asset_<n>` and
  `session_<n>` IDs stay in the in-memory fakes only).
- Picked file URIs are local paths and are **not stored** (no column in v1).
  Restored photos are addressed as `attachment://<attachment_id>`.
- ViewModels restore persisted state through the repositories on start.
- Open or migration failure shows an explicit error, never an in-memory
  fallback.
- The Archive starts empty; the demo seed runs only with
  `--dart-define=GARBLO_DEMO_SEED=true` (P2-D5).

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-005-S01 | A fresh database migrates from version 0 to the current version | Integration |
| TASK-005-S02 | Tables, columns, types and indexes match phone schema v1 and the PowerSync rules | Schema |
| TASK-005-S03 | After closing and reopening the database, the Archive, open batch (with review edits), consent, studio draft and Gu Match Fits with their decisions are restored | Repository/ViewModel |
| TASK-005-S04 | Indexing N Pieces commits all rows or none; repeating the same save adds nothing | Repository |
| TASK-005-S05 | A failure part-way through a save leaves no Piece rows | Repository |
| TASK-005-S06 | ObjectIds are 24 lowercase hex characters, unique, time-ordered and stored as text | Unit |
| TASK-005-S07 | Confirming the same Fit as worn twice on one day leaves one wear event (deterministic ID) | Repository |
| TASK-005-S08 | The SQLite repositories pass the same contract suites as the in-memory ones; no widget imports storage | Contract/architecture |
| TASK-005-S09 | A database that cannot be opened or migrated surfaces a `StorageFailure` | Integration |
| TASK-005-S10 | The database key and owner ID are created once per install and reused | Unit |
| TASK-005-S11 | A fresh install has an empty Archive; the demo seed adds the 9 demo Pieces only when enabled | Integration |

## Test plan

| Scenario | Level | Test file | Test name prefix |
|---|---|---|---|
| S01, S09 | Integration | test/core/storage/garblo_database_test.dart | [TASK-005-S01] / [TASK-005-S09] |
| S02 | Schema | test/core/storage/phone_schema_test.dart | [TASK-005-S02] |
| S03, S04, S05, S08 | Repository/contract | test/features/wardrobe/data/local_wardrobe_repository_test.dart | [TASK-005-S0x] |
| S03, S07 | Repository | test/features/wardrobe/data/local_wear_repository_test.dart | [TASK-005-S03] / [TASK-005-S07] |
| S03 | Repository | test/features/studio/data/local_studio_repository_test.dart | [TASK-005-S03] |
| S03 | Repository | test/features/gu_match/data/local_gu_match_repository_test.dart | [TASK-005-S03] |
| S03 | ViewModel | test/app/persistence_restore_test.dart | [TASK-005-S03] |
| S06 | Unit | test/core/storage/object_id_test.dart | [TASK-005-S06] |
| S08 | Architecture | test/architecture/storage_boundary_test.dart | [TASK-005-S08] |
| S10 | Unit | test/core/storage/install_identity_test.dart | [TASK-005-S10] |
| S11 | Integration | test/features/wardrobe/data/demo_seed_test.dart | [TASK-005-S11] |

Contract suites (S08) live in `test/helpers/contracts/` and run against both
the in-memory and the SQLite implementations. Shared helper:
`test/helpers/local_db.dart` (temporary database files; on Windows it loads
the host `sqlite3.dll`, see ci-cd.md).

Device checks (not in `flutter test`, reported as skipped until run): the
database file is unreadable without the key on a phone (SQLCipher); a real
restart on Android and iOS.

Questions from the red run, decided in
[CHG-006](../../changes/CHG-006-phase-2-green-decisions.md):

- The fake analysis works on any photo: a URI fixture wins (an empty one is
  the "no clothes found" path), otherwise the sample set comes from a stable
  hash of the sanitized bytes (G-01). The sample-photo picker is dropped
  (G-02).
- `ai_processing_jobs` (spec T2, C6) joins schema v1, one job per photo ×
  task, so the "N photos couldn't be read" note survives a restart (G-03).

## File confinement

**App Developer may create or modify:**

- `lib/core/storage/**` (open factory, migrations, phone schema, ObjectIds,
  secure store, install identity, providers)
- `lib/features/wardrobe/data/**`, `lib/features/studio/data/**`,
  `lib/features/gu_match/data/**` (local repositories; new interface methods
  with in-memory versions in the Mock classes)
- `lib/features/studio/domain/**`, `lib/features/gu_match/domain/**` (persisted
  snapshots; IDs on `PrivacyConsent`)
- `lib/features/*/presentation/*_view_model.dart` (restore on start only)
- `lib/main.dart`, `lib/app/bootstrap.dart` (open the database before `runApp`;
  explicit storage error screen)
- `pubspec.yaml`, `pubspec.lock`, `.gitignore` (approved dependencies, D-006)
- `test/core/storage/**`, `test/features/*/data/**`, `test/helpers/**`,
  `test/app/persistence_restore_test.dart`, `test/architecture/**`

**Locked:** widgets (`*_view.dart`, `widgets/**`), the dating feature tree,
`backend/**`.

## Anti-scope

- No PowerSync, upload queue, backend API, JWT or cloud storage.
- No Flow C/D tables or repositories (rewards, check-ins, Community,
  notifications) — deferred (P2-D2).
- No change to domain vocabulary, the fake analysis or the fake Fit generator.
- No silent fallback to in-memory storage after an open or migration failure.

## Acceptance criteria

- Migration, schema, restore, atomicity and idempotency are proven by tests.
- Repository contracts are unchanged for widgets; contract suites pass for both
  implementations.
- Only approved dependencies (D-006) are added.
- Format, analyze and the full Flutter suite pass.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | — | Created from T6 P2-01, P2-02, and P2-05. |
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | Must-have scope only (no rewards, check-ins, Community, notifications); PowerSync table rules; deterministic IDs; install identity; S08 reworded (ViewModels restore through repositories); S09–S11 added; test plan and file list. |
| 2026-10-30 | [CHG-006](../../changes/CHG-006-phase-2-green-decisions.md) | Red-run questions decided: fake analysis on any photo; `ai_processing_jobs` added. |
