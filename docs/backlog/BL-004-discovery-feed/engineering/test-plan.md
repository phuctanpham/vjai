# BL-004 Test Plan

Standard: [tdd.md](../../../policies/engineering/tdd.md). Existing tests do not carry IDs yet; [CHG-002](../../../changes/CHG-002-restore-green-build.md) renames them.

## Scenario tests
| Scenario | Level | Test file | Current test → required name |
|---|---|---|---|
| BL-004-S01 | Widget | `test/features/discovery/presentation/discovery_view_test.dart` | "renders profile card and controls when loaded" → `[BL-004-S01] …` |
| BL-004-S02 | ViewModel unit | `test/features/discovery/presentation/discovery_view_model_test.dart` | "advances current index …" → `[BL-004-S02] …` (also assert the recorded swipe) |
| BL-004-S03 | Widget | `discovery_view_test.dart` | missing: swipe the last card, expect `EmptyView` |
| BL-004-S04 | Widget | `discovery_view_test.dart` | "renders ErrorView … allows retry" → `[BL-004-S04] …` (also tap Try Again) |
| BL-004-S05 | Widget, 1280 × 800 | `discovery_view_test.dart` | "renders desktop layout with sidebar" → `[BL-004-S05] …` |
| BL-004-S06 | Widget, 400 × 800 | `discovery_view_test.dart` | missing |

## Required supporting tests
- `Profile`: equality, `hashCode` with non-const lists, `copyWith`, JSON round trip.
- Repository: success, empty, failure for `getProfiles` and `recordSwipe`.
- ViewModel: loaded, empty, error, retry; duplicate swipe ignored while busy.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Created from APRD-001 and existing tests |
