# TASK-024: Upload rejections, retries and "Couldn't save · Fix"

> **Phase:** P4 · P4-M02  
> **Track:** M (BE-012 rejection codes) → R (BE-020 + rejection notifications)  
> **Status:** Draft · needs CHG-015 approval, a UI spec for the Fix affordance (DOC-004 Q6) and an implementation plan  
> **Owner:** App Developer · Product Manager (copy, placement)  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Dependencies:** [TASK-010](TASK-010-mock-backend-integration.md), [TASK-017](TASK-017-local-upload-queue.md)  
> **Source:** Flow Spec v2.8 T4 › Write path (rejection row) · T6 › P4-M02 ("pending count drains to zero online") · DB handbook C04-09, NT-05, §12 open item (rejections before `my_progress` ships)

## Why

A 4xx must never block the queue, so the transaction is completed and the user's local row is
"corrected by the next sync". From the user's side, though, an edit simply vanishes. The spec
routes rejections to a notification through `my_progress`, which ships only with Flow C. The
handbook says the pilot needs "a small stream or a local banner" until then.

## Scope

- Local-only `sync_rejections` table: `tx_id`, `type`, `row_id`, `code`, `message`,
  `op_index`, `created_at`, `dismissed`. Written by the connector on every 4xx.
- `RejectionRepository`: `watchOpen()`, `dismiss(id)`. Each feature maps `(type, row_id)` to
  its screen. A Piece opens the Archive; a batch opens the Studio.
- Track M: a local banner. Track R: the server's `notifications` row replaces the local one,
  and the local row is dismissed when its notification syncs (no duplicates).
- Error codes map to plain copy. No raw code is shown.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-024-S01 | Each BE-012 rejection code (`OWNER_MISMATCH`, `FIELD_NOT_WRITABLE`, `APPEND_ONLY`, `ILLEGAL_TRANSITION`, `ITEM_NOT_OWNED`, …) from the recorded fixtures yields one `sync_rejections` row and the queue moves on | Unit |
| TASK-024-S02 | The banner names what could not be saved and "Fix" opens the affected screen; dismissing hides it after a restart | Widget (both layouts) |
| TASK-024-S03 | After a rejected Piece PUT, the next feed page removes the local Piece and the Archive count follows (I9) | Integration (mock) |
| TASK-024-S04 | Online with 20 queued transactions, the pending count drains to zero; one 503 midway is retried, not dropped | Integration (mock `FAIL_5XX_ONCE`) |
| TASK-024-S05 | Track R: a server `notifications` rejection replaces the local banner without showing it twice | Integration, tagged `live_backend` |

## Anti-scope

No notification inbox (gap ⑤). No push.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
