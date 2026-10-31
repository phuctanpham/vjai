# BE-002: Studio API — batches, consent, analysis jobs, review, commit

> **Owner:** Backend Developer  
> **Status:** Blocked by [BE-001](BE-001-platform-decision.md) · Track R; the mock is [BE-014](BE-014-fake-studio-side-effects.md)  
> **Spec phase:** P4 (P4-B05, P4-B06; stub extraction worker)  
> **Source:** UC-01, UC-02, UC-03 · T2 (state machine, I1, I2, I4) · TAC-01.4, 01.7, 01.8, 02.3–02.5, 03.2, 03.5, 03.6

## Why

Mobile Phase 1 runs Flow A on `MockStudioRepository` (fixture analysis) and
keeps batch status in the ViewModel. This card makes the pipeline real, with a
deterministic stub extractor, without changing the mobile contract.

## Contract fixed by Phase 1 (do not break)

| Mobile type | Fields / rule | Test that pins it |
|---|---|---|
| `BatchStatus` | `draft → sanitizing → queuedForAi → aiProcessing → awaitingReview → completed`; `aiProcessing → failed`; `failed → draft` / `queuedForAi` (A-02); erasure → `deletedByUser` | `apps/mobile/test/features/studio/domain/batch_status_test.dart` |
| `PhotoTray` | 1–10 photos, MIME `image/jpeg` or `image/png` only (I1, I2) | `photo_tray_test.dart` |
| `AnalysisSelection` | Outfit on by default; at least one task (I4) | `analysis_selection_test.dart` |
| `PrivacyConsent` | `version = v1.0_studio_body_ai`, `grantedAt`, **`includesBodyProcessing = true`** (the 1a box reads "Process my photos, including body photos if any"; UC-01 submit sends `includes_body_processing: true`); insert-only (TAC-01.8); one record reused by later batches (D3) | `studio_view_model_test.dart`, `studio_repository_test.dart` |
| Draft IDs | `draft_<assetId>_<itemIndex>` in Phase 1 (fixture only); the server issues its own `draft_id` | `studio_repository_test.dart` |
| Analysis tasks | Only Pieces (outfit extraction) yields items in Phase 1. Pose and Background have no Phase 1 output; the real pipeline ends them as `SKIPPED_NO_PERSON` when no person is found (AC-02.7, AI-001) | — |
| `ExtractedItem` | `draftId, assetId, slotIndex, itemIndex, name, confidence (0..1)`, `ai` and `value` attribute sets (`typeCode, color, material, styleTag`); `userModified` derived (TAC-03.5); group derived from type (TAC-03.6) | `extracted_item_test.dart` |
| Review order | slot, then item index (AC-03.3) | `studio_repository_test.dart` |
| Outcomes | partial / all failed / zero items (UC-02/03 states) | `review_draft_test.dart` |
| Commit | all N wardrobe items or none (TAC-03.2) | `wardrobe_repository_test.dart` |

## Scope

> **Spec v2.8 removed the REST + SSE surface** that this card used to list
> (`POST /v1/studio/batches`, `…/submit`, `GET …/events`, `POST …/commit`, …). See
> Flow Spec v2.8 T2 › *Sync contract (replaces the API surface)*. Each former
> endpoint is now a row the phone writes through `POST /v1/sync/tx`, plus a
> server side effect whose results sync back.

The behaviour is defined and tested in the mock first:
[BE-012](BE-012-mock-write-handler.md) (validators I1, I2, I4, transitions,
idempotency) and [BE-014](BE-014-fake-studio-side-effects.md) (jobs, fake
extraction, review, atomic commit). This card makes it real:

- The Studio worker runs on the real store ([BE-020](BE-020-write-handler-on-mongodb.md))
  and a real job runner, with the same effects registry and the BE-014 tests
  parametrised over both stores.
- Verify worker on uploaded photos ([BE-008](BE-008-rustfs-tickets-and-verify.md));
  draft retention, 7 days after COMPLETED (P4-B06, TAC-03.4).
- One job per (batch, photo, task) (TAC-02.3); retries ≤ 2 (TAC-02.4); progress
  through synced job rows (`my_studio_jobs`) and a nudge ([BE-009](BE-009-sync-nudge.md)).
- The deterministic stub extractor stays (AI-005 `FixtureOutfitExtractor`) until
  AI-001 swaps the adapter.

## Anti-scope

No real CV models (AI-001), no on-device sanitizer, no object storage beyond
what BE-001 approves.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created from the Phase 1 Studio contract. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | From TASK-003 green: consent includes body processing; draft IDs; Pose/Background output in Phase 1. |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Scope rewritten for the v2.8 sync contract (REST/SSE removed); mock predecessors BE-012, BE-014. |
