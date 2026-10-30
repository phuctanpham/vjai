# BL-004 Implementation Plan (as built)

## Generated files
| Role | Path |
|---|---|
| App Developer | `apps/mobile/lib/features/discovery/domain/{profile,swipe_type}.dart` |
| App Developer | `apps/mobile/lib/features/discovery/data/discovery_repository.dart` |
| App Developer | `apps/mobile/lib/features/discovery/presentation/{discovery_state,discovery_view_model,discovery_view}.dart`, `widgets/{discovery_layout,profile_card}.dart` |
| App Developer | `apps/mobile/test/features/discovery/**` |
| Backend Developer | `backend/app/api/v1/endpoints/discovery.py`, `backend/app/models/profile.py`, `backend/app/data/sample_data.py`, `backend/tests/test_discovery.py` |

## State model
| Status | Trigger | UI | Actions |
|---|---|---|---|
| `initial` / `loading` | View mounted / request started | Progress indicator | none |
| `loaded` | ≥ 1 profile | `DiscoveryLayout` + `ProfileCard` | swipe, reload |
| `empty` | 0 profiles or queue exhausted | `EmptyView` | Refresh Feed |
| `error` | Repository throws | `ErrorView` | Try Again |

## Contracts
- **Data:** `Profile`, `SwipeRequest`, `SwipeResponse` in [data-schema.md](../../../policies/engineering/data-schema.md).
- **Failure behaviour:** load failures show `ErrorView`. Swipe failures are currently swallowed, which violates policy ([CHG-002](../../../changes/CHG-002-restore-green-build.md)).

## Engineering acceptance
Built before this system existed. Known defects are listed in CHG-002.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Recorded from existing code and APRD-001 |
| 2026-10-30 | [CHG-010](../../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
