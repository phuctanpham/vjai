# BE-003: Wardrobe items, item-type catalog, wear events, dormancy parity

> **Owner:** Backend Developer  
> **Status:** Blocked by [BE-001](BE-001-platform-decision.md)  
> **Spec phase:** P3 (catalog + seed, P3-03) · P4 (write path, P4-B03, P4-B08 parity)  
> **Source:** UC-04, UC-07 AC-07.7 · T2 (C4, P6, I8, I9) · T4 (wear_events, derived values) · TAC-04.2, 04.5, 07.4

## Why

Phase 1 seeds 9 wardrobe items in `MockWardrobeRepository`, keeps the
item-type catalog in Dart (`ItemTypeCatalog`), and computes dormancy on the
phone (`DormancyRules`). The spec requires the server to compute the **same**
values from the **same** golden fixtures (T3 › Shared rules, TAC-04.2).

## Contract fixed by Phase 1 (do not break)

| Mobile type | Fields / rule | Test that pins it |
|---|---|---|
| `ItemGroup` | `TOPS, BOTTOMS, SHOES, BAGS, HATS, ACCESSORIES` | `item_type_test.dart` |
| `ItemType` | `code`, `group`, `label`; one group per type | `item_type_test.dart` |
| `WardrobeItem` | `itemId, name, typeCode, color, material, styleTag, aiConfidence?, sourceAssetId?, createdAt, lastWornEstimate?, isArchived` (T4 phone-schema names) | `wardrobe_item_test.dart` |
| Listing | non-archived only, newest first, pages of 20 by cursor, total independent of group filter (AC-04.3, AC-04.7, TAC-04.5) | `wardrobe_repository_test.dart` |
| Ready count | Same count as the Wardrobe total (I9) | `wardrobe_repository_test.dart` |
| Dormancy | days since latest of (wear event, Last-worn estimate), else since `createdAt`; badge at ≥ 30 (I8) | `dormancy_test.dart` (golden fixtures) |
| `WearEvent` | `wornDate`, `itemIds`, `candidateId?`, `signature` = sorted item IDs; one per (user, date, signature) (TAC-07.4); append-only | `wear_repository_test.dart` |

## Scope

- `GET /v1/wardrobe/items?group=&cursor=`, `POST /v1/wardrobe/wear-logs`.
- Item-type catalog served to the phone (P3 catalog stream or REST).
- Server dormancy computed from the shared golden fixtures; a parity test
  that runs the Dart fixtures' expected values.
- Seed script for the 9 demo items + the 41-day White T-shirt.

## Anti-scope

No item detail, archive, delete or add-without-photo endpoints (Gap ②, needs spec).
No rewards or rescue XP (Flow C).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created from the Phase 1 Wardrobe contract. |
