# Garblo — Claude Code instructions

Garblo is a wardrobe and outfit app: one Flutter codebase for Android, iOS, Windows and macOS,
built test-first. `backend/` holds a legacy FastAPI mock. This file is a thin adapter: the rules
live in [`docs/README.md`](docs/README.md) and its linked policies. Link to them; do not copy them here.

## Start here

Read in this order and stop when you have enough:

1. [`docs/README.md`](docs/README.md): agents, document types, delivery flow, precedence, rules for every agent.
2. [`docs/policies/engineering/codebase-map.md`](docs/policies/engineering/codebase-map.md): the annotated
   repository tree. Use it instead of crawling.
3. Your task. Current wardrobe work is `docs/tasks/mobile/TASK-NNN-*.md` (status in
   [`docs/tasks/mobile/README.md`](docs/tasks/mobile/README.md)); backend and AI follow-ups are in `docs/tasks/backend/`.
   Decisions are in `docs/changes/CHG-NNN-*.md`.
4. The Flow Spec sections your task cites, through the **`flow-spec`** skill. Never read the
   490 KB HTML whole.

Role specs are in `docs/agents/`. Matching subagents are in `.claude/agents/` (`app-developer`,
`backend-developer`, `engineering-manager`, `product-manager`).

## Current vs legacy

| Current: build on it | Legacy: read-only, do not extend or reuse its vocabulary |
|---|---|
| `apps/mobile/lib/features/{studio,wardrobe,gu_match,privacy}`, `apps/mobile/lib/core/`, `apps/mobile/lib/app/` | `apps/mobile/lib/features/discovery/` and the `*_placeholder.dart` features |
| `docs/tasks/`, `docs/changes/`, `docs/policies/`, Flow Spec | `docs/archive/legacy/` (dating backlog and superseded documents) |
| Wardrobe terms in `terminology.md` | `backend/` dating endpoints (platform pending [BE-001](docs/tasks/backend/BE-001-platform-decision.md)) |

## Commands

Flutter **3.24.5** (pinned in `.fvmrc`). The app lives in `apps/mobile/` ([CHG-010](docs/changes/CHG-010-monorepo-mobile-move.md)):
run Flutter commands from there; test paths in commands are relative to it. Gate definitions:
[`ci-cd.md`](docs/policies/engineering/ci-cd.md). Run the **`gates`** skill before you call work done.

```bash
cd apps/mobile
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test                                   # full suite
flutter test test/features/wardrobe/           # one feature
flutter test --plain-name '[TASK-006-S03]'     # one scenario
cd ../../backend && uv run pytest              # backend, from backend/
```

Paths that only exist on one machine (an SDK that is not on PATH, the Windows `sqlite3.dll`) go in
`CLAUDE.local.md`, which is git-ignored.

## Architecture in brief

View → ViewModel (Riverpod `StateNotifier`) → repository interface → `Mock*` or `Local*`
(SQLCipher) implementation. Full rules: [`architecture.md`](docs/policies/engineering/architecture.md)
and [`coding-conventions.md`](docs/policies/engineering/coding-conventions.md).

- `apps/mobile/test/architecture/` enforces the layering. Views and widgets never import `data/`.
- Layout is chosen by width (`Breakpoints.desktop = 800`). No `Platform.isX` in widgets.
- `localDatabaseProvider`, `ownerIdProvider` and `attachmentStoreProvider` throw until
  `apps/mobile/lib/app/bootstrap.dart` overrides them. Tests override them through `ProviderScope`.

## TDD loop

Follow [`tdd.md`](docs/policies/engineering/tdd.md): red → green → refactor, with the red run and the green run recorded in the report.

- Test names start with the scenario ID: `'[TASK-007-S02] …'`. Find existing ones with
  Grep `\[TASK-007-S` in `apps/mobile/test/`.
- Commits: `[TASK-NNN] test: …` before `[TASK-NNN] feat: …` (`coding-conventions.md` §3).
- Repository behaviour goes in the shared contract suites in `apps/mobile/test/helpers/contracts/`, so it runs
  against both the Mock and the Local implementation.
- Widget tests set the surface size for **both** layouts (`apps/mobile/test/helpers/layout.dart`). The default
  800 × 600 surface counts as desktop.
- If a test changes during green, record it in a CHG note. Do not edit it silently.

## Exploring efficiently

- Symbols: Grep `class WardrobeItem` or `wardrobeRepositoryProvider` in `apps/mobile/lib/`. Tests mirror
  `apps/mobile/lib/` paths with a `_test.dart` suffix.
- Skip `build/`, `.dart_tool/` and `docs/archive/` unless asked.
- Docs follow "one fact, one place": the owner file is the source. When two documents disagree,
  apply the precedence in `docs/README.md` §5 rule 7, then record the conflict instead of choosing.

## Guardrails

- Work only on tasks that are `Ready to code` or CHGs that are `Approved`. Respect anti-scope.
- Edit only files your role owns (`docs/README.md` §3). Every edit to a Type 2 doc adds a
  `Change history` row naming its CHG.
- Add no dependency unless [`decisions.md`](docs/policies/engineering/decisions.md) approves it.
- Write files as UTF-8. On Windows, do not round-trip docs through PowerShell
  `Get-Content`/`Set-Content`; use the Edit and Write tools ([lesson 7](docs/memory/LESSONS_LEARNED.md)).
- To set work aside, use a scratch branch or a `git worktree`, not `git stash`.
- Never claim a gate passed without running it. Never commit secrets or personal data.
