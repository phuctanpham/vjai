# Design System

The [Garblo Flow Spec](../../tasks/mobile/Garblo%20Flow%20Spec.html) T7 is
the source of truth for UI tokens, layout, interaction patterns and copy.
This policy records only the implementation bridge and accepted deviations;
it must not recreate T7 or reintroduce the retired dating design.

## 1. Authority and implementation

- T7 G0–G4 defines the visual contract and wins over older prose.
- `apps/mobile/lib/app/theme/` implements the tokens and themes.
- Widgets use theme tokens and localized product copy; they do not hard-code
  product colours or strings.
- Layout is selected from available width with `LayoutBuilder` or
  `MediaQuery`, never from the operating system.

## 2. Product tokens

| Token | Contract |
|---|---|
| Primary | Warm forest green `#1F5A2E`; dark theme primary `#7BC88A` |
| Working state | Violet means Garblo is working |
| Social accent | Cobalt is reserved for social/community surfaces |
| Anchor lock | Lime is reserved for the anchor-lock ring |
| Status | Use the T7 status dot/triangle plus a word; do not communicate status by colour alone |
| Product pillars | Add, Wardrobe, Gu Match, Impact, Community |

The exact type scale, spacing, grid, shapes, motion, shell modes and
component redlines remain in T7 G0–G3. UI copy and the glossary remain in
T7 G4.

## 3. Responsive contract

The application retains the accepted 800 px mobile/desktop breakpoint from
D-003 and CHG-003 Q-02. T7 grid thresholds still apply to grids and columns
where specified; the 800 px value is the application shell breakpoint.

| Class | Width | Structure |
|---|---|---|
| Mobile | `< 800` | Full-width content and bottom pillar navigation |
| Desktop | `≥ 800` | Multi-column layout or side navigation as defined by T7 |

## 4. Required states and copy

Screens that load data expose `initial`, `loading`, `loaded`, `empty` and
`error` states. Empty, error, trust and commit copy follows the relevant T7
screen and G4 glossary. Do not use dating copy such as “Feed”, “Match” or
“You're all caught up!” unless it is explicitly part of a legacy feature.

## 5. Phase-truth rule

Trust statements describe only behavior implemented in the current phase:

- P1 does not claim EXIF/GPS stripping or bystander blurring.
- P2 may claim implemented metadata stripping.
- Bystander blurring is not claimed until its implementation phase.

## 6. Known deviations

- The 800 px application breakpoint is retained even where T7 uses 600/840/1024
  grid thresholds.
- The legacy discovery feature retains its old visual contract until a
  separate removal or migration change.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Created from the implemented theme, layouts and backlog item constraints |
| 2026-10-30 | [CHG-007](../../changes/CHG-007-documentation-authority-migration.md) | Aligned active UI policy with Flow Spec T7 and CHG-003 |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
