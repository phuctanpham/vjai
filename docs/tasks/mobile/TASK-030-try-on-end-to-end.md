# TASK-030: Try-on end to end

> **Phase:** P5 · P5-M02 (UC-08 AC-08.5…08.11)  
> **Track:** M (fake render through [BE-021](../backend/BE-021-fake-try-on-side-effects.md)) → R (P5-A05 model or vendor behind the render worker, P5-B02)  
> **Status:** Draft · Track M needs CHG-015 approval, BE-021 and a plan. Track R is blocked by SP-3 and [AI-002](../backend/AI-002-virtual-try-on.md)  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Dependencies:** [TASK-026](TASK-026-gu-match-command-rows.md), [TASK-025](TASK-025-photo-upload-with-tickets.md) (BODY attachments), [TASK-027](TASK-027-privacy-requests-online.md) (withdrawal)  
> **Source:** Flow Spec v2.8 UC-08 · T4 › Side effects (`vton_jobs`) · DB handbook GM-08, C06-02, C06-03, FL-08, C05-10

## Why

Try-on shows "coming soon" today (P1-09). It is the only flow that handles body images, so it
carries the strictest rules: body consent (I7), its own bucket and key, 10-minute GET tickets,
cancellation within 1 minute of withdrawal, and never used in a post or poster (I16).

## Scope

- Add body photo: a `upload_batches` row with `purpose = BODY_REFERENCE`, a BODY attachment
  uploaded through TASK-025, and consent with `includes_body = 1` required first.
- Try on: insert a `vton_jobs` command row (`session_id`, `candidate_id`, `body_asset_id`).
  Status from sync. The render arrives as a RENDER attachment with a short GET ticket. The card
  then shows the TRY-ON label (AC-07.2).
- One active render per Fit (the server enforces it; the button is disabled while one is active).
- Withdrawal (TASK-027 BODY) removes body photos and renders from the cache at once. Queued jobs
  show "cancelled".
- Render files are never cached beyond their ticket lifetime unless the spec allows it
  (DOC-004 Q10).

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-030-S01 | Try on without body consent opens the consent step; nothing is uploaded | Widget |
| TASK-030-S02 | With consent and a body photo, Try on inserts one `vton_jobs` row; a second tap while active does nothing | Repository + ViewModel |
| TASK-030-S03 | A completed fake render shows on the card with the TRY-ON label; the ticket expiring hides it until renewed | Widget (recorded feed) |
| TASK-030-S04 | Withdrawing body consent clears body and render files from the cache within the test's 1 s budget and shows queued jobs as cancelled | Integration (mock) |
| TASK-030-S05 | No share, poster or post code path can read a RENDER or BODY attachment (architecture test, I16) | Architecture |

## Anti-scope

No render model on the phone. No sharing (Flow D).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
