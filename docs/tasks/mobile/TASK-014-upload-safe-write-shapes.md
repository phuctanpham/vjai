# TASK-014: Upload-safe write shapes and a write guard

> **Phase:** P3 preparation · refactor of P2 code  
> **Track:** M (no backend needed)  
> **Status:** Draft · needs CHG-015 approval and an implementation plan from the Engineering Manager  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) F-06, F-07, F-08, F-14)  
> **Dependencies:** [TASK-011](TASK-011-phone-schema-v2-alignment.md) (column classes) · **Blocks:** TASK-017  
> **Source:** Flow Spec v2.8 T4 › Write path, Phone schema · DB handbook §2 C03-06, C04-04…C04-08, §3 D05

## Why

With PowerSync every `INSERT`, `UPDATE` and `DELETE` on a synced table becomes one CRUD op in
the upload queue: PUT, PATCH or DELETE. Phase 2 code "upserts" by deleting a row and inserting
it again, and rewrites all review drafts on every edit. Uploaded as they are, these statements
would delete server rows, send PUTs for tables the phone may only PATCH, and send ops for tables
the phone may not write at all. The ops must say what the user did.

## Findings

| Code | Statement pattern | Ops it would upload | Rule broken |
|---|---|---|---|
| `LocalStudioRepository.saveBatch` | `DELETE` + `INSERT upload_batches` per save | DELETE + PUT of the batch | A batch delete means erasure (D05) |
| same | `DELETE FROM extracted_items WHERE batch_id` + re-insert every draft, on every edit | N × DELETE + N × PUT | Phone may only PATCH `value`, `last_worn_input` (ST-07) |
| `_upsertAsset` | `DELETE` + `INSERT media_assets` | DELETE + PUT | Unique slot index (D04) is broken for a moment; it reads as a removed photo |
| `_recordJobs` | `DELETE` + `INSERT ai_processing_jobs` | DELETE + PUT | Read-only table |
| `LocalGuMatchRepository.startSession` | `UPDATE gu_match_sessions SET recent = 0` | PATCH of a server field | `recent` is server-owned |
| `buildDeck`, `swapItem`, `updateSwipeStatus` | `INSERT` / `UPDATE outfit_candidates` | PUT / PATCH | Read-only table (BE-012-S06) |
| `LocalWardrobeRepository.saveItems` | `updated_at` = save time + i µs, used for order | — | A later PATCH reorders the Archive (F-07) |
| `LocalPrivacyRepository.withdrawBodyConsent` | `DELETE ai_processing_jobs` and `media_assets` | DELETE on a read-only table | From P4 this is a `privacy_requests` BODY row (TASK-027) |
| `LocalPrivacyRepository.counts` | No `user_id` filter | — | Owner-scoped reads (F-14) |

## Scope

1. **Insert once, then patch changed columns.** Phone-owned rows are inserted when first seen.
   After that, only the columns that changed are updated (PATCH semantics, C03-06). Removing a
   tray photo stays `removed = 1` (an update, never a delete). Review edits update
   `extracted_items.value` / `last_worn_input` of the one draft that changed.
2. **Server-owned writes go to mirrors.** Writes to `ai_processing_jobs`, `extracted_items`
   inserts, `outfit_candidates`, and the server fields of `gu_match_sessions` and
   `upload_batches` go to the `fake_*` mirrors defined in TASK-011. Read models union the real
   and mirror rows. With the dev connector on (TASK-018), the fakes stop writing.
3. **Stable Archive order.** Order by `created_at DESC, id`. Inside one save, `created_at` is
   the save instant minus i µs, so review item 0 comes first. `updated_at` is no longer used for
   order. The migration keeps the order of existing rows.
4. **Write guard.** A test-only `RecordingConnection` wraps `SqliteConnection`, maps each
   statement to (table, op, columns), and checks it against the TASK-011 column classes. Every
   repository contract test runs under it. One allow-list in `phone_schema.dart`; BE-011 holds
   the same table (parity through TASK-012).

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-014-S01 | Saving a batch twice with one edited draft records 1 PATCH of that draft's `value` and no other op on `extracted_items` | Repository (`RecordingConnection`) |
| TASK-014-S02 | No repository issues `DELETE` on a synced table except where the contract allows it (DOC-004 Q7 lists them) | Repository, all contract suites |
| TASK-014-S03 | No repository writes a read-only table or a server column; fakes write only `fake_*` | Repository + architecture |
| TASK-014-S04 | Removing a photo from the tray is one PATCH (`removed = 1`, `attachment_id = NULL`); the file is deleted after the commit | Repository |
| TASK-014-S05 | Archive order: newest save first, review order inside a save; patching an item's name later does not move it | Contract (Mock and Local) |
| TASK-014-S06 | Privacy counts ignore another owner's rows | Repository |
| TASK-014-S07 | Flow A, Flow B and persistence-restore journeys pass unchanged; crash images (TASK-009-S02) still give all or none | Journey + integration |

## File confinement

- `apps/mobile/lib/features/{studio,wardrobe,gu_match,privacy}/data/local_*.dart`
- `apps/mobile/lib/core/storage/phone_schema.dart` (allow-list only), migration step in `garblo_database.dart`
- `apps/mobile/test/helpers/` (`RecordingConnection`), contract suites, mirrored tests

## Anti-scope

No upload queue (TASK-017). No network. No change to what the user sees. Mock repositories are
not changed.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
