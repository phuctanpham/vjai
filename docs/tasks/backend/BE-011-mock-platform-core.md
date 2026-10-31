# BE-011: Mock platform core — sync row models, IDs, clock, in-memory store, dev token

> **Owner:** Backend Developer  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval  
> **Track / priority:** M · **2** (after BE-010 and BE-005)  
> **Source:** Flow Spec v2.8 T4 › Phone schema, Sync model, R8 · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §3 D01–D02, §4 · [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) phone schema v1 · [CHG-006](../../changes/CHG-006-phase-2-green-decisions.md) G-03

## Why

Every mock card needs the same foundation: typed rows for the phone tables, the
table classes that decide who may write what, IDs that match the phone
bit-for-bit, a clock that is not the wall clock, owner-scoped storage with no
database, and an owner identity. Building them once keeps BE-012…BE-018 small, and
lets BE-020 swap the store for MongoDB without touching the rules.

## Contract

### Table classes (who writes)

| Class | Tables in the mock | Phone may |
|---|---|---|
| Read-write | `profiles`, `wardrobe_items`, `upload_batches`, `media_assets`, `interactions`, `attachments` | PUT, PATCH (allow-listed fields), DELETE where the card allows |
| Insert-only | `wear_events`, `consents` (PATCH of `revoked_at` only) | PUT |
| Phone-PATCH-only | `extracted_items` (`value`, `last_worn_input`) | PATCH |
| Command rows | `gu_match_sessions`, `privacy_requests`, `vton_jobs` (refused until AI-002) | PUT; PATCH of its own fields |
| Read-only | `item_types`, `ai_processing_jobs`, `outfit_candidates`, `attachment_tickets` | Nothing |

Columns are exactly those of `apps/mobile/lib/core/storage/phone_schema.dart`
(schema v1), plus the handbook's columns for tables or fields that v1 lacks
(`profiles`, `attachments`, `attachment_tickets`, `privacy_requests`,
`gu_match_sessions.status/context/event_title/window_start/window_end/city_id/ambient_temp_c/expires_at`).
Handbook-only columns are **optional** on input, so the phone's v1 rows are accepted
until [TASK-011](../mobile/TASK-011-phone-schema-v2-alignment.md) lands. Types follow
data-schema.md §2: `TEXT`/`INTEGER`/`REAL`, ISO-8601 dates, 0/1 booleans, JSON as text.

### Modules

| Module | Content |
|---|---|
| `app/sync/schema.py` | One Pydantic v2 model per table (column names as field names, no aliases), `TableClass`, writable-field allow-lists |
| `app/sync/ids.py` | `is_object_id(s)`; `deterministic_object_id(parts)`, a port of the Dart `deterministicObjectId` (length-prefixed parts, two FNV-1a-64 passes); `stable_hash(bytes)` (FNV-1a-32) |
| `app/core/clock.py` | `Clock` protocol; `FixedClock` (default `2026-10-30T09:00:00Z`, or `GARBLO_MOCK_NOW`); a FastAPI dependency so tests and `/v1/mock/clock` replace it |
| `app/store/base.py`, `app/store/memory.py` | `Store` protocol: `get`, `put`, `patch`, `delete`, `query(table, owner, where)`, `transaction()` (all-or-nothing); `InMemoryStore` (dicts per owner per table, snapshot and rollback) |
| `app/auth/dev.py` | `POST /v1/auth/dev-token {user_id}` → `{token: "dev.<user_id>", user_id}`; `current_owner` dependency parses `Authorization: Bearer dev.<24 hex>` |
| `app/api/v1/endpoints/mock_controls.py` | `POST /v1/mock/reset`, `PUT /v1/mock/clock {now}`; 404 when `ENV=production` |
| `app/core/errors.py` | Error body `{"error": {"code", "message", "op_index"?}}` for every 4xx |

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| BE-011-S01 | `deterministic_object_id` equals the Dart output for the golden vectors (e.g. `[batch, asset, "OUTFIT_EXTRACTION"]`, a wear `[owner, date, signature]`, `["demo-seed", "seed_01"]`); order matters; `["ab","c"] != ["a","bc"]` | `tests/sync/test_ids.py` |
| BE-011-S02 | `is_object_id` accepts 24 lowercase hex characters only | `tests/sync/test_ids.py` |
| BE-011-S03 | Every phone-schema-v1 table and column has a model field with the same name, and nothing else is required (parity with `phone_schema.dart`, read as text) | `tests/sync/test_schema.py` |
| BE-011-S04 | A store transaction that raises leaves no partial rows; owners never see each other's rows | `tests/store/test_memory_store.py` |
| BE-011-S05 | `POST /v1/auth/dev-token` with a valid ObjectId returns a bearer token; a bad ID is 422; a request with no token, or a malformed one, is 401 `UNAUTHENTICATED` | `tests/test_auth_dev.py` |
| BE-011-S06 | `PUT /v1/mock/clock` changes `created_at` of server-written rows; nothing reads the wall clock (a test patches `datetime.now` to raise) | `tests/test_mock_controls.py` |
| BE-011-S07 | With `ENV=production`, `/v1/mock/*` and `/v1/auth/dev-token` return 404 | `tests/test_mock_controls.py` |

Golden vectors for S01: run the Dart function once and record the outputs in the
test, with a comment naming the commit. They move to `contracts/fixtures/` with
[TASK-012](../mobile/TASK-012-shared-golden-fixtures.md).

## Allowed files

`backend/app/sync/`, `backend/app/store/`, `backend/app/auth/`, `backend/app/core/`,
`backend/app/api/v1/endpoints/mock_controls.py`, `backend/app/api/router.py`,
`backend/app/config.py`, `backend/tests/` (new files above), report.

Also fix in `config.py`: `cors_origins` is annotated `list[str]` but holds a tuple,
and `allow_credentials=True` with origin `*` is not a valid CORS pairing. Use an
explicit dev origin list from `GARBLO_CORS_ORIGINS` and `allow_credentials=False`.

## Anti-scope

No JWT, crypto or JWKS (BE-019). No database driver. No `POST /v1/sync/tx` (BE-012).
No new dependency.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created |
