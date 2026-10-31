# TASK-026: Gu Match as command rows

> **Phase:** P4 · P4-M04  
> **Track:** M (BE-015 fake side effects) → R (BE-004: weather API, `recent` flag, `deck_history`)  
> **Status:** Draft · needs CHG-015 approval, DOC-004 Q3–Q5 decided, and an implementation plan  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) F-10, F-11, F-12)  
> **Dependencies:** [TASK-018](TASK-018-flows-on-server-fakes.md), [TASK-011](TASK-011-phone-schema-v2-alignment.md)  
> **Source:** Flow Spec v2.8 UC-05…UC-08 sync contracts · T4 › my_decks, deck_history · DB handbook §8 GM-01…GM-07

## Why

TASK-018 shows the deck from server rows. This card makes every Gu Match write match the
command-row contract, and it settles three conflicts the current code hides:

1. **Swipe decisions.** The phone PATCHes `outfit_candidates.swipe_status`, which BE-012
   rejects. The decision must be an `interactions` row, and the server sets `swipe_status`.
   "Save for later" (`SAVED_TO_LOOKBOOK`) has no `card_action`, so the phone cannot ask for it
   (DOC-004 Q3).
2. **Action names.** `CUSTOMIZE_EDIT` (T2) vs `ADJUST` (T4, GM-05) (DOC-004 Q4).
3. **Fit items.** The phone reads `name` and `days_unworn` from `outfit_candidates.items`. In a
   synced row these go stale (DOC-004 Q5). Proposal: the phone joins `item_id` to its local
   `wardrobe_items` and computes days unworn with `DormancyRules`, so the card is always current.

## Scope

- Start swiping: insert `gu_match_sessions` with phone fields only (`path`, `occasions`,
  `raw_prompt`, `event_title`, `window_start`, `window_end`, `city_id`, `ambient_temp_c`). The
  calendar and city fields stay null until device calendar and location are specified (P2-06,
  gap ③).
- Session status drives the screen: REQUESTED → GATHERING (cards) → ANALYZED → DECK_READY;
  NO_ELIGIBLE_ITEMS and FAILED map to the existing states.
- Swipes, adjust and save are `interactions` PUTs only. The card's state is optimistic until the
  server's `swipe_status` syncs; a rejection reverts it (TASK-024).
- Offline: swiping recent decks (`recent = 1`, 7 days) works; drafting needs a connection (GM-06).
- Restore after restart uses the latest `recent` session from sync, not phone-maintained `recent`.
- `deck_history` (Track R): opening an older deck subscribes on demand. UI only when specified.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-026-S01 | The session PUT carries only phone fields, with wire values (`PROMPT_LED`, `["WORK"]`); BE-015 accepts the recorded request | Repository + fixture |
| TASK-026-S02 | Pass, add to rotation and adjust each write one `interactions` PUT and **no** `outfit_candidates` op | Repository (`RecordingConnection`) |
| TASK-026-S03 | A swipe shows at once; the server's `swipe_status` confirms it; a rejection reverts the card and shows the Fix banner | ViewModel |
| TASK-026-S04 | Fit cards show item names and days unworn from local Pieces; a Piece worn today after the deck was drafted shows 0 days | Widget |
| TASK-026-S05 | Offline: swiping a synced deck works and queues interactions; Draft Fits shows the connection error | Journey |
| TASK-026-S06 | An adjust that the server rejects for I6 (foreign or archived Piece) leaves the Fit unchanged | Integration (mock) |

## Anti-scope

No try-on (TASK-030). No live weather UI change beyond the card text from the server. No
history screen without a spec.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
