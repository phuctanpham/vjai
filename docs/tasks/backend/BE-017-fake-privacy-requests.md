# BE-017: Fake privacy requests — erasure and body-consent withdrawal in memory

> **Owner:** Backend Developer  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval  
> **Track / priority:** M · **9**  
> **Blocked by:** [BE-012](BE-012-mock-write-handler.md), [BE-013](BE-013-mock-change-feed.md)  
> **Source:** UC-09 AC-09.4…09.6, TAC-09.4 · Flow Spec v2.8 T4 › Side effects (privacy_requests) · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §13 LC-01…LC-04, LC-07, LC-11 · mock of [BE-007](BE-007-privacy-erasure-and-export.md)

## Why

Today the phone erases data locally only (TASK-008). Once data syncs, erasure is a
`privacy_requests` command row. The handbook adds an important ordering rule
(LC-04): the phone wipes itself **after** the write handler acknowledges the
request, so an offline erasure is never lost. The mobile team needs a server that
acknowledges, purges and reports, to build that flow.

## Behaviour

| Phone writes | Mock side effect | Feed |
|---|---|---|
| `privacy_requests` PUT `scope=BODY` | In the request's tx: set `revoked_at` on the owner's body consents (`includes_body=1`); delete `BODY_REFERENCE` batches and their assets; `status=COMPLETED` | DELETEs, consent patch, request status |
| `privacy_requests` PUT `scope=ALL` | In the tx: revoke consents, mark open batches `DELETED_BY_USER`, cancel jobs; then purge every row and file of the owner, keeping only the request row; `status=IN_PROGRESS` → `COMPLETED` | DELETE for every synced row; request status |
| `privacy_requests` PUT `scope=EXPORT` | `status=FAILED` with reason `NEEDS_SPEC` (gap ④, UC-19) | request status |
| Same request replayed | No-op (TAC-09.4 idempotent) | — |

A proof function `remaining_rows(owner)` returns a per-table count, which must be
0 after ALL (TAC-09.2 proof query, mock version). Events `erasure_requested{scope}`
and `erasure_completed{duration_ms}` go to an in-memory event log with no personal
data (TAC-09.6).

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| BE-017-S01 | ALL on a seeded owner leaves `remaining_rows` = 0 everywhere, except the request row | `tests/test_privacy_effects.py` |
| BE-017-S02 | Another owner's rows are untouched | `tests/test_privacy_effects.py` |
| BE-017-S03 | An in-flight batch (`HOLD` scenario) becomes `DELETED_BY_USER`, and its held jobs never produce drafts after release (AC-09.6) | `tests/test_privacy_effects.py` |
| BE-017-S04 | BODY revokes body consents only; wardrobe items stay | `tests/test_privacy_effects.py` |
| BE-017-S05 | Replay is a no-op; the request acknowledges with a checkpoint the phone can wait for (LC-04) | `tests/test_privacy_effects.py` |
| BE-017-S06 | The event log holds scope and duration only: no IDs other than the request ID, and no names | `tests/test_privacy_effects.py` |

## Allowed files

`backend/app/workers/privacy.py`, `backend/app/sync/effects.py` (registration),
`backend/tests/test_privacy_effects.py`, report.

## Anti-scope

No export file (gap ④), no account deletion with grace period (S-19.4), no backups,
no audit store beyond the in-memory event log.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created |
