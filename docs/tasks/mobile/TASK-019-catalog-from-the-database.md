# TASK-019: Item-type catalog from the database

> **Phase:** P3 · P3-05 (catalog part)  
> **Track:** M (catalog from the mock feed) → R (catalog stream through PowerSync)  
> **Status:** Draft · needs CHG-015 approval and an implementation plan from the Engineering Manager  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) F-18)  
> **Dependencies:** [TASK-011](TASK-011-phone-schema-v2-alignment.md) (`item_types` id = `type_code`), [TASK-010](TASK-010-mock-backend-integration.md); backend [BE-013](../backend/BE-013-mock-change-feed.md) `catalog` stream  
> **Source:** Flow Spec v2.8 T6 › P3-05 ("changing the catalog in MongoDB updates the phone without a release") · T4 › Sync Streams › catalog · DB handbook WD-02

## Why

`ItemTypeCatalog` is a Dart constant. The domain calls `ItemTypeCatalog.groupOf` in entities,
the generator, SQL filters and the review type picker. The migration copies the constant into
`item_types`, but nothing reads that table. In P3 the catalog is server data, so a new type
must appear without an app release, and an unknown code must not crash the Archive.

## Scope

- `ItemTypeRepository` (`watchAll`, `byCode`), with a Local implementation over `item_types`.
  An `itemTypesProvider` feeds the ViewModels.
- Domain code takes the catalog as an argument (`WardrobeItem.group` resolved through it, not
  through the constant). The constant remains only as the **offline bootstrap seed**, used when
  the table is empty before the first sync.
- The migration seeds `item_types` into a local-only `fake_item_types` mirror, so the phone
  never writes the read-only table (C04-07). Reads union both until the first catalog sync.
- An unknown `type_code` (a newer server type, or one removed) groups the Piece under its
  `group_code` if known, else shows it under All only. It never throws in a widget.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-019-S01 | A new type in the `catalog` feed appears in the review type picker and the group filter without a restart | Repository + widget |
| TASK-019-S02 | Before any sync, the picker shows the 15 bootstrap types (TASK-003 codes unchanged) | Widget |
| TASK-019-S03 | A Piece whose type is unknown shows under All, keeps its group count, and does not throw | Repository + widget |
| TASK-019-S04 | No code under `lib/features/` reads `ItemTypeCatalog.all` except the bootstrap seed (architecture test) | Architecture |
| TASK-019-S05 | Track R: the same tests pass with `item_types` delivered by the PowerSync `catalog` stream (runs in TASK-020's suite) | Integration |

## Anti-scope

No badges, levels, quests or factors (Flow C). No type editing on the phone.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
