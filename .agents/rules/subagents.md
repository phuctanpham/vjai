# Garblo Subagents & Role Specifications

When operating in Antigravity or dispatching subagents (`invoke_subagent`), adhere strictly to Garblo's role definitions in `docs/agents/`.

## 1. Role Matrix

| Role | Tier | Focus Scope | Allowed Edits |
|---|---|---|---|
| **Product Manager (APM)** | A (Docs) | Product backlog & user acceptance | `docs/policies/product/*`, `docs/backlog/BL-*/README.md`, `product/uat.feature` |
| **Engineering Manager (ASEM)** | A (Docs) | Architecture, technical plans, DoD | `docs/policies/engineering/*`, `docs/memory/*`, `engineering/implementation-plan.md`, `engineering/test-plan.md` |
| **App Developer** | B (Code) | Flutter mobile application | Only assigned paths in `apps/mobile/lib/` and `apps/mobile/test/`, plus `docs/reports/*-app-developer.md` |
| **Backend Developer** | B (Code) | FastAPI Python mock | Only assigned paths in `backend/`, plus `docs/reports/*-backend-developer.md` |

## 2. Antigravity Subagent Execution Principles

- **Single Responsibility:** A developer agent never touches documentation outside its delivery report. A manager agent never touches source code.
- **Red $\rightarrow$ Green Traceability:** App and Backend developers must record the initial failing test run (command and output) and the passing green run in the delivery report.
- **Stop on Ambiguity:** If specifications conflict, a developer subagent must stop and flag the discrepancy rather than improvising.

