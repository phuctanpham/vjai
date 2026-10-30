---
name: gates
description: Run the Garblo quality gates (dart format check, flutter analyze, flutter test, backend pytest) exactly as CI does and report each as passed, failed or skipped. Use before claiming any code task is done, before a commit, or when asked to verify the build.
---

# Quality Gates

Commands and toolchain are defined in [`docs/policies/engineering/ci-cd.md`](../../../docs/policies/engineering/ci-cd.md) §1–2.
This skill defines how to execute and report them within Antigravity.

## 1. Toolchain & Environment

- **Flutter Pin:** 3.24.5 (`.fvmrc`).
- **Windows Path:** If Flutter/Dart is not on system PATH, use the pinned local location:
  - Flutter: `F:\tools\flutter\bin\flutter.bat`
  - Dart: `F:\tools\flutter\bin\dart.bat`
  - Command invocation in PowerShell:
    ```powershell
    & 'F:\tools\flutter\bin\flutter.bat' --version
    ```
- **SQLite on Windows:** `F:\tools\sqlite\sqlite3.dll` (default in `test/helpers/local_db.dart`) or environment variable `GARBLO_SQLITE3_DLL`.
- **Backend:** `uv run pytest` (from `backend/`).

## 2. Gate Execution Order

Run **only** the gates the change touches. Flutter gates run from `apps/mobile/`, backend from `backend/`. Stop at the first failure and report it.

| Change Touches | Commands (PowerShell) |
|---|---|
| `apps/mobile/lib/`, `apps/mobile/test/`, `apps/mobile/pubspec.*`, `apps/mobile/analysis_options.yaml` | `Set-Location apps/mobile`<br>`& 'F:\tools\flutter\bin\dart.bat' format --output=none --set-exit-if-changed .`<br>`& 'F:\tools\flutter\bin\flutter.bat' analyze`<br>`& 'F:\tools\flutter\bin\flutter.bat' test` |
| `.github/workflows/` | The Flutter gates above, then manual `workflow_dispatch` |
| `backend/` | `Set-Location backend`<br>`uv run pytest` |
| docs only | None (report as skipped: docs only) |

### Iterative Testing
While iterating on code, run a focused test suite first:
```powershell
& 'F:\tools\flutter\bin\flutter.bat' test test/features/wardrobe/
& 'F:\tools\flutter\bin\flutter.bat' test --plain-name '[TASK-006-S03]'
```
Only run the full test suite when ready to complete the delivery report.

## 3. Reporting Format

Always include the gate result table in your response or delivery report:

```markdown
| Gate | Command | Result |
|---|---|---|
| format | dart format --output=none --set-exit-if-changed . | passed |
| analyze | flutter analyze | passed (0 issues) |
| test | flutter test | passed (461 passed, 0 failed) |
| backend | uv run pytest | skipped: no backend change |
```

Never mark a gate passed without actually executing it. Never fix a failure by editing a test silently: any test modification during green must be recorded in a CHG note.

