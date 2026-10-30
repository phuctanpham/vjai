---
name: gates
description: Run the Garblo quality gates (dart format check, flutter analyze, flutter test, backend pytest) exactly as CI does and report each as passed, failed or skipped. Use before claiming any code task is done, before a commit, or when asked to verify the build.
---

# Quality gates

Commands and toolchain are defined in
[`docs/policies/engineering/ci-cd.md`](../../../docs/policies/engineering/ci-cd.md) §1–2; this skill only
says how to run and report them.

1. **Find the toolchain.** Flutter must be 3.24.5 (`.fvmrc`). Use `fvm flutter`/`fvm dart` if FVM is
   installed, else `flutter`/`dart` on PATH, else the SDK path in `CLAUDE.local.md`. Check
   `flutter --version` once. A different version is a finding to report, not something to fix.
2. **Run only the gates the change touches**, in this order. Flutter gates run from `apps/mobile/`,
   the backend gate from `backend/` (CHG-010). Stop at the first failure and report it.

   | Change touches | Gates |
   |---|---|
   | `apps/mobile/lib/`, `apps/mobile/test/`, `apps/mobile/pubspec.*`, `apps/mobile/analysis_options.yaml` | `cd apps/mobile` → `dart format --output=none --set-exit-if-changed .` → `flutter analyze` → `flutter test` |
   | `.github/workflows/` | the Flutter gates above, then a manual `workflow_dispatch` run |
   | `backend/` | `cd backend && uv run pytest` |
   | docs only | none; say so |

   While iterating, run a focused suite first (`flutter test test/features/<feature>/` or
   `flutter test --plain-name '[TASK-NNN-Sxx]'`), then the full gate once at the end.
3. **SQLite tests on Windows** need `GARBLO_SQLITE3_DLL` or `F:\tools\sqlite\sqlite3.dll`
   (ci-cd.md §2). If the DLL is missing, those tests fail at open: report it as an environment
   problem.
4. **Benchmarks** are skipped by default. Run `flutter test --run-skipped --tags benchmark` only when
   the task names a benchmark.

## Report

```text
| Gate | Command | Result |
|---|---|---|
| format | dart format --output=none --set-exit-if-changed . | passed |
| analyze | flutter analyze | passed (0 issues) |
| test | flutter test | passed (461 passed, 0 failed) |
| backend | uv run pytest | skipped: no backend change |
```

Never mark a gate passed without running it. Never fix a failure by editing a test silently: test
changes during green are recorded in a CHG note.
