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

**From Phase 2 (CHG-005):** the phone stores `wardrobe_items` and
`wear_events` in local SQLite with phone-generated ObjectIds. A wear event's
ID is deterministic (hash of owner + worn date + Fit signature), so the same
Fit logged twice on one day is one event on every device. Each event's
`items` JSON carries **provisional** `gap_days` and `rescue_eligible`
computed on the phone from logged wears only (N6); the server recomputes them
authoritatively (I12) and its values replace the phone's on sync. Item IDs
for indexed Pieces are hashed from their review draft ID, so a retried commit
cannot duplicate. Names and types: [BE-006](BE-006-phone-schema-sync-parity.md).

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
| Last worn estimate | A calendar date with no time, set once at index time from the review "Last worn" answer (A-01: lower bound of the bucket; never in the future); stored as an **estimate**, separate from wear events | `last_worn_test.dart`, `studio_view_model_test.dart` |
| Rescue rule (N6, I12) | A wear is a rescue only when the 30+ day gap is measured from a **logged** wear or the save date, never from the estimate. The rewards worker (P4-B08) must use the same rule and fixtures | `dormancy_test.dart` (`[TASK-003-S14]`) |
| Item IDs | Phase 1 uses readable placeholders (`seed_NN`, `item_b<batch>_<draftId>`). From P2 the phone generates ObjectId hex IDs (spec R8); the write handler must accept client IDs and treat a duplicate key from the same owner as already applied (TAC-03.2 retry) | — |
| Save atomicity | All Pieces of a batch or none; a retry never duplicates (TAC-03.2) | `wardrobe_repository_test.dart` |

## Scope

- `GET /v1/wardrobe/items?group=&cursor=`, `POST /v1/wardrobe/wear-logs`.
- Item-type catalog served to the phone (P3 catalog stream or REST).
- Server dormancy computed from the shared golden fixtures; a parity test
  that runs the Dart fixtures' expected values.
- Seed script for the 9 demo items, matching `MockWardrobeRepository.seeded`
  in `apps/mobile/lib/features/wardrobe/data/wardrobe_repository.dart` (White T-shirt
  benched 41 days, Short-sleeve shirt, Black jeans, Pleated skirt, Black
  loafers, White sneakers, Canvas tote, Bucket hat, Silk tie).

## Anti-scope

No item detail, archive, delete or add-without-photo endpoints (Gap ②, needs spec).
No rewards or rescue XP (Flow C).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created from the Phase 1 Wardrobe contract. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | From TASK-003 green: Last-worn estimate, rescue rule parity (N6/I12), client-generated IDs, save atomicity, seed list. |
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | Phase 2: local deterministic wear IDs, provisional gap_days/rescue_eligible, draft-hashed item IDs. |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
