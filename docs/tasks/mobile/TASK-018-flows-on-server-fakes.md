# TASK-018: Flow A and Flow B on server fakes

> **Phase:** P3 with a P4 preview (results written by the server, fakes on the server)  
> **Track:** M (recorded mock responses, then the live mock)  
> **Status:** Draft · needs CHG-014/015 approval and an implementation plan from the Engineering Manager  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 (old TASK-010 S04, S05, S07)  
> **Dependencies:** [TASK-010](TASK-010-mock-backend-integration.md), [TASK-015](TASK-015-result-engine-seams.md); backend [BE-014](../backend/BE-014-fake-studio-side-effects.md), [BE-015](../backend/BE-015-fake-gu-match-side-effects.md), [AI-005](../backend/AI-005-model-ports-and-fakes.md)  
> **Source:** Flow Spec v2.8 T4 › Side effects (DB5) · UC-02, UC-03, UC-05, UC-06, UC-07 sync contracts · CHG-014 Q2

## Why

The mock backend writes the same result rows the real server will: jobs, drafts, session status
and context, decks and swipe results. This card proves that both must-have flows work when
those rows arrive by sync and the phone runs no fake, while the phone still runs offline on its
local fakes when the flag is off.

## Scope

- `SyncedAnalysisEngine`. Analyze writes the batch PATCHes (SANITIZING → QUEUED_FOR_AI) and
  returns. Progress is read from `ai_processing_jobs` and `extracted_items` as the feed applies
  them. Review starts when the server sets AWAITING_REVIEW. FAILED shows the existing error.
- `SyncedContextSource` and `SyncedDeckEngine`. Start swiping inserts the `gu_match_sessions`
  command row. Cards appear one by one as `context` is patched. The deck appears when the status
  is DECK_READY. NO_ELIGIBLE_ITEMS shows the existing empty state.
- Providers pick the engines: `Synced*` when `GARBLO_BACKEND=mock`, else `Local*`.
- Swipe, swap and save use the interaction rows of [TASK-026](TASK-026-gu-match-command-rows.md)
  once DOC-004 Q3–Q4 are settled. Until then this card uses `interactions` for pass/like/adjust
  and records the open item for "save for later".

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-018-S01 | Flow A with recorded responses: pick → consent → Analyze → jobs and drafts arrive from the feed → review → Save N → Pieces in the Archive; no local fake ran | Journey (both layouts) |
| TASK-018-S02 | Flow A partial failure: one outfit job FAILED → "1 photo couldn't be read" with the rest reviewable (BE-014 outcome scenario) | Journey |
| TASK-018-S03 | Flow B with recorded responses: session row → cards in order (GATHERING) → deck (DECK_READY) → pass and add to rotation → `swipe_status` arrives from the server | Journey |
| TASK-018-S04 | Flow B with a missing weather source: the card shows "missing" and the deck still arrives (AC-06.9) | Journey |
| TASK-018-S05 | Draft Fits offline with the flag on: a retryable "Needs a connection" error; swiping an already-synced deck works offline (GM-06) | Journey |
| TASK-018-S06 | Live: S01 and S03 against the running Track M mock, tagged `live_backend` | Integration |
| TASK-018-S07 | Flag off: Flow A and B journeys are unchanged and nothing is uploaded | Regression |

## Anti-scope

No photo bytes upload (TASK-025): with the mock, `media_assets` refer to attachments that BE-018
treats as uploaded. No PowerSync. No new copy without the APM (the offline Draft Fits line is
DOC-004 Q8).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer from TASK-010 S04, S05, S07 |
