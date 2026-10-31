# BE-005: Retire the dating mock API

> **Owner:** Backend Developer  
> **Status:** Draft · the change record it needed is [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) (awaiting human approval)  
> **Track / priority:** M · **1** (after [BE-010](BE-010-restore-backend-gate.md), before [BE-011](BE-011-mock-platform-core.md))  
> **Must land before:** BE-011 and every wardrobe endpoint, so none is built next to dating ones  
> **Raised by:** TASK-004 green, dating-confusion audit ([CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md))

## Why

The mobile app is now a lookbook generating and matching app (Phase 1 is
green: Index Pieces → Archive → Gu Match Fits). The FastAPI mock in
`backend/` still serves the retired **dating** product. Because the wardrobe
spec reuses words like "Gu Match", "swipe", "match %" and `LIKE_SAVE` (see
[README › Read this first](README.md#read-this-first-garblo-is-not-a-dating-app)),
a developer could reasonably extend these endpoints for Gu Match. That would
mix two products in one API.

## What is dating-only today

| Path | Content |
|---|---|
| `backend/app/api/v1/endpoints/discovery.py` | `GET /api/v1/discovery` (candidate people), `GET /api/v1/profiles/{id}`, `POST /api/v1/swipes` (like / pass / superlike on a person) |
| `backend/app/api/v1/endpoints/matches.py` | `GET /api/v1/matches` placeholder |
| `backend/app/api/v1/endpoints/chat.py` | `GET /api/v1/chat/conversations` placeholder |
| `backend/app/api/v1/endpoints/auth.py` | `/api/v1/auth/status` placeholder (dating login; wardrobe identity is the anonymous JWT of spec T4, BE-001) |
| `backend/app/models/profile.py` | `Profile`, `SwipeRequest`, `SwipeResponse` |
| `backend/app/data/sample_data.py` | Sample people |
| `backend/tests/test_discovery.py` | Tests for the above |
| `backend/README.md` | Describes "discovery data, profile browsing, and swipe recording" |

Keep: `health.py` (`/health`, `/api/v1/health`), `config.py`, `main.py`.

## Scope

- A CHG that retires the dating mock API and records what is removed.
- Remove or move to an archive folder the files above; remove their router
  registration in `backend/app/api/router.py`.
- Rewrite `backend/README.md` for the wardrobe product: what the mock serves
  today (health only) and what comes next: the v2.8 sync contract
  (`POST /v1/sync/tx`, dev token, dev change feed) per CHG-014. The old plan of
  `/v1/studio`, `/v1/wardrobe`, `/v1/gu-match` REST routes was removed by spec v2.8.
- `app/main.py` title and description: "Garblo mock API", with no "discovery and
  profile data".
- `uv run pytest` stays green (health tests).

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| BE-005-S01 | `/health` and `/api/v1/health` still return `{"status": "ok", "service": "garblo-api"}` | `tests/test_health.py` (unchanged) |
| BE-005-S02 | `/api/v1/discovery`, `/api/v1/profiles/usr_01`, `POST /api/v1/swipes`, `/api/v1/matches`, `/api/v1/chat/conversations`, `/api/v1/auth/status` return 404 | `tests/test_retired_routes.py` |
| BE-005-S03 | The OpenAPI schema contains no `Profile`, `SwipeRequest` or `SwipeResponse` | `tests/test_retired_routes.py` |

## Anti-scope

- No wardrobe endpoints here (BE-002 … BE-004).
- No change to `apps/mobile/lib/`. The mobile dating feature tree (`apps/mobile/lib/features/discovery`
  and the placeholders) is unrouted and needs its own mobile CHG.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created from the TASK-004 dating-confusion audit. |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Covered by CHG-014; priority 1 in the mock track; scenarios added; README target updated for spec v2.8. |
