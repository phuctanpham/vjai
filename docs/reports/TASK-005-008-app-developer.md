# TASK-005 to TASK-008 · app-developer report

| Date | Status | Commits |
|---|---|---|
| 2026-10-30 | Complete (PR 4) | Red: `f9fed97` · `dc6f937` · `3b436d5` · `99eae08` (+ `3aab83b` format). Decisions: `d1949db` (CHG-006). Green: `7fbe653` · `201a917` · `0621544` · `d71e873` |

Items: [TASK-005](../tasks/mobile/TASK-005-local-persistence-foundation.md) · [TASK-006](../tasks/mobile/TASK-006-derived-queries-and-rules.md) · [TASK-007](../tasks/mobile/TASK-007-photo-privacy-pipeline.md) · [TASK-008](../tasks/mobile/TASK-008-device-integrations-and-data-rights.md) · contracts [CHG-005](../changes/CHG-005-phase-2-local-persistence.md), [CHG-006](../changes/CHG-006-phase-2-green-decisions.md).

Garblo is a lookbook generating and matching app. Phase 2 persists the user's own Pieces, photo batches, wear log and Gu Match Fits on the phone. It stores no other people and no dating data.

## Changed files
| Path | Purpose |
|---|---|
| `lib/core/storage/*` | Phone schema v1 (PowerSync rules, incl. `ai_processing_jobs`), PRAGMA-key open factory and v0→v1 migration, `StorageFailure`, ObjectIds and deterministic IDs, install identity in secure storage, file attachment store, `LocalDataStore` (open, wipe), providers |
| `lib/core/media/*` | MIME sniffing, lossless JPEG/PNG metadata stripping with orientation, `image_picker` picker (default) |
| `lib/features/wardrobe/data/local_*`, `demo_seed.dart` | SQLite Archive and wear log; `json_each` last worn and wear counts; provisional `gap_days`/`rescue_eligible`; demo seed behind `GARBLO_DEMO_SEED` |
| `lib/features/studio/data/local_studio_repository.dart` | Consent, open batch, tray, review edits, analysis jobs, photo storage, discard; fake analysis on any photo (byte hash) |
| `lib/features/gu_match/data/local_gu_match_repository.dart` | Sessions, Fits, decisions, swaps, interactions, studio draft |
| `lib/features/*/presentation/*_view_model.dart` | Restore on start; save every change; ignore results after dispose |
| `lib/features/privacy/**` | Privacy & data: counts, on-page confirmation, withdraw consent, delete all |
| `lib/app/bootstrap.dart`, `lib/main.dart`, `lib/app/router.dart`, `lib/app/shell/app_shell.dart` | Open the store before `runApp`, storage error screen, restart on a fresh scope after delete all, `/privacy`, header avatar |
| `.github/workflows/android-apk.yml` | `minSdk 23` for `flutter_secure_storage` 10 |

## Scenario coverage
| Task | Scenarios | Tests | Result |
|---|---|---|---|
| TASK-005 | S01–S11 | 115 (incl. contract suites on Mock and SQLite) | pass |
| TASK-006 | S01–S04, S08 | 9 + 1 benchmark | pass |
| TASK-007 | S01–S07 | 40 (one fixture test per stripping rule) | pass |
| TASK-008 | S01–S08 | 42 | pass |
| Phase 1 (TASK-002…004, other) | — | 255 | pass (unchanged) |

Full suite: **461 passed, 0 failed**, 1 skipped (the benchmark, run separately).

## TDD evidence
- **Red** (`99eae08`): TASK-005 93 failing / 17 passing guards, TASK-006 9, TASK-007 40, TASK-008 41 failing; Phase 1 255 passing.
- **Green** (`d71e873`): `flutter test` → 461 passed, 0 failed. TASK-005's 13 restore tests that store real photos went green with TASK-007 (sanitizer), as noted in `7fbe653`.
- **Benchmark** (TASK-006-S08, `flutter test --run-skipped --tags benchmark`): 139 ms on the Windows host for 500 Pieces and 3,000 wear events (limit 300 ms).
- `dart format --set-exit-if-changed .` and `flutter analyze`: clean.

## Deviations
- Test changes made while going green are listed in CHG-006 › Test changes (schema contract gains `ai_processing_jobs`; new job, failure-note, any-photo, bootstrap and restart tests; one wrong orientation expectation fixed; Linux `libsqlite3.so.0` fallback).
- Photo storage and discard were written with TASK-005 because the restore tests need them; the sanitizer and attachment store came with TASK-007.

## Device checks (not in `flutter test`, still to run)
| Check | Task |
|---|---|
| The database file is unreadable without the key (SQLCipher on Android and iOS) | TASK-005 |
| Real restart and app kill on Android and iOS | TASK-005, TASK-009 |
| Gallery picking on Android, iOS, Windows, macOS; an iPhone HEIC shows the rejected notice | TASK-007 |
| Delete all of the encrypted database and attachments within 5 s on a phone (TAC-09.1) | TASK-008 |
| Benchmark on a mid-range Android phone | TASK-006 |

## Follow-ups
- TASK-009 tests are next (CHG-005 P2-D6).
- Backend: BE-006 (schema parity incl. `ai_processing_jobs`), BE-007 (server-side erasure and export), AI-001 (replaces the byte-hash fake), AI-004 (on-device blur and person detection, so pose/background jobs stop ending as `SKIPPED_NO_PERSON` by default).
