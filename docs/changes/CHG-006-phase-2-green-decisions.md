# CHG-006: Phase 2 green, review decisions and test changes

| Status | Source | Date |
|---|---|---|
| Done | Review of the Phase 2 red run (PR 4) · [CHG-005](CHG-005-phase-2-local-persistence.md) · [Garblo Flow Spec](../tasks/mobile/Garblo%20Flow%20Spec.html) v2.7 T2, C6 | 2026-10-30 |

Status values: `Draft` → `Approved` (human) → `Done` (after merge).

## Problem
The Phase 2 red run left two open questions (TASK-005): real photos match no
fixture in the fake analysis, and a partial result's "N photos couldn't be
read" note is lost after a restart. The reviewer decided both and set the
delivery workflow until Phase 2 is complete. This record also lists every test
changed while going green, so no test is edited silently.

## Decisions
| ID | Decision | Reason |
|---|---|---|
| G-01 | **Fake analysis works on any photo.** A photo with a URI fixture uses it (an empty fixture is the "no clothes found" path). Otherwise the sample set is chosen from a stable hash of the sanitized bytes (FNV-1a, `hash % 3` over the three preset sample sets). Photos with neither bytes nor a fixture give zero items. AI-001 replaces the fake later | Flow A gives Pieces on a device; tests stay deterministic |
| G-02 | The sample-photo picker is dropped from the app: the default `photoPickerProvider` is `ImagePickerPhotoPicker`. `PresetPhotoPicker` stays only as a test and demo double | Real photos are the Phase 2 path |
| G-03 | **`ai_processing_jobs` joins phone schema v1** (spec T2 `AI_JOBS`, C6): `user_id`, `batch_id`, `asset_id`, `task_type` (`OUTFIT_EXTRACTION` · `POSE_ESTIMATION` · `BACKGROUND_ANALYSIS`), `status` (`PENDING` · `PROCESSING` · `COMPLETED` · `SKIPPED_NO_PERSON` · `FAILED`), `created_at`, `updated_at`; index `(batch_id, asset_id)`. One job per photo × task: the ID is `deterministicObjectId([batch_id, asset_id, task_type])`, so a retry updates the job instead of adding one (no UNIQUE, P2-D7). The restored review counts photos with jobs and failed photos from `OUTFIT_EXTRACTION` jobs in `FAILED` | Spec table that schema v1 had left out |
| G-04 | In the fake, pose and background jobs end as `SKIPPED_NO_PERSON` (no person detection before AI-004); outfit jobs end `COMPLETED` or `FAILED` | Spec C6 |
| G-05 | Approved as written in the red tests: picked file URIs are not stored (restored photos are `attachment://<id>`); batch, asset, draft, session and Fit IDs are random ObjectIds. **Wear events keep the deterministic ID** (P2-D8) | Review |
| G-06 | Workflow: no new PRs and no merges until every Phase 2 test is green. Green commits go on `phase-2/persistence-tdd`, one per task (TASK-005 → 006 → 007 → 008), pushed as they land; PR 4 stays Draft. Then: PR 2 into `main` (already merged on 2026-10-30), retarget and rebase PR 4 onto `main`, merge it, post the final test table | Review |
| G-07 | CI: the workflow runs on pushes to `main` only, so branch pushes are checked with a manual `workflow_dispatch` run. The generated Android project gets `minSdk 23` (required by `flutter_secure_storage` 10) | Keeps the APK build green |

## Test changes while going green
| Test | Change | Why |
|---|---|---|
| `apps/mobile/test/core/storage/phone_schema_test.dart` `[TASK-005-S02]` | Contract adds `ai_processing_jobs` and its index | G-03 |
| `apps/mobile/test/features/studio/data/local_studio_repository_test.dart` `[TASK-005-S03]` | New: a partial result's failure note survives closing and reopening; analysis writes one job per photo × task, and a retry does not add jobs | G-03, G-04 |
| `apps/mobile/test/features/studio/data/local_studio_repository_test.dart` `[TASK-005-S03]` | New: a photo without a fixture gets sample Pieces chosen from its bytes, the same every time; an empty fixture gives zero items | G-01 |
| `apps/mobile/test/helpers/local_db.dart` | On Linux, falls back from `libsqlite3.so` to `libsqlite3.so.0` | CI image may lack the dev symlink |
| `apps/mobile/test/features/studio/presentation/studio_erasure_test.dart` `[TASK-008-S07]` | The held fake uses the Mock's own `savedBatches` instead of shadowing it | The Mock now records saved batches itself |
| `apps/mobile/test/features/studio/data/local_studio_repository_test.dart` `[TASK-005-S03]` | The second test photo is a PNG without `eXIf`, so the restored orientations are 6 and 1 as the test expects | The default PNG fixture carries orientation 6; the expectation was wrong |
| `apps/mobile/test/app/bootstrap_test.dart` `[TASK-005-S09]` | New: a store that cannot be opened shows the error with "Try again", never the app | Covers the bootstrap error screen |
| `apps/mobile/test/app/bootstrap_test.dart` `[TASK-008-S05]` | New: "Delete all" restarts the app on a fresh provider scope | Covers the restart wiring in the bootstrap |

## Product impact (APM)
| Affected | Change needed |
|---|---|
| AI-001 | The real extractor replaces the byte-hash fake; job statuses as in G-03/G-04 |

## Engineering impact (ASEM)
| Affected | Change needed |
|---|---|
| [CHG-005](CHG-005-phase-2-local-persistence.md) › Phone schema v1 | Add `ai_processing_jobs` |
| [BE-006](../tasks/backend/BE-006-phone-schema-sync-parity.md) | Add `ai_processing_jobs` to the parity table list; job IDs are deterministic |
| `.github/workflows/android-apk.yml` | `minSdk 23` on the generated Android project |

## Code follow-up
| Role | Paths | Tests | Done |
|---|---|---|---|
| App Developer | TASK-005…008 file lists | Test plans in the cards, plus the rows above | [x] |
| Backend Developer | None in Phase 2. BE-006 updated | — | — |
