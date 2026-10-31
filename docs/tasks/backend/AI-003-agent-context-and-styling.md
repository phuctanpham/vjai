# AI-003: Agent context, LLM intent and naming, PII scrubber, ranked generator

> **Owner:** AI Engineer + Backend Developer  
> **Status:** Blocked by [BE-004](BE-004-gu-match-api.md) and spike SP-7 (LLM provider)  
> **Spec phase:** P5 (P5-A03, P5-A04, P5-B03)  
> **Source:** UC-05 TAC-05.3, 05.4 · UC-06 AC-06.1–06.11, TAC-06.1–06.4 · UC-07 AC-07.3

## Why

Phase 1 plays fixture context cards and builds Fits with a deterministic
fake (`FakeCandidateGenerator` behind `GuMatchRepository`, A-03: one top + one
bottom + one pair of shoes, match % = 70 + round(0.3 × days unworn of the
least-recently-worn Piece), capped at 95, template titles). This card
replaces the fixtures and the rule with the agent and models, keeping the
`ContextCard` and `OutfitCandidate` contracts.

## Scope

- Agent orchestrator: calendar-derived input (title, time window, city only),
  weather for the event location and window, mobility model; sources in
  parallel, 5 s timeout each; a failed source degrades only its own card.
- PII scrubber on the prompt before any LLM call (emails, phone numbers,
  names) with red-team fixtures (TAC-05.4).
- LLM intent parsing and look naming under a zero-retention agreement; no user
  ID, attendees or event notes in calls (TAC-06.4).
- Generator v2: embedding similarity + constraints + dormancy boost; must still
  pass the Phase 1 property tests (owned-only, ≤ 8, deterministic for a fixed
  model version) and beat the rule-based **Add to Rotation rate** (share of
  Fits kept with `CardAction.LIKE_SAVE`; a decision on an outfit, not a
  person) on the evaluation set.
- Calibrated match % (replaces A-03).

## Plug points and early work (CHG-014)

- Context sources, generator v2 and naming replace the fakes behind the
  `ContextSource`, `OutfitGenerator` and `LookNamer` ports of
  [AI-005](AI-005-model-ports-and-fakes.md). The session worker
  ([BE-015](BE-015-fake-gu-match-side-effects.md)) does not change.
- The PII scrubber starts as the rule-based v0 in
  [AI-006](AI-006-pii-scrubber-and-eval-harness.md) (emails, phone numbers, URLs,
  addresses; red-team fixtures). This card adds name detection behind its
  `NameDetector` port.
- "Beat the rule-based Add to Rotation rate" is measured with AI-006's `deck_eval`,
  against the committed baseline of `RuleOutfitGenerator`.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created; Phase 1 uses fixture context and a rule-based generator. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | "Like rate" → Add to Rotation rate (a decision on a Fit). |
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Plug points (AI-005), scrubber v0 and evaluation harness (AI-006). |
