# TASK-004: Flow B — Gu Match: style a new look

> **Phase:** 1 · MVP  
> **Status:** Tests written (red); pending CHG-003 approval for implementation  
> **Dependencies:** [TASK-003](TASK-003-flow-a-add-to-wardrobe.md) · [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md)  
> **Source use cases:** UC-05, UC-06, UC-07, UC-08 (AC-08.1–08.4 only) · spec T2 (I6, I9, enums) · T6 P1-09

"Style a new look" is the Wardrobe FAB label. The pillar and the feature are
**Gu Match** (`lib/features/gu_match/`).

## Objective

Use only the user's saved, non-archived wardrobe items to run a Gu Match
session: set the context, watch fixture context cards fill in, and decide on a
deterministic deck of up to 8 looks with pass, like, adjust and Change context.
No production AI.

## Scope

UI strings follow spec T7 › G3/G4 (CHG-003 W-11): never "Like", no "I", no
emoji. Strings derived from G4 are listed in CHG-003.

- **1b Gu Match studio**: "GU MATCH", "What are you wearing today?", "Pick a
  context. Garblo drafts only from your Archive.", multi-select context chips
  (C10, ≤ 5), "TELL GARBLO MORE" prompt with "0/280" counter (≤ 280
  characters, input stops), "{N} PIECES READY" where N equals the Archive
  total (I9), "No shopping. Drafts use only what you own.", **Draft Fits**
  disabled when N = 0 with "Index Pieces into your Archive first" + Index
  Pieces.
- **Path** (C1): any chip or text → `promptLed`; neither → `zeroInput`.
- **2b Reading your context**: status line "DRAFTING · CALENDAR, WEATHER &
  COMMUTE", four cards in fixed order (occasion, weather, rain, commute)
  revealed as each arrives, card 1 labelled "YOUR REQUEST" (prompt-led) or
  "TODAY" / "No event found · styling for an everyday day" (zero-input); a
  source that fails shows what is missing and the flow continues; title
  "Reading your context…" → "Context read" when all cards are in; then the
  deck opens without a tap.
- **Fake generator** (`FakeCandidateGenerator` in `data/`, behind
  `GuMatchRepository`, A-03; tests tagged `[fake-generator]`): a Fit is one
  top + one bottom + one pair of shoes from owned, non-archived Pieces (I6);
  deterministic; 8 per session (C11); most benched first; match %
  `70 + round(0.3 × days)` capped at 95 ("82% FIT" at 41 days); highlight
  reason "Benched 41 days · Violet shirt" for Pieces ≥ 30 days; label
  WARDROBE PHOTO; no commerce fields. A short deck shows the real total plus
  a hint; a missing top, bottom or shoes gives the no-Fits state.
- **3b Fit deck**: HUD "k/N FITS" + Change context; rail buttons Pass, Add to
  Rotation, Adjust, Try on (tooltips, alternatives to swipe).
- **Pass** → `swipedLeftPassed`, interaction recorded with dwell time, next card.
- **Add to Rotation** (`CardAction.likeSave`) → `swipedRightLiked`, "Wearing
  this today?": **Wear today** logs one `WearEvent` per Fit per day
  (TAC-07.4); **Save for later** → `savedToLookbook`, no wear.
- **Change context** → studio with chips and text pre-filled; starting again
  deals a new deck.
- **Adjust** → Pieces by slot with Swap; options are other owned non-archived
  Pieces of the same group; the card updates, match % is recalculated, an
  adjust interaction is logged, the card stays undecided.
- **Try on** → explicit "Try-on is coming soon" sheet; nothing is rendered.
- **End of deck** → "You added {n} Fits to Rotation" with Change context and
  Go to Archive.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-004-S01 | Styling starts only when the wardrobe has usable items; the ready count equals the Wardrobe total (I9) | ViewModel/widget |
| TASK-004-S02 | Context validates before starting: ≤ 5 occasions, ≤ 280 characters, path derived from input (C1, C10) | Domain/ViewModel |
| TASK-004-S03 | Context cards reveal one by one with provenance for each path; the title changes only when all are in | ViewModel/widget |
| TASK-004-S04 | Fits contain only owned, non-archived Piece IDs; deterministic; ≤ 8; no commerce fields (I6, AC-07.10) | Fake generator/ViewModel |
| TASK-004-S05 | Pass advances to the next Fit and records the interaction (AC-07.5) | ViewModel/widget |
| TASK-004-S06 | Add to Rotation asks "Wearing this today?"; Wear today logs one wear event per Fit per day; Save for later logs none (AC-07.6–07.8) | ViewModel/repository/widget |
| TASK-004-S07 | Change context returns to the studio with the context pre-filled and deals a new deck (AC-07.9, AC-05.9) | ViewModel |
| TASK-004-S08 | Try on shows an explicit coming-soon state; no false success is shown (P1-09) | ViewModel/widget |
| TASK-004-S09 | Adjust swaps only to an owned, non-archived Piece of the same group; match % recalculated (A-03); card stays undecided (AC-08.1–08.4) | Fake generator/ViewModel |
| TASK-004-S10 | A failed context source degrades only its own card and the deck is still built (AC-06.9, AC-06.10) | ViewModel |
| TASK-004-S11 | A Fit with a Piece benched ≥ 30 days names the most benched Piece in its reason (AC-07.4) | Fake generator |
| TASK-004-S12 | End of deck summarises Fits added to Rotation; a short deck shows its real total and a hint; no complete Fit → no-Fits state with the missing group | ViewModel/widget |

## Test plan

| Scenario | Level | Test file | Test name prefix |
|---|---|---|---|
| S01 | ViewModel | test/features/gu_match/presentation/gu_match_view_model_test.dart | [TASK-004-S01] |
| S01 | Widget | test/features/gu_match/presentation/gu_match_view_test.dart | [TASK-004-S01] |
| S02 | Domain | test/features/gu_match/domain/styling_context_test.dart | [TASK-004-S02] |
| S02 | ViewModel | test/features/gu_match/presentation/gu_match_view_model_test.dart | [TASK-004-S02] |
| S03 | ViewModel | test/features/gu_match/presentation/gu_match_view_model_test.dart | [TASK-004-S03] |
| S03 | Widget | test/features/gu_match/presentation/gu_match_view_test.dart | [TASK-004-S03] |
| S04 | Fake generator | test/features/gu_match/data/fake_candidate_generator_test.dart | [TASK-004-S04][fake-generator] |
| S05 | ViewModel | test/features/gu_match/presentation/gu_match_view_model_test.dart | [TASK-004-S05] |
| S05 | Widget | test/features/gu_match/presentation/gu_match_view_test.dart | [TASK-004-S05] |
| S06 | ViewModel | test/features/gu_match/presentation/gu_match_view_model_test.dart | [TASK-004-S06] |
| S06 | Repository | test/features/wardrobe/data/wear_repository_test.dart | [TASK-004-S06] |
| S06 | Widget | test/features/gu_match/presentation/gu_match_view_test.dart | [TASK-004-S06] |
| S07 | ViewModel | test/features/gu_match/presentation/gu_match_view_model_test.dart | [TASK-004-S07] |
| S08 | ViewModel | test/features/gu_match/presentation/gu_match_view_model_test.dart | [TASK-004-S08] |
| S08 | Widget | test/features/gu_match/presentation/gu_match_view_test.dart | [TASK-004-S08] |
| S09 | Fake generator | test/features/gu_match/data/fake_candidate_generator_test.dart | [TASK-004-S09][fake-generator] |
| S09 | ViewModel | test/features/gu_match/presentation/gu_match_view_model_test.dart | [TASK-004-S09] |
| S10 | ViewModel | test/features/gu_match/presentation/gu_match_view_model_test.dart | [TASK-004-S10] |
| S11 | Fake generator | test/features/gu_match/data/fake_candidate_generator_test.dart | [TASK-004-S11][fake-generator] |
| S12 | Fake generator | test/features/gu_match/data/fake_candidate_generator_test.dart | [TASK-004-S12][fake-generator] |
| S12 | ViewModel | test/features/gu_match/presentation/gu_match_view_model_test.dart | [TASK-004-S12] |
| S12 | Widget | test/features/gu_match/presentation/gu_match_view_test.dart | [TASK-004-S12] |

Required non-scenario tests: `OutfitCandidate` and `StylingContext` value
equality and list-content `hashCode`; `WearEvent` signature is independent of
item order; a ready-count load failure → error with retry; duplicate Pass /
Add to Rotation taps while a decision is in flight are ignored; Gu Match imports no Wardrobe
presentation code (covered by TASK-002-S06); both layouts for the widget file.

## File confinement

**App Developer may create or modify:**

- `lib/features/gu_match/{domain,data,presentation}/**`
- `lib/features/wardrobe/domain/wear_event.dart`,
  `lib/features/wardrobe/data/wear_repository.dart` (wear events are owned by
  the Wardrobe pillar; Gu Match writes them through the repository interface)
- No shell change: `lib/app/shell/pillar_pages.dart` (TASK-002) already maps
  the Gu Match pillar to `GuMatchView`
- `test/features/gu_match/**`, `test/features/wardrobe/data/wear_repository_test.dart`,
  `test/helpers/**`

Cross-feature reads must use the Wardrobe domain/repository contract, never
Wardrobe presentation widgets.

## Anti-scope

- No production LLM, weather API, calendar or location access, recommendation
  engine, or image-generation service. Context cards come from fixtures.
- No body-photo upload, consent for body processing, or real/mock try-on
  rendering (try-on is "coming soon").
- No 4b thank-you screen, Impact, Rewards, Share, or Community implementation.
- No mutation of `WardrobeItem` data from Gu Match. Wear is recorded only as
  append-only `WearEvent`s; dormancy is derived from them.
- No per-source timers (the 5 s timeout is backend work); no offline "Connect
  to start" copy (P1 is offline by design); no swipe animation budget tests.

## Acceptance criteria

- Candidate generation is deterministic, fixture-backed, and reachable only
  through `GuMatchRepository` (the ViewModel never sees the fake generator).
- The repository boundary exposes typed entities and typed failures
  (`NoEligibleItemsFailure` when N = 0).
- Loading, empty, and error states are tested.
- Mobile and desktop layouts are verified at the approved breakpoint.
- Flutter formatting, analysis, and targeted tests pass.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | — | Created Flow B task from the must-have mobile specification. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Renamed to Gu Match; split Adjust (swap) from Change context; Like → wear prompt; try-on → coming soon; wear events clarified; added S09–S12; test plan and file list added. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Review: T7 G3/G4 copy (Fit, Add to Rotation, Wear today); A-03 match % = 70 + round(0.3 × days); generator moved to `data/` as `FakeCandidateGenerator`, tests tagged `[fake-generator]`; no-Fits state. |
