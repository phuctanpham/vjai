# BE-010: Restore the backend gate with pip

> **Owner:** Backend Developer  
> **Status:** Ready to code
> **Track / priority:** M · 0
> **Toolchain decision:** [CHG-016](../../changes/CHG-016-pip-backend-toolchain.md)

## Why

The backend gate must use standard Python virtual environments and `pip`.
The previous package-manager-specific workflow is retired. The backend is an
application, not a package that needs editable installation.

## Scope

- Add or restore `backend/requirements.txt` for runtime dependencies.
- Add or restore `backend/requirements-dev.txt` including runtime dependencies
  and test dependencies.
- Add a supported Python version declaration.
- Add or update the backend CI workflow to install with `pip` and run
  `python -m pytest`.
- Preserve the existing backend endpoint and model behaviour.
- Record the red and green test runs in the delivery report.

## Allowed files

`backend/requirements.txt`, `backend/requirements-dev.txt`,
`backend/.python-version` or the repository-approved Python-version file,
`.github/workflows/backend.yml`, and
`docs/reports/BE-010-backend-developer.md`.

No endpoint, model, or test implementation changes are allowed under this
gate-restoration task.

## TDD and verification plan

| Step | Action | Expected result |
|---|---|---|
| 1 | Create a clean Python virtual environment and install `requirements-dev.txt` with `python -m pip` | Dependencies install successfully |
| 2 | Run `python -m pytest -q` before any runtime change | Baseline failure or existing test result is recorded |
| 3 | Run `python -m pytest --collect-only -q` | Baseline test IDs are recorded |
| 4 | Run `python -m pytest -q` after the packaging/toolchain change | The same tests pass without endpoint changes |
| 5 | Run the supported Python-version checks | The declared floor and supported version pass |
| 6 | Run the backend CI workflow | CI installs only through pip and runs the same test command |

Commands:

```bash
cd backend
python -m venv .venv
. .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements-dev.txt
python -m pytest -q
python -m pytest --collect-only -q
```

Windows:

```powershell
cd backend
py -m venv .venv
.venv\Scripts\activate
py -m pip install --upgrade pip
py -m pip install -r requirements-dev.txt
py -m pytest -q
```

## CI requirements

The backend workflow must:

1. Use the supported Python versions.
2. Create or use an isolated virtual environment.
3. Install `requirements-dev.txt` with `python -m pip`.
4. Run `python -m pytest -q`.
5. Never require a project-specific package manager.
6. Never print credentials or service connection strings.

## Anti-scope

No new backend runtime features, third-party service integration, database,
real authentication, OpenAI integration, Docker deployment, or test-contract
expansion.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Original backend gate task |
| 2026-11-03 | [CHG-016](../../changes/CHG-016-pip-backend-toolchain.md) | Rewritten to use pip and remove the retired package-manager workflow |
