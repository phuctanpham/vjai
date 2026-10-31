# CHG-014: Mock-first backend track for mobile integration

| Status | Source | Date |
|---|---|---|
| Draft | Human request: backend + AI analysis of the whole codebase; mock APIs (no database, fake data, fake AI) first, real APIs after | 2026-10-30 |

Status values: `Draft` → `Approved` (human) → `Done` (after merge).

## Problem

1. **No backend work can start.** Every wardrobe backend card (BE-002…BE-007) and
   every AI card is blocked by [BE-001](../tasks/backend/BE-001-platform-decision.md)
   (MongoDB + PowerSync + auth vs. the FastAPI mock). The mobile app therefore has
   no server to integrate against before P3.
2. **The backend cards target a contract the spec removed.** BE-002…BE-004 and
   AI-002 list REST + SSE endpoints from "T2 › API surface". Flow Spec **v2.8**
   ([`docs/specs/Garblo Flow Spec.md`](<../specs/Garblo Flow Spec.md>), T2 › *Sync
   contract (replaces the API surface)* and T4 › DB5) removes them: the app reads and
   writes only its local database; every write and command is a row uploaded to
   **one** endpoint, `POST /v1/sync/tx`; results come back only through Sync Streams.
3. **The backend gate does not run.** `uv run pytest` fails before collecting a test:
   hatchling cannot find the `app` package (project name `garblo-backend`), no
   `uv.lock` is committed although [ci-cd.md](../policies/engineering/ci-cd.md) §2
   says it is, and uv picks an unpinned interpreter (3.15 on the reference machine).
   With the build bypassed the 7 legacy tests pass.

## Decision proposed

Split the backend work into two tracks and run the **mock track first**.

| Track | What | Allowed by | Blocked by |
|---|---|---|---|
| **M · mock** | A deterministic FastAPI mock of the v2.8 contract: dev token, `POST /v1/sync/tx` with the real write rules, server-side **fake** side effects (fake extraction, fake context, rule-based deck, fake erasure, in-memory files), and a dev-only change feed standing in for Sync Streams. Process memory only; injected clock; no network calls | D-004 and the Backend Developer role rules as they stand (no database, no real auth, no external service, no randomness or wall-clock) | This CHG only |
| **R · real** | MongoDB, PowerSync, auth service, RustFS, real workers and models | BE-001 decision | BE-001 |

Track M gives the mobile team a server that behaves like P4 (the phone writes
command rows; the server writes `ai_processing_jobs`, `extracted_items`,
`outfit_candidates`, session status and tickets) **without** MongoDB or PowerSync.
Track R reuses Track M's validators and runs the same contract tests against the
real store, the way the mobile contract suites run against Mock and Local.

### Mock wire contract (summary; owner cards hold the detail)

| Surface | Mock | Real counterpart | Card |
|---|---|---|---|
| Identity | `POST /v1/auth/dev-token {user_id}` → bearer `dev.<user_id>`; the install owner ID is the `sub` (BE-006) | Auth service, JWT + JWKS (P4-B01) | BE-011 → BE-019 |
| Writes | `POST /v1/sync/tx {tx_id, ops[{op, type, id, data}]}`; 2xx applied or replayed, 4xx permanently rejected, never blocks the queue | Same endpoint on MongoDB (P4-B02, B03) | BE-012 → BE-020 |
| Reads | `GET /v1/mock/sync/changes?after=&streams=`: ordered full-row changes per Sync Stream name, with a checkpoint | PowerSync Sync Streams (P3-02) | BE-013 → BE-006 |
| Files | `attachments` PUT → `attachment_tickets` row with a mock URL; bytes held in memory; verify JPEG/PNG and no EXIF | RustFS presigned tickets, verify worker (P4-B04, B06) | BE-018 → BE-008 |
| Test controls | `/v1/mock/reset`, `/v1/mock/clock`, `/v1/mock/seed`, `/v1/mock/scenarios`; return 404 when `ENV=production` | None (mock only) | BE-011 |

The change feed and `/v1/mock/*` are **REST reads, a deliberate dev-only deviation
from DB5**. The phone may use them only from a dev connector behind a build flag
(TASK-010). Production builds talk to PowerSync.

## Product impact (APM)

| Affected | Change needed |
|---|---|
| [tasks/backend/README.md](../tasks/backend/README.md) | Priority-ordered handoff: Track M before Track R; cross-team requests listed |
| [tasks/mobile/README.md](../tasks/mobile/README.md) | List TASK-010…012 as Draft (P3 preparation) |
| Flow Spec v2.8 relocation | [DOC-002](../tasks/docs/DOC-002-flow-spec-v2-8-relocation.md) |
| Retired dating cards in `tasks/backend/` | [DOC-003](../tasks/docs/DOC-003-archive-legacy-backend-cards.md) |

## Engineering impact (ASEM)

| Affected | Change needed |
|---|---|
| [decisions.md](../policies/engineering/decisions.md) | New entry: Track M is the backend until BE-001 lands; process-memory state, a dev token and the dev change feed are allowed in the mock. Number to be assigned by the ASEM: the database handbook already cites D-010, D-011 and D-013 |
| [architecture.md](../policies/engineering/architecture.md) §4 | Backend mock serves the v2.8 sync contract: write handler, fake side effects behind ports, change feed; `Store` protocol with an in-memory implementation |
| [data-schema.md](../policies/engineering/data-schema.md) §5 | Mock wire contract (table above) is the active backend contract; snake_case column names exactly as phone schema v1 |
| [coding-conventions.md](../policies/engineering/coding-conventions.md) §2 | Conflict: "`Field(alias="camelCase")`" vs. the sync contract, whose names are the snake_case phone-schema columns. Proposed: sync models use the column names, no aliases |
| [tdd.md](../policies/engineering/tdd.md) §3 | pytest cannot name a function `[BE-012-S01] …`. Proposed: `def test_be012_s01_<slug>()` whose docstring starts with `[BE-012-S01]`; run one scenario with `uv run pytest -k be012_s01` |
| [ci-cd.md](../policies/engineering/ci-cd.md) §2–3 | `uv.lock` is not committed today; Python pin; backend job in CI (BE-010) |
| [codebase-map.md](../policies/engineering/codebase-map.md) | Backend tree after BE-005 and BE-011 |
| Agent spec `agents/backend-developer.md` (Type 1, human) | Role rules already allow Track M; add "Track R needs BE-001" when BE-001 lands |

## Open questions (answer before or during approval)

| # | Question | Proposal |
|---|---|---|
| Q1 | Idempotency key for `POST /v1/sync/tx`. T4 keys `applied_tx` by `tx_id`, but the PowerSync SDK's transaction ID is believed to be a local counter per database (to be confirmed in SP-6 or the BE-001 spike), so two installs, or one reinstall, can repeat it | Mock keys on `(sub, tx_id)` **and** stores a hash of the ops; the same key with different ops is a 409 `TX_ID_REUSED`. BE-001 picks the real key |
| Q2 | Should server-owned result rows (jobs, drafts, decks) come from the mock backend, or from phone-side `fake_*` mirrors (spec P3-04)? | Both. Local fakes stay the offline default (TASK-011); the dev connector switches the phone to server fakes (TASK-010) |
| Q3 | Fake extraction sample choice. The phone hashes sanitized bytes (CHG-006 G-01); the server has no bytes until BE-018 | Hash the bytes when the attachment is uploaded (BE-018), else hash `asset_id`. Same three sample sets as the phone (TASK-012 fixtures) |
| Q4 | Where shared golden fixtures live (dormancy, rescue, A-03 decks, ObjectId vectors, sample sets, item types) | Repo-root `contracts/fixtures/*.json`, read by both test suites (TASK-012) |

## Code follow-up

| Role | Paths | Tests | Done |
|---|---|---|---|
| Backend Developer | `backend/` per BE-010, BE-005, BE-011…BE-018 | `backend/tests/` per card | [ ] |
| AI Engineer | `backend/app/ai/` per AI-005 | `backend/tests/ai/` | [ ] |
| App Developer | `apps/mobile/` per TASK-010…TASK-012 (after their plans) | per card | [ ] |

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | CHG-014 | Created (Draft) from the backend + AI codebase analysis |
