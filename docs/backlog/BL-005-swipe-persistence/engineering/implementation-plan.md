# BL-005 Implementation Plan

## Generated files
| Role | Path | Change |
|---|---|---|
| App Developer | `apps/mobile/lib/features/discovery/data/discovery_repository.dart` | Inject `LocalStorage`; `getProfiles()` filters swiped IDs; `recordSwipe()` persists the ID; add `clearSwipeHistory()` |
| App Developer | `apps/mobile/lib/features/discovery/presentation/discovery_view_model.dart` | Add `resetFeed()`; surface swipe-persistence failures |
| App Developer | `apps/mobile/lib/features/discovery/presentation/discovery_view.dart` | App-bar menu item "Reset Feed History" |
| App Developer | `apps/mobile/test/features/discovery/data/discovery_repository_test.dart` | New tests |
| App Developer | `apps/mobile/test/features/discovery/presentation/discovery_view_model_test.dart`, `discovery_view_test.dart` | New tests |

**Locked:** everything else, including `apps/mobile/lib/core/storage/local_storage.dart` (use the existing interface).

## State model
| Stored IDs | Result |
|---|---|
| `[]` | `loaded`, `usr_01` first |
| `[usr_01, usr_02, usr_03]` | `loaded`, `usr_04` first |
| all five | `empty` |
| after reset | `loaded`, `usr_01` first |

## Contracts
- **Boundary:** `MockDiscoveryRepository` receives `LocalStorage` through `discoveryRepositoryProvider` (`ref.watch(localStorageProvider)`). Widgets call `resetFeed()` on the ViewModel only.
- **Data:** key `garblo_swiped_profile_ids`, a JSON array of IDs ([data-schema.md §5](../../../policies/engineering/data-schema.md)).
- **Failure behaviour:** storage read or write errors throw `StorageFailure`. A failed write must not be reported as a persisted swipe; the ViewModel shows the error.

## Sequence
1. Repository: storage injection → filter → persist → clear.
2. ViewModel: `resetFeed()`, error handling.
3. View: menu action.

## Verification
`dart format --output=none --set-exit-if-changed .` · `flutter analyze` · `flutter test test/features/discovery/`

## Engineering acceptance
Pending.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Migrated from TASK-005; key format fixed to a JSON array |
| 2026-10-30 | [CHG-010](../../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
