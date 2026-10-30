# BE-006: MongoDB collections and Sync Streams match phone schema v1

> **Owner:** Backend / DevOps  
> **Status:** Blocked by [BE-001](BE-001-platform-decision.md)  
> **Spec phase:** P3 (P3-01 MongoDB, P3-02 PowerSync Sync Streams, P3-03 seeds) · P4 (P4-B01 identity, P4-B02 write handler)  
> **Source:** spec T4 › Phone schema, Sync Streams, Write path, R2, R8 · [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md)

## Why

Mobile Phase 2 stores everything in a local SQLite database whose tables are
**phone schema v1** (CHG-005). In P3 the phone swaps that database for
PowerSync, which builds the same tables as views over synced data. If the
MongoDB collections or the Sync Streams use different names, columns or ID
formats, the swap stops being mechanical and phone data is lost or duplicated.

Garblo is a lookbook generating and matching app; none of these collections
holds people or matches between people (see
[README › Read this first](README.md#read-this-first-garblo-is-not-a-dating-app)).

## Contract fixed by Phase 2 (do not break)

| Rule | Detail | Pinned by |
|---|---|---|
| Table and column names | Exactly as listed in CHG-005 › Phone schema v1, defined in `lib/core/storage/phone_schema.dart` | `[TASK-005-S02]` |
| IDs | Every row has `id`: 24 lowercase hex characters (ObjectId), generated **on the phone** (R8). Sync queries map `_id AS id` | `[TASK-005-S06]` |
| Types | `TEXT`, `INTEGER`, `REAL` only. Dates are ISO-8601 text; booleans 0/1; JSON columns are text (`items`, `ai`, `value`, `last_worn_input`, `occasions`) | `[TASK-005-S02]` |
| No DB-enforced uniqueness | PowerSync tables are views: no UNIQUE, no foreign keys. Idempotency comes from **deterministic IDs**: a wear event's ID is a hash of owner + worn date + Fit signature; a wardrobe item's ID is a hash of its review draft ID. The write handler must treat a duplicate `_id` from the same owner as already applied | `[TASK-005-S04]`, `[TASK-005-S07]` |
| Owner | `user_id` is a random ObjectId generated once per install and kept in secure storage. In P4 it becomes the anonymous JWT `sub` (no re-keying); the auth service must accept a phone-generated `sub` for the first anonymous account | `[TASK-005-S10]` |
| Append-only | `wear_events` and `consents` are insert-only; withdrawing consent sets `revoked_at` | TASK-005, TASK-008 |
| Derived, not stored | Last worn, wear count, dormancy and rescue eligibility are queries over `wear_events` (R2). The phone stores **provisional** `gap_days` / `rescue_eligible` in `wear_events.items`; the server recomputes them (BE-003) | `[TASK-006-S03]` |

## Scope

- MongoDB collections and `$jsonSchema` validators for the phone schema v1
  tables (P3-01).
- Sync Streams `my_wardrobe`, `my_studio`, `my_decks`, `catalog` returning
  exactly these columns (P3-02).
- Seed scripts for `item_types` matching `ItemTypeCatalog` (P3-03).
- A parity test: run the phone's schema description against the deployed
  Sync Streams and fail on any difference.
- Verify on a PowerSync view that a write-transaction "check the ID, then
  insert" works as the phone expects (the phone does not use
  `INSERT OR IGNORE`, which views may not support).

## Anti-scope

No Flow C/D collections in this card (rewards, check-ins, Community); no
change to the phone schema without a mobile CHG.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | Created from the Phase 2 phone schema v1 contract. |
