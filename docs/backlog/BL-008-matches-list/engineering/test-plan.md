# BL-008 Test Plan

Standard: [tdd.md](../../../policies/engineering/tdd.md).

## Scenario tests
| Scenario | Level | Test file | Test name |
|---|---|---|---|
| BL-008-S01 | Widget | `apps/mobile/test/features/matching/presentation/matches_view_test.dart` | [BL-008-S01] empty state routes to discovery |
| BL-008-S02 | Widget | same | [BL-008-S02] carousel and list show both matches |
| BL-008-S03 | ViewModel unit | `matches_view_model_test.dart` | [BL-008-S03] case-insensitive search filters matches |
| BL-008-S04 | ViewModel unit + widget | both files | [BL-008-S04] error then retry loads matches |
| BL-008-S05 | Widget | `matches_view_test.dart` | [BL-008-S05] tapping a match opens conversation placeholder |

## Required supporting tests
- Search with no results shows the no-results message, not the empty state.
- Layouts at 400 × 800 and 1280 × 800 (max width 720).
- Relative time is fixed by an injected clock.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Created |
| 2026-10-30 | [CHG-010](../../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
