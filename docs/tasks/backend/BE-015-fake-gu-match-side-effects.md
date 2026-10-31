# BE-015: Fake Gu Match side effects — session, context cards, deck, swipes, swap

> **Owner:** Backend Developer  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval  
> **Track / priority:** M · **7**  
> **Blocked by:** [BE-012](BE-012-mock-write-handler.md), [BE-013](BE-013-mock-change-feed.md), [AI-005](AI-005-model-ports-and-fakes.md)  
> **Source:** UC-05…UC-08 · Flow Spec v2.8 T4 › Side effects (gu_match_sessions, interactions) · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §8 GM-01…GM-05 · spec P4-B07 (this is its mock)

> **⚠ Not a dating API.** Gu Match drafts **Fits** (outfits) from the user's own
> Pieces. A swipe decides on a Fit, never on a person. See
> [README › Read this first](README.md#read-this-first-garblo-is-not-a-dating-app).

## Why

This is the mock of [BE-004](BE-004-gu-match-api.md). In P4 the server owns deck
generation, and the phone writes only the session request and its interactions.
The mock lets the mobile team build that P4 shape now: insert a REQUESTED session,
watch context cards arrive in the session row, then swipe a deck that synced down.

## Behaviour

| Phone writes | Mock side effect | Rows in the feed |
|---|---|---|
| `gu_match_sessions` PUT (`path`, `occasions`, `raw_prompt`, optional derived context) | Validate C1/C10 (≤ 5 known occasions, prompt ≤ 280, `PROMPT_LED` iff any chip or text); count eligible items (I9) | session patches, in order: `status=GATHERING` + `eligible_item_count`, `owned_only=1`, `deck_size=8`, `recent=1`, `expires_at` (mock now + 90 days) |
| … eligible = 0 | `status=NO_ELIGIBLE_ITEMS`; no deck (replaces 409 `NO_ELIGIBLE_ITEMS`) | session |
| … eligible > 0 | One `context` patch per card, in the fixed order occasion, weather, rain, commute (`ContextSource` fakes); a missing source yields `is_missing=true`, never a failed session (TAC-06.2); then `status=ANALYZED` | session (`context` JSON grows card by card) |
| … deck | `OutfitGenerator` → ≤ 8 `outfit_candidates` (`deck_order`, `title`, `match_pct`, `highlight_reason`, `visual_mode=COLLAGE_FLATLAY`, `swipe_status=PENDING_SWIPE`, `items[{slot_role, item_id, name, days_unworn}]`), IDs `deterministic_object_id([session_id, str(deck_order)])`; then `status=DECK_READY` | candidates, session |
| `interactions` PUT `DISMISS_PASS` / `LIKE_SAVE` | `swipe_status` → `SWIPED_LEFT_PASSED` / `SWIPED_RIGHT_LIKED` | candidate |
| `interactions` PUT `CUSTOMIZE_EDIT` with `from_item_id`, `to_item_id` (ADJUST) | Same group, owned, not archived (TAC-08.6), else 422 `ITEM_NOT_OWNED` / `GROUP_MISMATCH`; recompute items and `match_pct` | candidate |
| `interactions` PUT `TRIGGER_VTON` | Logged only; try-on is AI-002 | — |

`days_unworn` uses the shared dormancy rules ([BE-016](BE-016-wear-rules-parity.md));
until BE-016 lands, the server counts days since `created_at` and `last_worn_estimate` only.

Status values `REQUESTED → GATHERING → ANALYZED → DECK_READY`, `NO_ELIGIBLE_ITEMS`,
`FAILED` are the DB handbook's GM-02. They are **not** in Flow Spec T2 › Enums, nor in
phone schema v1, which has no `status` or `context` column. Recorded in
[TASK-011](../mobile/TASK-011-phone-schema-v2-alignment.md).

Scenarios: `PUT /v1/mock/scenarios {"gu_match": "OK" | "WEATHER_MISSING" | "ALL_MISSING" | "FAIL"}`.

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| BE-015-S01 | Demo wardrobe + REQUESTED session → feed shows GATHERING, 4 context patches in order, ANALYZED, ≤ 8 candidates, DECK_READY | `tests/test_gu_match_effects.py` |
| BE-015-S02 | The deck equals the Dart generator's golden deck for the same wardrobe and clock (AI-005-S04 through the endpoint) | `tests/test_gu_match_effects.py` |
| BE-015-S03 | Empty or all-archived wardrobe → `NO_ELIGIBLE_ITEMS`, no candidates | `tests/test_gu_match_effects.py` |
| BE-015-S04 | `WEATHER_MISSING` → weather card `is_missing=true`, the deck is still built | `tests/test_gu_match_effects.py` |
| BE-015-S05 | Replaying the session PUT creates no second deck (TAC-05.6) | `tests/test_gu_match_effects.py` |
| BE-015-S06 | 6 occasions, a 281-character prompt, or `ZERO_INPUT` with a chip → 422 | `tests/test_gu_match_rules.py` |
| BE-015-S07 | PASS and Add to Rotation (`LIKE_SAVE`) set `swipe_status`; a replayed interaction changes nothing (TAC-07.3) | `tests/test_gu_match_interactions.py` |
| BE-015-S08 | Swap within the group succeeds and recomputes match %; another group, an archived item or a foreign item → 422 | `tests/test_gu_match_interactions.py` |
| BE-015-S09 | No candidate has a price or shop field (TAC-07.6), and every item is owned and not archived (I6) | `tests/test_gu_match_effects.py` |

## Allowed files

`backend/app/workers/gu_match.py`, `backend/app/sync/effects.py` (registration),
`backend/app/api/v1/endpoints/mock_controls.py` (scenarios),
`backend/tests/test_gu_match_*.py`, report.

## Anti-scope

No weather API, calendar or mobility model (AI-003), no LLM naming, no try-on
(AI-002), no `recent`-flag expiry job or `deck_history` (P3-03), no rewards.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created |
