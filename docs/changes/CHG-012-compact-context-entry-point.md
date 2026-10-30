# CHG-012: Compact documentation context entry point

| Status | Source | Date |
|---|---|---|
| Draft | Human request · review of `docs/` and the duplicate `docs/docs/` tree | 2026-10-30 |

Status values: `Draft` → `Approved` (human) → `Done` (after migration review).

## Problem

The repository has an active `docs/` tree and a duplicate `docs/docs/` tree.
The duplicate contains an older, partially divergent snapshot, while Phase 1
and Phase 2 decisions are implemented and must remain traceable.

## Decision

The earlier compact-context proposal was implemented temporarily in
`docs/docs/README.md`. CHG-013 superseded that duplicate snapshot and removed
it after the active `docs/` tree was confirmed as the sole canonical tree.

The active policy and task files are not copied, deleted or rewritten by this
change. Legacy dating material remains preserved under
[`archive/legacy/`](../archive/legacy/).

## Flow Spec basis

The context summary relies on these anchored sections:

- [T6 `phases`](../tasks/mobile/Garblo%20Flow%20Spec.html#phases):
  “P1–P5 development phases” for phase status and boundaries.
- [T4 `platform`](../tasks/mobile/Garblo%20Flow%20Spec.html#platform):
  “SQLite + PowerSync + MongoDB” for the future platform boundary; P2 remains
  local-only.
- [T7 `design`](../tasks/mobile/Garblo%20Flow%20Spec.html#design):
  “tokens, grid, copy” for the UI authority.

The Flow Spec remains source material and is not edited here.

## Engineering impact

| Area | Impact |
|---|---|
| Agents | The active root `docs/` tree remains the source of truth; the duplicate context snapshot was removed under CHG-013. |
| Phase records | TASK-001 through TASK-009 and CHG-003/005/009 remain unchanged. |
| Legacy docs | No deletion; duplicate snapshots are quarantined and legacy dating material remains preserved. |
| Root entry point | `docs/README.md` was not edited because it is a Type 1 file outside the ASEM ownership boundary; this is recorded as an open integration conflict. |
| Code | None. |

## Open conflicts recorded

The migration exposed unresolved documentation questions affecting completed
Phase 1/2 records. They are recorded, not resolved, in
[DOC-001](../tasks/docs/DOC-001-phase-history-reconciliation.md):
consent-copy truth by phase, the 800/840 breakpoint deviation, the P2/P3
ownership wording for generated deck rows, and the Flow Spec source-version
drift.

## Acceptance criteria

- [x] The duplicate context proposal was reviewed and superseded by the
  canonical root `docs/` tree.
- [ ] Implemented Phase 1/2 decisions remain linked and unchanged.
- [ ] Duplicate snapshots and legacy dating material are preserved and clearly
  marked or quarantined.
- [ ] Each unresolved conflict has a follow-up task with status and
  acceptance criteria.
- [ ] No application or backend code changes are made.
- [ ] Relative links in the changed documentation resolve.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-012](CHG-012-compact-context-entry-point.md) | Created the migration record for the compact context entry point and conflict traceability. |
| 2026-10-30 | [CHG-013](CHG-013-final-documentation-cleanup.md) | Superseded by the final cleanup record for archive relocation and duplicate-tree removal. |
