# BE-013: Mock change feed (Sync Streams stand-in), catalog and demo seed

> **Owner:** Backend Developer  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval (dev-only deviation from DB5)  
> **Track / priority:** M · **4**  
> **Blocked by:** [BE-012](BE-012-mock-write-handler.md)  
> **Source:** Flow Spec v2.8 T4 › Sync Streams, Sync model (write checkpoints); spec P3-02, P3-03 · [BE-003](BE-003-wardrobe-and-wear-api.md) seed list

## Why

On the real platform the phone reads everything through PowerSync Sync Streams,
which need MongoDB change streams. The mock has no database, so it serves the same
rows through a dev-only, ordered change feed. The mobile dev connector
([TASK-010](../mobile/TASK-010-mock-backend-integration.md)) applies these changes
to the local database, so repositories and screens see server rows exactly as they
will from PowerSync.

## Contract

```http
GET /v1/mock/sync/changes?after=<checkpoint>&streams=catalog,my_wardrobe,my_studio,my_studio_jobs,my_decks,my_files&limit=500
Authorization: Bearer dev.<user_id>

200 { "checkpoint": 57, "has_more": false,
      "changes": [ { "seq": 51, "stream": "my_studio_jobs", "op": "PUT", "type": "ai_processing_jobs",
                     "id": "<24 hex>", "data": { ...full row... } },
                   { "seq": 52, "stream": "my_studio", "op": "DELETE", "type": "media_assets", "id": "...", "data": null } ] }
```

- Stream names and membership are those of T4 › Sync Streams: `catalog` (all
  users), `my_wardrobe`, `my_studio` and `my_studio_jobs` (open batches only, so a
  COMPLETED batch's rows produce DELETE changes), `my_decks` (sessions with
  `recent = 1`), `my_files`. `my_progress`, `my_community` and `deck_history` are out
  of scope.
- `data` is the full row after the change (PowerSync syncs whole rows); DELETE has `data: null`.
- The phone's own applied writes appear too, after normalisation (owner filled,
  server fields added), so the phone can treat the feed as the authority.
- **Write checkpoint:** a `/v1/sync/tx` response's `checkpoint` is ≤ the feed's
  checkpoint once that tx and its side effects are visible.
- Seeds: `POST /v1/mock/seed {"preset": "catalog"}` (applied on reset) and
  `{"preset": "demo_wardrobe"}`. Item types match `ItemTypeCatalog`; the 9 demo items match
  `MockWardrobeRepository.seeded` and the phone's `demo_seed.dart` IDs
  (`deterministic_object_id(["demo-seed", "seed_NN"])`), with dates relative to the mock clock.
  Read both from `contracts/fixtures/` once [TASK-012](../mobile/TASK-012-shared-golden-fixtures.md) exports them.

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| BE-013-S01 | After reset, `after=0&streams=catalog` returns every item type once, in a stable order | `tests/test_change_feed.py` |
| BE-013-S02 | A PUT through `/v1/sync/tx` appears in the owner's feed with `user_id` filled; never in another owner's | `tests/test_change_feed.py` |
| BE-013-S03 | `after=<checkpoint>` returns only newer changes; paging with `limit` and `has_more` loses and repeats nothing | `tests/test_change_feed.py` |
| BE-013-S04 | The tx response checkpoint ≤ the feed checkpoint, and every side-effect row of that tx has `seq` ≤ it | `tests/test_change_feed.py` |
| BE-013-S05 | A batch moving to COMPLETED emits DELETE changes for its `my_studio` and `my_studio_jobs` rows | `tests/test_change_feed.py` |
| BE-013-S06 | `demo_wardrobe` seeds 9 items with the phone's IDs, names and type codes; seeding twice changes nothing | `tests/test_mock_seed.py` |
| BE-013-S07 | Unknown stream → 422; no token → 401; `ENV=production` → 404 | `tests/test_change_feed.py` |

## Allowed files

`backend/app/api/v1/endpoints/mock_sync.py`, `backend/app/sync/streams.py`,
`backend/app/data/catalog.py`, `backend/app/data/demo_wardrobe.py`,
`backend/app/api/v1/endpoints/mock_controls.py`, `backend/tests/test_change_feed.py`,
`backend/tests/test_mock_seed.py`, report.

## Anti-scope

No WebSocket, no SSE, no PowerSync protocol emulation. No `deck_history`. No
seeded decks (decks come from BE-015).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created |
