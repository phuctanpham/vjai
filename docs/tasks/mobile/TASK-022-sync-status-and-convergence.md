# TASK-022: Sync status, Sync now and the convergence suite

> **Phase:** P3 · P3-05 (status part), P3-07  
> **Track:** M (two phones against the mock) → R (two devices against PowerSync)  
> **Status:** Blocked · the UI needs a spec from the Product Manager (P3-05 is "Needs spec"; DOC-004 Q9). The convergence suite (S04–S06) can start after TASK-010  
> **Owner:** App Developer · Product Manager (UI spec)  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Dependencies:** [TASK-010](TASK-010-mock-backend-integration.md), [TASK-017](TASK-017-local-upload-queue.md)  
> **Source:** Flow Spec v2.8 T6 › P3-05, P3-07 · T3 › Budgets (replication lag ≤ 1 s) · UC-04 TAC-04.4 · DB handbook C03-01, C10-01, DB2 ("Sync now remains as a button")

## Why

The P3 demo needs three things: local edits show a pending-upload count, the user sees whether
the phone is connected or offline and when it last synced, and two phones converge. No screen
for this is specified yet.

## Scope

- `SyncStatus` domain state: `connected | connecting | offline`, `lastSyncedAt`,
  `pendingUploads`, `lastError`. A `syncStatusProvider` reads it from the connector. Widgets
  never read the connector directly.
- UI per the APM's spec (proposed home: Avatar › Privacy & data or the account hub, gap ④).
  "Sync now" forces one download and one upload pass.
- Convergence harness in `test/helpers/`: two local databases (two "phones", one owner) against
  one recorded or live mock.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-022-S01 | Offline: three edits show "3 changes waiting to upload" (copy per spec) | Widget (both layouts) |
| TASK-022-S02 | Back online: status moves offline → connecting → connected; `lastSyncedAt` updates | ViewModel |
| TASK-022-S03 | Sync now runs one pass and is disabled while it runs | ViewModel + widget |
| TASK-022-S04 | Two phones, one owner: a Piece saved on phone A appears on phone B after one sync pass each | Integration (mock) |
| TASK-022-S05 | Offline edits on both phones to different fields of one row converge per field (C03-06); a delete wins | Integration (mock) |
| TASK-022-S06 | A seeded change (mock `/v1/mock/seed`) reaches both phones; Track R measures lag ≤ 1 s p95 on staging (tagged `live_powersync`) | Integration |

## Anti-scope

No lag dashboard (DevOps, P3-07). No notifications (P4).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Blocked on UI spec) by the App Developer |
