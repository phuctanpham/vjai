# TASK-012: Shared golden fixtures for phone–server parity

> **Phase:** P3 preparation  
> **Status:** Draft · needs the Engineering Manager to approve the location (CHG-014 Q4) and record the test changes in a CHG  
> **Owner:** App Developer (export, Dart tests read the files) · Engineering Manager (location, CHG note)  
> **Raised by:** Backend Developer, backend + AI codebase analysis, 2026-10-30 ([CHG-014](../../changes/CHG-014-mock-first-backend-track.md))

## Why

The spec requires one rules library that runs on the phone and the server and
"is tested against the same fixtures" (T3 › Sync model › Shared rules; TAC-04.2;
DB handbook WD-08). Today the expected values exist only inside Dart tests. The
backend mock must reproduce several of them exactly (BE-011, BE-013, BE-016,
AI-005, BE-018). Copying them by hand would create two sources that drift
(docs/README.md §3 rule 1).

## Fixtures to export

| File (proposed `contracts/fixtures/`) | Source today | Used by |
|---|---|---|
| `object_id_vectors.json`: parts → `deterministicObjectId`, bytes → `stableHash` | `apps/mobile/lib/core/storage/object_id.dart` | BE-011-S01 |
| `item_types.json`: code, group, label | `ItemTypeCatalog` (`features/wardrobe/domain/item_type.dart`) | BE-013, BE-012 |
| `demo_wardrobe.json`: the 9 seeded Pieces and their dates relative to "today" | `MockWardrobeRepository.seeded`, `demo_seed.dart` | BE-013-S06 |
| `dormancy_cases.json`: item, wear events, estimate, today → days, badge, gap days, rescue | `dormancy_test.dart` (incl. `[TASK-003-S14]`), `[TASK-006-S03]` | BE-016 |
| `fake_extraction_sets.json`: the three sample sets; byte fixtures → set index | `LocalStudioRepository._samples`, CHG-006 G-01 tests | AI-005-S01, BE-018-S05 |
| `rule_decks.json`: wardrobe, context, days unworn → the deck (items, order, match %, highlight, title) | `fake_candidate_generator_test.dart` (`[fake-generator]`) | AI-005-S04, BE-015-S02 |
| `context_cards.json`: fixture cards in order | `MockGuMatchRepository` | AI-005-S06 |
| `images/`: stripped and unstripped JPEG/PNG | `test/helpers/image_fixtures.dart` | BE-018 |
| `sync/*.json`: recorded request/response pairs | written by the backend contract tests | TASK-010 |
| `enums.json`: every T2 enum and its wire values (incl. `last_worn_input.option`, `wear_events.source`) | Enum codecs from [TASK-013](TASK-013-wire-values-and-time.md) | TASK-013-S01, BE-011 models, BE-022 |
| `table_classes.json`: table → class, column → phone- or server-written | `PhoneSchema` after [TASK-011](TASK-011-phone-schema-v2-alignment.md) | TASK-014 write guard, BE-011/BE-012 allow-lists |
| `dormancy_cases.json` gains time-zone cases (a save at 06:00 in UTC+7) | TASK-013-S04 | BE-016 |

## Scope

- Write the JSON files; Dart tests **read** them (no expected values left inline),
  so a change to a rule fails both suites. Changing those tests is a TDD-loop test
  change: record it in a CHG.
- A small Dart helper `test/helpers/contract_fixtures.dart` that finds the repo-root
  folder from `apps/mobile/`.
- `codebase-map.md` gains the `contracts/` folder (ASEM).

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-012-S01 | Every listed file exists and parses; each Dart parity test reads its file | Unit |
| TASK-012-S02 | Changing one expected value in a file makes the matching Dart test fail (checked once, by hand, in the report) | Manual check |
| TASK-012-S03 | All existing tests still pass | Regression |

## Anti-scope

No rule changes. No backend code (the backend reads the files in its own cards).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created (Draft) by the Backend Developer |
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | App Developer: `enums.json`, `table_classes.json`, time-zone dormancy cases; runs after TASK-013 and TASK-011 so the files hold v2 values |
