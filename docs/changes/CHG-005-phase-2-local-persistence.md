# CHG-005: Phase 2 persistent offline app (local SQLite, photo privacy, local erasure)

| Status | Source | Date |
|---|---|---|
| Approved | Human request · review of the Phase 2 plan · [Garblo Flow Spec](../tasks/mobile/Garblo%20Flow%20Spec.html) v2.7 T4, T6 › P2 | 2026-10-30 |

Status values: `Draft` → `Approved` (human) → `Done` (after merge).

## Problem
Phase 1 ([CHG-003](CHG-003-wardrobe-direction-phase-1.md)) runs on in-memory
repositories, so nothing survives a restart. Spec T6 › **P2 Persistent offline
app** replaces them with a local SQLite database whose tables have the T4 phone
schema names, so that P3 can swap in PowerSync "without renaming anything". The
first drafts of TASK-005…009 also pulled in Flow C/D features that Phase 1
deferred, and left several gated items unresolved.

Garblo is a lookbook generating and matching app. Phase 2 persists Pieces,
batches, wear events and Gu Match Fits. It stores no other people and no dating
data.

## Decisions
| ID | Decision | Reason |
|---|---|---|
| P2-D1 | Storage: `sqlite_async` 0.13.1 (+ `sqlite3` 2.9.4), `sqlcipher_flutter_libs` 0.6.8 (encrypted SQLite in the app), `flutter_secure_storage` 10.3.4 (database key and install owner ID), `path_provider` 2.1.5 | PowerSync's Dart SDK is built on `sqlite_async`; repositories written against `SqliteConnection` swap to `PowerSyncDatabase` in P3 |
| P2-D2 | Scope is must-have only: Flow A, Flow B, UC-09 local erasure. Flow C/D (rewards, check-ins, Impact metrics, poster), calendar save, evening reminder and data export are deferred | Phase 1 deferred C/D; the rest is nice-to-have or "Needs spec" (gaps ③ ④) |
| P2-D3 | Privacy entry is **Avatar › Privacy & data** (T7 › G3 1a). A person icon shows until first-launch (gap ①) provides the first-name initial. The UC-09 "bell › gear" route is dropped (spec fix pending) | T7 wins over UC prose |
| P2-D4 | Real photos through `image_picker` 1.1.2 behind `PhotoPicker`. JPG and PNG only; **HEIC shows the rejected-file state** (no conversion in P2) | Spec P2-04 needs real photos to sanitize |
| P2-D5 | The Archive starts empty. The 9 demo Pieces load only with `--dart-define=GARBLO_DEMO_SEED=true` | A persistent store must not hold fake Pieces |
| P2-D6 | Tests for TASK-005…008 first; TASK-009 tests after those are green | TASK-009 verifies the integrated stack and later migrations |
| P2-D7 | **PowerSync-shaped schema.** Every synced table is `id TEXT PRIMARY KEY` plus columns of type `TEXT`, `INTEGER` or `REAL` only, with **no foreign keys and no UNIQUE constraints** (PowerSync tables are views). Plain indexes are allowed. Only the local-only `session_draft` table may use full SQL constraints | Keeps the P3 swap mechanical |
| P2-D8 | **Deterministic IDs for idempotent writes.** A wear event's ID is 24 hex characters hashed from owner, date and Fit signature; a wardrobe item's ID is hashed from its review draft ID. Writes check for the ID inside the same write transaction and skip existing rows | Idempotent without UNIQUE constraints, and across devices after sync |
| P2-D9 | **Owner ID** is a random ObjectId generated once per install and kept in secure storage. In P4 it becomes the anonymous identity's `sub`, so nothing is re-keyed | Spec T4 account lifecycle |
| P2-D10 | In-house metadata stripping, no image re-encoding. JPEG: remove every APP1 (EXIF and XMP) and APP13; keep APP0 and APP2 (ICC). PNG: remove `tEXt`, `zTXt`, `iTXt`, `eXIf`; keep `iCCP`. Read the EXIF orientation first and store it on `media_assets.orientation` | Lossless; GPS can live in XMP; orientation lives in EXIF |
| P2-D11 | ObjectIds generated in-house: 4-byte seconds + 5-byte install random + 3-byte counter, as 24 lowercase hex characters | No dependency |
| P2-D12 | "Delete all" = close the database → delete the database files and the attachments folder → delete the database key → reopen fresh. The owner ID is kept ("Delete my data" is not "Delete account") | Simple to verify |
| P2-D13 | `pubspec.lock` is committed; `.gitignore` stops ignoring `*.lock` | ci-cd.md already requires it (CHG-002 item 9); native dependencies need a pinned lock |
| P2-D14 | Host tests use plain SQLite (`F:\tools\sqlite\sqlite3.dll` on Windows, kept out of the repo; the system library on Linux CI). SQLCipher encryption, the real picker, real app-kill and device timing are **device checks**, reported as skipped until run | They cannot run in `flutter test` |

## Phone schema v1 (contract)
Defined declaratively in `lib/core/storage/phone_schema.dart` and pinned by
`[TASK-005-S02]`. All dates are ISO-8601 text; booleans are `INTEGER` 0/1;
JSON is `TEXT`. Every synced table also has `id TEXT PRIMARY KEY`.

| Table | Class (spec T4) | Columns |
|---|---|---|
| `wardrobe_items` | synced rw | `user_id`, `name`, `type_code`, `color`, `material`, `style_tag`, `ai_confidence` REAL, `source_asset_id`, `cutout_attachment_id`, `last_worn_estimate`, `archived` INTEGER, `created_at`, `updated_at` |
| `wear_events` | synced rw, append-only | `user_id`, `worn_date`, `candidate_id`, `source`, `signature`, `ambient_temp_c` INTEGER, `items` (JSON `[{item_id, gap_days, rescue_eligible}]`), `created_at` |
| `upload_batches` | synced rw | `user_id`, `purpose`, `consent_id`, `status`, `req_outfit`, `req_pose`, `req_background` (INTEGER), `ambient_temp_c` INTEGER, `created_at`, `updated_at` |
| `media_assets` | synced rw | `user_id`, `batch_id`, `slot_index` INTEGER, `mime_type`, `attachment_id`, `orientation` INTEGER, `exif_gps_stripped`, `bystanders_blurred`, `contains_person`, `removed` (INTEGER), `created_at` |
| `ai_processing_jobs` | synced rw (server-written from P4), added by [CHG-006](CHG-006-phase-2-green-decisions.md) G-03 | `user_id`, `batch_id`, `asset_id`, `task_type`, `status`, `created_at`, `updated_at` — one job per photo × task, deterministic ID |
| `extracted_items` | synced rw (server-written from P4) | `user_id`, `batch_id`, `asset_id`, `item_index` INTEGER, `name`, `confidence` REAL, `ai` JSON, `value` JSON, `last_worn_input` JSON, `cutout_attachment_id`, `created_at` |
| `consents` | synced rw, insert-only | `user_id`, `version`, `includes_body` INTEGER, `granted_at`, `revoked_at` |
| `interactions` | synced rw | `user_id`, `session_id`, `candidate_id`, `action`, `dwell_ms` INTEGER, `from_item_id`, `to_item_id`, `created_at` |
| `gu_match_sessions` | written on the phone in P2–P3, server-written from P4 | `user_id`, `path`, `occasions` JSON, `raw_prompt`, `eligible_item_count`, `owned_only`, `deck_size`, `recent` (INTEGER), `created_at` |
| `outfit_candidates` | written on the phone in P2–P3, server-written from P4 | `user_id`, `session_id`, `deck_order` INTEGER, `title`, `match_pct` INTEGER, `highlight_reason`, `visual_mode`, `swipe_status`, `items` JSON `[{slot_role, item_id, name, days_unworn}]`, `created_at` |
| `item_types` | synced read-only catalog (seeded locally in P2) | `type_code`, `group_code`, `label` (`id` = `type_code`) |
| `session_draft` | local-only | `id` (always `current`), `occasions` JSON, `prompt` — may use NOT NULL/CHECK |

Indexes: `wardrobe_items(user_id, archived, created_at)`,
`wear_events(user_id, worn_date)`, `upload_batches(user_id, status)`,
`media_assets(batch_id, slot_index)`, `ai_processing_jobs(batch_id, asset_id)`,
`extracted_items(batch_id, item_index)`,
`gu_match_sessions(user_id, recent)`, `outfit_candidates(session_id, deck_order)`,
`interactions(session_id)`.

Not in P2 (deferred with their features): `profiles` (gap ①),
`purchase_checkins`, `calendar_exports`, `notifications`, rewards and
Community tables, `feed_cache`.

## Product impact (APM)
| Affected | Change needed |
|---|---|
| Flow spec | UC-09 AC-09.1: "bell › gear" → "Avatar › Privacy & data" (product owner, next spec version) |
| TASK-005…009 | Rewritten per this record (scope, scenarios, test plans, file lists) |
| [terminology.md](../policies/product/terminology.md) | Add "Privacy & data", "Delete all my photos and wardrobe data" with the other TASK-001 terms |

## Engineering impact (ASEM)
| Affected | Change needed |
|---|---|
| [decisions.md](../policies/engineering/decisions.md) | D-006 storage, D-007 photo picker, D-008 in-house ObjectId and metadata stripping; dependency list |
| [ci-cd.md](../policies/engineering/ci-cd.md) | Lock files committed; host SQLite for tests; benchmark tag |
| `.gitignore` | Stop ignoring `*.lock` |
| CI workflow | May need `libsqlite3` on the runner; checked in TASK-005 green |
| [docs/tasks/backend/](../tasks/backend/README.md) | New BE-006 (schema and Sync Streams parity), BE-007 (server erasure and export), AI-004 (on-device blur and duplicates); BE-003 and BE-004 notes |

## Code follow-up
| Role | Paths | Tests | Done |
|---|---|---|---|
| App Developer | TASK-005…008 file lists; TASK-009 after | Test plans in the cards | [ ] |
| Backend Developer | None in Phase 2. See BE-006, BE-007 | — | — |
