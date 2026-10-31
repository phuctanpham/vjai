# BE-010: Restore the backend gate

> **Owner:** Backend Developer  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval  
> **Track / priority:** M · **0** (first: every other backend card needs a green `uv run pytest`)  
> **Blocked by:** nothing

## Why

[ci-cd.md](../../policies/engineering/ci-cd.md) §1 defines the backend gate as
`uv sync --extra dev` + `uv run pytest`. On 2026-10-30 it fails before collecting a test:

```text
error: Failed to build `garblo-backend @ file:///F:/github/vjai/backend`
  hatchling ... default_only_include ...   (no package matches the project name)
```

- `pyproject.toml` builds a wheel with hatchling, but the code is in `app/`, not
  `garblo_backend/`, so the editable build cannot find a package.
- No `uv.lock` is committed, although ci-cd.md §2 says it is (CHG-005).
- No Python version is pinned; uv picked a 3.15 interpreter on the reference machine.
- With the build bypassed (`uv run --no-project --with …`) the 7 legacy tests pass,
  with 4 Pydantic `class Config` deprecation warnings (gone after BE-005).

## Scope

1. Make the project runnable without packaging: `[tool.uv] package = false` (the
   backend is an app, not a library), or `[tool.hatch.build.targets.wheel] packages = ["app"]`.
   Prefer the first; record the choice in the report.
2. `.python-version` = `3.12` and `requires-python = ">=3.10,<3.14"`.
3. Generate and commit `backend/uv.lock`.
4. `[tool.pytest.ini_options]` with `testpaths = ["tests"]` and
   `filterwarnings = ["error::DeprecationWarning:app.*"]` so new deprecated code fails.
5. Backend job in CI: `.github/workflows/backend.yml`, on pull requests and pushes
   touching `backend/**`: `astral-sh/setup-uv` → `uv sync --extra dev --locked` →
   `uv run pytest`. (This is the "planned `ci.yml` backend job" of ci-cd.md §3,
   started as its own file so the APK workflow is untouched.)

## Scenarios

| ID | Given / when / then | Test |
|---|---|---|
| BE-010-S01 | A clean checkout: `uv sync --extra dev --locked` then `uv run pytest` exits 0 | The gate command itself (red run = today's failure) |
| BE-010-S02 | The lock is current: `uv lock --check` exits 0 | CI step |

## Allowed files

`backend/pyproject.toml`, `backend/uv.lock`, `backend/.python-version`,
`.github/workflows/backend.yml`, report `docs/reports/BE-010-backend-developer.md`.

## Anti-scope

No new runtime dependency. No change to endpoints or tests (BE-005 removes the
dating ones). No linter added here (a `ruff` proposal needs a decisions.md entry).

## Done when

The red run (today's build error) and the green run are in the report, and the
`backend` CI job passes on the PR.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created from the gate failure found in the backend analysis |
