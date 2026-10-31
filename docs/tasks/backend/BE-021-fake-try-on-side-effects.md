# BE-021: Fake try-on side effects (`vton_jobs` in the mock)

> **Owner:** Backend Developer  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) and [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) approval  
> **Track / priority:** M · after BE-015 and BE-018  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31, for [TASK-030](../mobile/TASK-030-try-on-end-to-end.md)  
> **Blocked by:** [BE-015](BE-015-fake-gu-match-side-effects.md), [BE-018](BE-018-mock-attachments.md), [AI-005](AI-005-model-ports-and-fakes.md) (render port)  
> **Source:** Flow Spec v2.8 T4 › Side effects (`vton_jobs` PUT REQUESTED) · UC-08 · DB handbook GM-08, C06-02, C06-03, FL-03, FL-08

## Why

BE-011 lists `vton_jobs` as "refused until AI-002", and AI-002 waits for SP-3 and a vendor.
The phone can build and test the whole try-on flow (consent, body photo, one active render,
withdrawal) against a fake render now, so P5 only swaps the render worker.

## Contract (mock)

| Phone writes | Mock does | Rows in the feed |
|---|---|---|
| `vton_jobs` PUT `{session_id, candidate_id, body_asset_id}`, status REQUESTED | Precheck I7: an active consent with `includes_body = 1` and a VERIFIED BODY attachment owned by the user. One active job per candidate | `vton_jobs` status PROCESSING → COMPLETED or FAILED (`I7_PRECHECK_FAILED`, `ACTIVE_RENDER_EXISTS`) |
| — | Fake render: a fixture PNG from `contracts/fixtures/images/`, stored in the in-memory files under `users/{id}/renders/` | RENDER `attachments` row (READY) + GET ticket (10 min) |
| `consents` PATCH `revoked_at`, or `privacy_requests` BODY | Cancel queued and processing jobs; delete body and render files | `vton_jobs` CANCELLED (value to confirm with the APM), attachment DELETEs |

Latency comes from the mock clock or scenarios (`/v1/mock/scenarios {"vton": "SLOW_20S" | "FAIL"}`).
The wall clock is never read.

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| BE-021-S01 | A valid request completes with a RENDER attachment and a 10-minute ticket | `tests/test_fake_vton.py` |
| BE-021-S02 | No body consent, or no verified BODY photo → FAILED `I7_PRECHECK_FAILED` | `tests/test_fake_vton.py` |
| BE-021-S03 | A second request for the same candidate while one is active → rejected `ACTIVE_RENDER_EXISTS` | `tests/test_fake_vton.py` |
| BE-021-S04 | Withdrawal cancels active jobs and deletes body and render files in the same transaction | `tests/test_fake_vton.py` |
| BE-021-S05 | Render and body files are never readable through any ticket for another owner | `tests/test_fake_vton.py` |

## Anti-scope

No real model or vendor (AI-002). No `body` bucket encryption (BE-008).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer for the Backend Developer |
