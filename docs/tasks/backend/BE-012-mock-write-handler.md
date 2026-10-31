# BE-012: Mock write handler — `POST /v1/sync/tx`

> **Owner:** Backend Developer  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval  
> **Track / priority:** M · **3**  
> **Blocked by:** [BE-011](BE-011-mock-platform-core.md)  
> **Source:** Flow Spec v2.8 T4 › Write path, Side effects; T2 › Invariants I1, I2, I4, I6 · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §2 C04, §3 D05 · spec P4-B02, P4-B03 (this card is their mock)

## Why

`uploadData()` on the phone sends one CRUD transaction at a time to this endpoint,
and that is the only way phone data reaches the server (DB5). The mobile dev
connector ([TASK-010](../mobile/TASK-010-mock-backend-integration.md)) needs the
real accept/reject behaviour, so the queue logic (complete on 2xx/4xx, retry on 5xx)
can be tested before any database exists.

## Contract

```http
POST /v1/sync/tx
Authorization: Bearer dev.<user_id>
{ "tx_id": 42,
  "ops": [ { "op": "PUT",   "type": "upload_batches", "id": "<24 hex>", "data": { ... } },
           { "op": "PATCH", "type": "upload_batches", "id": "<24 hex>", "data": { "status": "SANITIZING" } } ] }
```

`op`, `type`, `id` and `data` follow the PowerSync `CrudEntry` JSON. Confirm the
exact field names against the SDK version chosen in BE-001, and record any
difference in the report.

| Result | Status | Body | Phone does |
|---|---|---|---|
| Applied | 200 | `{"applied": true, "replayed": false, "tx_id", "checkpoint"}` | `tx.complete()` |
| Replay of an applied tx (same owner, `tx_id`, ops hash) | 200 | `{"applied": true, "replayed": true, ...}` | `tx.complete()` |
| Same `(owner, tx_id)` with different ops | 409 | `TX_ID_REUSED` (CHG-014 Q1) | complete; log |
| Rule broken | 401/403/409/422 | `{"error": {"code", "message", "op_index"}}` | complete (never block the queue); the row is corrected by the next sync |
| Injected fault (`/v1/mock/scenarios {"sync": "FAIL_5XX_ONCE"}`) | 503 | `RETRY_LATER` | retry |

Rules, checked for **every** op before **any** op is applied (one store transaction):

| Rule | Code |
|---|---|
| `data.user_id`, when present, equals the token owner; a PUT gets `user_id` = owner if missing | `OWNER_MISMATCH` 403 |
| `type` is a known table and its class allows the op (BE-011 table classes) | `TABLE_NOT_WRITABLE` 403 |
| PATCH touches only allow-listed fields | `FIELD_NOT_WRITABLE` 422 |
| Insert-only tables reject PATCH (except `consents.revoked_at`) and DELETE | `APPEND_ONLY` 422 |
| `id` is an ObjectId; `data` validates against the table model | `INVALID_ID` / `SCHEMA_VIOLATION` 422 |
| PUT of an existing `id` from the same owner is "already applied" (deterministic IDs, BE-006) | — (no-op) |
| PUT of an `id` owned by another user | `OWNER_MISMATCH` 403 |
| I1: `upload_batches` → SANITIZING needs 1–10 non-removed `media_assets` and a non-revoked `consent_id` of the owner | `PHOTO_COUNT_OUT_OF_RANGE`, `CONSENT_REQUIRED` 422 |
| I2: `media_assets.mime_type` ∈ {`image/jpeg`, `image/png`}; ≤ 10 non-removed per batch | `UNSUPPORTED_MIME`, `PHOTO_COUNT_OUT_OF_RANGE` 422 |
| I4: → QUEUED_FOR_AI needs at least one `req_*` = 1 | `NO_ANALYSIS_TASK` 422 |
| Batch status moves only along the T2 state machine | `ILLEGAL_TRANSITION` 409 |
| `wardrobe_items.type_code` exists in `item_types` | `UNKNOWN_TYPE_CODE` 422 |
| `wear_events.items` has 1–12 entries, each owned and not archived (I6) | `ITEM_NOT_OWNED` 422 |

After commit the handler dispatches side effects through a registry
(`app/sync/effects.py`: table + op + status → handler). BE-014…BE-018 register
handlers; this card ships the registry with no handlers. Every applied op and every
side-effect row is appended to the change log that BE-013 serves, and the
response's `checkpoint` is the log position after them.

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| BE-012-S01 | A valid PUT is applied and returns a checkpoint; reading the store shows the row with `user_id` = owner | `tests/test_sync_tx.py` |
| BE-012-S02 | Replaying the same tx is a no-op (`replayed: true`); the change log does not grow | `tests/test_sync_tx.py` |
| BE-012-S03 | Same `tx_id` with different ops → 409 `TX_ID_REUSED` | `tests/test_sync_tx.py` |
| BE-012-S04 | Atomicity: op 2 of 3 breaks a rule → 4xx with `op_index: 1`; ops 1 and 3 are not applied | `tests/test_sync_tx.py` |
| BE-012-S05 | Writes to read-only tables (`ai_processing_jobs`, `outfit_candidates`, `item_types`, `attachment_tickets`) → 403 | `tests/test_sync_tx_rules.py` |
| BE-012-S06 | PATCH of a non-allow-listed field (e.g. `extracted_items.ai`, `outfit_candidates.swipe_status`) → 422 | `tests/test_sync_tx_rules.py` |
| BE-012-S07 | `wear_events` PATCH/DELETE → 422 `APPEND_ONLY`; `consents` PATCH of `revoked_at` is applied | `tests/test_sync_tx_rules.py` |
| BE-012-S08 | Duplicate PUT of a deterministic wear-event ID from the same owner is applied once | `tests/test_sync_tx_rules.py` |
| BE-012-S09 | Another owner's ID or `user_id` → 403 `OWNER_MISMATCH` | `tests/test_sync_tx_rules.py` |
| BE-012-S10 | I1, I2 and I4 negatives each return their code; their positives pass | `tests/test_sync_tx_invariants.py` |
| BE-012-S11 | Illegal batch transition (DRAFT → AWAITING_REVIEW) → 409 | `tests/test_sync_tx_invariants.py` |
| BE-012-S12 | Wear event with an archived or foreign item → 422 `ITEM_NOT_OWNED` | `tests/test_sync_tx_invariants.py` |
| BE-012-S13 | `FAIL_5XX_ONCE` returns 503 once, then the same tx is applied | `tests/test_sync_tx.py` |

## Allowed files

`backend/app/api/v1/endpoints/sync.py`, `backend/app/sync/` (handler, rules,
effects registry, change log), `backend/app/api/router.py`, `backend/tests/test_sync_tx*.py`, report.

## Anti-scope

No side effects (BE-014…BE-018). No MongoDB (BE-020). No rejection notifications
(the spec's `sync_rejections` → `notifications` path needs the notifications table;
record rejections in memory only). No Community or rewards tables.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created |
