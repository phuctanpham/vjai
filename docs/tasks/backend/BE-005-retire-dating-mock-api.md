# BE-005: Retire the dating mock API

> **Owner:** Backend Developer  
> **Status:** Proposed · needs a change record approved by the human (TASK-001 forbids deleting or reinterpreting the dating docs silently)  
> **Must land before:** [BE-002](BE-002-studio-pipeline.md), so no wardrobe endpoint is built next to dating ones  
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
  today (health only) and where wardrobe endpoints will go
  (`/v1/studio`, `/v1/wardrobe`, `/v1/gu-match`, per BE-001's decision).
- `uv run pytest` stays green (health tests).

## Anti-scope

- No wardrobe endpoints here (BE-002 … BE-004).
- No change to `apps/mobile/lib/`. The mobile dating feature tree (`apps/mobile/lib/features/discovery`
  and the placeholders) is unrouted and needs its own mobile CHG.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created from the TASK-004 dating-confusion audit. |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
