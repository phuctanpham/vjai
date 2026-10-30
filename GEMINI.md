# Garblo — Google Antigravity Coding Agent Instructions

Garblo is an offline-first wardrobe and outfit application: one Flutter codebase for Android, iOS, Windows, and macOS, built test-first. `backend/` holds a deterministic FastAPI mock. This file is the primary Antigravity adapter; repository policies and rules live in [`docs/README.md`](docs/README.md) and linked documents. Link to them; do not duplicate them here.

---

## 1. Start Here (Document Reading Order)

Read in this sequence and stop once sufficient context is acquired:

1. [`docs/README.md`](docs/README.md): Multi-agent hierarchy, document tiers, delivery flow, precedence rules.
2. [`docs/policies/engineering/codebase-map.md`](docs/policies/engineering/codebase-map.md): The authoritative repository tree. Use this instead of crawling or globbing.
3. **Your Assigned Task:**
   - Active wardrobe mobile work: `docs/tasks/mobile/TASK-NNN-*.md` (status in [`docs/tasks/mobile/README.md`](docs/tasks/mobile/README.md)).
   - Decisions & changes: `docs/changes/CHG-NNN-*.md`.
   - Backend & AI tasks: `docs/tasks/backend/`.
4. **Flow Spec Sections:** Look up cited sections (T0–T7, T11, UC-NN) via the `flow-spec` skill (`.agents/skills/flow-spec/`). Never load `docs/tasks/mobile/Garblo Flow Spec.html` (490 KB) as a whole.

Role specs are in `docs/agents/` (`app-developer.md`, `backend-developer.md`, `engineering-manager.md`, `product-manager.md`).

---

## 2. Environment & Windows Execution Setup

The operating environment is **Windows** with **PowerShell** as the primary shell.

- **Flutter SDK Pin (3.24.5 in `.fvmrc`):**
  - Path: `F:\tools\flutter\bin\flutter.bat` and `F:\tools\flutter\bin\dart.bat` (not on system `PATH`).
  - Command syntax in PowerShell:
    ```powershell
    & 'F:\tools\flutter\bin\flutter.bat' --version
    & 'F:\tools\flutter\bin\dart.bat' --version
    ```
- **SQLite on Windows:**
  - DLL path: `F:\tools\sqlite\sqlite3.dll` (default in `apps/mobile/test/helpers/local_db.dart`) or set via `$env:GARBLO_SQLITE3_DLL`.
- **Backend / Python:**
  - Python toolchain managed by `uv` (`uv.exe` is on PATH).
  - Run backend tests: `cd backend; uv run pytest`.
- **File Encoding:**
  - All files must be UTF-8 without BOM.
  - Never pipe documents through PowerShell `Get-Content`/`Set-Content` (corrupts encoding / formatting); always use Antigravity `read_file`, `edit_file`, and `write_file` tools.

---

## 3. Monorepo Layout: Current vs Legacy

| Current (Build upon & test) | Legacy (Read-only, do not extend or reuse) |
|---|---|
| `apps/mobile/lib/features/{studio,wardrobe,gu_match,privacy}`, `apps/mobile/lib/core/`, `apps/mobile/lib/app/` | `apps/mobile/lib/features/discovery/` and `*_placeholder.dart` features (dating code) |
| `docs/tasks/`, `docs/changes/`, `docs/policies/`, Flow Spec | `docs/backlog/BL-*` (legacy dating backlog), `docs/archive/` |
| Wardrobe terms in `docs/policies/product/terminology.md` | `backend/` dating endpoints (pending platform decision [BE-001](docs/tasks/backend/BE-001-platform-decision.md)) |

---

## 4. Architecture & Design Rules

Strict Clean Architecture:
$$\text{View} \longrightarrow \text{ViewModel (Riverpod StateNotifier)} \longrightarrow \text{Repository Interface} \longrightarrow \text{Local (SQLCipher) / Mock Implementation}$$

Full policies: [`architecture.md`](docs/policies/engineering/architecture.md) and [`coding-conventions.md`](docs/policies/engineering/coding-conventions.md).

- **Layer Boundaries:** Views and widgets **never** import `data/`. Architecture tests in `apps/mobile/test/architecture/` enforce this boundary.
- **Adaptive Layout:** Layout adapts strictly by width (`Breakpoints.desktop = 800`). No `Platform.isX` branches in UI widgets.
- **Provider Injection:** `localDatabaseProvider`, `ownerIdProvider`, and `attachmentStoreProvider` throw by default until `apps/mobile/lib/app/bootstrap.dart` overrides them. Tests override them via `ProviderScope`.

---

## 5. TDD Loop & Delivery Workflow

Follow [`tdd.md`](docs/policies/engineering/tdd.md): **Red $\rightarrow$ Green $\rightarrow$ Refactor**.

1. **Gate Check:** Confirm task status is `Ready to code` or CHG is `Approved`. Never write code for unapproved tasks.
2. **Red Run:**
   - Write tests from the test plan matching the scenario ID: `'[TASK-007-S02] ...'`.
   - Run the test suite and confirm it fails for the expected reason.
   - Record the exact command, failure reason, and failing count in the delivery report.
3. **Green Run:**
   - Implement the minimum code within assigned files only to make tests pass.
   - Commits follow: `[TASK-NNN] test: ...` before `[TASK-NNN] feat: ...`.
4. **Refactor:**
   - Clean up code while maintaining green status across all tests.
5. **Quality Gates:**
   - Execute the `gates` skill before declaring work complete.

---

## 6. Commands & Quality Gates

Run Flutter commands from `apps/mobile/`. Gate definitions are in [`ci-cd.md`](docs/policies/engineering/ci-cd.md).

```powershell
# From apps/mobile/
cd apps/mobile
& 'F:\tools\flutter\bin\dart.bat' format --output=none --set-exit-if-changed .
& 'F:\tools\flutter\bin\flutter.bat' analyze
& 'F:\tools\flutter\bin\flutter.bat' test                                     # full test suite
& 'F:\tools\flutter\bin\flutter.bat' test test/features/wardrobe/             # single feature
& 'F:\tools\flutter\bin\flutter.bat' test --plain-name '[TASK-006-S03]'       # single scenario

# From backend/
cd ../backend
uv run pytest
```

Always include the gate result table in delivery reports:
```markdown
| Gate | Command | Result |
|---|---|---|
| format | dart format --output=none --set-exit-if-changed . | passed |
| analyze | flutter analyze | passed (0 issues) |
| test | flutter test | passed (X passed, 0 failed) |
| backend | uv run pytest | skipped: no backend change |
```

---

## 7. Antigravity Skills

- **`flow-spec` (`.agents/skills/flow-spec/SKILL.md`):** Extracts targeted plain-text sections from `Garblo Flow Spec.html`. Run:
  ```powershell
  powershell -ExecutionPolicy Bypass -File .agents/skills/flow-spec/scripts/section.ps1 <anchor>
  powershell -ExecutionPolicy Bypass -File .agents/skills/flow-spec/scripts/section.ps1 -List
  ```
- **`gates` (`.agents/skills/gates/SKILL.md`):** Verifies all CI quality gates (format, analyze, test, pytest) before submitting delivery reports or commits.

---

## 8. Agent Roles & Antigravity Delegation

When working on complex tasks or using Antigravity subagents (`invoke_subagent`):

- **Product Manager (APM):** Owns product policies, backlog items, UAT feature scenarios, and acceptance. Does not edit code or engineering policies.
- **Engineering Manager (ASEM):** Owns architecture, implementation plans, test plans, and DoD verification. Does not edit code or product policies.
- **App Developer:** Generates Flutter code lines in `apps/mobile/lib/` and `apps/mobile/test/` and the delivery report `docs/reports/<TASK|CHG>-NNN-app-developer.md`. Does not edit backend or documentation.
- **Backend Developer:** Generates Python code in `backend/` and delivery report `docs/reports/<TASK|CHG>-NNN-backend-developer.md`. Does not edit mobile code or documentation.

---

## 9. Non-Negotiable Guardrails

1. **Strict Scope:** Build only what is in the approved task plan. Respect anti-scope unconditionally.
2. **No Dependency Additions:** Add no package/dependency unless explicitly approved in [`decisions.md`](docs/policies/engineering/decisions.md).
3. **No Secret Commits:** Never expose or commit keys, tokens, or credentials (e.g. `atlas-credentials.env`).
4. **Precedence on Conflict:** Agent specs > Item card > `uat.feature` > Implementation plan > Test plan > Flow Spec > Policies > Existing code. When a conflict is found, record it in a CHG note and stop; never guess.
5. **Never Fake Gates:** Never claim a test or check passed without running it. Report failures faithfully.

