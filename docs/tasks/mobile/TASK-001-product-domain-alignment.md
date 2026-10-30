# TASK-001: Product-domain alignment and contract freeze

> **Phase:** 1 · Product decision  
> **Status:** Wardrobe direction selected; Phase 1 contract frozen in [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) (Draft, awaiting human approval)  
> **Dependencies:** None  
> **Owner:** Product Manager + Engineering Manager  
> **Source:** [Garblo Flow Spec.html](Garblo%20Flow%20Spec.html) v2.7

## Objective

Resolve whether Garblo is the existing dating/matching product or the wardrobe
and outfit product described by the mobile flow specification. The product
decision for this plan is **wardrobe and outfit**.

## Evidence reviewed

- Existing product identity in [pubspec.yaml](../../../pubspec.yaml).
- Existing bounded contexts in [lib/](../../../lib/) and the codebase map
  [codebase-map.md](../../policies/engineering/codebase-map.md).
- Existing terminology in [terminology.md](../../policies/product/terminology.md).
- Wardrobe journeys, screens, use cases and the phase ladder (T6) in
  [Garblo Flow Spec.html](Garblo%20Flow%20Spec.html).

## Decision

**Selected direction: Wardrobe/outfit application.**

The mobile flow specification is the canonical product direction for Phase 1.
Phase 1 is the spec's **P1 · Clickable offline app** (T6): Flutter UI,
in-memory repositories seeded from fixtures, fake AI. No SQLite, PowerSync,
backend API or ML. The existing dating/matching feature tree and vocabulary
must not be reused for wardrobe implementation.

## Feature tree decision

| Context | Path | Pillar | Owns |
|---|---|---|---|
| Studio | `lib/features/studio/` | Add (1a–4a) | Upload batch, photo tray, consent, analysis scope, review drafts |
| Wardrobe | `lib/features/wardrobe/` | Wardrobe (5a) | Wardrobe items, item types and groups, wear events, dormancy |
| Gu Match | `lib/features/gu_match/` | Gu Match (1b–3b) | Styling context, session, context cards, outfit candidates, interactions |
| Shell | `lib/app/shell/`, `lib/core/navigation/` | all | Pillar navigation, header, Impact/Community off states |

The dating tree (`discovery`, `auth`, `onboarding`, `matching`, `chat`,
`profile`, `notifications`, `moderation`) stays in place, unchanged and
unrouted (CHG-003 W-04). Its removal needs its own CHG.

## Canonical terms

Use the **code symbol** in code, tests and documents. Symbols follow the
spec's T2/T4 names so later SQLite/PowerSync swaps need no renaming.

| Term | Code symbol | Definition | Prohibited synonyms |
|---|---|---|---|
| Wardrobe item | `WardrobeItem` | A garment the user owns, saved from review or seeded | Profile, Product, Garment, Card |
| Item group | `ItemGroup` | `tops`, `bottoms`, `shoes`, `bags`, `hats`, `accessories` (C4, P6) | Category |
| Item type | `ItemType` | A type such as Shirt or Sneakers; belongs to exactly one group | Kind, Subcategory |
| Upload batch | `BatchStatus` | Lifecycle of one Add session: `draft` → `sanitizing` → `queuedForAi` → `aiProcessing` → `awaitingReview` → `completed` / `failed` | Upload, Job |
| Photo tray | `PhotoTray` | The 1–10 staged photos of a batch, in pick order | Gallery, Selection |
| Media asset | `MediaAsset` | One staged photo with its slot | Image, File |
| Privacy consent | `PrivacyConsent` | The consent record (version, time) given before analysis | Agreement, Permission |
| Analysis task | `AnalysisTask` | `outfitExtraction`, `poseEstimation`, `backgroundAnalysis` | Option, Mode |
| Extracted item | `ExtractedItem` | An editable AI draft of a wardrobe item, before save | Suggestion, Result |
| Last worn input | `LastWornInput` | The optional "Last worn" answer given in review (C3) | — |
| Wear event | `WearEvent` | One confirmed wear of a set of items on a date; append-only | Wear log entry, Usage |
| Dormancy | `DormancyRules` | Days since last wear (or save); badge at ≥ 30 days (I8) | Staleness |
| Occasion | `Occasion` | `work`, `coffee`, `afternoonRain`, `date`, `weekendOuting`; multi-select (C10) | Tag, Event |
| Styling context | `StylingContext` | The chips and prompt typed in 1b | Query, Filter |
| Session path | `SessionPath` | `promptLed` or `zeroInput` (C1) | Mode |
| Gu Match session | `GuMatchSession` | One styling session that deals one deck | StylingSession |
| Context card | `ContextCard` | One of the four 2b cards: occasion, weather, rain, commute | Tile |
| Outfit candidate | `OutfitCandidate` | One look on the 3b deck, built only from owned items | Match, Profile, Outfit card |
| Swipe status | `SwipeStatus` | `pendingSwipe`, `swipedLeftPassed`, `swipedRightLiked`, `savedToLookbook` | SwipeType, Vote |
| Card action | `CardAction` | `dismissPass`, `likeSave`, `customizeEdit`, `triggerVton` | SwipeType, Direction |
| Pillar | `Pillar` | `add`, `wardrobe`, `guMatch`, `impact`, `community` | Tab, Section |

UI screens that load data still use the state names `initial`, `loading`,
`loaded`, `empty`, `error`.

## Approved Phase 1 tasks

| Task | Anti-scope summary |
|---|---|
| [TASK-002](TASK-002-mobile-foundation.md) | No feature logic, no first-launch screen, no flags service, no new dependency |
| [TASK-003](TASK-003-flow-a-add-to-wardrobe.md) | No sanitizing, upload, real AI, item detail, archive, add-without-photo |
| [TASK-004](TASK-004-flow-b-style-new-look.md) | No LLM, weather, calendar, real try-on, thank-you screen, rewards |

## Phase 1 exclusions (spec P1 items deferred)

| Spec task | Reason |
|---|---|
| P1-04 First-launch screen (name + 18+) | Gap ① "Needs spec" |
| P1-08 Item detail, Archive/Delete, Add without photo | Gap ② "Needs spec" |
| P1-10 Manual wear logging | Gap ③ "Needs spec" |
| P1-11 Nice-to-have screens behind flags | Flows C and D are deferred by the Phase 1 plan |
| P1-12 Account hub, notification inbox | Gaps ④ ⑤ "Needs spec" |
| P1-02 ARB localisation | Needs `flutter_localizations`/`intl`, not approved in decisions.md |

## Deliverables

- [x] A change record describing the selected direction and affected documents: [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md).
- [x] Canonical terms (above), pending migration into `terminology.md` by the APM.
- [x] A decision on the Flutter feature tree (above).
- [x] A list of approved Phase 1 tasks and their anti-scope (above).

## Acceptance criteria

- The wardrobe product direction is written in one authoritative document (this card + CHG-003).
- The required contract migration is listed in an approved change record (CHG-003 needs human approval).
- Every Phase 1 task links to that decision.
- At least one reviewer confirms that the domain terms are consistent.
- No implementation task is marked ready before this task is accepted.

## Anti-scope

- Do not modify backend source code.
- Do not introduce wardrobe entities into the dating feature tree.
- Do not delete, rename, or silently reinterpret the existing product
  documentation.
- Do not approve Flow C or Flow D as part of this phase.

## Verification

Documentation review only. Confirm all links resolve and that the selected
direction does not leave conflicting canonical terms.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | — | Created to block implementation until the dating-versus-wardrobe conflict is resolved. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Recorded the decision, feature tree, canonical terms, Phase 1 exclusions; links moved to `docs/policies/`. |
