# CHG-002: Restore a green build

| Status | Source | Date |
|---|---|---|
| Draft | Codebase analysis | 2026-10-16 |

**Must be done before any other backlog item:** the quality gates cannot pass until it is.

## Problem
Found by reading the code; no toolchain was available to confirm.
1. `discovery_view.dart`: `Text('Garblo', fontWeight: FontWeight.bold)`. `Text` has no `fontWeight` parameter, so the app does not compile.
2. Platform folders `android/ ios/ windows/ macos/` are missing, so `flutter run` cannot target the supported platforms.
3. `discovery_view_test.dart` "renders loading state initially" leaves a 10 s timer pending, which fails the test.
4. Widget tests run at 800 × 600 (the desktop layout), so the mobile layout is never tested.
5. `Profile.hashCode` and `DiscoveryState.hashCode` hash list identity rather than contents, so equal objects can have different hash codes.
6. `DiscoveryViewModel.swipe` swallows repository errors with an empty `catch`; neither `swipe` nor `retry` blocks duplicate calls.
7. Analyzer warnings: unused `theme` locals in `discovery_layout.dart`; `isCompact` is always false.
8. `ThemeData.cardTheme: CardTheme(...)` breaks on Flutter ≥ 3.27 (`CardThemeData`); `withOpacity` is deprecated there. Flutter version not pinned.
9. `.gitignore` ignores `*.lock`, dropping `apps/mobile/pubspec.lock` and `uv.lock`.
10. Backend: Pydantic v1-style `class Config`; `cors_origins` typed as list but set to a tuple; `allow_credentials=True` with origin `*`.
11. Fixture drift: `usr_01` has 2 images in Python, 1 in Dart.
12. Existing discovery tests do not carry BL-004 scenario IDs.

## Product impact (APM)
| Affected | Change needed |
|---|---|
| BL-004 | None to behaviour. Product acceptance re-run once scenario IDs are in test names |
| design-system.md | Known deviations (white swipe buttons, hard-coded app bar colour) may be fixed here or in a later CHG |

## Engineering impact (ASEM)
| Affected | Change needed |
|---|---|
| ci-cd.md | Pin the Flutter version; remove the lock-file note once fixed |
| codebase-map.md | Add platform folders |
| data-schema.md | Remove the fixture-drift note once fixed |

## Code follow-up
| Role | Paths | Tests | Done |
|---|---|---|---|
| App Developer | `apps/mobile/lib/features/discovery/**`, `apps/mobile/lib/app/theme/app_theme.dart`, `apps/mobile/test/features/discovery/**`, platform folders (`flutter create --platforms=android,ios,windows,macos .`), `.gitignore` | Rename tests with `[BL-004-Sxx]`; add mobile-layout and hashCode tests | [ ] |
| Backend Developer | `backend/app/models/*.py`, `backend/app/config.py`, `backend/app/main.py`, `backend/app/data/sample_data.py` | Existing pytest suite stays green | [ ] |
