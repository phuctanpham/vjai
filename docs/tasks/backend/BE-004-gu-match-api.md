# BE-004: Gu Match API — sessions, context events, generator, interactions

> **Owner:** Backend Developer  
> **Status:** Blocked by [BE-001](BE-001-platform-decision.md)  
> **Spec phase:** P4 (P4-B07: rule-based generator, live weather, SSE)  
> **Source:** UC-05 – UC-08 · T2 (I6, I9, enums) · TAC-05.2, 05.5, 05.6, 06.1–06.3, 06.5–06.7, 07.3, 08.6

## Why

Phase 1 builds decks on the phone with `FakeCandidateGenerator` (behind
`GuMatchRepository`) and plays fixture
context cards from `MockGuMatchRepository`. The server takes over session
creation, context gathering (with the 5 s per-source timeout the phone does
not implement), deck generation, and interaction logging.

## Contract fixed by Phase 1 (do not break)

| Mobile type | Fields / rule | Test that pins it |
|---|---|---|
| `StylingContext` | occasions ⊆ `WORK, COFFEE, AFTERNOON_RAIN, DATE, WEEKEND_OUTING`, ≤ 5; prompt ≤ 280; path `PROMPT_LED` iff any chip or text (C1, C10) | `styling_context_test.dart` |
| Session start | `NoEligibleItemsFailure` when the eligible count is 0 (409 `NO_ELIGIBLE_ITEMS`) | `gu_match_view_model_test.dart` |
| `ContextCard` | kinds `occasion, weather, rain, commute`, fixed order; a missing source yields a card with `isMissing = true`, never a failed session (TAC-06.2) | `gu_match_view_model_test.dart` |
| `OutfitCandidate` | `candidateId, deckOrder, title, matchPct (0..100), highlightReason?, visualMode, swipeStatus, items[{slotRole, itemId, name, daysUnworn}]`; no price/shop fields (TAC-07.6) | `fake_candidate_generator_test.dart` |
| Generator | owned, non-archived only (I6); ≤ 8; deterministic; dormant-first; match % rule A-03 (70 + round(0.3 × days), cap 95) | `fake_candidate_generator_test.dart` (`[fake-generator]`) |
| `CardAction` | `DISMISS_PASS, LIKE_SAVE, CUSTOMIZE_EDIT, TRIGGER_VTON`, with dwell time | `gu_match_view_model_test.dart` |
| Swap | same group, owned, non-archived; else 403 (TAC-08.6) | `fake_candidate_generator_test.dart` |

## Scope

- `POST /v1/gu-match/sessions`, `GET …/events` (SSE: `status`, `card`,
  `deck_ready`), `GET …/candidates`, `POST /v1/gu-match/candidates/{id}/interactions`,
  `PUT …/items/{slot}`.
- Idempotent session start (TAC-05.6) and interactions (TAC-07.3).
- Weather API with a per-city-hour cache (TAC-06.3); 5 s per-source timeout.
- Rule-based generator on the server that passes the same property tests as the
  phone generator (owned-only, deterministic).

## Anti-scope

No LLM intent/naming (AI-003), no try-on (AI-002), no thank-you or rewards.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created from the Phase 1 Gu Match contract. |
