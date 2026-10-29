# TASK-002: Mobile foundation and app-shell baseline

> **Phase:** 1 · Foundation  
> **Status:** Green · delivered, in review ([report](../../reports/TASK-002-app-developer.md))  
> **Dependencies:** [TASK-001](TASK-001-product-domain-alignment.md) · [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md)  
> **Target:** Flutter app shell, theme, routing, clock, shared state views  
> **Source:** Spec T1 (zone grammar, shell modes, accent tokens) · T6 P1-01 to P1-03 · V1 (flags off) · D1

## Objective

Create the smallest mobile foundation the wardrobe direction needs: one entry
route, a 5-pillar shell that adapts at 800 px, explicit shared state views, an
injectable clock, and the forest-green primary colour. Feature screens plug
into the shell; this task builds none of them.

## Scope

- `Pillar` enum and a `pillarProvider` that any feature may use to switch
  pillars (cross-feature navigation goes through `lib/core/`, never `lib/app/`).
- `AppShell`: header (Z0: `garblo` wordmark, static `29°`, bell) and pillar
  navigation labelled `ADD · ARCHIVE · GU MATCH · IMPACT · COMMUNITY`
  (T7 › G4). `< 800 px`: bottom `NavigationBar`, 64 high (T7 › G1/G2).
  `≥ 800 px`: `NavigationRail` (repo D-003; the spec's 840 tablet rail is
  CHG-003 Q-02).
  Each pillar page is wrapped in `KeyedSubtree(key: ValueKey('pillar-page-<name>'))`.
- Entry route `/` opens the shell on **Add**. Unknown routes render an explicit
  `UnknownRouteView` with a way back.
- Impact and Community render their flag-off state (V1): "Your impact report is
  coming soon" and "Coming soon".
- `LoadingView` added next to `EmptyView` and `ErrorView`.
- `Clock` interface, `SystemClock`, `clockProvider`.
- Theme primary from T7 › G0: warm light `#1F5A2E` / on-primary `#FFFFFF`,
  warm dark `#7BC88A` / on-primary `#000000` (D1).
- An architecture test that guards the layering rules for the new features.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-002-S01 | App starts on the Add pillar | Widget |
| TASK-002-S02 | Unknown routes render an explicit error destination with a way back | Widget |
| TASK-002-S03 | Below 800 px the shell uses a bottom navigation bar with the 5 pillars | Widget |
| TASK-002-S04 | At or above 800 px the shell uses a navigation rail with the 5 pillars | Widget |
| TASK-002-S05 | Loading, empty, and error views remain distinct | Widget |
| TASK-002-S06 | Presentation never imports data, ViewModels never import widgets, no `Platform.isX`, no cross-feature presentation imports | Architecture |
| TASK-002-S07 | Impact and Community show their flag-off state, never an error | Widget |
| TASK-002-S08 | Time is read through an overridable `clockProvider` | Unit |
| TASK-002-S09 | The primary colour follows T7 › G0: `#1F5A2E` light, `#7BC88A` dark | Unit |

## Test plan

| Scenario | Level | Test file | Test name |
|---|---|---|---|
| TASK-002-S01 | Widget | test/app/app_shell_test.dart | [TASK-002-S01] app starts on the Add pillar |
| TASK-002-S01 | Widget | test/app/app_shell_test.dart | [TASK-002-S01] tapping a pillar switches the page |
| TASK-002-S02 | Widget | test/app/router_test.dart | [TASK-002-S02] unknown route renders the not-found destination |
| TASK-002-S02 | Widget | test/app/router_test.dart | [TASK-002-S02] not-found destination returns to Add |
| TASK-002-S03 | Widget | test/app/app_shell_test.dart | [TASK-002-S03] mobile shell uses a bottom navigation bar with 5 pillars |
| TASK-002-S04 | Widget | test/app/app_shell_test.dart | [TASK-002-S04] desktop shell uses a navigation rail with 5 pillars |
| TASK-002-S05 | Widget | test/core/widgets/state_views_test.dart | [TASK-002-S05] loading view shows progress and no error copy |
| TASK-002-S05 | Widget | test/core/widgets/state_views_test.dart | [TASK-002-S05] empty and error views are distinguishable |
| TASK-002-S06 | Architecture | test/architecture/layering_test.dart | [TASK-002-S06] … (one test per rule) |
| TASK-002-S07 | Widget | test/app/app_shell_test.dart | [TASK-002-S07] Impact shows its coming-soon state |
| TASK-002-S07 | Widget | test/app/app_shell_test.dart | [TASK-002-S07] Community shows its coming-soon state |
| TASK-002-S08 | Unit | test/core/time/clock_test.dart | [TASK-002-S08] default clock is the system clock |
| TASK-002-S08 | Unit | test/core/time/clock_test.dart | [TASK-002-S08] clockProvider can be overridden |
| TASK-002-S09 | Unit | test/app/theme/app_theme_test.dart | [TASK-002-S09] light primary is forest green with white text |
| TASK-002-S09 | Unit | test/app/theme/app_theme_test.dart | [TASK-002-S09] dark primary is light forest green with black text |

Required non-scenario tests: the header shows the wordmark, temperature and
bell on both layouts.

Shared helpers: `test/helpers/layout.dart` (mobile 400 × 800, desktop
1280 × 800), `test/helpers/fixed_clock.dart`.

S06 is a guardrail: it scans source files, so it can pass against contract
stubs. It is still listed in the red-run report.

## File confinement

**App Developer may create or modify:**

- `lib/app/router.dart`, `lib/app/app.dart`, `lib/app/theme/app_theme.dart`
- `lib/app/shell/app_shell.dart`, `lib/app/shell/coming_soon_view.dart`,
  `lib/app/shell/unknown_route_view.dart`, `lib/app/shell/pillar_pages.dart`
  (`pillarPagesProvider`: maps each pillar to its page; tests override it so
  shell tests do not depend on feature screens)
- `lib/core/navigation/pillar.dart`, `lib/core/time/clock.dart`,
  `lib/core/widgets/loading_view.dart`, `lib/core/layout/breakpoints.dart`
  (`Breakpoints.desktop = 800`, shared so features do not hard-code it)
- `test/app/**`, `test/core/**`, `test/architecture/**`, `test/helpers/**`

**Locked:** `lib/features/discovery/**` and the other dating features,
`backend/**`, `pubspec.yaml` dependencies.

## Anti-scope

- Do not implement Flow A or Flow B business logic here.
- Do not add a database, authentication provider, AI service, or network
  dependency.
- Do not add platform checks to widgets.
- Do not preserve incompatible dating and wardrobe routes together: `/` and
  `/discovery` no longer open `DiscoveryView`.
- No first-launch screen (Gap ① needs spec), avatar initial, feature-flag
  service, ARB localisation, or live weather.

## Acceptance criteria

- The selected domain has one unambiguous entry route and shell.
- The breakpoint and state contracts have tests.
- `flutter analyze` reports zero issues.
- `dart format --output=none --set-exit-if-changed .` passes.
- Targeted Flutter tests pass.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | — | Created foundation task, gated by product-domain alignment. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Entry route = Add; 5-pillar shell with Impact/Community off states; Clock; D1 primary; test plan and file list added. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Review: G4 nav labels, 64 nav height, G0 dark primary `#7BC88A`. |
