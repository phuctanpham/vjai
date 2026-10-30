# CHG-007: Align active documentation with the wardrobe Flow Spec

| Status | Source | Date |
|---|---|---|
| Done | Human request · [TASK-001 documentation conflict analysis](../tasks/docs/TASK-001-doc-conficts.md) · [Garblo Flow Spec](../tasks/mobile/Garblo%20Flow%20Spec.html) v2.7.1 | 2026-10-30 |

Status values: `Draft` → `Approved` (human) → `Done` (after merge).

## Problem

The active policy files still describe the retired dating product while the
approved Phase 1 and Phase 2 records describe the wardrobe/outfit product.
Agents therefore receive contradictory product, UI and data contracts.

This change migrates only the authority-layer documents whose target contract
is already fixed by T2, T4, T7, CHG-003, CHG-005 and CHG-006. It does not
decide the future backend platform, rewrite the Flow Spec, or delete legacy
dating documents.

## Decisions

| ID | Decision | Reason |
|---|---|---|
| D7-01 | T7 is authoritative for UI tokens, layout, interaction and copy; T2 is authoritative for domain names and logical data; T4 is authoritative for platform and sync rules; T6 is authoritative for phase boundaries | Prevents policies from overriding the source specification |
| D7-02 | The wardrobe vocabulary is canonical for new work; dating vocabulary is retained only as legacy terminology for the unrouted feature tree | TASK-001 and CHG-003 prohibit silently reinterpreting or deleting the old tree |
| D7-03 | The current FastAPI backend decision remains unresolved for P3/P4 | BE-001 must decide MongoDB, PowerSync, authentication and wire contracts |

## Product impact (APM)

| Affected | Change needed |
|---|---|
| [design-system.md](../policies/product/design-system.md) | Replace dating tokens, components and copy with the T7 contract |
| [terminology.md](../policies/product/terminology.md) | Add TASK-001 wardrobe terms and mark dating terms as legacy |
| [docs/README.md](../README.md) | Add Flow Spec precedence above policies |
| [README.md](../../README.md) | Update the repository product identity, phase status and legacy API disclaimer |
| [GUIDE.md](../archive/legacy/GUIDE.md) | Mark the historical guide as non-authoritative and redirect current work |

## Engineering impact (ASEM)

| Affected | Change needed |
|---|---|
| [data-schema.md](../policies/engineering/data-schema.md) | Replace dating API/storage contract with T2/T4 and CHG-005/006 references |
| [.github/copilot-instructions.md](../../.github/copilot-instructions.md) | Point agents to active policies and the Flow Spec; constrain the legacy mock |
| [backend/README.md](../../backend/README.md) | Label the current FastAPI endpoints as a phase-limited legacy mock |
| [architecture.md](../policies/engineering/architecture.md) | Deferred until BE-001 resolves the P3/P4 backend platform |
| [decisions.md](../policies/engineering/decisions.md) | Deferred until BE-001 resolves whether D-004 is superseded |

## Deferred follow-up

- Publish the next Flow Spec version to reconcile T6 scope, first launch,
  consent copy, UC-09 navigation and P3 write ownership.
- Record accepted deviations and backend sync parity in CHG-003, CHG-005 and
  BE-006.
- Mark the old dating specifications and architecture documents as
  superseded in a separate cleanup change.

## Code follow-up

| Role | Paths | Tests | Done |
|---|---|---|---|
| App Developer | None | None | [x] |
| Backend Developer | None | None | [x] |

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | — | Created to track the first safe documentation authority migration. |
| 2026-10-30 | — | Centralized superseded architecture, APRD and DoD documents under `docs/archive/legacy/` and repaired repository links. |
| 2026-10-30 | [CHG-008](CHG-008-claude-code-adapter.md) | Repaired Windows-1252 double encoding that the link rewrite introduced in 12 files; moved `GUIDE.MD` to `docs/archive/legacy/GUIDE.md` |
| 2026-10-30 | — | Approved by the human |
| 2026-10-30 | — | Done: merged to `main` with Phase 2 (PR 4) |
