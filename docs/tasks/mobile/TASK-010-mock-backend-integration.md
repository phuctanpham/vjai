# TASK-010: Sync transport and dev connector to the mock backend

> **Phase:** P3 (mock track of [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) and [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Track:** M (recorded responses, then the live Track M mock)  
> **Status:** Draft · needs CHG-014/015 approval, an implementation plan from the Engineering Manager, and the dependency decision below  
> **Owner:** App Developer (code) · Engineering Manager (plan, dependency entry)  
> **Raised by:** Backend Developer, 2026-10-30; narrowed by the App Developer, 2026-10-31  
> **Dependencies:** [BE-012](../backend/BE-012-mock-write-handler.md), [BE-013](../backend/BE-013-mock-change-feed.md), [TASK-017](TASK-017-local-upload-queue.md) (the queue it drains), [TASK-016](TASK-016-retire-legacy-mobile-code.md) (removes the placeholder `ApiClient`) · **Blocks:** TASK-018, TASK-019, TASK-021…TASK-027

## Why

The app has no way to talk to a server. `ApiClient` is a placeholder with only `get` and
`post`; TASK-016 deletes it. No HTTP package is approved: decisions.md lists `http` as
"proposed in BL-006, not yet approved", and BL-006 is an archived dating item.

The mock backend (BE-011…BE-018) serves the spec v2.8 contract without MongoDB or PowerSync.
This task builds the two halves of a PowerSync connector against it: `uploadData`, which drains
the local queue to `POST /v1/sync/tx`, and a download loop that applies the dev change feed.
When PowerSync arrives (TASK-020), only the download half is replaced. The upload half becomes
the real `uploadData`.

## Decision needed first (Engineering Manager)

| Option | Pros | Cons |
|---|---|---|
| A. `dart:io` `HttpClient` inside `core/sync/` | No dependency; Android, iOS, Windows and macOS are all `dart:io` platforms | More code; must stay out of ViewModels and widgets (architecture.md §2) |
| B. Approve `http` (decisions.md entry) | Small and standard; `MockClient` for unit tests | A new dependency |

Recommendation: **B**. Its `MockClient` keeps tests free of the network
(tdd.md §3), and it is the package the PowerSync examples use.

## Scope

- `core/sync/sync_transport.dart`: `SyncTransport` interface:
  `applyTransaction(tx) → TxResult(applied | replayed | rejected(code, opIndex) | retryable)`,
  `fetchChanges(after, streams) → ChangePage`. `HttpSyncTransport` implements it.
- `core/sync/dev_connector.dart`:
  - **Upload.** Takes the next transaction from the TASK-017 queue. Completes it on 2xx and 4xx
    (a 4xx is recorded through TASK-024's hook; this card only stores it). Keeps it on 5xx and
    network errors, with backoff up to 5 tries (C08-04). One transaction per call, in order.
  - **Download.** Applies feed changes to the local database in one transaction per page:
    PUT = replace the full row, DELETE = delete. Applied rows are **not** re-queued for upload.
    The checkpoint is stored in a local-only `sync_state` table.
  - Write checkpoints: after an upload, server data older than that transaction's checkpoint is
    not shown over newer local writes (C03-07).
- Credentials: a `CredentialsSource` interface. The dev token comes from
  `POST /v1/auth/dev-token` with the install owner ID; TASK-023 replaces it.
- Off by default. Enabled by `--dart-define=GARBLO_BACKEND=mock` and `GARBLO_BACKEND_URL`.
  Production builds never contain the `/v1/mock/*` calls (CHG-014: dev-only deviation from DB5).

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-010-S01 | A queued PUT is sent as `{tx_id, ops[{op, type, id, data}]}` with the bearer token; 200 completes the transaction | Unit (`MockClient`) |
| TASK-010-S02 | 4xx completes the transaction and records the rejection; 5xx and network errors keep it queued and retry with backoff; the 6th failure stops retrying until the next sync | Unit |
| TASK-010-S03 | Feed pages are applied in order and atomically; the checkpoint survives a restart; a repeated page changes nothing; applied rows add nothing to the upload queue | Unit (`local_db.dart`) |
| TASK-010-S04 | A row the phone wrote, then normalised by the server (owner filled, server fields added), replaces the local row without losing a newer local edit (write checkpoint) | Unit |
| TASK-010-S05 | With the flag off, every existing test passes unchanged, and no `core/sync/` code runs | Regression |
| TASK-010-S06 | Live: tagged `live_backend` (skipped by default), S01–S04 run against `uv run uvicorn app.main:app` with `/v1/mock/reset` between tests | Integration |

Recorded responses come from the backend's contract tests (BE-012, BE-013) and are saved as JSON
in `contracts/fixtures/sync/` ([TASK-012](TASK-012-shared-golden-fixtures.md)). The Flutter suite
needs no running server.

## Anti-scope

No PowerSync SDK (TASK-020). No real auth (TASK-023). No attachment bytes (TASK-021, TASK-025).
No server-result screens (TASK-018). No sync status UI (TASK-022).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created (Draft) by the Backend Developer for the App Developer and the ASEM |
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Narrowed by the App Developer: the queue moved to TASK-017, the Flow A/B journeys (old S04, S05, S07) to TASK-018; added the write-checkpoint scenario and retry cap |
