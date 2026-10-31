# CHG-015: Mobile contract alignment (P1–P2 refactor) and the mock-first P3–P5 mobile plan

| Status | Source | Date |
|---|---|---|
| Draft | Human request: App Developer (Flutter TDD + database) analysis of the whole codebase against Flow Spec v2.8 and the DB handbook; refactor P1–P2, then plan P3–P5 with mock APIs, fake data and fake AI first | 2026-10-31 |

Status values: `Draft` → `Approved` (human) → `Done` (after merge).

Companion to [CHG-014](CHG-014-mock-first-backend-track.md) (backend Track M / Track R). This
record is the mobile side: it uses the same two tracks.

## Problem

Phases 1–2 (TASK-001…009) are green and merged. Baseline on 2026-10-31: `flutter test`
from `apps/mobile/` passed 481 tests, skipped 1 (`benchmark` tag), exit 0. The code was written against Flow Spec v2.7 and
CHG-005/006. Flow Spec v2.8 ([`docs/specs/Garblo Flow Spec.md`](<../specs/Garblo Flow Spec.md>))
and the [DB handbook](<../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) change the
data contract the phone must meet before P3. The existing tests still pass because no test pins
the stored values, so these differences fail silently. The first mock-backend integration would hit them.

## Findings

| # | Area | Code today | Contract (v2.8 / handbook) | Fixed by |
|---|---|---|---|---|
| F-01 | Enum wire values | `gu_match_sessions.path`, `occasions`, `outfit_candidates.swipe_status`, `interactions.action`, `items[].slot_role`, `extracted_items.last_worn_input.option` are stored with Dart `.name` (`promptLed`, `work`, `pendingSwipe`, `dismissPass`, `top`, `oneToThreeMonths`). `CandidateItem.toJson` writes `TOP`, but the database codec writes `top` | T2 › Enums are UPPER_SNAKE (`PROMPT_LED`, `WORK`, `PENDING_SWIPE`, `DISMISS_PASS`). BE-015 validates `PROMPT_LED` | [TASK-013](../tasks/mobile/TASK-013-wire-values-and-time.md) |
| F-02 | Timestamps | `SystemClock` returns local time; `toIso8601String()` writes it with no offset | D01: ISO-8601 **UTC** text | TASK-013 |
| F-03 | Calendar dates | `wardrobe_items.last_worn_estimate` stored as a full date-time | D01: `YYYY-MM-DD`, no time part | TASK-013 |
| F-04 | Clock | `LocalWardrobeRepository.saveItems` and `LocalWearRepository.logWear` call `DateTime.now()` | Every time comes from `Clock` (TASK-006 anti-scope) | TASK-013 |
| F-05 | Day math across time zones | `DormancyRules` takes calendar days from whatever `DateTime` it gets; UTC storage moves a 06:00 save in Vietnam (UTC+7) to the previous day | Server dormancy must match the phone (WD-08), but the server has no user time zone | [DOC-004](../tasks/docs/DOC-004-mobile-contract-decisions.md) Q1, [BE-022](../tasks/backend/BE-022-mock-contract-requests-from-mobile.md) |
| F-06 | Write shapes | Saves "upsert" by `DELETE` + `INSERT` (`upload_batches`, `media_assets`, `ai_processing_jobs`). `extracted_items` is deleted and re-inserted on **every** save | PowerSync records each statement as a CRUD op. The write handler rejects DELETE/PUT on `extracted_items` (PATCH of `value`, `last_worn_input` only) and treats a DELETE as a delete | [TASK-014](../tasks/mobile/TASK-014-upload-safe-write-shapes.md) |
| F-07 | Archive order | Review order inside one save rests on `updated_at` + i µs | Any later PATCH (archive, edit, gap ②) changes `updated_at` and reorders the Archive | TASK-014 |
| F-08 | Server-owned writes | Phone fakes write `ai_processing_jobs`, insert `extracted_items`, `outfit_candidates`, the server fields of `gu_match_sessions` (incl. `recent` upkeep), batch states AI_PROCESSING / AWAITING_REVIEW / FAILED, and seed `item_types` | Read-only for the phone; from P3 fakes write only local-only `fake_*` mirrors (C04-07) | [TASK-011](../tasks/mobile/TASK-011-phone-schema-v2-alignment.md), TASK-014, [TASK-015](../tasks/mobile/TASK-015-result-engine-seams.md) |
| F-09 | Two writers on one column | `upload_batches.status` is written by the phone (DRAFT, SANITIZING, QUEUED_FOR_AI, COMPLETED) and by the server (AI_PROCESSING, AWAITING_REVIEW, FAILED) | C01-03: one writer per collection | DOC-004 Q2 |
| F-10 | Swipe decisions | Phone PATCHes `outfit_candidates.swipe_status` | BE-012-S06 rejects that PATCH; the server sets it from `interactions`. `SAVED_TO_LOOKBOOK` ("save for later") has no `card_action`, so the phone cannot request it | DOC-004 Q3, [TASK-026](../tasks/mobile/TASK-026-gu-match-command-rows.md) |
| F-11 | Interaction action enum | Code uses T2 `card_action` | T2: `CUSTOMIZE_EDIT`, `TRIGGER_VTON`; T4 side effects and GM-05: `ADJUST` | DOC-004 Q4 |
| F-12 | Fit item shape | Phone stores and reads `{slot_role, item_id, name, days_unworn}` | T4: `{slot_role, item_id}`; handbook: all four. `name` and `days_unworn` go stale (days change daily) | DOC-004 Q5 |
| F-13 | Body photos | Withdrawing body consent deletes `media_assets` with `contains_person = 1` (TASK-008) | Body photos are `upload_batches.purpose = BODY_REFERENCE` / `attachments.kind = BODY`. `contains_person` is a detection flag (0 today). Once P5 sets it, withdrawal would delete ordinary outfit photos | TASK-011 |
| F-14 | Owner scope | `LocalPrivacyRepository.counts()` does not filter by `user_id` | Every read is owner-scoped (merge re-keys `user_id`, ID-06) | TASK-014 |
| F-15 | Seams | `LocalGuMatchRepository` wraps `MockGuMatchRepository`; fake analysis sits inside `LocalStudioRepository`. No seam lets results come from the server | Results arrive as synced rows (DB5); P5 swaps only the worker | TASK-015 |
| F-16 | Legacy code | `ApiClient`/`MockApiClient`, `apiClientProvider`, `localStorageProvider`, `InMemoryLocalStorage`, `features/discovery/` and the `*_placeholder.dart` features are compiled and tested | CLAUDE.md marks them legacy. A sync transport would sit beside a dead `ApiClient` | [TASK-016](../tasks/mobile/TASK-016-retire-legacy-mobile-code.md) |
| F-17 | PowerSync limits | `session_draft` uses `NOT NULL` + `CHECK (id = 'current')`; migrations use `PRAGMA user_version`; `item_types` has `id` and `type_code` | PowerSync tables, local-only ones included, are views with no constraints; PowerSync owns the schema; handbook `_id` = `type_code` | TASK-011, [TASK-020](../tasks/mobile/TASK-020-powersync-sdk-swap.md) |
| F-18 | Catalog | `item_types` seeded by migration from the `ItemTypeCatalog` constant, which the domain reads directly | P3-05: the catalog arrives by sync and drives the type picker without a release | [TASK-019](../tasks/mobile/TASK-019-catalog-from-the-database.md) |
| F-19 | Docs | Mobile README cites the deleted HTML (v2.7); the `flow-spec` skill reads the deleted HTML; retired backend `TASK-013…015` cards share IDs with the new mobile cards | — | README fixed under this CHG; the rest is in [DOC-002](../tasks/docs/DOC-002-flow-spec-v2-8-relocation.md) #1–2 and [DOC-003](../tasks/docs/DOC-003-archive-legacy-backend-cards.md) |

## Decision proposed

1. **Refactor before integrating.** TASK-013…016 and TASK-011/012 change no screen or user-visible
   behaviour. They make the stored rows match the sync contract. They run first and need no backend.
2. **Every P3–P5 card runs mock-first.** Its Track M scenarios run against recorded mock
   responses (`contracts/fixtures/sync/`, TASK-012), then optionally against the live Track M
   mock (tag `live_backend`). Its Track R scenarios reuse the same tests against PowerSync or the
   real services, after BE-001.
3. **One seam per result type.** Studio analysis, context gathering and deck generation sit
   behind engines with a `Local*` fake (today's behaviour) and a `Synced*` implementation that
   reads server rows. A provider picks one; the dev flag `GARBLO_BACKEND=mock` selects synced.

### Mobile plan

| Order | ID | Phase · track | Task | Needs |
|---|---|---|---|---|
| 1 | TASK-013 | P3 prep · M | Wire values, UTC timestamps, calendar dates, injected clock (data migration) | DOC-004 Q1 for the time-zone rule |
| 2 | TASK-016 | P3 prep · M | Retire legacy mobile code | Removal decision (APM) |
| 3 | TASK-015 | P3 prep · M | Result engine seams; Local no longer wraps Mock | — |
| 4 | TASK-011 | P3 prep · M | Phone schema v2: tables, column classes, `fake_*` mirrors | ASEM schema CHG |
| 5 | TASK-014 | P3 prep · M | Upload-safe write shapes and a write guard | TASK-011 |
| 6 | TASK-012 | P3 prep · M | Shared golden fixtures | Location decision |
| 7 | TASK-017 | P3 · M | Local upload queue and pending count | TASK-014 |
| 8 | TASK-010 | P3 · M | Sync transport and dev connector to the mock | BE-012, BE-013, `http` decision |
| 9 | TASK-018 | P3 · M | Flow A and Flow B on server fakes | BE-014, BE-015, TASK-015 |
| 10 | TASK-019 | P3 · M → R | Catalog from the database | TASK-010 |
| 11 | TASK-021 | P3 · M → R | Attachment downloads and file cache | BE-018 |
| 12 | TASK-022 | P3 · M → R | Sync status, Sync now and convergence suite | UI spec (APM) |
| 13 | TASK-020 | P3 · R | PowerSync SDK swap | BE-001, `powersync` decision |
| 14 | TASK-023 | P4 · M → R | Identity: dev token, then anonymous account | BE-011 → BE-019 |
| 15 | TASK-024 | P4 · M → R | Rejections, retries and "Couldn't save · Fix" | DOC-004 Q6 |
| 16 | TASK-025 | P4 · M → R | Photo upload with tickets; Analyze queued offline | BE-018 → BE-008 |
| 17 | TASK-026 | P4 · M → R | Gu Match as command rows | BE-015 → BE-004, DOC-004 Q3–Q5 |
| 18 | TASK-027 | P4 · M → R | Privacy requests online | BE-017 → BE-007 |
| 19 | TASK-028 | P5 · M → R | Real-pipeline states (job progress, partial failure, provenance) | AI-005 fakes, BE-014 scenarios |
| 20 | TASK-029 | P5 · M → R | On-device blur and duplicate check behind ports | SP-1, SP-4, AI-004 |
| 21 | TASK-030 | P5 · M → R | Try-on end to end | BE-021, AI-002, SP-3 |

Not planned as cards yet (no content until their spec or release exists, README §3 rule 2): P1-04
first launch (gap ①), item detail and manual wear logging (gaps ②③), P2-06 device calendar and
notifications, P4-M05 rewards and P4-M06 Community (Flow C/D, flagged), P5-M03, P5-M04.

## Product impact (APM)

| Affected | Change needed |
|---|---|
| [tasks/mobile/README.md](../tasks/mobile/README.md) | P3–P5 plan listed as Draft; Source re-pointed to v2.8 (done under this CHG) |
| Flow Spec T2 › Enums | Decide F-10, F-11 (DOC-004 Q3, Q4) |
| UI specs | Sync status, pending count and "Couldn't save · Fix" (P3-05, P4-M02 "Needs spec"); offline Analyze line (ST-06) |

## Engineering impact (ASEM)

| Affected | Change needed |
|---|---|
| [data-schema.md](../policies/engineering/data-schema.md) §2–3 | Value encoding rules from TASK-013 (UPPER_SNAKE enums, UTC `Z` timestamps, `YYYY-MM-DD` dates); column classes from TASK-011 |
| [decisions.md](../policies/engineering/decisions.md) | `http` (TASK-010), `powersync` + `powersync_sqlcipher` (TASK-020); numbers that do not collide with the handbook's D-010…D-013 (DOC-002 #4) |
| [architecture.md](../policies/engineering/architecture.md) §2 | `ApiClient / LocalStorage` in the layering diagram is replaced by `core/sync/` (TASK-010, TASK-016) |
| [codebase-map.md](../policies/engineering/codebase-map.md) | `core/sync/`, engines, `contracts/` after each merge |
| Implementation plans | One per card before `Ready to code` |

## Tests that change during green (to be confirmed per card)

| Test | Why | Card |
|---|---|---|
| `[TASK-005-S02] is version 1` (`phone_schema_test.dart`) and the column map in that file | Schema version and columns change | TASK-013, TASK-011 |
| `[TASK-009-S06]` migration fixtures (`offline_reliability_test.dart`) | Each new version adds its predecessor fixture (the test asks for it) | TASK-013, TASK-011 |
| `local_gu_match_repository_test.dart` (`recent = 1`, `swipe_status` read back) | `recent` and `swipe_status` become server-owned | TASK-014, TASK-026 |
| `privacy_repository_test.dart` (`contains_person` rows) | Body photos are identified by purpose/kind (F-13) | TASK-011 |

## Code follow-up

| Role | Paths | Tests | Done |
|---|---|---|---|
| App Developer | `apps/mobile/` per TASK-010…TASK-030 | per card | [ ] |
| Backend Developer | `backend/` per [BE-021](../tasks/backend/BE-021-fake-try-on-side-effects.md), [BE-022](../tasks/backend/BE-022-mock-contract-requests-from-mobile.md) | per card | [ ] |

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | CHG-015 | Created (Draft) from the mobile + database codebase analysis |
