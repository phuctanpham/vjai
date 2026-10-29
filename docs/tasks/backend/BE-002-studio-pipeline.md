# BE-002: Studio API — batches, consent, analysis jobs, review, commit

> **Owner:** Backend Developer  
> **Status:** Blocked by [BE-001](BE-001-platform-decision.md)  
> **Spec phase:** P4 (P4-B05, P4-B06; stub extraction worker)  
> **Source:** UC-01, UC-02, UC-03 · T2 (state machine, I1, I2, I4) · TAC-01.4, 01.7, 01.8, 02.3–02.5, 03.2, 03.5, 03.6

## Why

Mobile Phase 1 runs Flow A on `MockStudioRepository` (fixture analysis) and
keeps batch status in the ViewModel. This card makes the pipeline real, with a
deterministic stub extractor, without changing the mobile contract.

## Contract fixed by Phase 1 (do not break)

| Mobile type | Fields / rule | Test that pins it |
|---|---|---|
| `BatchStatus` | `draft → sanitizing → queuedForAi → aiProcessing → awaitingReview → completed`; `aiProcessing → failed`; `failed → draft` / `queuedForAi` (A-02); erasure → `deletedByUser` | `test/features/studio/domain/batch_status_test.dart` |
| `PhotoTray` | 1–10 photos, MIME `image/jpeg` or `image/png` only (I1, I2) | `photo_tray_test.dart` |
| `AnalysisSelection` | Outfit on by default; at least one task (I4) | `analysis_selection_test.dart` |
| `PrivacyConsent` | `version = v1.0_studio_body_ai`, `grantedAt`; insert-only (TAC-01.8) | `studio_repository_test.dart` |
| `ExtractedItem` | `draftId, assetId, slotIndex, itemIndex, name, confidence (0..1)`, `ai` and `value` attribute sets (`typeCode, color, material, styleTag`); `userModified` derived (TAC-03.5); group derived from type (TAC-03.6) | `extracted_item_test.dart` |
| Review order | slot, then item index (AC-03.3) | `studio_repository_test.dart` |
| Outcomes | partial / all failed / zero items (UC-02/03 states) | `review_draft_test.dart` |
| Commit | all N wardrobe items or none (TAC-03.2) | `wardrobe_repository_test.dart` |

## Scope

- Endpoints from spec T2 › API surface: `POST /v1/studio/batches`,
  `…/assets`, `DELETE …/assets/{id}`, `…/submit`, `…/analysis`, `…/reopen`,
  `GET …/events` (SSE), `GET …/extracted-items`, `PATCH /v1/studio/extracted-items/{id}`,
  `POST …/commit`.
- Validators for I1, I2, I4; 409/422 responses as in the spec contracts.
- Idempotent submit (`client_event_id`) and commit (TAC-01.4, TAC-03.2).
- One job per (batch, photo, task) (TAC-02.3); retries ≤ 2 (TAC-02.4).
- Deterministic stub extraction worker returning the Phase 1 fixture items.
- Pydantic models in `backend/app/models/` with tests in
  `backend/tests/test_studio.py` (if BE-001 keeps FastAPI).

## Anti-scope

No real CV models (AI-001), no on-device sanitizer, no object storage beyond
what BE-001 approves.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created from the Phase 1 Studio contract. |
