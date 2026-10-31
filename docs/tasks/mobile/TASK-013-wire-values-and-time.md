# TASK-013: Wire values, UTC timestamps, calendar dates and the injected clock

> **Phase:** P3 preparation · refactor of P1–P2 code  
> **Track:** M (no backend needed)  
> **Status:** Draft · needs CHG-015 approval, DOC-004 Q1 (time-zone rule) and an implementation plan from the Engineering Manager  
> **Owner:** App Developer (code) · Engineering Manager (plan, data-schema.md rule)  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) F-01…F-05)  
> **Dependencies:** none · **Blocks:** TASK-011, TASK-012, TASK-010  
> **Source:** [Flow Spec v2.8](<../../specs/Garblo Flow Spec.md>) T2 › Enums · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §3 D01

## Why

Every row the phone writes will be uploaded unchanged in P3–P4 and checked by the write
handler. Today the phone stores enum values with Dart's `.name`, local times with no offset, and
a date-only field with a time part. No test reads those raw values, so the suite is green, but
the first `POST /v1/sync/tx` would fail with `SCHEMA_VIOLATION` (BE-012, BE-015).

## Findings

| Column | Stored today | Must be |
|---|---|---|
| `gu_match_sessions.path` | `promptLed`, `zeroInput` | `PROMPT_LED`, `ZERO_INPUT` |
| `gu_match_sessions.occasions`, `session_draft.occasions` (JSON) | `["work","afternoonRain"]` | `["WORK","AFTERNOON_RAIN"]` |
| `outfit_candidates.swipe_status` | `pendingSwipe` … | `PENDING_SWIPE` … |
| `outfit_candidates.items[].slot_role` | `top` (database); `TOP` in `CandidateItem.toJson` | `TOP` everywhere, one codec |
| `interactions.action` | `dismissPass` … | `DISMISS_PASS` … (final names per DOC-004 Q4) |
| `extracted_items.last_worn_input.option` | `oneToThreeMonths` | Value set to be pinned by the ASEM (proposed `ONE_TO_THREE_MONTHS`) |
| Every `*_at` column | Local time, no offset (`2026-10-31T09:00:00.000`) | UTC with `Z` |
| `wardrobe_items.last_worn_estimate` | `2026-09-20T00:00:00.000` | `2026-09-20` |
| `wardrobe_items.updated_at`, `wear_events.created_at` | `DateTime.now()` | `Clock.now()` |

Already correct: `upload_batches.status`, `ai_processing_jobs.task_type` and `status`,
`outfit_candidates.visual_mode`, `wear_events.source`, `wear_events.worn_date`,
`item_types.group_code`.

## Scope

1. **One codec per enum** in `domain/` (`wireName` getter + `fromWire`), as `VisualMode` already
   has. Repositories and `toJson` use only the codec. `OutfitCandidate.toJson` and
   `CandidateItem.toJson` cite "the spec's candidates API contract", which v2.8 removed. Point
   them at T4 › Phone schema, or delete them if nothing uses them.
2. **Time helpers** in `core/time/`: `toStoredInstant(DateTime)` → UTC ISO-8601 with `Z`;
   `toStoredDate(DateTime)` → local `YYYY-MM-DD`; parsers back to the domain types. Wear and
   dormancy day maths keeps using the user's **local** calendar date. The rule for the server
   follows DOC-004 Q1.
3. **Clock everywhere.** `LocalWardrobeRepository` and `LocalWearRepository` take a `Clock`.
   Add an architecture test that fails on `DateTime.now()` outside `core/time/clock.dart`
   (legacy `discovery/` excluded until TASK-016).
4. **Migration step v1 → v2.** No column changes. Rewrite the stored values in one transaction:
   enum strings, JSON arrays and objects, timestamps (read as local, written as UTC) and
   `last_worn_estimate` (cut to the date). `PhoneSchema.version` becomes 2. The TASK-009-S06
   fixture list gains the v1 image.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-013-S01 | Every enum round-trips through its codec, and every wire value equals the T2 › Enums list (table-driven, reading `contracts/fixtures/enums.json` once TASK-012 lands) | Unit |
| TASK-013-S02 | Each Local repository writes only wire values: a session, a Fit, an interaction, a draft and a review item read back raw from SQL match the table above | Repository (`local_db.dart`) |
| TASK-013-S03 | Every `*_at` column written by a repository ends in `Z` and parses to the clock's instant; `last_worn_estimate` matches `^\d{4}-\d{2}-\d{2}$` | Repository |
| TASK-013-S04 | A save at 06:00 local in UTC+7 (fixed clock) keeps the local calendar date: dormancy, `gap_days` and the BENCHED badge equal the TASK-006 fixtures | Unit + repository |
| TASK-013-S05 | No `DateTime.now()` outside `core/time/clock.dart` (architecture test) | Architecture |
| TASK-013-S06 | A v1 database with rows in every table migrates to v2 with every value rewritten and nothing lost; the Phase 2 crash images still open | Migration (`offline_reliability_test.dart`) |
| TASK-013-S07 | Regression: the full suite passes; only the tests listed in CHG-015 change | Regression |

## File confinement

- `apps/mobile/lib/features/*/domain/` (enum codecs; `wear_event.dart`, `last_worn.dart`)
- `apps/mobile/lib/features/*/data/local_*_repository.dart`
- `apps/mobile/lib/core/time/`, `apps/mobile/lib/core/storage/garblo_database.dart`, `phone_schema.dart` (version)
- `apps/mobile/test/` mirrors, `apps/mobile/test/architecture/`, `apps/mobile/test/integration/offline_reliability_test.dart`

## Anti-scope

No new tables or columns (TASK-011). No change to visible copy or behaviour. No write-shape
changes (TASK-014). Mock repositories keep their readable IDs (`session_1`).

## Decisions needed

| # | Question | Proposal | Owner |
|---|---|---|---|
| 1 | Server-side calendar days (DOC-004 Q1) | Phone computes days in local time; `profiles.time_zone` (IANA) syncs so the server can do the same | ASEM, APM |
| 2 | `last_worn_input.option` wire values | UPPER_SNAKE of the Dart names; add to T2 › Enums | APM |

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
