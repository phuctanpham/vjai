# Design System

Visual and interaction rules for every screen. Source of truth for UI decisions; code in `lib/app/theme/` implements it.

## 1. Foundations

| Token | Value |
|---|---|
| Framework | Material 3 (`useMaterial3: true`) |
| Colour | `ColorScheme.fromSeed(seedColor: #FF4B6E)`, light and dark, `ThemeMode.system` |
| Colour usage | Always from `Theme.of(context).colorScheme`. Hard-coded colours only for the swipe actions below and white text on photo overlays |
| Typography | Material text theme. Names: `headlineMedium` bold; section titles: `titleLarge`/`titleMedium` bold; body: `bodyMedium`/`bodyLarge` |
| Spacing scale | 4 · 8 · 12 · 16 · 20 · 24 · 32 |
| Corner radius | 12 list tiles · 16 cards and chips · 20 profile card |
| Touch target | ≥ 48 × 48 logical px |
| Brand mark | `Icons.local_fire_department_rounded` + "Garblo" |

## 2. Layout

| Class | Width | Structure |
|---|---|---|
| Mobile | `< 800` | App bar; full-width content; primary actions at the bottom |
| Desktop | `≥ 800` | 240 px navigation sidebar; centred content; optional detail panel on the right |

Maximum content widths on desktop: profile card 480 × 700 · auth form 420 · onboarding 560 · matches 720 · dialogs 400.

Layout is chosen by available width, never by operating system.

## 3. Components

| Component | Rule |
|---|---|
| Loading | Centred `CircularProgressIndicator` |
| Empty | `EmptyView` (`lib/core/widgets/`): icon, title, message, optional outlined action |
| Error | `ErrorView`: "Something went wrong", message, filled "Try Again" button |
| Swipe actions | Pass: `close`, red · Superlike: `star`, blue · Like: `favorite`, green. Circular, sizes 64 / 54 / 64, every button has a tooltip |
| Profile card | Photo or gradient fallback, dark bottom gradient, name + age, occupation, distance, bio (3 lines), interest chips |

## 4. Standard copy

| Situation | Text |
|---|---|
| Feed exhausted | "You're all caught up!" · action "Refresh Feed" |
| Generic error | "Something went wrong" · action "Try Again" |
| No matches | "No matches yet!" |

## 5. Known deviations in code
- Swipe buttons use `Colors.white` as background, which fails in dark mode.
- The discovery app bar uses `Colors.deepOrangeAccent` instead of `colorScheme.primary`.

Fix through a CHG record; do not copy these patterns.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Created from the implemented theme, layouts and backlog item constraints |
