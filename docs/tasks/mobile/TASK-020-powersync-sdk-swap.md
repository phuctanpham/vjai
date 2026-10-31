# TASK-020: Swap plain SQLite for the PowerSync SDK

> **Phase:** P3 · P3-04  
> **Track:** R (real platform)  
> **Status:** Blocked · [BE-001](../backend/BE-001-platform-decision.md) (platform), dependency approval (`powersync`, `powersync_sqlcipher`), [BE-006](../backend/BE-006-phone-schema-sync-parity.md) (Sync Streams deployed)  
> **Owner:** App Developer · Engineering Manager (plan, decisions.md entry)  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) F-17)  
> **Dependencies:** TASK-010, TASK-011, TASK-013, TASK-014, TASK-017  
> **Source:** Flow Spec v2.8 T4 › DB3, Phone schema, Write path · T6 › P3-04 ("All P2 tests still pass on PowerSync; queued writes survive restarts") · decisions.md D-006, D-009

## Why

D-006 chose `sqlite_async` because PowerSync's Dart SDK is built on it, so the swap replaces
the database object, not the repositories. Three things in the current storage layer do not
carry over, and each needs a plan before the swap:

| Today | Under PowerSync | Plan |
|---|---|---|
| `GarbloDatabase` runs `CREATE TABLE` and `PRAGMA user_version` migrations | PowerSync creates views from a `Schema`; there are no user migrations for synced tables | Generate `Schema` from `PhoneSchema` (one source, TASK-011). Local data is not migrated: P2/P3 builds are internal (T6) |
| `GarbloOpenFactory` sends `PRAGMA key` | `powersync_sqlcipher` takes the key in its open factory | Keep the key in `InstallIdentity`; move the pragma to the SDK's factory |
| `crud_queue` + triggers (TASK-017), feed apply (TASK-010) | `ps_crud` and the sync stream | Delete both; `DevConnector.uploadData` becomes `GarbloConnector.uploadData` over the same `SyncTransport` |

## Scope

- `PowerSyncDatabase` opened in `bootstrap.dart` behind a `LocalStore` interface, so tests keep
  opening plain SQLite through `local_db.dart` (no PowerSync service in unit tests).
- `GarbloConnector`: `fetchCredentials` from `CredentialsSource` (dev JWT in P3, TASK-023 in
  P4); `uploadData` holds the queue in P3 (download-only) and drains it in P4.
- Local-only tables (`session_draft`, `ui_state`, `fake_*`, `sync_rejections`) as
  `Table.localOnly`.
- "Delete all" calls `disconnectAndClear`, then deletes files.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-020-S01 | The generated PowerSync `Schema` equals `PhoneSchema` table for table, column for column, local-only flags included | Unit |
| TASK-020-S02 | Every repository contract suite passes against a PowerSync database opened without a service (offline mode) | Contract |
| TASK-020-S03 | Writes made offline appear in `ps_crud` with the same ops as TASK-017's queue (same fixtures) | Integration |
| TASK-020-S04 | Queued writes survive a restart; P3 never calls the write handler | Integration |
| TASK-020-S05 | Catalog and seeded wardrobe arrive from the dev PowerSync service and two phones converge ≤ 10 s (with TASK-022) | Device / staging, tagged `live_powersync` |
| TASK-020-S06 | The database file is encrypted (cannot be opened without the key) | Integration |

## Anti-scope

No write handler calls in P3 (P4, TASK-024). No user-data migration from P2 builds.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Blocked) by the App Developer |
