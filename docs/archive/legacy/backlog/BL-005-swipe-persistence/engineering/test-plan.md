# BL-005 Test Plan

Standard: [tdd.md](../../../policies/engineering/tdd.md).

## Scenario tests
| Scenario | Level | Test file | Test name |
|---|---|---|---|
| BL-005-S01 | ViewModel unit | `apps/mobile/test/features/discovery/presentation/discovery_view_model_test.dart` | [BL-005-S01] like persists usr_01 and advances |
| BL-005-S02 | ViewModel unit | same | [BL-005-S02] swiped profiles are filtered on reload |
| BL-005-S03 | Widget | `apps/mobile/test/features/discovery/presentation/discovery_view_test.dart` | [BL-005-S03] all swiped shows empty view |
| BL-005-S04 | Widget | same | [BL-005-S04] reset feed history restores usr_01 |
| BL-005-S05 | ViewModel unit | `discovery_view_model_test.dart` | [BL-005-S05] storage write failure surfaces an error |

## Required supporting tests
- Repository: an empty or missing key returns all profiles; a malformed stored value throws `StorageFailure`; `clearSwipeHistory()` removes the key.
- Use `InMemoryLocalStorage` and a failing `LocalStorage` fake; no real storage.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Created |
| 2026-10-30 | [CHG-010](../../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
