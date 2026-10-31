# TASK-017: Local upload queue and pending count

> **Phase:** P3 · P3-04 (queue part)  
> **Track:** M (no network)  
> **Status:** Draft · needs CHG-015 approval and an implementation plan from the Engineering Manager  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Dependencies:** [TASK-011](TASK-011-phone-schema-v2-alignment.md), [TASK-014](TASK-014-upload-safe-write-shapes.md) · **Blocks:** TASK-010  
> **Source:** Flow Spec v2.8 T6 › P3 ("uploads queue locally, '3 changes waiting to upload'"), P3-04 · T4 › Pilot topology (`ps_crud`)

## Why

P3 is download-only: every write the user makes must wait in a queue that survives restarts,
and flush in P4. PowerSync keeps that queue in `ps_crud`. To test the connector (TASK-010) and
the pending count before the SDK is approved, the phone needs the same queue on plain SQLite.
Its shape must match PowerSync's, so TASK-020 can delete it without touching the connector.

## Scope

- A local-only `crud_queue` table: `id` (autoincrement order), `tx_id`, `op`
  (PUT/PATCH/DELETE), `type`, `row_id`, `data` (JSON of the changed columns only), `created_at`.
  Field names follow PowerSync `CrudEntry`, as BE-012 expects.
- Recording happens at the repository's write transaction, not in widgets. The ASEM plan picks
  one of:

  | Option | How | Trade-off |
  |---|---|---|
  | A. SQL triggers on synced tables | `AFTER INSERT/UPDATE/DELETE` triggers write `crud_queue` rows | Mirrors PowerSync exactly; triggers must skip feed writes (a `sync_state.applying` flag) |
  | B. `QueuedConnection` decorator | Wraps `SqliteWriteContext`; repositories declare their ops | Explicit; relies on TASK-014's statement mapping |

  Recommendation: **A**. It matches how PowerSync records CRUD ops, so the queue shape is right
  by construction.
- Only phone-writable columns are recorded (TASK-011 classes). Local-only and `fake_*` tables
  are never recorded.
- `UploadQueue` interface in `core/sync/`: `next()`, `complete(txId)`, `pendingCount()`,
  `watchPendingCount()`.
- "Delete all" (TASK-008) empties the queue with the database. P4 replaces this with a
  `privacy_requests` row (TASK-027).

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-017-S01 | Saving 3 Pieces in one save is one transaction of 3 PUT entries with the wire values of TASK-013 | Repository |
| TASK-017-S02 | Editing one review draft queues one PATCH with only `value`; removing a tray photo queues one PATCH | Repository |
| TASK-017-S03 | Logging the same wear twice queues one PUT (deterministic ID; the second is a no-op) | Repository |
| TASK-017-S04 | Writes to `session_draft`, `fake_*`, `sync_state` and feed-applied rows queue nothing | Repository |
| TASK-017-S05 | The queue and its order survive a restart and an app kill mid-transaction (crash image: all or none) | Integration (`offline_reliability`) |
| TASK-017-S06 | `pendingCount` counts transactions; `watchPendingCount` emits after each commit and after `complete` | Unit |

## Anti-scope

No network (TASK-010). No pending-count UI (TASK-022). No conflict handling; the server decides
(C03-06).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer; split from TASK-010 |
