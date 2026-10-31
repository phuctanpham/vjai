# TASK-011: Phone schema v2 — align with Flow Spec v2.8 T4 and the DB handbook

> **Phase:** P3 preparation  
> **Status:** Draft · needs an Engineering Manager CHG (schema change) and Product Manager review of the open items  
> **Owner:** Engineering Manager (CHG, plan) · App Developer (migration, tests)  
> **Raised by:** Backend Developer, backend + AI codebase analysis, 2026-10-30 ([CHG-014](../../changes/CHG-014-mock-first-backend-track.md))  
> **Related:** [DOC-001](../docs/DOC-001-phase-history-reconciliation.md) item 3 (deck ownership) · [BE-006](../backend/BE-006-phone-schema-sync-parity.md) · [BE-011](../backend/BE-011-mock-platform-core.md)  
> **Dependencies:** [TASK-013](TASK-013-wire-values-and-time.md) (migration v1 → v2 lands first; this card adds v2 → v3) · **Blocks:** TASK-014, TASK-017 · App Developer findings added under [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md)

## Why

Phone schema v1 (`apps/mobile/lib/core/storage/phone_schema.dart`, CHG-005/006)
was cut against Flow Spec v2.7. Spec v2.8 T4 and the
[DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>)
(§4–§8, §13) sync tables and columns that v1 does not have. They also make some
tables server-only that the phone writes today. P3 swaps SQLite for PowerSync "without renaming
anything" (P2-01), so every difference must be settled before P3-04. The mock
backend accepts v1 rows in the meantime (BE-011 makes the v2 columns optional).

## Differences found

| # | Area | Phone schema v1 | v2.8 T4 / DB handbook | Who decides |
|---|---|---|---|---|
| 1 | Missing tables | none | `profiles` (§4), `attachments`, `attachment_tickets` (§6), `privacy_requests` (§13), `vton_jobs` (§8) | ASEM |
| 2 | `gu_match_sessions` | `eligible_item_count`, `owned_only`, `deck_size`, `recent` written by the phone; no `status` or `context` | Phone writes `path`, `occasions`, `raw_prompt`, `event_title`, `window_start`, `window_end`, `city_id`, `ambient_temp_c`; **server** writes `status`, `context`, `eligible_item_count`, `owned_only`, `deck_size`, `recent`, `expires_at` | ASEM |
| 3 | Session status values | none | Handbook GM-02: `REQUESTED → GATHERING → ANALYZED → DECK_READY`, `NO_ELIGIBLE_ITEMS`, `FAILED`. **Not** in Flow Spec T2 › Enums | APM (spec owner) |
| 4 | Server-owned tables written by the phone | Local fakes write `ai_processing_jobs`, `extracted_items` (all columns), `gu_match_sessions` (server fields), `outfit_candidates` | Read-only for the phone; "until P4 the fakes write only to local-only `fake_*` mirror tables" (T4 › Phone schema, P3-04) | ASEM, with DOC-001 item 3 |
| 5 | `item_types.id` | `id` + `type_code` | `_id` = `type_code` | ASEM |
| 6 | Local-only tables | `session_draft` | Adds `ui_state`, `rewards_provisional`, `fake_*`; TASK-010 adds a checkpoint table and `sync_rejections` | ASEM |
| 7 | `wear_events.source` | Column exists; values not pinned in tests | Enum `LIKE_CONFIRM, ITEM, MULTI, CHECKIN, PHOTO, REMINDER, TREND` (handbook §7) | APM |
| 8 | Body photos (CHG-015 F-13) | `LocalPrivacyRepository.withdrawBodyConsent` deletes `media_assets` with `contains_person = 1`; `privacy_repository_test.dart` pins that | Body photos are `upload_batches.purpose = BODY_REFERENCE` and `attachments.kind = BODY`; `contains_person` is a detection flag, set from P5 | ASEM |
| 9 | Local-only constraints (F-17) | `session_draft` uses `NOT NULL` and `CHECK (id = 'current')` | PowerSync local-only tables are views too: no constraints. The repository enforces the single row | ASEM |
| 10 | Two writers on `upload_batches.status` (F-09) | Phone writes every state | Phone: DRAFT, SANITIZING, QUEUED_FOR_AI, COMPLETED; server: AI_PROCESSING, AWAITING_REVIEW, FAILED (DOC-004 Q2) | ASEM |
| 11 | User time zone (F-05) | None | Proposed `profiles.time_zone` (IANA), so server day maths matches the phone (DOC-004 Q1) | ASEM, APM |

## Scope

1. A CHG (ASEM) that defines **phone schema v2**: tables, columns, the class of
   each column (phone-written or server-written), and the v1 → v2 migration.
2. Repositories write only phone-owned columns. Local fakes write `fake_*` mirrors
   (or go through the `AnalysisEngine` / `DeckEngine` seam of
   [TASK-010](TASK-010-mock-backend-integration.md)), and read models union the
   real and mirror rows until P4.
3. Tests that change during green are listed in the CHG (CLAUDE.md, TDD loop).
4. **Column classes in `PhoneSchema`.** Each `TableSpec` gets its class (read-write, insert-only,
   phone-PATCH-only, command, read-only, local-only). Each column is marked phone-written or
   server-written. TASK-014's write guard and BE-011's allow-lists read this one declaration
   (exported by TASK-012), so phone and server cannot drift.
5. **Schema description for PowerSync.** `PhoneSchema` stays the single source. TASK-020
   generates the PowerSync `Schema` from it. No constraint, `UNIQUE` or `CHECK` remains on any table.

## TDD scenarios (proposed; the ASEM finalises them)

| ID | Scenario | Level |
|---|---|---|
| TASK-011-S01 | `PhoneSchema` v2 has every v2.8 table and column, and nothing outside the CHG | Unit (`phone_schema_test.dart`) |
| TASK-011-S02 | A v1 database with data migrates to v2 without loss; the Phase 2 crash images still open | Migration (`offline_reliability`) |
| TASK-011-S03 | No repository writes a server-owned column (an architecture test over SQL strings, or a write-guard in the database wrapper) | Architecture |
| TASK-011-S04 | Flow A and Flow B journeys pass unchanged with fakes writing `fake_*` mirrors | Journey |
| TASK-011-S05 | Withdrawing body consent removes only body-reference photos; an outfit photo with `contains_person = 1` stays | Repository (`privacy_repository_test.dart`, test change recorded) |
| TASK-011-S06 | No table has a constraint other than its primary key; a second `session_draft` row is refused by the repository | Unit + repository |
| TASK-011-S07 | Every column has exactly one class, and the classes match handbook §3 D02 | Unit |

## Anti-scope

No PowerSync SDK; no Flow C/D tables beyond what the CHG names; no change to the
shipped P2 behaviour other than where rows are written.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created (Draft) by the Backend Developer from the v1 vs. v2.8 comparison |
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | App Developer: rows 8–11, scope 4–5, S05–S07; ordered after TASK-013 |
