# TDD Standard

How the ASEM writes `engineering/test-plan.md` and how developers execute it.

## 1. Cycle
1. **Red:** write the planned tests, run them, and confirm each fails for the expected reason (missing behaviour, not a typo).
2. **Green:** write the minimum code that makes them pass.
3. **Refactor:** improve the code with all tests still green.

The developer report records the red run and the green run (command and pass/fail counts).

## 2. Test levels

| Level | Location | Covers |
|---|---|---|
| Domain unit | `test/features/<f>/domain/` | Equality, `hashCode`, `copyWith`, JSON round trip, validation |
| Repository unit | `test/features/<f>/data/` | Success, empty, failure, mutations, filtering |
| ViewModel unit | `test/features/<f>/presentation/` | Every status transition, duplicate-action blocking, retry |
| Widget | `test/features/<f>/presentation/` | Every status rendered; user actions; **both layouts** |
| Endpoint | `backend/tests/test_<feature>.py` | Status codes, body shape per data-schema, validation errors |

## 3. Rules
- **Scenario traceability.** Every `@BL-NNN-Sxx` scenario has at least one test whose name starts with `[BL-NNN-Sxx]`. Other tests need no ID.
- **Both layouts.** The default test surface is 800 × 600, which counts as desktop. Set the size explicitly in widget tests:
  `tester.view.physicalSize = const Size(400, 800)` for mobile and `Size(1280, 800)` for desktop, each with `devicePixelRatio = 1.0` and `addTearDown(tester.view.reset)`.
- **No pending timers.** Mocks use `Duration.zero`, or the test pumps past the delay before it ends.
- **No network or real storage.** Override providers with fakes or mocks via `ProviderScope(overrides: [...])`.
- **Deterministic.** No reliance on wall-clock time, random values or test order.

## 4. Test plan format
```markdown
| Scenario | Level | Test file | Test name |
|---|---|---|---|
| BL-005-S02 | ViewModel unit | test/features/discovery/presentation/discovery_view_model_test.dart | [BL-005-S02] swiped profiles are filtered on reload |
```
followed by a list of required non-scenario tests (edge cases, failures).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Created; merges test coverage rules from `docs/archive/legacy/quality/DOD.md` |
