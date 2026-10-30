# BL-008 Implementation Plan

## Generated files
| Role | Path | Change |
|---|---|---|
| App Developer | `apps/mobile/lib/features/matching/presentation/matches_state.dart` | `MatchesStatus { loading, loaded, empty, error }`, `matches`, `query`, derived `visibleMatches` |
| App Developer | `apps/mobile/lib/features/matching/presentation/matches_view_model.dart` | Load from `MatchingRepository.getMatches()`, `search(query)`, `retry()` |
| App Developer | `apps/mobile/lib/features/matching/presentation/matches_view.dart` | Screen per [information-layout.md](../product/information-layout.md) |
| App Developer | `apps/mobile/lib/features/matching/presentation/widgets/{new_matches_carousel,match_list_item}.dart` | Receive already-filtered data only |
| App Developer | `apps/mobile/lib/app/router.dart` | `/matches` route |
| App Developer | `apps/mobile/lib/features/discovery/presentation/widgets/discovery_layout.dart` | Sidebar "Matches" item navigates to `/matches` |
| App Developer | `apps/mobile/test/features/matching/presentation/**` | New tests |

**Locked:** `apps/mobile/lib/features/matching/{domain,data}/**` (BL-007 contract), auth, onboarding, backend.

## State model
| Status | Condition | UI | Actions |
|---|---|---|---|
| `loading` | Fetching | Progress indicator | none |
| `empty` | 0 matches | `EmptyView` "No matches yet!" + "Start Swiping" | go to `/discovery` |
| `loaded` | ≥ 1 match | Carousel + list | search, open match |
| `error` | Repository throws | `ErrorView` | Try Again |

## Contracts
- **Boundary:** filtering lives in the ViewModel (`visibleMatches`); widgets do not filter.
- **Data:** the canonical `Match`; no `Connection` or `Pair` types ([terminology.md](../../../policies/product/terminology.md)).
- **Failure behaviour:** errors and empty results are distinct states.

## Verification
`dart format --output=none --set-exit-if-changed .` · `flutter analyze` · `flutter test test/features/matching/`

## Engineering acceptance
Pending.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Migrated from TASK-008; sidebar wiring added |
| 2026-10-30 | [CHG-010](../../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
