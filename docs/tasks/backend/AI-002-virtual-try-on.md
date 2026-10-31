# AI-002: Virtual try-on

> **Owner:** AI Engineer + Backend Developer  
> **Status:** Blocked by [BE-004](BE-004-gu-match-api.md) and spike SP-3 (model or vendor)  
> **Spec phase:** P5 (P5-A05, P5-B02, P5-M02)  
> **Source:** UC-08 AC-08.5–08.11 · C5 · I7 · TAC-08.2–08.5, 08.7

## Why

Phase 1 shows "Try-on is coming soon" (CHG-003 W-08) and never renders. The
mobile `CardAction.triggerVton` and `VisualMode.virtualTryOn` ("TRY-ON" label)
already exist; this card makes them real.

## Scope

- A `vton_jobs` command row (`PUT … REQUESTED`) through `POST /v1/sync/tx`. Spec v2.8
  removed `POST /v1/gu-match/candidates/{id}/try-on`. The I7 precheck rejects the
  write with 422 `BODY_REFERENCE_REQUIRED` / `BODY_CONSENT_REQUIRED` (the queue moves
  on, BE-012 rules), or the worker sets the job `FAILED` with that reason. Pick one
  with the APM, because the phone shows a different message for each.
- The render model sits behind a `TryOnRenderer` port, added next to the
  [AI-005](AI-005-model-ports-and-fakes.md) ports, with a fake that returns a fixed
  illustration, so the mobile flow can be built before SP-3 picks a model or vendor.
- Body-reference batch (`purpose = BODY_REFERENCE`, pose analysis forced on).
- Render worker: ≤ 20 s p95, cancellable; ≤ 1 active render per candidate,
  ≤ 2 retries; failures keep the illustration ("Try-on didn't work · Retry").
- Body photos and renders in a separate store with its own key, never on the
  public CDN, signed URLs ≤ 10 min (TAC-08.3).
- Withdrawing consent cancels queued jobs within 1 minute (TAC-08.4).
- Vendor (if any) signs no-retention and no-training terms (TAC-08.5).

## Mobile follow-up (later task, not Phase 1)

Replace the coming-soon sheet with the add-body-photo step, body consent, and
render progress; tests for AC-08.5–08.11.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created; Phase 1 try-on is "coming soon". |
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Try-on endpoint replaced by the `vton_jobs` command row (spec v2.8); `TryOnRenderer` port with a fake. |
