# TASK-002 · app-developer report

| Date | Status | Commits |
|---|---|---|
| 2026-10-29 | Complete (in review) | `cd3eb08` [TASK-002] test · [TASK-002] feat (this delivery) |

Item: [TASK-002 Mobile foundation](../tasks/mobile/TASK-002-mobile-foundation.md) · contract [CHG-003](../changes/CHG-003-wardrobe-direction-phase-1.md) · PR #2 (draft, "Phase 1 · red").

## Changed files
| Path | Purpose |
|---|---|
| `lib/app/router.dart` | `/` opens `AppShell`; every other route, including the retired `/discovery`, opens `UnknownRouteView` |
| `lib/app/theme/app_theme.dart` | T7 › G0 primary: `#1F5A2E` / on `#FFFFFF` (light), `#7BC88A` / on `#000000` (dark) |
| `lib/app/shell/app_shell.dart` | Header (garblo · 29° · bell) and 5-pillar navigation: 64-high `NavigationBar` below 800, `NavigationRail` at 800+ |
| `lib/app/shell/pillar_pages.dart` | Pillar → page map; Impact and Community show their flag-off state; Add/Archive/Gu Match map to the feature views (stubs until TASK-003/004) |
| `lib/app/shell/coming_soon_view.dart` | Flag-off state view |
| `lib/app/shell/unknown_route_view.dart` | "Page not found" with "Go to Add" |
| `lib/core/navigation/pillar.dart` | `Pillar`, G4 labels, `PillarController`, `pillarProvider` |
| `lib/core/time/clock.dart` | `SystemClock`, `clockProvider` |
| `lib/core/widgets/loading_view.dart` | Shared loading state |
| `lib/core/layout/breakpoints.dart` | `Breakpoints.desktop = 800` (added; see Deviations) |

## Scenario coverage
| Scenario | Test name | Result |
|---|---|---|
| TASK-002-S01 | [TASK-002-S01] app starts on the Add pillar · tapping a pillar switches the page | pass |
| TASK-002-S02 | [TASK-002-S02] unknown route renders the not-found destination · not-found destination returns to Add | pass |
| TASK-002-S03 | [TASK-002-S03] mobile shell uses a bottom navigation bar with 5 pillars | pass |
| TASK-002-S04 | [TASK-002-S04] desktop shell uses a navigation rail with 5 pillars | pass |
| TASK-002-S05 | [TASK-002-S05] loading view shows progress and no error copy · empty and error views are distinguishable | pass |
| TASK-002-S06 | [TASK-002-S06] × 6 layering rules | pass |
| TASK-002-S07 | [TASK-002-S07] Impact shows its coming-soon state · Community shows its coming-soon state | pass |
| TASK-002-S08 | [TASK-002-S08] default clock is the system clock · clockProvider can be overridden | pass |
| TASK-002-S09 | [TASK-002-S09] light primary is forest green with white text · dark primary is light forest green with black text | pass |

Non-scenario: header shows wordmark, temperature and bell (both layouts); `pillarProvider` switches the page from outside the shell; `/discovery` is no longer reachable. All pass.

## TDD evidence
- **Red:** `flutter test test/app/app_shell_test.dart test/app/router_test.dart test/app/theme test/core test/architecture` at `cd3eb08` → 8 passed, 16 failed. Failures were stub `UnimplementedError`s plus the old router (`DiscoveryView` on `/`) and coral theme. The 8 passes are the 6 layering guardrails, the existing empty/error views, and the clock override.
- **Green:** the same command → 24 passed, 0 failed.

## Gates
| Gate | Result |
|---|---|
| format (`dart format --output=none --set-exit-if-changed .`) | pass (whole repo) |
| analyze (`flutter analyze`) | pass, no issues |
| tests, TASK-002 files | 24 / 24 pass |
| tests, dating baseline (`test/features/discovery`) | 18 / 18 pass, unchanged |
| tests, full suite | 43 pass, 210 fail. Every failure is in a TASK-003 or TASK-004 test file (red by design) |

Toolchain: Flutter 3.24.5, Dart 3.5.4 (pinned by CHG-004).

## Deviations from plan
- Added `lib/core/layout/breakpoints.dart` so the shell and the feature layouts share one 800 px constant (D-003) instead of repeating it. TASK-002's file list is updated.
- `pillar_pages.dart` maps the Add, Archive and Gu Match pillars to the feature views now, so TASK-003/004 need no shell change. Their file lists are updated. Until those tasks are green, the running app shows an error on those three pillars, because the views are still stubs.

## Doc issues
- None blocking. CHG-003 Q-02 (800 vs. the spec's 840 tablet rail) is still open; the shell uses 800.

## Lesson candidates
- A Flutter `initialRoute` such as `/does-not-exist` first pushes `/`, so the shell sits off-stage under the not-found page. Router tests should find on-stage widgets only (the default) and expect the stack to be cleared on "Go to Add".
- Building fixtures from a stub at a test file's top level makes the whole file fail to load, which hides per-test red results. Build them in `setUp` or inside the tests.
