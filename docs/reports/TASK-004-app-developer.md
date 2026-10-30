# TASK-004 · app-developer report

| Date | Status | Commits |
|---|---|---|
| 2026-10-29 | Complete (in review) | `6204f74` [TASK-004] test · [TASK-004] feat (this delivery) |

Item: [TASK-004 Flow B: Gu Match](../tasks/mobile/TASK-004-flow-b-style-new-look.md) · contract [CHG-003](../changes/CHG-003-wardrobe-direction-phase-1.md) · PR #2 (draft).

Gu Match drafts **Fits** (outfits) from the user's own Pieces for the day ahead. "Match %" is how well a Fit suits the context; "swipe" is a decision on a Fit (Pass or Add to Rotation). Nothing here matches people, and no dating code is used or routed.

## Changed files
| Path | Purpose |
|---|---|
| `lib/features/gu_match/domain/*` | Occasion, StylingContext (≤ 5 chips, ≤ 280 chars, path), GuMatchSession, ContextCard (+ missing card), SlotRole, VisualMode labels, Interaction, OutfitCandidate (+ wire JSON, no commerce fields), GeneratedDeck (+ missing-group hint) |
| `lib/features/gu_match/data/fake_candidate_generator.dart` | Phase 1 fake: Fit = top + bottom + shoes, owned and non-archived; dormant first; ≤ 8; match % = 70 + round(0.3 × days), cap 95; "Benched {d} days · {Piece}"; swap rules |
| `lib/features/gu_match/data/gu_match_repository.dart` | `MockGuMatchRepository`: ready count = Archive total, `NoEligibleItemsFailure`, fixture context cards per path, deck from Archive + wear log, interactions, swaps, wear once per Fit per day |
| `lib/features/gu_match/presentation/*` | `GuMatchState`, `GuMatchViewModel` (studio → context → deck → end / no Fits; busy guard; wear prompt; Change context pre-fill; Adjust swap; Try-on coming soon), `GuMatchView` + 1b/2b/3b widgets |
| `test/features/gu_match/presentation/gu_match_view_test.dart` | Test fix: one more `pump()` after a streamed context card (see Deviations) |
| `test/app/flow_b_journey_test.dart` | New: the ready count follows the Archive across pillars (I9), then a short deck of 4 Fits |

## Scenario coverage
| Scenario | Tests | Result |
|---|---|---|
| TASK-004-S01 Ready count = Archive total; N = 0 blocks | ViewModel 3, widget 4, journey 2 | pass |
| TASK-004-S02 Context: ≤ 5 chips, ≤ 280 chars, path | domain 5, ViewModel 3 | pass |
| TASK-004-S03 Cards reveal one by one; provenance per path | ViewModel 3, widget 2 | pass |
| TASK-004-S04 Owned, non-archived, deterministic, ≤ 8, no commerce | `[fake-generator]` 7, ViewModel 1 | pass |
| TASK-004-S05 Pass advances and is logged; no double tap | ViewModel 2, widget 2 | pass |
| TASK-004-S06 Add to Rotation → Wear today once per day / Save for later | ViewModel 5, wear repository 3, widget 2 | pass |
| TASK-004-S07 Change context pre-fills, new deck | ViewModel 1 | pass |
| TASK-004-S08 Try-on coming soon, no false success | ViewModel 1, widget 2 | pass |
| TASK-004-S09 Adjust swap rules; match % recalculated | `[fake-generator]` 5, ViewModel 1 | pass |
| TASK-004-S10 Failed source degrades only its card | ViewModel 3 | pass |
| TASK-004-S11 Reason names the most benched Piece | `[fake-generator]` 3 | pass |
| TASK-004-S12 End of deck, short deck, no Fits | `[fake-generator]` 2, ViewModel 3, widget 2 | pass |

## TDD evidence
- **Red:** `flutter test test/features/gu_match test/features/wardrobe/data/wear_repository_test.dart` at `6204f74` → 0 passed, 70 failed (stub `UnimplementedError`s).
- **Green:** the same command → 70 passed, 0 failed.
- Note: the 5 wear-log tests had already gone green in TASK-003, which needed the wear log for Archive dormancy.

## Gates
| Gate | Result |
|---|---|
| format (`dart format --output=none --set-exit-if-changed .`) | pass (whole repo) |
| analyze (`flutter analyze`) | pass, no issues |
| tests, full suite | **255 / 255 pass** (TASK-002 24, TASK-003 141, TASK-004 70 + 2 journey, dating baseline 18) |

Toolchain: Flutter 3.24.5, Dart 3.5.4.

## Deviations from plan
- **Test fix (S03 widget).** A streamed context card reaches the ViewModel in a microtask that runs after the frame of a single `pump()`, so the card shows only on the next frame. The test already pumped twice after "Draft Fits" for this reason; it now does the same after the weather card.
- **Added test** `test/app/flow_b_journey_test.dart` (both layouts). The Gu Match ViewModel is kept alive so Change context can pre-fill, which means its ready count could go stale after indexing new Pieces. `GuMatchView` refreshes the count each time the pillar is shown; this journey proves "N PIECES READY" equals the Archive total across pillars (I9).
- **No-Fits state** shows "No Fits to draft yet" with the missing-group hint, "Change context" and "Index Pieces" (derived from G4; listed with the other derived strings in CHG-003).
- **Phase 1 visuals.** Fit cards show a flat-lay list of the Pieces (label WARDROBE PHOTO) instead of images; there are no cutouts until the extraction pipeline (AI-001).
- Swipe gestures map left → Pass and right → Add to Rotation; the rail buttons are the tested path and the accessible alternative.

## Backend / AI follow-ups recorded
The Gu Match vocabulary ("match", "swipe", `LIKE_SAVE`) and the backend code itself still read as the retired dating product, so:
- [docs/tasks/backend/README.md](../tasks/backend/README.md) › "Read this first: Garblo is not a dating app": a term table for backend and AI developers.
- [BE-004](../tasks/backend/BE-004-gu-match-api.md): warning not to build Gu Match on `POST /api/v1/swipes`, `/api/v1/discovery` or `/api/v1/matches`.
- New [BE-005](../tasks/backend/BE-005-retire-dating-mock-api.md): retire the dating mock API (`discovery.py`, `matches.py`, `chat.py`, `auth.py` placeholder, `models/profile.py`, sample people) and rewrite `backend/README.md`, before BE-002. Needs a CHG.
- [BE-001](../tasks/backend/BE-001-platform-decision.md): the current FastAPI code is not a starting point for the wardrobe API.
- [AI-003](../tasks/backend/AI-003-agent-context-and-styling.md): "like rate" → Add to Rotation rate, a decision on a Fit.
- CHG-003 product impact: the root `README.md` and `pubspec.yaml` still describe a social discovery app.

## Doc issues
- The root `README.md` describes "discovery and social connection", swipe cards and profile panels. It is a product document, so I did not rewrite it; it is listed in CHG-003 for the APM.
- The mobile dating tree (`lib/features/discovery` and the placeholders) is unrouted but still in the codebase; removing it needs its own mobile CHG.
- Still open from CHG-003: Q-01, Q-02, the strings derived from G4.

## Lesson candidates
- Widget tests driven by a `StreamController` need two pumps per event: one delivers the event, the next renders the rebuild.
- A kept-alive ViewModel that shows a count owned by another feature must refresh when its page is shown; cover it with a cross-pillar journey test.
