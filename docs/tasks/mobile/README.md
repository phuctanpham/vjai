# Mobile Phase 1 Task Plan

> **Product:** Garblo  
> **Phase:** 1 · Spec T6 **P1 Clickable offline app** — scope alignment, mobile foundation, Flows A and B  
> **Status:** Contract frozen in [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) (Draft); tests written (red) on branch `phase-1/wardrobe-tdd`  
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
| [TASK-001](TASK-001-product-domain-alignment.md) | Product-domain alignment and contract freeze | None | **Decided; CHG-003 awaiting approval** |
| [TASK-002](TASK-002-mobile-foundation.md) | Mobile foundation and 5-pillar shell | TASK-001 | **Green · in review** ([report](../../reports/TASK-002-app-developer.md)) |
| [TASK-003](TASK-003-flow-a-add-to-wardrobe.md) | Flow A: Index Pieces → Archive (`studio`, `wardrobe`) | TASK-002 | **Green · in review** ([report](../../reports/TASK-003-app-developer.md)) |
| [TASK-004](TASK-004-flow-b-style-new-look.md) | Flow B: Gu Match, drafting Fits from your own Pieces (`gu_match`) | TASK-003 | **Green · in review** ([report](../../reports/TASK-004-app-developer.md)) |

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
