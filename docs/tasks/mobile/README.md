# Mobile Phase 1 and Phase 2 Task Plan

> **Product:** Garblo  
> **Phase:** 1 · P1 Clickable offline app and Phase 2 · P2 Persistent offline app  
> **Status:** Phase 1 green and merged (PR 2, [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md)); Phase 2 (TASK-005 to 009) green and merged (PR 4, [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md), [CHG-006](../../changes/CHG-006-phase-2-green-decisions.md), [CHG-009](../../changes/CHG-009-phase-2-verification.md)); Phase 2 complete, P3 waits for BE-001  
> **Source:** [Garblo Flow Spec.html](Garblo%20Flow%20Spec.html) v2.7

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
