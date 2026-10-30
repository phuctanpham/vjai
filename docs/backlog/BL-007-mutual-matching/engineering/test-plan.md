# BL-007 Test Plan

Standard: [tdd.md](../../../policies/engineering/tdd.md).

## Scenario tests
| Scenario | Level | Test file | Test name |
|---|---|---|---|
| BL-007-S01 | ViewModel unit + widget | `apps/mobile/test/features/discovery/presentation/discovery_view_model_match_test.dart`, `apps/mobile/test/features/matching/presentation/match_celebration_dialog_test.dart` | [BL-007-S01] like and superlike on usr_01 emit one match event / dialog shows title and name |
| BL-007-S02 | Widget | `match_celebration_dialog_test.dart` | [BL-007-S02] keep swiping closes dialog and shows next candidate |
| BL-007-S03 | Widget | same | [BL-007-S03] send a message opens conversation placeholder |
| BL-007-S04 | ViewModel unit | `discovery_view_model_match_test.dart` | [BL-007-S04] like on usr_02 emits no match event |
| BL-007-S05 | ViewModel unit | same | [BL-007-S05] pass on usr_01 emits no match event |

## Required supporting tests
- `Match`: equality, `hashCode`, JSON round trip with a fixed `createdAt`.
- Repository: `recordMatch` then `getMatches`; failure path → no celebration.
- Dialog at 400 × 800 and 1280 × 800 (max width 400 on desktop).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Created |
| 2026-10-30 | [CHG-010](../../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
