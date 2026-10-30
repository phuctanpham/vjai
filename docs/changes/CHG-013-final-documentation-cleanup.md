# CHG-013: Final documentation cleanup and canonical-tree enforcement

| Status | Source | Date |
|---|---|---|
| Approved | Human cleanup request · review of active and duplicate documentation trees | 2026-10-30 |

Status values: `Draft` → `Approved` (human) → `Done` (after migration review).

## Decision

- `docs/` is the sole canonical documentation tree.
- Retired dating backlog records formerly under `docs/backlog/` moved to
  [`archive/legacy/backlog/`](../archive/legacy/backlog/). No historical
  record was discarded; the archive index marks the entire set as historical
  and non-authoritative.
- Existing retired architecture, specification and quality material remains
  under [`archive/legacy/architecture/`](../archive/legacy/architecture/),
  [`archive/legacy/specs/`](../archive/legacy/specs/) and
  [`archive/legacy/quality/`](../archive/legacy/quality/).
- The confirmed duplicate snapshot under `docs/docs/` was removed after
  comparison with the active tree. The active Flow Spec and Phase 1/2 records
  under `docs/tasks/` were retained.
- `TASK-003-phase-history-reconciliation.md` was renamed to
  [`DOC-001-phase-history-reconciliation.md`](../tasks/docs/DOC-001-phase-history-reconciliation.md).

## Historical versus future requirements

Archived dating BDD and plans describe historical dating behavior only. They
are not active requirements, product vocabulary or implementation guidance.
Phase 1/2 wardrobe task cards and their delivery records remain authoritative
for shipped behavior. Future platform questions remain in DOC-001 and must
not be backfilled into historical task records.

## Flow Spec basis

The canonical product authority remains:
[T4 `platform`](../tasks/mobile/Garblo%20Flow%20Spec.html#platform),
[T6 `phases`](../tasks/mobile/Garblo%20Flow%20Spec.html#phases), and
[T7 `design`](../tasks/mobile/Garblo%20Flow%20Spec.html#design).

## Type 1 integration

The human-approved integration pass updated the root `docs/README.md` and
adapters after the ASEM-owned migration. They now point to the canonical
`docs/tasks/` and `docs/archive/legacy/` paths.

## Acceptance criteria

- [x] Retired dating backlog is relocated without deleting history.
- [x] Duplicate `docs/docs/` snapshot is removed after confirmation.
- [x] DOC-001 rename and references are complete.
- [x] Active BDD guidance distinguishes wardrobe work from archived dating
  behavior.
- [x] Phase 1/2 records and behavior are not rewritten.
- [x] Human updates Type 1 root README/adapters and confirms final links.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-013](CHG-013-final-documentation-cleanup.md) | Recorded final documentation structure, archive relocation, duplicate snapshot removal and Type 1 integration conflict. |
| 2026-10-30 | [CHG-013](CHG-013-final-documentation-cleanup.md) | Updated Type 1 entry points and adapters to reference the canonical tasks/archive structure. |
