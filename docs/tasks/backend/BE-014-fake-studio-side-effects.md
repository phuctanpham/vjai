# BE-014: Fake Studio side effects — jobs, fake extraction, review, commit

> **Owner:** Backend Developer  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval  
> **Track / priority:** M · **6**  
> **Blocked by:** [BE-012](BE-012-mock-write-handler.md), [BE-013](BE-013-mock-change-feed.md), [AI-005](AI-005-model-ports-and-fakes.md)  
> **Source:** UC-01…UC-03 · Flow Spec v2.8 T2 › State machines; T4 › Side effects (upload_batches, wardrobe_items) · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §5 · [CHG-006](../../changes/CHG-006-phase-2-green-decisions.md) G-01, G-03, G-04 · spec P4-B05 (this is its mock)

## Why

This is the mock of the Studio pipeline in [BE-002](BE-002-studio-pipeline.md).
The phone writes the batch, assets, consent and status changes. The server creates
one job per photo × task, runs the fake extractor, and writes `extracted_items` for
review. When the user saves, the phone writes N `wardrobe_items` and the batch
COMPLETED in one tx. The mobile team can then test progress, partial results,
failures, review edits and atomic save against a server.

## Behaviour

| Phone writes (via `/v1/sync/tx`) | Mock side effect | Rows in the feed |
|---|---|---|
| `upload_batches` PATCH `SANITIZING` | Mark each non-removed asset verified (BE-018 does real checks later) | `media_assets` |
| `upload_batches` PATCH `QUEUED_FOR_AI` | One `ai_processing_jobs` row per non-removed asset × requested task, ID `deterministic_object_id([batch_id, asset_id, task_type])`; batch → `AI_PROCESSING`; run jobs | jobs PENDING → PROCESSING → final; `extracted_items`; batch status |
| Outfit job | `OutfitExtractor` → `COMPLETED` with 0..n `extracted_items`, or `FAILED` | `extracted_items` with `ai` = `value` = extractor attributes, `item_index` per asset, ID `deterministic_object_id([batch_id, asset_id, str(item_index)])` |
| Pose / background job | `PersonDetector` → `SKIPPED_NO_PERSON` | job row |
| All jobs final | Batch → `AWAITING_REVIEW`, or `FAILED` when every outfit job failed (T2 state machine) | batch status |
| `extracted_items` PATCH `value`, `last_worn_input` | Accept (allow-list in BE-012); `ai` never changes | the patched row |
| `upload_batches` PATCH `DRAFT` (reopen) | Cancel the batch's jobs by deleting them, and delete its `extracted_items` (`job_status` has no CANCELLED value; the phone's `discardBatch` also deletes jobs) | DELETE changes for jobs and drafts |
| `wardrobe_items` PUT ×N + batch PATCH `COMPLETED`, one tx | Check the batch is `AWAITING_REVIEW` and every item's `source_asset_id` is in it; IDs are the phone's `deterministic_object_id([draft_id])`; a retried tx is a replay | items in `my_wardrobe`; DELETEs for the batch's `my_studio` rows |

Retries: a `FAILED` outfit job is retried up to 2 times before it stays FAILED
(TAC-02.4). The fake scripts a failure count per scenario, so tests see a
retried-then-completed job and a job that stays failed.

Scenarios from `PUT /v1/mock/scenarios {"studio": …}` (owner-scoped, reset by
`/v1/mock/reset`): `OK` (default), `PARTIAL` (first photo's outfit job fails),
`ALL_FAILED`, `ZERO_ITEMS` (every outfit job completes with no pieces), `HOLD`
(jobs stay PROCESSING until `POST /v1/mock/jobs/release`, for progress UI tests).

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| BE-014-S01 | 3 photos, outfit only → 3 jobs with the deterministic IDs, each PENDING → PROCESSING → COMPLETED in feed order; batch ends `AWAITING_REVIEW` | `tests/test_studio_effects.py` |
| BE-014-S02 | Outfit + pose + background on 2 photos → 6 jobs; pose and background end `SKIPPED_NO_PERSON` | `tests/test_studio_effects.py` |
| BE-014-S03 | Extracted items equal the fake's pieces, ordered by slot then item index (AC-03.3), `ai == value`, type codes in the catalog | `tests/test_studio_effects.py` |
| BE-014-S04 | Re-sending the QUEUED_FOR_AI tx (replay) creates no extra job (TAC-02.3) | `tests/test_studio_effects.py` |
| BE-014-S05 | `PARTIAL` → batch `AWAITING_REVIEW` with one FAILED outfit job; `ALL_FAILED` → batch `FAILED`; `ZERO_ITEMS` → `AWAITING_REVIEW` with no drafts | `tests/test_studio_outcomes.py` |
| BE-014-S06 | A job failing once is retried and completes; failing 3 times stays FAILED (≤ 2 retries) | `tests/test_studio_outcomes.py` |
| BE-014-S07 | Reopen (→ DRAFT) during `HOLD` cancels jobs and removes drafts; re-analysis creates them again | `tests/test_studio_outcomes.py` |
| BE-014-S08 | PATCH of `value.color` keeps `ai.color` (TAC-03.5: user_modified is derived) | `tests/test_studio_commit.py` |
| BE-014-S09 | Commit N items + COMPLETED applies all or none: an unknown type code in item 3 → 422 and no item stored (TAC-03.2) | `tests/test_studio_commit.py` |
| BE-014-S10 | A retried commit (same tx or same deterministic IDs in a new tx) stores N items, not 2N | `tests/test_studio_commit.py` |
| BE-014-S11 | After COMPLETED the batch's studio rows leave the feed (DELETE changes); the items stay | `tests/test_studio_commit.py` |

## Allowed files

`backend/app/workers/studio.py`, `backend/app/sync/effects.py` (registration only),
`backend/app/api/v1/endpoints/mock_controls.py` (scenarios, job release),
`backend/tests/test_studio_*.py`, report.

## Anti-scope

No real models (AI-001), no cutouts or embeddings (`item_embeddings` is P5 and
AI-001), no file verification (BE-018), no draft retention job (P4-B06), no
data-free push (BE-009).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created |
