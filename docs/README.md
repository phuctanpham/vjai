# Garblo Agentic Coding System

The single entry point for the human and every coding agent. Rules stated here are not repeated anywhere else.

## 1. Agents

| Agent | Tier | Generates | Spec |
|---|---|---|---|
| **Product Manager (APM)** | A · documents | Product policies; per backlog item: item card, BDD scenarios, UI/UX, user flow, information layout, interactions | [agents/product-manager.md](agents/product-manager.md) |
| **Engineering Manager (ASEM)** | A · documents | Engineering policies; per backlog item: implementation plan, test plan, dataflow, functionality, event stream | [agents/engineering-manager.md](agents/engineering-manager.md) |
| **App Developer** | B · code | Flutter code lines in `lib/`, `test/` | [agents/app-developer.md](agents/app-developer.md) |
| **Backend Developer** | B · code | Python code lines in `backend/` | [agents/backend-developer.md](agents/backend-developer.md) |

The **human** approves documents, edits agent specs, and merges code.

## 2. Document types

| Type | Content | Written by | Location |
|---|---|---|---|
| **1 · Agent specs** | Role, skills, workflow, followed files, generated files | Human | `docs/README.md`, `docs/agents/`, tool adapters (`CLAUDE.md`, `.claude/agents/`, `.github/copilot-instructions.md`) |
| **2 · Followed files** | Policies, backlog documents, change records, lessons | Tier A, one owner per file | `docs/policies/`, `docs/backlog/`, `docs/changes/`, `docs/memory/` |
| **3 · Generated files** | Code lines and delivery reports | Tier B | `lib/`, `test/`, `backend/`, `docs/reports/` |

```text
docs/
├── README.md                    this file
├── agents/                      T1
├── policies/
│   ├── product/                 T2 · APM   terminology · design-system · bdd
│   └── engineering/             T2 · ASEM  architecture · codebase-map · data-schema · coding-conventions
│                                           tdd · ci-cd · definition-of-done · decisions
├── backlog/
│   ├── README.md                T2 · APM   index and status
│   ├── _TEMPLATE/               copy to start an item
│   └── BL-NNN-<slug>/
│       ├── README.md            T2 · APM   item card: goal, scope, anti-scope, status, product acceptance
│       ├── product/             T2 · APM   uat.feature  (+ ui-ux · user-flow · information-layout · interactions)
│       └── engineering/         T2 · ASEM  implementation-plan · test-plan  (+ dataflow · functionality · event-stream)
├── changes/                     T2 · APM + ASEM   CHG-NNN change records
├── memory/LESSONS_LEARNED.md    T2 · ASEM
└── reports/                     T3 · developers   one report per delivery
```

## 3. Context rules (keep agent context small)

1. **One fact, one place.** Link to the source instead of copying it. If you find a duplicate, delete it and keep the version in its owner file.
2. **A file exists only when it has content.** Documents in parentheses above are created only when the backlog item needs them, never as empty stubs.
3. **Read only your list.** Each agent spec lists its followed files. Read those plus the item you work on; use [codebase-map](policies/engineering/codebase-map.md) instead of crawling the repository.
4. **One owner per Type 2 file.** Other agents read it but never edit it. No agent edits Type 1.
5. **Merged code is followed code.** A developer changes only the files its role is given in `implementation-plan.md`. All other code is a read-only contract.
6. **Diagrams are Mermaid inside the owning document.**
7. **Every Type 2 file ends with a `Change history` table** (`| Date | CHG | Change |`).

## 4. Delivery flow: issue → documents → tests → code (BDD + TDD)

```text
Issue
 ① APM + ASEM   docs/changes/CHG-NNN-<slug>.md: impact on policies, BL items, code areas
                (a new feature creates a new BL-NNN folder)
 ② APM          item card, uat.feature (scenarios tagged @BL-NNN-Sxx), optional product docs
 ③ ASEM         implementation-plan.md, test-plan.md (every scenario → tests), optional engineering docs
 ④ HUMAN        approves → APM sets status "Ready to code"
 ⑤ Developers   TDD: failing tests (red) → minimum code (green) → refactor
                report: docs/reports/<BL|CHG>-NNN-<role>.md
 ⑥ ASEM         engineering acceptance against definition-of-done (in implementation-plan.md)
    APM         product acceptance: every scenario has a passing test (in item README)
 ⑦ HUMAN        merges → APM sets status "Done", ASEM updates codebase-map and lessons
```

**Status values** (set only by the APM): `Draft` → `Ready to code` → `Done`, or `Blocked` with a reason.
A delivery is "in review" when its report exists in `docs/reports/`.

**Traceability**
- Test names start with the scenario ID: `'[BL-005-S02] swiped profiles are filtered on reload'`.
- Commits start with the ID: `[BL-005] test: …` then `[BL-005] feat: …`.
- Type 2 edits name their CHG in the `Change history` table.

## 5. Rules for every agent

1. **Stay in scope.** Never build anything listed in the item's anti-scope, and never start an item that is not `Ready to code`.
2. **Add no dependency** unless [decisions.md](policies/engineering/decisions.md) approves it.
3. **Use canonical terms** from [terminology.md](policies/product/terminology.md); never invent synonyms.
4. **Report the truth.** Never claim a command passed without running it. List skipped commands and why.
5. **No secrets.** Never commit credentials, tokens, keys or personal data.
6. **Stop when blocked.** If followed files conflict or are missing, record it (report or CHG) and stop. Do not improvise.
7. **Precedence when documents conflict:** agent specs > item card > uat.feature > implementation plan > test plan > policies > existing code.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](changes/CHG-001-agentic-documentation-system.md) | System created; replaces GUIDE.MD, docs/architecture, docs/specs, docs/tasks, docs/quality |
