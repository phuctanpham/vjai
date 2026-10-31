# Garblo Database Handbook (DRS + DDS)

Oct 30, 2026 · @Gad

## 0. Overview

This handbook holds Garblo's database requirements (DRS) and design (DDS). It follows Flow Spec v2.8 and change record CHG-007 (one-piece data flow and RustFS), and it replaces the PostgreSQL drafts of 26–27 Oct 2026.

| Topic | Decision | Source |
| --- | --- | --- |
| Data flow | The app reads and writes only its local PowerSync database. Commands are rows. `POST /v1/sync/tx` is the only data endpoint; results return through Sync Streams | D-009, Flow Spec T4 › DB5 |
| Server store | One MongoDB replica set per cell, with change streams and post-images | T4 › DB1 |
| Sync | PowerSync Service, Sync Streams edition 3 | T4 › DB3 |
| Files | RustFS (S3-compatible); presigned URLs arrive as synced rows | D-010, T4 › DB6 |
| Backend | Write handler + workers + auth service | D-011 |
| Not used | PostgreSQL, pgvector, pgmq, PgBouncer, REST reads, SSE, CDN | Decision 30 Oct, D-009, D-010 |
| Scope | Flow A and Flow B are must-have; Flow C and Flow D are nice-to-have behind feature flags | Flow Spec › index |

Precedence when documents disagree (repo `docs/README.md` › §5 rule 7):

1. Agent specs
2. Item card
3. uat.feature
4. Implementation plan
5. Test plan
6. Flow Spec (T7 for UI)
7. Policies, including this handbook
8. Existing code

How to read it: sections 2–3 apply to every module; sections 4–13 hold one module each, its DRS table first and its DDS tables after. Requirement IDs use the section's code (C for common, ID, ST, FL, WD, GM, RW, CM, NT, SP, LC). Priority is M (must), S (should) or C (could); verification is I (inspection), A (analysis), D (demonstration) or T (test), as in ISO/IEC/IEEE 29148. Terms follow `policies/product/terminology.md`.

## 1. Decisions and open items

Ten decisions shape this handbook; six items still need an owner's call.

| # | Decision | Source |
| --- | --- | --- |
| 1 | MongoDB + PowerSync + RustFS; no PostgreSQL stack | T4 › DB1, DB6; D-010, D-011 |
| 2 | One-piece data flow: no REST reads, no SSE, no direct MongoDB access from the app | D-009 |
| 3 | Backend = write handler + workers + auth service, not one database per service | D-011, `architecture.md` §1 |
| 4 | IDs are 24-character hex ObjectIds generated on the phone | T4 › R8 |
| 5 | PowerSync per-field PATCH resolves conflicts; no HLC | T4 › R7 |
| 6 | Collection and field names match the phone schema exactly | CHG-005, `data-schema.md` |
| 7 | Commands are rows; from P3 the phone never writes server-owned tables | CHG-007 O-04, O-09 |
| 8 | Scope follows the Flow Spec: no wishlist, no friends, no chat, no prompt-built lookbooks | Decision 30 Oct |
| 9 | Values follow the Flow Spec: 18+, 6 item groups, 512-dimension server vectors with int8 × 128 phone embeddings, visible ♡ counts, T3 budgets | Flow Spec T2, T3, T4 |
| 10 | One Claude Doc in English, diagrams drawn in the doc (a deliberate deviation from the repo's Mermaid rule) | Decisions 30 Oct |

| # | Open item | What the sources say | Decision needed |
| --- | --- | --- | --- |
| O1 | Deadline for requested erasure | Hard delete ≤ 24 h, legal ceiling 30 days (TAC-09.2) | Confirm the deadline (section 13) |
| O2 | Inactive accounts | Flow Spec: delete anonymous accounts after 12 months without sync; product owner proposed a 36-month flow on 26 Oct | Pick one (section 13) |
| O3 | Backups after erasure | Age out within 35 days; every restore re-applies the erasure log (TAC-09.3) | Confirm the window |
| O4 | Data residency | The pilot runs in ap-southeast-1 (Singapore), so Vietnamese users' data is stored abroad | Legal check before P2 cells |
| O5 | Phone verification for Community | Not in the Flow Spec; Decree 147/2024 requires it before posting | Add it or accept the gap |
| O6 | RustFS features | Spike SP-R1 must pass before P3 (CHG-007 O-11) | DevOps report |

Repo note: two different change records are both numbered CHG-007. This handbook follows `CHG-007-one-piece-data-flow-and-rustfs.md`. The QN3, QN4, QN7, QN8 and QN9 response files still mention PostgreSQL, pgvector, the wishlist, hidden like counts and the 8-category taxonomy, and need an update.

## 2. Common DRS

Every module meets these 72 requirements and 9 performance budgets; module sections add their own.

### C01 · Data architecture

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| C01-01 | The system shall keep one MongoDB replica set per cell for personal, Community and config data. | M | I | T4 › DB1 |
| C01-02 | Every document shall carry `user_id` or `city_id` from day one, so it is shard-key ready. | M | I | T4 › DB1 |
| C01-03 | Each collection shall have one writer, the phone or a named server component, as listed in section 3 › D02. | M | I | T4 › Phone schema |
| C01-04 | Collection and field names of every synced table shall match the phone schema exactly. | M | T | BE-006, `data-schema.md` |
| C01-05 | Synced tables on the phone shall have no foreign keys or UNIQUE constraints; MongoDB shall keep its unique indexes and `$jsonSchema` validators. | M | I | `data-schema.md` §1 |
| C01-06 | Counters (wear count, last worn, image count) shall not be stored as editable fields; they shall be derived from append-only records. | M | T | T4 › R2 |
| C01-07 | Other people's posts shall reach a phone only as per-user `feed_entries` snapshots; authors shall sync only their own Community rows. | M | T | CHG-007 O-08, T4 › R5 |
| C01-08 | Wide server-only fields (512-dimension vectors, carbon fields) shall live in server-only collections and never sync to the phone. | M | I | T4 › R3 |

### C02 · Identity and IDs

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| C02-01 | Every synced row shall have `id` = a 24-character lowercase hex ObjectId generated on the phone; sync queries shall map `_id AS id`. | M | T | T4 › R8 |
| C02-02 | Idempotency shall come from deterministic IDs: wear event = hash(owner, worn date, Fit signature); wardrobe item = hash(review draft ID); AI job = hash(batch, asset, task). | M | T | BE-003, CHG-006 |
| C02-03 | When a duplicate `_id` arrives from the same owner, the write handler shall treat it as already applied. | M | T | T4 › Write path |
| C02-04 | First launch shall create an anonymous account whose JWT `sub` is the `user_id` generated once per install. | M | T | T4 › DB2 |
| C02-05 | When a user links Google, the system shall keep the same `user_id`; when that identity already has an account, a merge job shall re-key `user_id` across personal collections. | M | T | T4 › Account lifecycle |
| C02-06 | The write handler shall check the `linked=true` claim before it applies any Community row. | M | T | T4 › Account lifecycle |

### C03 · Sync

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| C03-01 | Every account, anonymous or linked, shall sync automatically while online from first launch. | M | D | T4 › DB2 |
| C03-02 | The Sync Streams shall be `catalog`, `my_wardrobe`, `my_studio`, `my_studio_jobs`, `my_decks`, `my_files`, `my_community` (Flow D) and the on-demand `deck_history`; `my_progress` ships with Flow C. | M | T | `data-schema.md` §4 |
| C03-03 | A user should hold about 24 buckets, well under PowerSync's limit of 1,000. | S | A | T4 › Sync Streams |
| C03-04 | `my_studio` and `my_studio_jobs` shall hold open batches only; their rows shall leave the phone when the batch is COMPLETED. | M | T | T4 › Sync Streams |
| C03-05 | `my_decks` shall hold sessions flagged `recent` (last 7 days); older decks shall come through `deck_history` on demand. | M | T | CHG-007 O-08 |
| C03-06 | PATCH shall apply only the changed fields (last upload wins per field); append-only collections shall only insert; deletes shall win. | M | T | T4 › R7 |
| C03-07 | The phone shall show only server data that already includes its own uploaded writes (write checkpoints). | M | T | T4 › Write path |
| C03-08 | Server-authoritative values (rescue eligibility, `gap_days`, XP, rank) shall replace provisional phone values on sync. | M | T | T3 › Sync model |

### C04 · Write path and commands

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| C04-01 | Phone data shall reach the server only through the upload queue to `POST /v1/sync/tx`, one CRUD transaction per call. | M | T | D-009 |
| C04-02 | Only three calls shall bypass PowerSync, and none shall read or write data rows: the auth service, file bytes to RustFS, and the public poster page. | M | T | CHG-007 O-07 |
| C04-03 | The write handler shall apply each CRUD transaction in one MongoDB multi-document transaction keyed by `tx_id`; a replay shall be a no-op. | M | T | T4 › Write path |
| C04-04 | Every PUT, PATCH and DELETE shall pass four guards: owner = token `sub`, collection writable by the client, per-collection field allow-list, `$jsonSchema`. | M | T | T4 › Write path |
| C04-05 | A command (analyze, draft Fits, try on, delete my data, share, load a feed page) shall be a row the phone inserts; the server shall complete it by writing result rows. | M | T | CHG-007 O-04 |
| C04-06 | The phone shall PATCH only its own fields of a command row, and only along allowed status transitions. | M | T | T4 › MongoDB collections |
| C04-07 | From P3 the phone shall never write server-owned tables; P3 fakes shall write only local-only `fake_*` mirrors, which P4 removes. | M | T | CHG-007 O-09 |
| C04-08 | Append-only collections (`wear_events`, `consents`, `xp_ledger`) shall reject PATCH and DELETE, except setting `consents.revoked_at`. | M | T | `data-schema.md` §2 |
| C04-09 | If a transaction is rejected (4xx), the system shall log it to `sync_rejections`, notify the user, and complete it so the queue moves on. | M | T | T4 › Write path |
| C04-10 | Business rules I1, I2, I4, I6, I7, I12 and wear-event uniqueness shall be checked before commit; saving a batch shall be all items or none. | M | T | P4-B03, TAC-03.2 |

### C05 · Security and privacy

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| C05-01 | The phone database shall be encrypted with SQLCipher, its key in secure storage. | M | I | D-006 |
| C05-02 | Network traffic shall use TLS 1.3; cloud data shall be encrypted at rest, with a separate key for body images. | M | I | T3 › Sync model |
| C05-03 | Body images shall be readable only by the try-on worker role and never be public; there shall be no CDN and no public personal file. | M | T | BE-008 |
| C05-04 | Nothing shall reach an AI model until EXIF/GPS data is stripped and bystanders are blurred on the phone. | M | T | UC-01 |
| C05-05 | Calendar and precise location shall be read on the phone; only event title, time window and city shall leave it. | M | T | TAC-05.3 |
| C05-06 | LLM calls shall carry no user ID, attendees or event notes, only title, time, city and the scrubbed prompt, under a zero-retention agreement. | M | I | TAC-06.4 |
| C05-07 | No analytics event, log line or push message shall contain images, names, prompt text or precise location. | M | T | T3, BE-009 |
| C05-08 | Community data shall store a city ID only, never coordinates. | M | I | T4 › MongoDB collections |
| C05-09 | Card payloads shall have no commerce fields (shop URL, price). | M | T | TAC-07.6 |
| C05-10 | No post, poster or link shall contain a body photo or a try-on render. | M | T | I16 |

### C06 · Consent and compliance

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| C06-01 | Consent shall be one insert-only record per user and version, reused across batches; each batch shall point at the consent active when it was submitted. | M | T | T2 › D3 |
| C06-02 | Try-on shall require an active consent with `includes_body = 1` and a body reference photo. | M | T | I7 |
| C06-03 | When body consent is withdrawn, the system shall delete body photos and renders and cancel queued try-on jobs within 1 minute. | M | T | AC-09.3, TAC-08.4 |
| C06-04 | First launch shall ask for a first name, an 18+ confirmation and agreement to the Terms. | M | T | T4 › Account lifecycle, gap ① |
| C06-05 | The privacy dashboard shall say that guest data is stored on the server. | M | D | T4 › DB2 |
| C06-06 | Data-residency duties shall be confirmed with legal before growth phase P2. | M | I | Open item O4 |
| C06-07 | Community posting shall meet Vietnam's social-network rules (Decree 147/2024). | M | I | Open item O5 |

### C07 · Performance budgets

The Flow Spec marks these as placeholders for engineering to confirm (T3 › Budgets).

| Budget | Target (p95) | Applies to |
| --- | --- | --- |
| Local write visible in the UI | ≤ 100 ms | All use cases |
| Screen render from the local database | ≤ 300 ms with 500 items and 3,000 wear logs | UC-03, 04, 10, 15 |
| Upload applied (`uploadData` → MongoDB commit) | ≤ 500 ms | All writes |
| Command round trip (local write → first result row on the phone, excluding model time) | ≤ 1.5 s | All commands |
| RustFS photo PUT (≤ 2 MB) | ≤ 2 s on 4G | UC-01, 08 |
| Sync of 100 changes | ≤ 5 s on 4G | All synced tables |
| PowerSync replication lag (MongoDB write → phone) | ≤ 1 s while connected | All synced tables |
| Context: first card / all cards / deck ready | ≤ 2.5 s / ≤ 6 s / ≤ 7 s | UC-06 |
| Feed page (request uploaded → rows on the phone) | ≤ 1.5 s | UC-13 |

### C08 · Availability and recovery

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| C08-01 | The pilot shall reach 99.5% monthly availability and ≥ 99.5% crash-free sessions. | M | A | T3 › Budgets |
| C08-02 | Each replica set shall have 3 nodes with automatic failover, and post-images enabled on synced collections. | M | T | P3-01 |
| C08-03 | If the server is unreachable, the app shall keep working on the local database and queue its writes; Analyze shall be queued too, while Draft Fits shall need a connection. | M | T | CHG-007 O-10 |
| C08-04 | Sync shall retry with exponential backoff up to 5 times; AI jobs shall retry up to 2 times. | M | T | T3 › Budgets |
| C08-05 | Backups shall allow point-in-time restore, and every restore shall re-apply the erasure log. | M | T | TAC-09.3 |
| C08-06 | Disaster-recovery copies should stay in the same legal jurisdiction as the cell. | S | I | Decision 20 Oct |

### C09 · Schema versioning and parity

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| C09-01 | A change to the phone schema shall require a mobile CHG; collections and Sync Streams shall follow it. | M | I | BE-006 |
| C09-02 | A parity test shall compare the phone's schema description with the deployed Sync Streams and fail on any difference. | M | T | BE-006 |
| C09-03 | One versioned rules library (dormancy, metrics, XP, eco) shall run on phone and server and pass the same golden fixtures. | M | T | T3 › Shared rules |
| C09-04 | Validator changes should keep accepting writes from app versions still in support. | S | T | — |
| C09-05 | Seed scripts (catalog, factors, demo data) shall be re-runnable without duplicates. | M | T | P3-03 |

### C10 · Observability

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| C10-01 | The system shall chart replication lag, command round trips and sync convergence, and alert when a C07 budget is missed. | M | D | P3-07, P4-B12 |
| C10-02 | `sync_rejections` should be counted per collection and rule, so a bad validator shows up within a day. | S | D | T4 › Write path |
| C10-03 | Erasure shall emit `erasure_requested{scope}` and `erasure_completed{duration}` with no personal data. | M | T | TAC-09.6 |
| C10-04 | Like and save counts kept with `$inc` shall be reconciled nightly against `post_reactions`. | M | T | I20 |

### C11 · AI provenance

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| C11-01 | Extracted items shall keep the AI's original attributes (`ai`) apart from the user's edits (`value`); `userModified` shall be derived. | M | T | TAC-03.5 |
| C11-02 | There shall be one AI job per photo × task; pose and background jobs on photos without a person shall end as `SKIPPED_NO_PERSON`. | M | T | T2 › C6 |
| C11-03 | Every image shall carry a provenance label (TRY-ON, WARDROBE PHOTO, ILLUSTRATION, AI-GENERATED IMAGE). | M | T | AC-07.2, I16, I22 |
| C11-04 | Each AI result should record the model and model version that produced it. | S | I | Decision 20 Oct |

### C12 · Growth and installations

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| C12-01 | The pilot shall run 1 replica set, 1 PowerSync instance, 1 write handler and 1 RustFS cluster in one region. | M | I | T4 › Growth path |
| C12-02 | When write load nears one primary's limit or a residency rule applies, the system shall split into cells, each with its own replica set, PowerSync, write handler and RustFS. | M | D | T4 › Growth path |
| C12-03 | Community, interactions and analytics shall be able to move to a sharded cluster while the feed builder keeps writing each user's `feed_entries` into their cell. | S | A | T4 › Growth path |
| C12-04 | Each white-label installation should be an independent deployment with its own data and keys; the shared support system (OSS) should receive no personal data. | S | I | Decision 26 Oct |

## 3. Common DDS

One path carries every data row: phone → upload queue → write handler → MongoDB → PowerSync → phone. Only file bytes (RustFS) and the login token (auth service) travel outside it.

&#91;embedded content: one-piece data flow · rows ①②, file bytes ③\]

Rows go up through ① and come back through ②; file bytes take ③ with tickets that arrive through ②. The auth service and the sync nudge sit outside this loop and carry no data rows.

### D01 · Names and types

Collection names are the phone table names (snake\_case, plural); field names are the phone column names. Server-only collections and fields never appear in a Sync Stream.

| Concept | Server (MongoDB) | Phone (SQLite via PowerSync) | Rule |
| --- | --- | --- | --- |
| ID | `_id`: ObjectId | `id`: 24-character hex text | Generated on the phone; sync maps `_id AS id` |
| Owner | `user_id`: ObjectId | `user_id`: text | Equals the JWT `sub` |
| Timestamp | BSON date | ISO-8601 UTC text | The server also stamps its own `created_at` on insert |
| Calendar date (`worn_date`, `last_worn_estimate`) | string `YYYY-MM-DD` | text | No time part, never in the future |
| Boolean | bool | integer 0/1 | — |
| Embedded object or array (`items`, `ai`, `value`, `occasions`, `context`) | embedded document or array | JSON text | `$jsonSchema` on the server, app layer on the phone |
| File | `attachment_id` reference | `attachment_id` text | Bytes live in RustFS, never in a row |

The BSON-to-SQLite mapping is confirmed by the BE-006 parity test before P3-01 is accepted.

### D02 · Collection classes

| Class | Collections | Who writes |
| --- | --- | --- |
| Synced, read-write | `profiles`, `wardrobe_items`, `upload_batches`, `media_assets`, `extracted_items` (`value.*` and `last_worn_input` only), `wear_events` (insert-only), `purchase_checkins`, `calendar_exports`, `notifications` (dismiss only), `consents` (insert-only), `interactions`, `attachments` | The phone, through the upload queue; the write handler validates |
| Synced, command rows | `gu_match_sessions`, `vton_jobs`, `privacy_requests`, `share_cards`, `share_links`, `community_posts`, `post_reactions`, `post_reports`, `post_hides`, `feed_requests` | The phone inserts the request and may PATCH only its own fields; a worker completes it |
| Synced, read-only | `item_types`, `badges`, `levels`, `quest_templates`, `emission_factors`, `impact_factors`, `item_embeddings`, `ai_processing_jobs`, `outfit_candidates`, `xp_ledger`, `user_badges`, `user_quests`, `user_rank_daily`, `attachment_tickets`, `feed_entries` | Server only; client writes are rejected |
| Server-only | `item_vectors`, `applied_tx`, `sync_rejections`, `follows`, device tokens | Server only; never synced |
| Local-only (phone) | `rewards_provisional`, `session_draft`, `ui_state`, `fake_*` (P2–P3 only) | The phone; never uploaded |
| Files (RustFS) | photo, cutout, body, render, poster, export, editorial | Bytes through the attachments helper with presigned tickets |

### D03 · Validation

Every collection has a `$jsonSchema` validator (`validationLevel: strict`, `validationAction: error`). The write handler checks what a validator cannot, inside the same transaction.

| Rule kind | Where it lives | Example |
| --- | --- | --- |
| Shape, enum, range | `$jsonSchema` | `wear_events.items` holds 1–12 entries; `source` is one of 7 values |
| Uniqueness | Unique index | One wear event per (user, worn date, signature) |
| Ownership and allow-list | Write handler | Owner = token `sub`; only allowed fields in a PATCH |
| Cross-document rule | Write handler | Every `item_id` in a wear event is owned and not archived (I6) |
| Status transition | Write handler | A command row moves only along its allowed transitions |
| Derived value | Aggregation or shared rules library | Last worn and wear count come from `wear_events` (R2) |

### D04 · Indexes

Every index starts with the field a Sync Stream or worker filters on, usually `user_id`. A stream query without a matching index fails review.

| Collection | Index | Kind |
| --- | --- | --- |
| `wardrobe_items` | `{user_id, archived, created_at}` | Compound |
| `wear_events` | `{user_id, worn_date}`; `{user_id, worn_date, signature}` | Compound; unique |
| `upload_batches` | `{user_id, status}` | Compound |
| `media_assets` | `{batch_id, slot_index}` where `removed = false` | Unique, partial |
| `ai_processing_jobs` | `{batch_id, asset_id}` | Compound |
| `extracted_items` | `{batch_id, item_index}` | Compound |
| `gu_match_sessions` | `{user_id, recent}`; `expires_at` | Compound; TTL 90 days |
| `outfit_candidates` | `{session_id, deck_order}` | Compound |
| `interactions` | `{session_id}` | Single |
| `vton_jobs`, `privacy_requests`, `feed_requests` | `{user_id, created_at}` | Compound |
| `attachments` | `{user_id, owner_id}` | Compound |
| `attachment_tickets` | `expires_at` | TTL |
| `feed_entries` | `{user_id}`; `expires_at` | Single; TTL 24 h |
| `xp_ledger`, `user_badges`, `user_quests` | `{user_id, rule, idem_key}` | Unique |
| `community_posts` | `{city_id, created_at}`; `{author_id, created_at}` | Compound |
| `applied_tx` | `created_at` | TTL 7 days |

### D05 · Write handler

`POST /v1/sync/tx` receives `{tx_id, ops[]}`, one CRUD transaction from the phone's queue. It runs one MongoDB multi-document transaction with write concern `majority`, records `tx_id` in `applied_tx` inside it, then dispatches the side effect (section 12).

| Operation | Server action | Guard |
| --- | --- | --- |
| PUT | `insertOne` with the phone's `_id`; a duplicate key from the same owner counts as applied | Owner, collection writable, `$jsonSchema` |
| PATCH | `updateOne({_id, user_id}, {$set: changed fields})` | Field allow-list; append-only collections reject it |
| DELETE | `deleteOne`; items are archived or deleted per gap ② | Append-only collections reject it; erasure goes through `privacy_requests` |
| Rejection (4xx) | Written to `sync_rejections`, a notification row for the user, transaction completed | The next sync corrects the phone |

### D06 · Change streams and Sync Streams

PowerSync reads MongoDB change streams, so every synced collection has `changeStreamPreAndPostImages` enabled. Results written by workers (jobs, drafts, decks, renders, feed pages, tickets) reach the phone the same way; while the app is in the background a data-free push asks it to sync (section 11).

| Stream | Holds | Subscribe |
| --- | --- | --- |
| `catalog` | `item_types`, `badges`, `levels`, `quest_templates`, factors | Auto, shared by everyone |
| `my_wardrobe` | `profiles`, `wardrobe_items`, `item_embeddings`, `wear_events`, `purchase_checkins`, `calendar_exports`, `consents` | Auto |
| `my_studio` | Open batches with their `media_assets` and `extracted_items` | Auto |
| `my_studio_jobs` | `ai_processing_jobs` of open batches | Auto |
| `my_decks` | Recent `gu_match_sessions`, their `outfit_candidates`, `interactions` and `vton_jobs` | Auto |
| `my_files` | `attachments`, `attachment_tickets`, `privacy_requests` | Auto |
| `my_community` | Own `share_cards`, `share_links`, `community_posts`, `post_reactions`, plus `feed_entries` | Auto (Flow D) |
| `my_progress` | `xp_ledger`, `user_badges`, `user_quests`, `user_rank_daily`, undismissed `notifications` | Auto (ships with Flow C) |
| `deck_history` | One older session and its candidates | On demand, by `session_id` |

### D07 · RustFS

RustFS replaces object storage, MinIO and the CDN. Rows hold attachment IDs; presigned URLs arrive as `attachment_tickets` rows (section 6). Object keys start with `users/{user_id}/`, so erasure deletes one prefix per bucket.

| Bucket | Content | Rules |
| --- | --- | --- |
| `sanitized` | Photos after EXIF strip and blur; item cutouts | Versioning off |
| `body` | Body reference photos | Own encryption key; try-on worker role only; versioning off |
| `renders` | Try-on results | Body image; GET tickets last 10 min |
| `posters` | Share posters | Public only through the poster page |
| `exports` | Download-my-data packages | 7-day lifecycle |
| `editorial` | Garblo's own illustration images | Shared, not personal |

## 4. Identity & Account

Every install starts as an anonymous account whose `user_id` never changes; Google sign-in links to it instead of creating a new one.

### DRS

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| ID-01 | First launch shall ask for a first name, an 18+ confirmation and agreement to the Terms, then create an anonymous account. | M | T | Gap ①, S-16.1 |
| ID-02 | The install owner ID shall be generated once, kept in secure storage, and become the anonymous JWT `sub` without re-keying. | M | T | BE-006 |
| ID-03 | The refresh token shall live in the iOS Keychain or Android Block Store, so a reinstall restores the same anonymous account. | M | T | T4 › Account lifecycle |
| ID-04 | If the refresh token is lost and Google was never linked, the data cannot be recovered, and the privacy dashboard shall say so. | M | D | T4 › Account lifecycle |
| ID-05 | When a user links Google to a new identity, the token shall keep the same `sub`. When the identity already has an account, the user shall choose keep this phone, keep the account, or merge. | M | T | T4 › Account lifecycle |
| ID-06 | A merge shall re-key `user_id` across personal collections in batched transactions, then the app shall disconnect, clear and reconnect PowerSync with the surviving `sub`. | M | T | T4 › Account lifecycle |
| ID-07 | The auth service shall issue the JWT with the `linked` claim, rotate refresh tokens, and publish a JWKS for PowerSync; from P2 the JWT shall also carry the cell's PowerSync endpoint. | M | T | P4-B01, T4 › Growth path |
| ID-08 | Joining Community shall be a PATCH of `profiles` (`community_opt_in`, `display_name`) and shall require a Google-linked account. | M | T | Sync contract › Share and Community |

### DDS

| Collection | Class | Fields | Stream |
| --- | --- | --- | --- |
| `profiles` | Synced, read-write | `_id` (= `user_id`), `first_name`, `community_opt_in`, `display_name`, `created_at`, `updated_at` | `my_wardrobe` |
| Auth store (proposed) | Server-only | `user_id`, linked identities (provider, subject, linked time), hashed refresh tokens with rotation state | Never synced |

| Secure-storage key (phone) | Value |
| --- | --- |
| Database key | SQLCipher key |
| Install owner ID | ObjectId; the anonymous `sub` from P4 |
| Refresh token | Auth refresh token (P4) |

The auth store's shape is not in the Flow Spec; it is this handbook's proposal for the P4-B01 card. The only `profiles` fields the phone may PATCH are `first_name`, `community_opt_in` and `display_name`.

## 5. Studio

Studio turns 1–10 photos into reviewed wardrobe items; every step is a row the phone writes, and AI results come back as rows.

### DRS

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| ST-01 | A batch shall hold 1–10 photos, each `image/jpeg` or `image/png` (I1, I2), enforced by the write handler and `$jsonSchema`. | M | T | TAC-01.7 |
| ST-02 | Submit shall insert the consent and move the batch to SANITIZING in one transaction; a replay shall create no second consent or transition. | M | T | TAC-01.4 |
| ST-03 | Analysis shall wait until every asset is VERIFIED (section 6), then create one `ai_processing_jobs` row per photo × task with a deterministic ID. | M | T | UC-02, CHG-006 |
| ST-04 | At least one analysis task shall be selected; Outfit shall be on by default; Pose and Background shall stay off unless the user asks (I4). | M | T | UC-02 |
| ST-05 | Jobs shall retry up to 2 times; jobs on photos without a person shall end as SKIPPED\_NO\_PERSON. | M | T | TAC-02.4, T2 › C6 |
| ST-06 | Analyze shall work offline: it is queued and the status line reads "OFFLINE · ANALYSIS STARTS WHEN ONLINE". | M | T | TAC-01.6 |
| ST-07 | The phone shall PATCH `extracted_items` only in `value.*` and `last_worn_input`; inserts are server-only. | M | T | T4 › Phone schema |
| ST-08 | Commit shall write all N wardrobe items and set the batch to COMPLETED in one transaction; a retried commit shall never duplicate items. | M | T | TAC-03.2 |
| ST-09 | Draft rows shall be deleted 7 days after COMPLETED and leave the phone when the batch closes; sanitized photos and cutouts stay with the account. | M | T | TAC-03.4 |
| ST-10 | Review order shall be slot, then item index; an item's group shall follow its type. | M | T | AC-03.3, TAC-03.6 |

Batch states: DRAFT → SANITIZING → QUEUED\_FOR\_AI → AI\_PROCESSING → AWAITING\_REVIEW → COMPLETED. AI\_PROCESSING can end in FAILED, which returns to DRAFT or QUEUED\_FOR\_AI; erasure sets DELETED\_BY\_USER from any state.

### DDS

| Collection | Class | Fields | Stream |
| --- | --- | --- | --- |
| `upload_batches` | Synced, read-write | `user_id`, `purpose` (WARDROBE, BODY\_REFERENCE), `consent_id`, `status`, `req_outfit`, `req_pose`, `req_background`, `ambient_temp_c`, `created_at`, `updated_at` | `my_studio` |
| `media_assets` | Synced, read-write | `user_id`, `batch_id`, `slot_index`, `mime_type`, `attachment_id`, `orientation`, `exif_gps_stripped`, `bystanders_blurred`, `contains_person`, `removed`, `created_at` | `my_studio` |
| `consents` | Synced, insert-only | `user_id`, `version` (`v1.0_studio_body_ai`), `includes_body`, `granted_at`, `revoked_at` | `my_wardrobe` |
| `ai_processing_jobs` | Synced, read-only | `user_id`, `batch_id`, `asset_id`, `task_type` (OUTFIT\_EXTRACTION, POSE\_ESTIMATION, BACKGROUND\_ANALYSIS), `status` (PENDING, PROCESSING, COMPLETED, SKIPPED\_NO\_PERSON, FAILED), `created_at`, `updated_at` | `my_studio_jobs` |
| `extracted_items` | Synced; phone PATCH only | `user_id`, `batch_id`, `asset_id`, `item_index`, `name`, `confidence`, `ai` (type\_code, color, material, style\_tag), `value` (same keys), `last_worn_input`, `cutout_attachment_id`, `created_at` | `my_studio` |

Indexes: `upload_batches {user_id, status}`, `media_assets {batch_id, slot_index}` (unique where not removed), `ai_processing_jobs {batch_id, asset_id}`, `extracted_items {batch_id, item_index}`.

| Row the phone writes | Side effect | Rows synced back |
| --- | --- | --- |
| `upload_batches` PATCH SANITIZING | Verify assets (section 6) | `media_assets`, `attachments` state |
| `upload_batches` PATCH QUEUED\_FOR\_AI | Create photo × task jobs and enqueue them | `ai_processing_jobs`, `extracted_items`, cutout tickets, batch status |
| `upload_batches` PATCH DRAFT | Cancel queued jobs | Job and batch status |
| `wardrobe_items` PUT ×N + batch COMPLETED | Atomic commit, then embeddings | `item_embeddings` |

## 6. Files

PowerSync carries no files, so bytes go straight between the phone and RustFS, using presigned URLs that arrive as synced `attachment_tickets` rows. The phone never asks for a URL.

### DRS

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| FL-01 | Every file shall have one `attachments` row; the phone shall insert only PHOTO and BODY attachments. | M | T | T4 › MongoDB collections |
| FL-02 | When the phone inserts a PHOTO or BODY attachment, the server shall write a PUT ticket valid 15 minutes. | M | T | CHG-007 O-06 |
| FL-03 | For files the phone needs, the server shall write GET tickets valid 1 hour (body renders 10 minutes) and renew them before they expire. | M | T | BE-008 |
| FL-04 | Uploads above 5 MB shall use multipart; failed uploads shall retry with backoff up to 5 times; an expired ticket shall be reissued through sync. | M | T | TAC-01.5 |
| FL-05 | After the phone sets an attachment to UPLOADED, the verify worker shall check size, hash and (for photos) that no EXIF/GPS/maker notes remain, then set VERIFIED or REJECTED and delete rejected objects. | M | T | TAC-01.3 |
| FL-06 | Objects with no VERIFIED attachment shall be removed after 24 hours. | M | T | BE-008 |
| FL-07 | Object keys shall start with `users/{user_id}/`; personal buckets shall have versioning off. | M | I | T4 › DB6 |
| FL-08 | The `body` bucket shall use its own encryption key and be readable only by the try-on worker role. | M | T | BE-008 |
| FL-09 | There shall be no CDN and no public personal file; the public poster page is the only file view outside the app. | M | I | BE-008, CHG-007 O-07 |
| FL-10 | Spike SP-R1 shall prove presigned PUT/GET (SigV4), multipart, lifecycle rules and per-bucket server-side encryption before P3. | M | D | CHG-007 O-11 |

Attachment states: PENDING\_UPLOAD → UPLOADED → VERIFIED or REJECTED for files from the phone; files made on the server (cutouts, renders, posters, exports) start at READY.

### DDS

| Collection | Class | Fields | Stream |
| --- | --- | --- | --- |
| `attachments` | Synced, read-write | `user_id`, `kind` (PHOTO, CUTOUT, BODY, RENDER, POSTER, EXPORT, EDITORIAL), `owner_table`, `owner_id`, `mime_type`, `bytes`, `sha256`, `state`, `created_at` | `my_files` |
| `attachment_tickets` | Synced, read-only | `user_id`, `attachment_id`, `op` (PUT, GET), `url`, `expires_at` | `my_files` |

Indexes: `attachments {user_id, owner_id}`; `attachment_tickets` TTL on `expires_at`. Buckets are listed in section 3 › D07.

| Row the phone writes | Side effect | Rows synced back |
| --- | --- | --- |
| `attachments` PUT (PHOTO, BODY) | Issue a presigned PUT | `attachment_tickets` |
| `attachments` PATCH UPLOADED | Verify the object | `attachments.state` |

## 7. Wardrobe

The phone owns wardrobe edits; dormancy and wear counts are always computed from `wear_events`, never stored.

### DRS

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| WD-01 | The wardrobe list shall show non-archived items, newest first, in pages of 20, with a total that ignores the group filter; it is a local query. | M | T | AC-04.3, AC-04.7, TAC-04.5 |
| WD-02 | Items shall belong to one of 6 groups (TOPS, BOTTOMS, SHOES, BAGS, HATS, ACCESSORIES) through the read-only `item_types` catalog. | M | T | T2 › C4 |
| WD-03 | Dormancy shall count days since the latest of (wear event, last-worn estimate), else since `created_at`; the badge shows at ≥ 30 days (I8). | M | T | BE-003 |
| WD-04 | The last-worn estimate shall be a date with no time, set once from the review answer, never in the future, and kept apart from wear events. | M | T | BE-003 |
| WD-05 | A wear event shall be insert-only, hold 1–12 owned, non-archived items (I6), and be unique per (user, worn date, signature). | M | T | TAC-07.4, T4 › validator |
| WD-06 | A wear counts as a rescue only when the 30+ day gap is measured from a logged wear or the save date, never from the estimate; the server recomputes it (N6, I12). | M | T | BE-003 |
| WD-07 | After commit, the server shall write a compact `item_embeddings` row (int8 × 128) for the on-device duplicate check and a server-only `item_vectors` row (512 dimensions). | M | T | T4 › R3 |
| WD-08 | Server dormancy shall match the phone's on the shared golden fixtures. | M | T | TAC-04.2 |

### DDS

| Collection | Class | Fields | Stream |
| --- | --- | --- | --- |
| `wardrobe_items` | Synced, read-write | `user_id`, `name`, `type_code`, `color`, `material`, `style_tag`, `ai_confidence`, `source_asset_id`, `cutout_attachment_id`, `last_worn_estimate`, `archived`, `created_at`, `updated_at` | `my_wardrobe` |
| `wear_events` | Synced, insert-only | `user_id`, `worn_date`, `candidate_id`, `source` (LIKE\_CONFIRM, ITEM, MULTI, CHECKIN, PHOTO, REMINDER, TREND), `signature`, `ambient_temp_c`, `items` (`[{item_id, gap_days, rescue_eligible}]`), `created_at` | `my_wardrobe` |
| `item_types` | Synced, read-only catalog | `_id` = `type_code`, `group_code`, `label` | `catalog` |
| `item_embeddings` | Synced, read-only | `user_id`, `item_id`, int8 × 128 embedding | `my_wardrobe` |
| `item_vectors` | Server-only | `user_id`, `item_id`, 512-dimension style embedding, carbon fields | Never synced |

Indexes: `wardrobe_items {user_id, archived, created_at}`; `wear_events {user_id, worn_date}` and unique `{user_id, worn_date, signature}`.

| Derived value | Phone (SQLite) | Server (MongoDB) |
| --- | --- | --- |
| Last worn, wear count per item | `MAX(worn_date)`, `COUNT(*)` over `json_each(wear_events.items)` | `$unwind items` → `$group` by `item_id` |
| Days unworn, dormancy | Shared rules library | Same library |

The phone stores provisional `gap_days` and `rescue_eligible`; the server's values replace them on sync.

## 8. Gu Match

A Gu Match session is a command row: the phone asks for a deck, and the server answers with context cards and up to 8 Fits built only from the user's own items. Swipes decide on Fits, never on people.

### DRS

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| GM-01 | Starting a session shall insert `gu_match_sessions` with status REQUESTED, `path` (PROMPT\_LED or ZERO\_INPUT), up to 5 occasions, a prompt of ≤ 280 characters, the derived calendar context and the ambient temperature. | M | T | BE-004, T4 › MongoDB collections |
| GM-02 | The server shall move the session through GATHERING, ANALYZED and DECK\_READY, or end it as NO\_ELIGIBLE\_ITEMS or FAILED. | M | T | `data-schema.md` §2 |
| GM-03 | Context cards (occasion, weather, rain, commute) shall be patched into the session row one at a time, each source with a 5 s timeout; a missing source shall yield a card marked missing, not a failed session. | M | T | T2 › C7, TAC-06.2 |
| GM-04 | A deck shall hold at most 8 candidates, built only from owned, non-archived items (I6), deterministic and dormant-first, with no shop link or price. | M | T | BE-004, TAC-07.6 |
| GM-05 | Swipes and edits shall be `interactions` rows (DISMISS\_PASS, LIKE\_SAVE, ADJUST) with dwell time; the server shall set `swipe_status`, and an ADJUST shall swap only within the same group among owned items. | M | T | Side effects table, TAC-08.6 |
| GM-06 | Drafting Fits shall need a connection; swiping a synced deck shall work offline. | M | T | CHG-007 O-10 |
| GM-07 | Sessions shall stay on the phone for 7 days (`recent`), expire after 90 days, and older decks shall open through `deck_history`. | M | T | T4 › R4, O-08 |
| GM-08 | Try-on shall be a `vton_jobs` command row; the server shall precheck I7, allow one active render per candidate, store the render in `renders` and finish within 20 s p95. | M | T | Side effects table, T3 › Budgets |
| GM-09 | The deck request shall carry no item data or images; LLM calls shall follow C05-06. | M | T | TAC-05.2 |

### DDS

| Collection | Class | Fields | Stream |
| --- | --- | --- | --- |
| `gu_match_sessions` | Command row | Phone: `user_id`, `path`, `occasions`, `raw_prompt`, `event_title`, `window_start`, `window_end`, `city_id`, `ambient_temp_c`, `created_at`. Server: `status`, `context`, `eligible_item_count`, `owned_only`, `deck_size`, `recent`, `expires_at` | `my_decks`, `deck_history` |
| `outfit_candidates` | Synced, read-only | `user_id`, `session_id`, `deck_order`, `title`, `match_pct` (0–100), `highlight_reason`, `visual_mode`, `swipe_status`, `items` (`[{slot_role, item_id, name, days_unworn}]`), `created_at` | `my_decks`, `deck_history` |
| `interactions` | Synced, read-write | `user_id`, `session_id`, `candidate_id`, `action`, `dwell_ms`, `from_item_id`, `to_item_id`, `created_at` | `my_decks` |
| `vton_jobs` | Command row | `user_id`, `session_id`, `candidate_id`, `body_asset_id`, `status`, `output_attachment_id`, `created_at`, `updated_at` | `my_decks` |

| Enum | Values |
| --- | --- |
| Occasion | WORK, COFFEE, AFTERNOON\_RAIN, DATE, WEEKEND\_OUTING |
| `swipe_status` | PENDING\_SWIPE, SWIPED\_LEFT\_PASSED, SWIPED\_RIGHT\_LIKED, SAVED\_TO\_LOOKBOOK |
| Card action | DISMISS\_PASS, LIKE\_SAVE, CUSTOMIZE\_EDIT, TRIGGER\_VTON |

Indexes: `gu_match_sessions {user_id, recent}` with a TTL on `expires_at`; `outfit_candidates {session_id, deck_order}`; `interactions {session_id}`; `vton_jobs {user_id, created_at}`.

| Row the phone writes | Side effect | Rows synced back |
| --- | --- | --- |
| `gu_match_sessions` PUT REQUESTED | Check eligible items, run the agent, patch context cards, generate the deck | Session status and context, `outfit_candidates` |
| `interactions` PUT | Set `swipe_status`; for ADJUST check I6, recompute items and match % | `outfit_candidates` |
| `vton_jobs` PUT REQUESTED | Precheck I7, render, store in RustFS | `vton_jobs`, RENDER attachment and ticket |

## 9. Rewards & Impact (Flow C, nice-to-have)

Rewards are server-authoritative and ship with Flow C behind a feature flag; impact figures are local queries over the user's own wear data.

### DRS

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| RW-01 | The rewards worker shall write XP to an append-only ledger, idempotent per (user, rule, key); the phone shall never write it (I11). | M | T | T4 › MongoDB collections |
| RW-02 | A wear event shall trigger the rewards worker, which recomputes rescue eligibility (I12) before awarding XP, quests and badges. | M | T | Side effects table |
| RW-03 | Badges, levels and quest templates shall be read-only catalog rows. | M | I | T4 › Phone schema |
| RW-04 | A nightly job shall write `user_rank_daily` (rewear rate and percentile). | M | T | P4-B08 |
| RW-05 | Purchase check-ins shall be one per user per month; the purchases tile shall stay hidden until 2 check-ins exist and be labelled "self-reported" (I13). | M | T | T2+ › N4 |
| RW-06 | Eco figures shall be labelled "estimated" and come from versioned factors (I21). | M | I | T2+ › I21 |
| RW-07 | No reward, quest or badge shall link to a purchase (R5, I14). | M | I | T2+ › I14 |
| RW-08 | Impact screens shall be local queries plus the user's own `user_rank_daily` row; there is no impact API. | M | T | Sync contract › v2 rewards |

### DDS

| Collection | Class | Fields | Stream |
| --- | --- | --- | --- |
| `xp_ledger` | Synced, read-only, append-only | `user_id`, `rule`, `points`, `idem_key`, `created_at` | `my_progress` |
| `levels` | Catalog | `level`, `name`, `min_xp` | `catalog` |
| `badges` | Catalog | `code`, name and rule fields | `catalog` |
| `user_badges` | Synced, read-only | `user_id`, `code`, `unlocked_at` | `my_progress` |
| `quest_templates` | Catalog | `code`, `title`, `target`, `period` (WEEK) | `catalog` |
| `user_quests` | Synced, read-only | `user_id`, `code`, `week_start`, `progress`, `status` | `my_progress` |
| `user_rank_daily` | Synced, read-only | `user_id`, `as_of`, `rewear_rate_pct`, `percentile` | `my_progress` |
| `purchase_checkins` | Synced, read-write | `user_id`, `month`, `items_bought` | `my_wardrobe` |
| `emission_factors`, `impact_factors` | Catalog | `group_code`, `kg_co2e_per_item`, `source_ref`, `factor_version` | `catalog` |

Indexes: unique `{user_id, rule, idem_key}` on `xp_ledger`, `user_badges` and `user_quests`. The phone keeps provisional rewards in the local-only `rewards_provisional` table until the server's rows arrive.

## 10. Community & Share (Flow D, nice-to-have)

Community runs through command rows too: authors sync only their own rows, and other people's posts reach a phone only as `feed_entries` pages the feed builder writes for that user.

### DRS

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| CM-01 | Community rows shall be applied only for a Google-linked account that has opted in. | M | T | C02-06, ID-08 |
| CM-02 | A post shall be AI\_LOOKBOOK, QUOTE, MILESTONE or POSTER; visibility shall be MEMBERS (default) or FOLLOWERS. | M | T | T2+ › N9a |
| CM-03 | Quote posts shall wait in PENDING\_SCREEN until the text passes screening; a post shall be hidden after 3 reports (placeholder) until review clears it. | M | T | T2+ › Post lifecycle |
| CM-04 | Loading a feed page shall insert `feed_requests` (tab, cursor); the feed builder shall write 20 cards into `feed_entries` with a 24 h TTL, within 1.5 s p95. | M | T | CHG-007 O-08, T3 › Budgets |
| CM-05 | Likes and saves shall be `post_reactions` PUT or DELETE; counts shall change with `$inc` in the same transaction and be reconciled nightly (I20). | M | T | T4 › Derived values |
| CM-06 | A share card shall snapshot the metrics; any outfit image on it shall be an AI illustration, never a body photo (I16). | M | T | T2+ › N8, I16 |
| CM-07 | A share link shall expire 30 days after creation and be revocable; the public poster page is the only view for people outside the app. | M | T | T2+ › N9b |
| CM-08 | Reports and hides shall remove the post from the reporter's `feed_entries`. | M | T | Sync contract › Community |
| CM-09 | Community rows shall store a city ID only, never coordinates. | M | I | C05-08 |

### DDS

| Collection | Class | Fields | Stream |
| --- | --- | --- | --- |
| `share_cards` | Command row | `user_id`, `metrics_snapshot`, `show_outfit`, `outfit_signature`, poster attachment | `my_community` |
| `share_links` | Command row | `user_id`, `share_card_id`, token URL, `expires_at`, `revoked_at` | `my_community` |
| `community_posts` | Command row | `author_id`, `post_type`, `visibility`, `moderation_status`, `title`, `quote_text`, image attachment, `ai_generated_label`, `like_count`, `save_count`, `city_id`, `created_at` | `my_community` (author's own) |
| `post_reactions` | Command row | `user_id`, `post_id`, reaction (LIKE, SAVE) | `my_community` |
| `post_reports`, `post_hides` | Command row | `user_id`, `post_id`, reason (reports) | Not synced back |
| `feed_requests` | Command row | `user_id`, `tab`, `cursor`, `created_at` | Not synced back |
| `feed_entries` | Synced, read-only | `user_id`, `tab`, card snapshot, counts, `expires_at` | `my_community` |
| `follows` | Server-only | `follower_id`, `following_id` | Never synced |

Indexes: `community_posts {city_id, created_at}` and `{author_id, created_at}`; `feed_requests {user_id, created_at}`; `feed_entries {user_id}` with a 24 h TTL. Post states: PENDING\_SCREEN → VISIBLE or REJECTED; VISIBLE ↔ HIDDEN\_BY\_REPORTS.

Gap: the Flow Spec gives `follows` no sync contract, so following someone has no row the phone can write yet. Field lists here beyond the T2+ ERD (reaction kind, card snapshot) are proposals for the P4-B11 card.

## 11. Notifications, sync nudge and calendar exports

The inbox is synced rows; the push is only a data-free nudge that tells a sleeping app to sync.

### DRS

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| NT-01 | When a worker writes a result row for a user whose app is not connected, the system shall send an APNs/FCM push carrying only a type (such as `results_ready` or `deletion_complete`). | M | T | BE-009 |
| NT-02 | Nudges shall be limited to one per user per minute, with duplicates collapsed. | M | T | BE-009 |
| NT-03 | Device tokens shall be stored per install and removed on erasure. | M | T | BE-009 |
| NT-04 | Inbox items shall be `notifications` rows synced through `my_progress`; the phone shall only dismiss them. | M | T | T4 › Phone schema |
| NT-05 | Rejected uploads shall create a notification ("Couldn't save … · Fix"). | M | T | T4 › Write path |
| NT-06 | Categories, quiet hours (22:00–07:00 by default) and the inbox dot rule shall follow gap ⑤ once it is specified. | S | D | Gap ⑤ |
| NT-07 | Garblo shall write only its own calendar entries, never edit the user's events, and list its entries for removal (I23). | M | T | T2+ › I23 |

### DDS

| Collection | Class | Fields | Stream |
| --- | --- | --- | --- |
| `notifications` | Synced; phone dismisses only | `user_id`, `type`, reference to the source row, `dismissed`, `created_at` | `my_progress` |
| `calendar_exports` | Synced, read-write | `user_id`, `wear_event_id`, `provider` (ios, google), `external_entry_id`, `starts_at`, `status` (CREATED, FAILED, DELETED) | `my_wardrobe` |
| Device tokens | Server-only | `user_id`, install ID, platform, token, `updated_at` | Never synced |

The `notifications` and device-token fields are this handbook's proposal; the Flow Spec leaves them to gap ⑤ and the P4-B10 card. Until Flow C ships `my_progress`, rejection notifications need another stream (open in section 12).

## 12. Sync platform

This section covers the collections that keep the one loop honest, the bucket budget, and how the platform grows from one region to many without changing the phone.

### DRS

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| SP-01 | Each upload transaction shall commit as one MongoDB multi-document transaction, with its `tx_id` stored in `applied_tx` for 7 days so a replay is a no-op. | M | T | T4 › Write path |
| SP-02 | A 4xx rejection shall be logged to `sync_rejections`, raise a notification, and complete the transaction so the queue moves on. | M | T | T4 › Write path |
| SP-03 | The phone shall show server data only after it includes the phone's own uploaded writes (PowerSync write checkpoints). | M | T | T4 › Write path |
| SP-04 | Buckets per user shall stay near 24, well under PowerSync's default limit of 1,000. | M | A | T4 › Sync Streams |
| SP-05 | Every document shall carry `user_id` or `city_id` from day one, so it is shard-key ready. | M | I | T4 › DB1 |
| SP-06 | Moving to a later growth phase shall not change the phone's schema or its single data path. | M | A | T4 › Growth path |
| SP-07 | Data-residency duties shall be checked with legal before P2 (see O4). | M | I | T4 › Growth path, EN-7.6 |

### DDS

| Collection | Class | Fields | Notes |
| --- | --- | --- | --- |
| `applied_tx` | Server-only | `_id` = `tx_id`, `user_id`, `created_at` | TTL index on `created_at`, 7 days |
| `sync_rejections` | Server-only | `user_id`, `tx_id`, collection, row `id`, op, error code, `created_at` (proposed) | Feeds the "Couldn't save … · Fix" notification |
| `_powersync_checkpoints` | Managed by PowerSync | — | Never written by Garblo code |

Bucket budget per user: `catalog` 1 + `my_wardrobe` 1 + `my_progress` 1 + `my_files` 1 + `my_community` 1 + `my_studio` and `my_studio_jobs` up to 6 + `my_decks` up to about 10 recent sessions + `deck_history` up to 3 open ≈ 24.

### Growth path

&#91;embedded content: growth path · 3 phases, phone unchanged\]

Each phase adds server topology; the phone's schema and its single path through PowerSync stay the same.

| Phase | Topology | Trigger to move |
| --- | --- | --- |
| P1 · pilot | 1 replica set + 1 PowerSync instance + 1 write handler + 1 RustFS cluster, single region | Now |
| P2 · cells | One replica set + PowerSync + write handler + RustFS per region (a "cell"). A small directory maps `user_id` to its cell; the JWT carries the cell's PowerSync endpoint. | Write load near one primary's limit, or a data-residency requirement |
| P3 · global cluster | Community, interactions and analytics move to a sharded cluster. The feed builder reads it and still writes each user's `feed_entries` into their cell. | Community volume, or cross-region feeds |

Proposed P3 shard keys: posts `{city_id: 1, _id: "hashed"}`, interactions `{post_id: "hashed"}`, events `{user_id: "hashed", ts: 1}`. Zones keep Vietnamese cities on APAC shards. PowerSync cannot connect to a sharded cluster today, which is why personal data stays in a cell's replica set in every phase.

Open: rejection notifications travel through `my_progress`, which ships with Flow C. Until then the pilot needs a small stream or a local banner for rejections.

## 13. Lifecycle and erasure

Erasure is a command row like any other: the phone inserts `privacy_requests`, the write handler revokes and hides in one transaction, and a resumable worker purges MongoDB and RustFS. This section follows the Flow Spec (UC-09); the owner decisions still open are listed at the end.

### Erasure flow

&#91;embedded content: erasure · phone and cloud lanes, scope ALL\]

The phone wipes itself only after the write handler acknowledges the request, so an offline erasure is never lost; the purge then runs on the server without the phone.

### DRS

| ID | Requirement | Pri | Ver | Source |
| --- | --- | --- | --- | --- |
| LC-01 | Erasure shall start from a `privacy_requests` row with scope BODY (body photos and renders only), ALL (everything), or EXPORT (a copy). | M | T | UC-09, T4 › Side effects |
| LC-02 | Before confirming, the app shall show counts from local rows ("23 photos, 12 items, 2 try-ons") and need a second, explicit tap. | M | T | AC-09.2 |
| LC-03 | The write handler shall revoke consents, mark batches DELETED\_BY\_USER and soft-delete rows in one transaction, so the data leaves the app at once. | M | T | AC-09.4, AC-09.5 |
| LC-04 | Once the request's upload is acknowledged, the phone shall wipe the PowerSync database, file cache, render cache and auth token within 5 s. | M | T | TAC-09.1 |
| LC-05 | The server hard delete shall finish within 24 h (placeholder; legal ceiling 30 days), and an automated proof query shall show zero rows and objects for the user ID. | M | T | TAC-09.2, O1 |
| LC-06 | The erasure worker shall delete every object under `users/{user_id}/` in every bucket, including `body` and `renders`. | M | T | DB6, EN-09.2 |
| LC-07 | Batch and render jobs in flight shall be cancelled and their outputs discarded; renders queued under a withdrawn body consent shall stop within 1 minute. | M | T | AC-09.6, P5-B02 |
| LC-08 | Community posts shall leave every `feed_entries` page within 5 minutes, and shared links shall stop working at once. | M | T | TAC-09.5, AC-09.4 |
| LC-09 | Garblo's calendar entries shall be removed, or listed for the user to remove when calendar access was revoked (I23). | M | T | AC-09.4 |
| LC-10 | Backups shall age out within the retention window (placeholder 35 days), and every restore shall re-apply the erasure log. | M | T | TAC-09.3, O3 |
| LC-11 | The erasure job shall be idempotent and resumable, with its status visible in the account hub. | M | T | TAC-09.4 |
| LC-12 | The system shall emit `erasure_requested{scope}` and `erasure_completed{duration}`; the audit log shall hold only request ID, time and scope. | M | I | TAC-09.6 |
| LC-13 | Inactive anonymous accounts shall be deleted after 12 months without a sync (placeholder). | S | T | T4 › Account lifecycle, O2 |
| LC-14 | "Download my data" shall produce a file in the `exports` bucket, reached through an `attachment_tickets` row, kept for 7 days. | S | T | DB6, UC-19 (needs spec) |
| LC-15 | "Delete account" shall offer a 7-day grace period before erasure starts. | S | D | S-19.4 (needs spec) |

### DDS

| Collection | Class | Fields | Stream |
| --- | --- | --- | --- |
| `privacy_requests` | Command row | `user_id`, `scope` (BODY, ALL, EXPORT), `status` (REQUESTED, IN\_PROGRESS, COMPLETED, FAILED), export attachment, `created_at`, `completed_at` | `my_files` (own rows) |
| Erasure log | Server-only | request ID, `user_id`, scope, step reached, `created_at` | Never synced; read by restores |
| Audit log | Server-only | request ID, time, scope | Never synced; no personal data |

The status values and log fields are this handbook's proposal for EN-09.2.

### Retention

| Data | Kept for | Removed by | Source |
| --- | --- | --- | --- |
| Draft upload rows | 7 days after the batch is COMPLETED | Retention job | TAC-03.4 |
| Sanitized photos and cutouts | Until the item or the account is deleted | User action or erasure | TAC-03.4 |
| `gu_match_sessions` | 90 days | TTL index | T4 › Collections |
| `applied_tx` | 7 days | TTL index | T4 › Write path |
| `attachment_tickets` | Until the ticket expires | TTL index | T4 › Collections |
| `feed_entries` | 24 h | TTL index | R5 |
| Exports | 7 days | Bucket lifecycle rule | DB6 |
| Backups | 35 days (placeholder) | Backup rotation | TAC-09.3 |
| Inactive anonymous accounts | 12 months without a sync (placeholder) | Erasure worker | T4 › Account lifecycle |

### Owner input needed

| Item | Flow Spec today | Decision wanted |
| --- | --- | --- |
| O1 · Hard-delete deadline | ≤ 24 h, legal ceiling 30 days | Confirm the target with legal |
| O2 · Inactive accounts | Anonymous accounts deleted after 12 months | Keep 12 months, or adopt the 36-month flow proposed by the product owner |
| O3 · Backup window | 35 days | Confirm with ops and legal |
| Item-level delete | Archive or delete per gap ② | Archive flag, delete, or both (S-17.2) |

## 14. Review, traceability and change history

### Traceability

| Source | Covered in |
| --- | --- |
| Flow Spec v2.8 · T4 DB1–DB6 (platform, one-piece flow, RustFS) | §1, §2 C01–C04, §3 |
| Flow Spec v2.8 · T4 Sync Streams and bucket estimate | §3 D06, §12 |
| Flow Spec v2.8 · T4 Write path and side effects | §3 D05, each module's side effects, §12 |
| Flow Spec v2.8 · T4 Account lifecycle (anonymous JWT, Google link, merge) | §4 |
| Flow Spec v2.8 · T3 budgets and quality targets | §2 C07–C08 |
| Flow Spec v2.8 · T2 / T2+ ERDs, enums, invariants I1–I23 | §5–§11 |
| UC-01 to UC-04 (Studio) | §5, §6 |
| UC-05 to UC-08 (Gu Match, try-on) | §8 |
| UC-09 (erasure), UC-19 (settings hub) | §13 |
| Flow C (rewards, impact) | §9 |
| Flow D (Community, share) | §10 |
| CHG-007, D-009 to D-013 | §1, §3, §6, §12 |
| BE-008 (RustFS), BE-009 (sync nudge) | §6, §11 |

### Checks before sign-off

| Check | How | Owner | Blocks |
| --- | --- | --- | --- |
| Schema parity | BE-006 test: every SQLite table matches its MongoDB validator and Sync Stream query | Backend | P1 exit |
| RustFS spike | SP-R1: presigned PUT/GET, multipart, lifecycle, server-side encryption | Backend + SRE | P3 |
| Validators | `$jsonSchema` and field allow-lists for every collection in §3 D03 | Backend | P1 exit |
| Erasure proof | Automated test: zero rows and objects remain for a test user ID (LC-05) | Backend + QA | R1 |
| Bucket budget | Count buckets per user on the pilot data set (SP-04) | Backend | P3 |
| Open items | O1–O6 in §1 decided by their owners | Product owner, legal | R1 |

### Change history

| Date | Version | Change |
| --- | --- | --- |
| 26–27 Oct 2026 | Drafts | PostgreSQL DRS v0.3 and DDS v0.1 in Markdown. Superseded: the stack, pgmq, PgBouncer and pgvector are dropped. |
| 30 Oct 2026 | v0.1 | First Claude Doc on MongoDB + PowerSync, written against Flow Spec v2.7.1. |
| 30 Oct 2026 | v1.0 draft | Rewritten in one pass as this handbook, against CHG-007 (one-piece data flow, RustFS) and Flow Spec v2.8. Added the Files module, the sync platform section and the erasure flow. English only. |
