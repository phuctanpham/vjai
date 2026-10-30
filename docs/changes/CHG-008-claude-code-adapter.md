# CHG-008: Claude Code adapter and agent navigation

| Status | Source | Date |
|---|---|---|
| Done | Human request: centralize documents in `docs/` and set up Claude Code instructions for exploring the codebase | 2026-10-30 |

Status values: `Draft` → `Approved` (human) → `Done` (after merge).

## Problem

Claude Code had no entry point. `docs/README.md` named `CLAUDE.md` and
`.claude/agents/` as tool adapters, but neither existed. Agents that followed the
rule "use the codebase map instead of crawling" got a map of the retired dating
slice: it had no `studio`, `wardrobe`, `gu_match`, `privacy`, `core/storage` or
`core/media`. The product authority is a single 490 KB HTML file that agents
read whole or not at all. `GUIDE.MD` was still at the repository root.

The uncommitted CHG-007 link rewrite had also re-encoded 12 UTF-8 documents as
Windows-1252 (`—` became `â€”`, and tree lines became `â”œâ”€â”€`).

## Decisions

| ID | Decision | Reason |
|---|---|---|
| D8-01 | `CLAUDE.md` is a thin Type 1 adapter: reading order, current vs legacy, commands, guardrails. Rules stay in their owner files | One fact, one place (`docs/README.md` §3) |
| D8-02 | `.claude/agents/*.md` wrap `docs/agents/*.md` and add only tool lists and a return format | Role specs remain the single source |
| D8-03 | Two project skills: `flow-spec` prints one Flow Spec section by anchor; `gates` runs and reports the ci-cd.md gates | Keeps agent context small; makes the "never claim an unrun gate" rule routine |
| D8-04 | The Flutter package stays at the repository root for now. Moving it to `apps/mobile/` is deferred to a separate CHG after PR 4 merges | A tree-wide rename would turn the Draft Phase 2 review into a rename diff and break `.github/workflows/android-apk.yml` and every `apps/mobile/lib/` path in the docs |
| D8-05 | `README.md`, `backend/README.md` and `.github/copilot-instructions.md` stay where they are | GitHub, `pyproject.toml` (`readme = "README.md"`) and Copilot need those paths |
| D8-06 | `.claude/settings.json` (permission allowlist) is approved by the human but installed by the human: the agent may not write its own permission settings | Claude Code blocks self-modification of permissions |

## Product impact (APM)

| Affected | Change needed |
|---|---|
| None | — |

## Engineering impact (ASEM)

| Affected | Change needed |
|---|---|
| [codebase-map.md](../policies/engineering/codebase-map.md) | Rebuilt for the Phase 1–2 tree; adds the monorepo layout, test helpers and docs navigation |
| [LESSONS_LEARNED.md](../memory/LESSONS_LEARNED.md) | Add #7: encoding corruption from a PowerShell round-trip |
| [docs/README.md](../README.md) | List `.claude/skills/` as an adapter; archive now holds `GUIDE.md` |
| [archive/README.md](../archive/README.md) | Index `legacy/GUIDE.md` |
| [README.md](../../README.md) | Replace the stale duplicate tree with a layout table linking the codebase map |
| `GUIDE.MD` → [archive/legacy/GUIDE.md](../archive/legacy/GUIDE.md) | Move; rebase its relative links; repoint inbound links (CHG-007, TASK-001 doc conflicts) |
| 12 files touched by CHG-007 | Reverse the Windows-1252 double encoding (verified: zero changes on the HEAD copies, single pass on the working copies) |

## Added files

| Path | Content |
|---|---|
| `CLAUDE.md` | Claude Code entry instructions |
| `.claude/agents/{app-developer,backend-developer,engineering-manager,product-manager}.md` | Subagents wrapping `docs/agents/` |
| `.claude/skills/flow-spec/` (`SKILL.md`, `section.sh`) | Flow Spec anchor index and section extractor |
| `.claude/skills/gates/SKILL.md` | Gate runner and report format |
| `.gitignore` | Ignore `CLAUDE.local.md` and `.claude/settings.local.json` |

## Deferred follow-up

- **Monorepo move (D8-04):** after PR 4 merges, open a CHG to move the Flutter
  package to `apps/mobile/`, update the APK workflow's working directory, the
  codebase map, `tdd.md` paths and the architecture tests' `apps/mobile/lib/` roots.
- `.github/copilot-instructions.md` still repeats architecture rules. CHG-001
  intended a thin adapter like `CLAUDE.md`.
- Resolved: `docs/tasks/mobile/README.md` said Phase 2 was "merged (PR 4)" while
  PR 4 was Draft; PR 4 is now merged ([CHG-009](CHG-009-phase-2-verification.md)).

## Code follow-up

| Role | Paths | Tests | Done |
|---|---|---|---|
| App Developer | None | None | [x] |
| Backend Developer | None | None | [x] |

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | — | Created |
| 2026-10-30 | — | Approved by the human |
| 2026-10-30 | — | Done: merged to `main` with Phase 2 (PR 4) |
| 2026-10-30 | [CHG-010](CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
