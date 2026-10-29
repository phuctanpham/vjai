# CHG-003: Wardrobe/outfit direction and Phase 1 test-first contract

| Status | Source | Date |
|---|---|---|
| Approved | Human request · [Garblo Flow Spec](../tasks/mobile/Garblo%20Flow%20Spec.html) v2.7 · review of the Phase 1 red run | 2026-10-29 |

Status values: `Draft` → `Approved` (human) → `Done` (after merge).

## Problem
The repository describes a dating/matching product (`Profile`, `SwipeType`,
`Match`, `Conversation`). The tagged flow specification describes a wardrobe
and outfit product (Flow A: photos → Archive; Flow B: Gu Match styling). The
product owner selected the wardrobe direction
([TASK-001](../tasks/mobile/TASK-001-product-domain-alignment.md)). Phase 1
task cards were written before the contract migration and conflicted with the
spec and with CHG-001's document system.

Phase 1 follows the spec's own phase ladder (T6 · **P1 Clickable offline
app**): Flutter UI, in-memory repositories seeded from fixtures, fake AI. No
SQLite, PowerSync, backend API or ML.

## Decisions
| ID | Decision | Reason |
|---|---|---|
| W-01 | Phase 1 task cards live in `docs/tasks/mobile/`; scenario IDs are `TASK-00N-Sxx` and test names start with `[TASK-00N-Sxx]` | Human-selected location; replaces the `BL-NNN` folder for this phase only |
| W-02 | Bounded contexts `lib/features/studio/` (Add pillar), `lib/features/wardrobe/` (Archive pillar, wear events), `lib/features/gu_match/` (Gu Match pillar) | Matches the spec's pillars and API groups (`/v1/studio`, `/v1/wardrobe`, `/v1/gu-match`) |
| W-03 | Canonical terms are listed in [TASK-001 › Canonical terms](../tasks/mobile/TASK-001-product-domain-alignment.md#canonical-terms) until `terminology.md` is migrated. **Code symbols** follow the spec's T2/T4 data names (`WardrobeItem`, `Pillar.wardrobe`); **UI strings** follow W-11 | T7 › G4: "Data names stay `wardrobe_items`" |
| W-04 | The dating feature tree stays in place, unchanged and unrouted. `AppRouter` no longer routes to `DiscoveryView` | TASK-001 forbids deleting or silently reinterpreting it; TASK-002 forbids keeping both route sets |
| W-05 | Shell has 5 pillars. Impact and Community render their flag-off state ("coming soon") | Spec V1: with every flag off the app behaves as v1 |
| W-06 | Primary colour (T7 › G0): warm light `#1F5A2E` with on-primary `#FFFFFF`; warm dark `#7BC88A` with on-primary `#000000`. Violet only for "Garblo is working"; lime only for the anchor-lock ring | Spec D1 / T7 › G0 supersede the coral seed |
| W-07 | Time is read through an injectable `Clock` (`lib/core/time/`) | Dormancy depends on "today"; tdd.md forbids wall-clock reliance |
| W-08 | Try on shows an explicit "Try-on is coming soon" state in Phase 1 | Spec T6 P1-09; real try-on is AI work (P5) |
| W-09 | Red runs use compile-only contract stubs (`throw UnimplementedError()`); each task's stubs are committed with its tests | Tests fail on missing behaviour, and every commit compiles |
| W-10 | No new dependency. Photo picking uses a preset-photo fake behind `PhotoPicker` | decisions.md approves only `flutter_riverpod`, `flutter_lints` |
| W-11 | **UI strings come from T7 › G3 (per screen) and G4 (glossary)**, which win over UC/AC prose. Sizes for widget tests come from T7 › G1–G2 (bottom nav 64, primary button 48) | T7: "Where this section and older prose disagree on a colour, size or UI string, this section wins" |
| W-12 | The look rule is a **fake** (`FakeCandidateGenerator`, `lib/features/gu_match/data/`) behind `GuMatchRepository`; its tests are tagged `[fake-generator]` | Stand-in until P4/P5, not a product rule |
| W-13 | Red Phase 1 tests are not merged into `main`; the branch goes up as a Draft PR "Phase 1 · red" | CI runs `flutter test` on `main` |

## Approved assumptions
| ID | Decision (product owner, 2026-10-29) | Tests |
|---|---|---|
| A-01 | "Last worn" resolves to the **lower bound** of each bucket (deliberately under-states dormancy): This week → today, This month → today − 7 d, 1–3 months → today − 30 d, Over 3 months → today − 90 d. "Don't remember" (the default) stores no estimate, so dormancy falls back to the **save date**. An exact date may not be in the future. The value is stored as an **estimate** (`lastWornEstimate`). Under N6/I12 an estimate never counts toward a rescue, rescue XP, quests or the "30-day rescue" badge; the Archive BENCHED status still uses it (C3, AC-04.6) | TASK-003-S13, S14 |
| A-02 | If every photo fails, the batch is FAILED and the person can Reselect photos (→ DRAFT) or Try again (→ QUEUED_FOR_AI), keeping photos and consent. If only some fail, the successful Pieces go to review with "1 photo couldn't be read". Phase 1's fake analysis has no automatic retries; the retry cap of 2 starts with the real job pipeline in P4 | TASK-003-S11, S12 |
| A-03 | Phase 1 fake generator: a Fit = one top + one bottom + one pair of shoes from non-archived Pieces; 8 Fits per session (C11); match % = **70 + round(0.3 × days unworn of the least-recently-worn Piece)**, capped at 95 (41 days → 82%, the spec demo); if a top, bottom or shoes is missing, the no-Fits state shows the missing group | TASK-004-S04, S09, S12 (`[fake-generator]`) |

## Copy derived from G4 (not spelled out in G3)
G3/G4 do not give these strings. They apply the G4 glossary (Piece, Archive,
Fit, Index, Rotation) to the UC copy. Product, please confirm or replace:

| Where | UC copy | Phase 1 string |
|---|---|---|
| 4a save failure | "Couldn't save … · Try again" | "Couldn't index your Pieces." · "Try again" |
| 4a zero items CTA | "Nothing to save" | "Nothing to index" |
| 5a empty Archive | "Your wardrobe is empty" · "Add photos" | "Your Archive is empty" · "Index Pieces" |
| 5a empty group | "No bags yet" · "Add photos" | "No bags yet" · "Index Pieces" |
| 1b N = 0 | "Add clothes to your wardrobe first › Add" | "Index Pieces into your Archive first" · "Index Pieces" |
| 3b highlight reason | "Uses a top unworn for 41 days" | "Benched 41 days · Violet shirt" (G3 3b: "Benched 41 days · violet shirt returns for drizzle"; the narrative part is LLM work, P5) |
| 3b wear prompt | "Yes, wearing it" · "Save for later" | "Wear today" (G4) · "Save for later" |
| 3b end of deck | "You liked N looks" · "Go to wardrobe" | "You added N Fits to Rotation" · "Go to Archive" |
| 3b short deck | "Add shoes to unlock more looks" | "Index a pair of shoes to unlock more Fits" |

## Open questions (product owner)
| ID | Question | Phase 1 behaviour until answered |
|---|---|---|
| Q-01 | The 1a consent card (G3) says "EXIF and GPS removed, bystanders blurred on this phone", but Phase 1 does neither (stripping is P2, blur is P5). Show the line in P1 builds? | Tests do not assert the line. Recommendation: hide it until P2 |
| Q-02 | G1 moves the nav to a side rail at ≥ 840 (tablet); the repo breakpoint (D-003) is 800 | Keep 800 (D-003). Archive grid: 2 flush columns below 800, 3 at or above (G1 tablet value) |
| Q-03 | T6 › P1-02 still says "violet primary, accent-positive lime, celebration-eco", which predates D1 / T7 › G0 | Follow G0 (W-06). Fix the spec (v2.7.1) |

## Dating tests (18)
All 18 tests in `test/features/discovery/` are **kept, unchanged**. They pump
`DiscoveryView` directly and import only `lib/features/discovery/` and
`lib/core/widgets/`, never `lib/app/`, so re-pointing the router and changing
the theme cannot affect them. None is re-pointed or retired in Phase 1; the
green run must still show 18/18. The only dating-route test is a new one in
`test/app/router_test.dart` that asserts `/discovery` is no longer reachable.

## Product impact (APM)
| Affected | Change needed |
|---|---|
| [terminology.md](../policies/product/terminology.md) | Add the TASK-001 canonical wardrobe terms; mark dating terms as retired |
| [design-system.md](../policies/product/design-system.md) | Replace with T7 tokens (G0), grid (G1), components (G2), voice (G4) |
| `pubspec.yaml` description | "social discovery application" → wardrobe/outfit wording |
| Flow spec | Q-03 (T6 › P1-02) |
| [docs/tasks/backend/](../tasks/backend/README.md) | Dating tasks marked superseded; wardrobe handoff cards added |

## Engineering impact (ASEM)
| Affected | Change needed |
|---|---|
| [codebase-map.md](../policies/engineering/codebase-map.md) | Add `studio/`, `wardrobe/`, `gu_match/`, `lib/core/{time,media,navigation}/`, `lib/app/shell/` after merge |
| [decisions.md](../policies/engineering/decisions.md) | Record W-02, W-07, W-12; [BE-001](../tasks/backend/BE-001-platform-decision.md) (MongoDB + PowerSync replace the FastAPI mock), decided before P3 |
| CI and the format gate | [CHG-004](CHG-004-enforce-format-gate.md), merged **before** Phase 1 |

## Code follow-up
| Role | Paths | Tests | Done |
|---|---|---|---|
| App Developer | Paths listed in TASK-002, TASK-003 and TASK-004 › File confinement | Test plans in the same cards | [ ] |
| Backend Developer | None in Phase 1. See [docs/tasks/backend/](../tasks/backend/README.md) | — | — |
