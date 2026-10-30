# CHG-001: Adopt the agentic documentation system

| Status | Source | Date |
|---|---|---|
| Approved | Human request | 2026-10-16 |

## Problem
Agent context was large and repetitive. The same rules were stated in 4–5 files, each feature was split between an APRD and a TASK card that repeated each other, the repository tree was drawn four times, and `GUIDE.MD` contained an outdated (Go backend) bootstrap prompt twice.

## Product impact (APM)
| Affected | Change |
|---|---|
| `docs/archive/legacy/architecture/GLOSSARY.md` | → `policies/product/terminology.md` (domain terms only) |
| — | New `policies/product/design-system.md`, `policies/product/bdd.md` |
| `docs/archive/legacy/specs/APRD-*`, `docs/tasks/TASK-*` | → one folder per item in `docs/backlog/` (`README.md` + `product/uat.feature`) |
| `docs/tasks/README.md` | → `docs/backlog/README.md` (index only; active phase tasks now live under `docs/tasks/mobile/` and `docs/tasks/backend/`) |

## Engineering impact (ASEM)
| Affected | Change |
|---|---|
| `docs/archive/legacy/architecture/README.md`, ADR 001–003 | → `policies/engineering/architecture.md` |
| ADR 001–005, lesson #001 | → `policies/engineering/decisions.md` |
| `docs/archive/legacy/architecture/MAP.md` | → `policies/engineering/codebase-map.md` |
| `docs/archive/legacy/quality/DOD.md` | → `definition-of-done.md`, `tdd.md`, `ci-cd.md` |
| `docs/agent/LESSONS_LEARNED.md` | → `docs/memory/LESSONS_LEARNED.md` (condensed) |
| — | New `data-schema.md`, `coding-conventions.md` |
| TASK-* file lists, state machines, contracts | → `backlog/BL-*/engineering/implementation-plan.md` + `test-plan.md` |
| `GUIDE.MD`, `.github/copilot-instructions.md` | Deleted / reduced to an adapter pointing at `docs/README.md` |

## Code follow-up
None. Code defects found during the restructure are tracked in [CHG-002](CHG-002-restore-green-build.md).
