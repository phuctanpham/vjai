# CHG-010: Move the Flutter app to `apps/mobile/`

| Status | Source | Date |
|---|---|---|
| Approved | [CHG-008](CHG-008-claude-code-adapter.md) D8-04 (deferred until PR 4 merged; it merged on 2026-10-30) · human approval 2026-10-30 (commit straight to `main`; rewrite historical docs too) | 2026-10-30 |

Status values: `Draft` → `Approved` (human) → `Done` (after merge).

## Problem
The Flutter package (`lib/`, `test/`, `pubspec.*`, `analysis_options.yaml`,
`dart_test.yaml`) sits at the repository root next to `backend/` and `docs/`.
CHG-008 D8-04 deferred moving it to `apps/mobile/` until Phase 2 merged, so the
Phase 2 review would not turn into a rename diff. Phase 2 is merged and no PR
is open, so the move can happen now as one mechanical change.

Garblo is a lookbook generating and matching app. This change moves files only;
no behaviour, vocabulary or scope changes.

## Decisions
| ID | Decision | Reason |
|---|---|---|
| M-01 | Move with `git mv`: `lib/`, `test/`, `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `dart_test.yaml` → `apps/mobile/`. `.fvmrc` stays at the root (FVM searches parent folders) | `git log --follow` keeps history; one Flutter SDK pin for the repo |
| M-02 | `backend/` does **not** move in this CHG. Its place in the monorepo is decided with the platform in [BE-001](../tasks/backend/BE-001-platform-decision.md) | Avoids a second move if BE-001 replaces the FastAPI mock |
| M-03 | No Dart source changes. Tests resolve `lib/` and `test/` relative to the package root, so the architecture tests keep working when run from `apps/mobile/` | Keeps the diff to renames plus path text |
| M-04 | **Every document** gets the new paths: owner documents (policies, agents, skills, `CLAUDE.md`, `README.md`, the codebase map, task cards) **and** historical records (Done CHGs, delivery reports, legacy `docs/backlog/BL-*`, `docs/archive/`). Only the paths change; the records' content and dates stay as written. Paths inside `flutter test …` commands stay package-relative (`test/…`), because the commands run from `apps/mobile/`. The Flow Spec HTML is not edited | Human decision: one set of paths everywhere, so no link points at a folder that no longer exists |
| M-06 | Work goes straight to `main` (the repo is main-only): one docs commit (this record, Approved), then one move commit (renames, workflow, path rewrites) | Human decision |
| M-05 | Commands run from `apps/mobile/` (`cd apps/mobile && flutter test`). The CI workflow sets `defaults.run.working-directory: apps/mobile` and uploads `apps/mobile/build/app/outputs/flutter-apk/app-release.apk` | One place for the working directory |

## Product impact (APM)
| Affected | Change needed |
|---|---|
| None | Files move; the app is unchanged |

## Engineering impact (ASEM)
| Affected | Change needed |
|---|---|
| `.github/workflows/android-apk.yml` | Working directory `apps/mobile`; `flutter create` and the minSdk step run there; artifact path updated |
| [codebase-map.md](../policies/engineering/codebase-map.md) | New tree with `apps/mobile/` |
| [ci-cd.md](../policies/engineering/ci-cd.md), [tdd.md](../policies/engineering/tdd.md), [architecture.md](../policies/engineering/architecture.md), [coding-conventions.md](../policies/engineering/coding-conventions.md) | Paths and commands; `Change history` row naming CHG-010 |
| `CLAUDE.md`, `README.md`, `docs/README.md`, `docs/agents/*`, `.claude/agents/*`, `.claude/skills/gates/SKILL.md`, `.github/copilot-instructions.md` | Paths and `cd apps/mobile` in commands |
| Open task and backend cards (`docs/tasks/**` not Done) | Paths in file-confinement lists |
| `CLAUDE.local.md` (git-ignored, human-owned) | The human updates `test/helpers/local_db.dart` → `apps/mobile/test/helpers/local_db.dart` |

## Code follow-up
| Role | Paths | Tests | Done |
|---|---|---|---|
| App Developer | `git mv` per M-01; the workflow and owner docs per the table above | Gates from `apps/mobile/`: format, analyze, full `flutter test` (461 + TASK-009 tests, same counts as before the move); `git log --follow` on one moved file; a manual `workflow_dispatch` CI run including the APK | [ ] |
| Backend Developer | None (M-02) | `cd backend && uv run pytest` unchanged | — |

When the change does not need a full backlog item, this table serves as the implementation plan. Only the listed paths may change.
