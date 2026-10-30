# BDD Standard — active wardrobe work

How the APM writes active `product/uat.feature` files. Each scenario is both
the acceptance test (UAT) and the input to the test plan. The former dating
BDD files are archived under [`../../archive/legacy/backlog/`](../../archive/legacy/backlog/)
and are historical only; do not extend, revive or use their vocabulary.

## Rules
1. **One file per item:** Active wardrobe phase work lives under
   `tasks/mobile/` or `tasks/backend/`; any future backlog item must be
   explicitly created and approved under the active documentation structure.
2. **Stable IDs.** Tag every scenario `@BL-NNN-Sxx` (for example `@BL-005-S02`). IDs are never reused or renumbered. A retired scenario keeps its ID and gets the extra tag `@retired`.
3. **Observable behaviour.** `Then` steps describe what the user sees or what a contract returns, not internal variables. Assertions on internal state are allowed only for items with no UI (for example networking).
4. **Deterministic data.** Use fixture names and IDs from
   [data-schema.md](../engineering/data-schema.md). Do not copy dating
   fixtures or IDs from archived BDD.
5. **Canonical words.** Steps use only [terminology.md](terminology.md) terms and the standard copy from [design-system.md](design-system.md).
6. **One behaviour per scenario.** Use `Background:` for shared `Given` steps and `Scenario Outline:` for data variations.
7. **Cover every state.** Each item covers its happy path plus every `empty` and `error` behaviour it introduces.
8. **Layouts.** When behaviour differs between mobile and desktop, write a scenario for each.

## Historical example (not an active requirement)
```gherkin
Feature: Local swipe persistence

  @BL-005-S02
  Scenario: Swiped profiles are filtered on reload
    Given "usr_01" and "usr_02" were swiped earlier
    When the discovery feed loads
    Then the first candidate shown is "usr_03"
```

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Created |
| 2026-10-30 | [CHG-013](../../changes/CHG-013-final-documentation-cleanup.md) | Clarified that this standard governs active wardrobe work; dating BDD is archived and historical. |
