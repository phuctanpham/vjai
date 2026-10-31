# Mobile Task Plan (P1–P5)

> **Product:** Garblo  
> **Phase:** P1 Clickable offline app and P2 Persistent offline app (done); P3–P5 planned mock-first ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md), Draft)  
> **Status:** Phase 1 green and merged (PR 2, [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md)); Phase 2 (TASK-005 to 009) green and merged (PR 4, [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md), [CHG-006](../../changes/CHG-006-phase-2-green-decisions.md), [CHG-009](../../changes/CHG-009-phase-2-verification.md)); Phase 2 complete. Track M (mock) cards need no BE-001; Track R cards wait for BE-001  
> **Source:** P1–P2 cards were written against Flow Spec v2.7 (historical, not rewritten). Forward cards follow [Garblo Flow Spec.md](<../../specs/Garblo Flow Spec.md>) v2.8 and the [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) (relocation: [DOC-002](../docs/DOC-002-flow-spec-v2-8-relocation.md))

## Purpose

This folder converts the mobile flow specification into bounded, TDD-ready task
documents. Phase 1 matches the spec's own phase ladder: Flutter UI, in-memory
repositories seeded from fixtures, and fake AI. There is no SQLite, PowerSync,
backend API, or ML in this phase.

## Domain decision

The repository previously described a dating and matching application. The
product owner selected the **wardrobe/outfit** direction
([TASK-001](TASK-001-product-domain-alignment.md)). The dating feature tree
stays in place, unchanged and unrouted, until a removal CHG.

## Phase 1 task sequence

| ID | Task | Dependency | Status |
|---|---|---|---|
| [TASK-001](TASK-001-product-domain-alignment.md) | Product-domain alignment and contract freeze | None | **Decided; CHG-003 approved** |
| [TASK-002](TASK-002-mobile-foundation.md) | Mobile foundation and 5-pillar shell | TASK-001 | **Green · merged** ([report](../../reports/TASK-002-app-developer.md)) |
| [TASK-003](TASK-003-flow-a-add-to-wardrobe.md) | Flow A: Index Pieces → Archive (`studio`, `wardrobe`) | TASK-002 | **Green · merged** ([report](../../reports/TASK-003-app-developer.md)) |
| [TASK-004](TASK-004-flow-b-style-new-look.md) | Flow B: Gu Match, drafting Fits from your own Pieces (`gu_match`) | TASK-003 | **Green · merged** ([report](../../reports/TASK-004-app-developer.md)) |

## Explicitly deferred

- Flow C: Impact, rewards, XP, streaks, and badges (Impact tab shows its
  flag-off state).
- Flow D: Share achievements and Community (Community tab shows its
  flag-off state).
- First-launch, item detail, manual wear logging, account hub, notification
  inbox (spec gaps ①–⑤, "Needs spec").
- Try-on, calendar export, notifications, and production AI/cloud
  integrations. Backend and AI follow-ups are in
  [docs/tasks/backend/](../backend/README.md).

## Phase 2: Persistent offline app

Phase 2 follows the specification's T6 P2 ladder. It replaces the in-memory
repositories behind the existing interfaces with persistent local storage while
keeping the UI and domain contracts stable.

| ID | Task | Dependency | Status |
|---|---|---|---|
| [TASK-005](TASK-005-local-persistence-foundation.md) | SQLite/SQLCipher, PowerSync-shaped phone schema v1, local repositories, restore | Phase 1 merged | **Green · merged** (PR 4, [report](../../reports/TASK-005-008-app-developer.md)) |
| [TASK-006](TASK-006-derived-queries-and-rules.md) | Derived wear values in SQL (dormancy, rescue eligibility), benchmark | TASK-005 | **Green · merged** (PR 4, [report](../../reports/TASK-005-008-app-developer.md)) |
| [TASK-007](TASK-007-photo-privacy-pipeline.md) | Real photos, lossless metadata stripping, private attachments | TASK-005 | **Green · merged** (PR 4, [report](../../reports/TASK-005-008-app-developer.md)) |
| [TASK-008](TASK-008-device-integrations-and-data-rights.md) | UC-09 local erasure: Avatar › Privacy & data (calendar, reminders, export and poster deferred) | TASK-005, TASK-007 | **Green · merged** (PR 4, [report](../../reports/TASK-005-008-app-developer.md)) |
| [TASK-009](TASK-009-offline-reliability-validation.md) | Restart, app-kill, offline, and migration verification | TASK-005 through TASK-008 green | **Green · merged** (PR 4, [report](../../reports/TASK-009-app-developer.md)) |

### Phase 2 constraints

- Must-have scope only: Flow A, Flow B, UC-09 local erasure ([CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) P2-D2).
- Synced tables follow the PowerSync rules: `id TEXT PRIMARY KEY`, no foreign
  keys, no UNIQUE constraints; idempotency comes from deterministic IDs.
- SQLite/SQLCipher is local-only; PowerSync and backend APIs remain Phase 3+.
- Fake extraction and fake Gu Match generation remain unchanged.
- Repository interfaces remain the UI boundary; no widget reads SQL directly.
- Every persistent write must be transactional or append-only as specified.
- No production AI/ML, cloud upload, authentication, or sync is included.
- Device permissions and data-rights UX are gated by explicit product
  specification where the source still marks a gap as “Needs spec”.

## P3–P5 plan (Draft, mock first)

Proposed in [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) (backend analysis) and
[CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) (mobile + database
analysis). Each card needs an implementation plan from the Engineering Manager before it is
`Ready to code`. The open contract decisions are in
[DOC-004](../docs/DOC-004-mobile-contract-decisions.md).

**Tracks.** **M**: recorded responses from the Track M mock (`contracts/fixtures/sync/`), then the
live mock (tag `live_backend`); no database, fake data and fake AI, no BE-001. **R**: the same
tests against PowerSync and the real services, after BE-001. `M → R` cards ship M first.

### Refactor of P1–P2 (no backend; run first)

The P1–P2 code passes its tests (481 passed, 1 benchmark skipped on 2026-10-31) but stores rows
that the v2.8 sync contract would reject (CHG-015 F-01…F-17).

| Order | ID | Task | Dependency | Status |
|---|---|---|---|---|
| 1 | [TASK-013](TASK-013-wire-values-and-time.md) | Wire values (UPPER_SNAKE enums), UTC timestamps, `YYYY-MM-DD` dates, injected clock; data migration | DOC-004 Q1, Q4, Q11 | Draft |
| 2 | [TASK-016](TASK-016-retire-legacy-mobile-code.md) | Retire the legacy dating code (`ApiClient`, `LocalStorage`, `discovery/`, placeholders) | APM removal decision | Draft |
| 3 | [TASK-015](TASK-015-result-engine-seams.md) | Engine seams for analysis, context and decks; Local no longer wraps Mock | TASK-013 | Draft |
| 4 | [TASK-011](TASK-011-phone-schema-v2-alignment.md) | Phone schema v2: v2.8 tables, column classes, `fake_*` mirrors, body photos by purpose | TASK-013, ASEM CHG | Draft |
| 5 | [TASK-014](TASK-014-upload-safe-write-shapes.md) | Upload-safe write shapes (no DELETE + INSERT), stable Archive order, write guard | TASK-011 | Draft |
| 6 | [TASK-012](TASK-012-shared-golden-fixtures.md) | Shared golden fixtures in `contracts/fixtures/` (incl. enums and table classes) | TASK-011, location decision | Draft |

### P3 · Synced app, download-only

| ID | Task | Spec | Track | Dependency | Status |
|---|---|---|---|---|---|
| [TASK-017](TASK-017-local-upload-queue.md) | Local upload queue (`ps_crud` shape) and pending count | P3-04 | M | TASK-014 | Draft |
| [TASK-010](TASK-010-mock-backend-integration.md) | Sync transport and dev connector: drain queue, apply feed, checkpoint | P3-04 | M | TASK-017, BE-012, BE-013, `http` | Draft |
| [TASK-018](TASK-018-flows-on-server-fakes.md) | Flow A and Flow B on server fakes (synced engines) | P3-04, P4 preview | M | TASK-010, TASK-015, BE-014, BE-015 | Draft |
| [TASK-019](TASK-019-catalog-from-the-database.md) | Item-type catalog from the database | P3-05 | M → R | TASK-010, TASK-011 | Draft |
| [TASK-021](TASK-021-attachment-downloads.md) | Attachment rows, GET tickets, offline file cache | P3-06 | M → R | TASK-010, BE-018 | Draft |
| [TASK-022](TASK-022-sync-status-and-convergence.md) | Sync status, Sync now, two-phone convergence | P3-05, P3-07 | M → R | TASK-010, UI spec | Blocked (UI spec, DOC-004 Q9) |
| [TASK-020](TASK-020-powersync-sdk-swap.md) | Swap plain SQLite for the PowerSync SDK | P3-04 | R | BE-001, BE-006, dependency decision | Blocked (BE-001) |

### P4 · Full backend, no AI

| ID | Task | Spec | Track | Dependency | Status |
|---|---|---|---|---|---|
| [TASK-023](TASK-023-identity-dev-token-to-anonymous-account.md) | Identity: dev token, then anonymous account | P4-M01 | M → R | TASK-010; BE-011 → BE-019 | Draft (UI blocked by gap ①) |
| [TASK-024](TASK-024-rejections-and-retries.md) | Upload rejections, retries, "Couldn't save · Fix" | P4-M02 | M → R | TASK-010, DOC-004 Q6 | Draft |
| [TASK-025](TASK-025-photo-upload-with-tickets.md) | Photo upload with tickets; Analyze queued offline | P4-M03 | M → R | TASK-021, BE-018 → BE-008 | Draft |
| [TASK-026](TASK-026-gu-match-command-rows.md) | Gu Match as command rows (sessions, interactions, Fit items) | P4-M04 | M → R | TASK-018, DOC-004 Q3–Q5 | Draft |
| [TASK-027](TASK-027-privacy-requests-online.md) | Privacy requests online (BODY, ALL; wipe after ack) | P4-M07 | M → R | TASK-023, BE-017 → BE-007 | Draft (export blocked by gap ④) |

### P5 · Intelligent app

| ID | Task | Spec | Track | Dependency | Status |
|---|---|---|---|---|---|
| [TASK-028](TASK-028-real-pipeline-states.md) | Real-pipeline states: job progress, retries, skips, provenance, slow path | P5-A01/A02 readiness | M → R | TASK-018, AI-005, BE-014 | Draft |
| [TASK-029](TASK-029-on-device-blur-and-duplicates.md) | On-device blur and duplicate check behind ports | P5-M01 | M → R | TASK-011; SP-1, SP-4, AI-004 for R | Draft |
| [TASK-030](TASK-030-try-on-end-to-end.md) | Try-on end to end (`vton_jobs`, body photo, withdrawal) | P5-M02 | M → R | TASK-026, TASK-025, [BE-021](../backend/BE-021-fake-try-on-side-effects.md); SP-3, AI-002 for R | Draft |

### Not planned as cards yet

No card until its spec or release exists (docs/README.md §3 rule 2): P1-04 first launch
(gap ①), item detail and Add without photo (gap ②), manual wear logging (gap ③), P2-06 device
calendar and local notifications, P2-07 export (gap ④), P4-M05 rewards and P4-M06 Community
(Flow C/D, flagged), P5-M03 outfit-photo logging, P5-M04 eco figures.

### Requests raised for other roles

| ID | For | Problem |
|---|---|---|
| [DOC-004](../docs/DOC-004-mobile-contract-decisions.md) | APM, ASEM, human | 12 contract decisions (time zone, status writers, save-for-later, action names, Fit item shape, offline copy, dependencies) |
| [BE-022](../backend/BE-022-mock-contract-requests-from-mobile.md) | Backend Developer, ASEM | Keep the mock strict on the v2.8 encoding; read shared fixtures; export recorded responses |
| [BE-021](../backend/BE-021-fake-try-on-side-effects.md) | Backend Developer | Fake `vton_jobs` side effects for TASK-030 |
| [DOC-003](../docs/DOC-003-archive-legacy-backend-cards.md) | APM, ASEM | Retired `tasks/backend/TASK-013…015` share IDs with the new mobile cards |

## Delivery gates

Every implementation task must follow:

1. Approved scope and anti-scope.
2. Failing tests named with the task and scenario ID: `[TASK-003-S05] …`.
3. Minimum implementation.
4. Refactor and verification.
5. Delivery report in `docs/reports/` and product/engineering acceptance.

Rules: [tdd.md](../../policies/engineering/tdd.md),
[definition-of-done.md](../../policies/engineering/definition-of-done.md),
[ci-cd.md](../../policies/engineering/ci-cd.md),
[architecture.md](../../policies/engineering/architecture.md). Canonical
terms: [TASK-001 › Canonical terms](TASK-001-product-domain-alignment.md#canonical-terms).

Red-phase commits stay on the feature branch: CI
([android-apk.yml](../../../.github/workflows/android-apk.yml)) runs
`flutter test` on every push to `main`.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | — | Created Phase 1 mobile task index and recorded the product-domain conflict. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Aligned with spec T6 P1; links moved to `docs/policies/`; backend handoff linked. |
| 2026-10-29 | — | Added the P2 persistent-offline task breakdown based on T6 P2-01 through P2-09. |
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | Phase 1 merged; Phase 2 scope corrected to must-have; PowerSync table rules; statuses updated. |
| 2026-10-30 | [CHG-009](../../changes/CHG-009-phase-2-verification.md) | TASK-009 green; Phase 2 complete and merged. |
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Listed TASK-010…012 (Draft) for P3 preparation. |
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | P1–P2 refactor (TASK-013…016) and the mock-first P3–P5 plan (TASK-017…030); Source re-pointed from the deleted v2.7 HTML to v2.8. |
