# BE-010: Restore the backend gate

> **Owner:** Backend Developer  
> **Status:** **Ready to code** · implementation and test plan accepted by the Engineering Manager; [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approved for BE-010 only
> **Track / priority:** M · **0** (first: every other backend card needs a green `uv run pytest`)  
> **Blocked by:** none (the other open CHG-014 questions do not apply to this gate-restoration task)

## Why

[ci-cd.md](../../policies/engineering/ci-cd.md) §1 defines the backend gate as
`uv sync --extra dev` + `uv run pytest`. It fails before collecting a test:

```text
error: Failed to build `garblo-backend @ file:///…/backend`
  cause: Call to `hatchling.build.build_editable` failed (exit code: 1)
  … packages = ["src/foo"]      (hatchling finds no package named like the project)
```

| Finding | Evidence (2026-10-31, uv 0.13.1, scratch copy of the committed tree) |
|---|---|
| `pyproject.toml` asks hatchling for an editable wheel, but the code is in `app/`, not `garblo_backend/` | Reproduced on a clean copy of `93cb941`, with the committed lock |
| `backend/uv.lock` **is now committed** (`93cb941`), but it is an artefact of the 2026-10-30 diagnostic `uv run pytest`, not a reviewed fix. It records the project as `source = { editable = "." }`, the broken build mode | File time 2026-10-30 23:14 matches the diagnostic run; `uv sync --locked` accepts it and the build then fails |
| No Python pin: uv picked a managed 3.15 interpreter; the ignored local `backend/.venv` is on 3.15 | `.venv/pyvenv.cfg` |
| The tests themselves are fine | 7 passed, 4 Pydantic `class Config` deprecation warnings |

## Decisions taken in this plan

| # | Decision | Why (dry-run result) | Rejected alternative |
|---|---|---|---|
| D1 | `[tool.uv] package = false` (a virtual project) | The backend is an app run by uvicorn, never installed. Green: 7 passed on 3.12.15. The lock changes by **one line**, `editable` → `virtual`; all 34 pinned versions stay the same | `[tool.hatch.build.targets.wheel] packages = ["app"]`: also green, but builds and installs an editable `garblo_backend` dist for no use |
| D2 | `.python-version` = `3.12`; keep `requires-python = ">=3.10"` (no upper bound) | The pin chooses the interpreter; the floor stays as coding-conventions §2 says. The same lock passes on 3.10.22 and 3.12.15. An upper bound would only change resolution markers | `">=3.10,<3.14"` from the first draft of this card: no benefit |
| D3 | Warnings-as-errors is **moved to [BE-005](BE-005-retire-dating-mock-api.md)** | With `-W error::DeprecationWarning`, collection of **both** test files fails (`app.main` imports the dating `Profile` models), so BE-010 would break the gate it restores | Keeping it here (first draft, scope item 4) |
| D4 | CI is a new `.github/workflows/backend.yml`, not an edit to `android-apk.yml` | Keeps the APK workflow untouched; this is the "backend" job planned in ci-cd.md §3 | One combined `ci.yml` (left to the ASEM when the Flutter PR job is added) |
| D5 | Existing local environments need no manual step | uv removes and recreates a 3.15 `.venv` on the next `uv sync` once 3.12 is pinned (checked) | — |

## Implementation plan

**Allowed files (only these):** `backend/pyproject.toml`, `backend/.python-version`
(new), `backend/uv.lock` (regenerated), `.github/workflows/backend.yml` (new), report
`docs/reports/BE-010-backend-developer.md`. No file under `backend/app/` or
`backend/tests/` changes.

| Step | Change | Check |
|---|---|---|
| 0 | Gate: CHG-014 is `Approved`. Branch `be-010/backend-gate` from `main` | — |
| 1 | **Red.** From `backend/`: `uv sync --extra dev --locked` then `uv run pytest -q`; save the output for the report. Save `uv run --no-project --with fastapi --with httpx --with pytest pytest --collect-only -q` as the baseline test list | Fails with the hatchling error above; baseline lists 7 tests |
| 2 | `pyproject.toml`: add `[tool.uv] package = false`; remove `[build-system]` (unused once virtual); add `[tool.pytest.ini_options] testpaths = ["tests"]` | — |
| 3 | `backend/.python-version`: `3.12` | — |
| 4 | `uv lock`; review that the diff is only the `garblo-backend` source line (plus nothing else) | `git diff backend/uv.lock` |
| 5 | **Green.** `uv sync --extra dev --locked` → `uv run pytest -q`; `uv run pytest --collect-only -q` equals the step 1 baseline | 7 passed; same 7 test IDs |
| 6 | Floor check: `UV_PROJECT_ENVIRONMENT=.venv310 uv run --python 3.10 --extra dev --locked pytest -q`, then delete `.venv310` | 7 passed on 3.10 |
| 7 | `.github/workflows/backend.yml` (sketch below) | Runs on the PR |
| 8 | Commit and report (below); open a PR; do not merge (the human merges) | CI green |

Workflow sketch (the action versions are pinned to their current major at
implementation time and recorded in the report):

```yaml
name: Backend
on:
  pull_request:
    paths: ["backend/**", ".github/workflows/backend.yml"]
  push:
    branches: [main]
    paths: ["backend/**", ".github/workflows/backend.yml"]
  workflow_dispatch:
permissions:
  contents: read
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python: ["3.10", "3.12"]   # declared floor and pinned version
    defaults:
      run:
        working-directory: backend
    env:
      UV_PYTHON: ${{ matrix.python }}
    steps:
      - uses: actions/checkout@v4
      - uses: astral-sh/setup-uv@<major>
        with:
          enable-cache: true
          cache-dependency-glob: backend/uv.lock
      - name: Lock is current
        run: uv lock --check
      - name: Install (locked)
        run: uv sync --extra dev --locked
      - name: Tests
        run: uv run pytest -q
```

**Commits** use the confirmed task prefix `[BE-010]`. This is a scoped
extension of the current task-card convention; general task prefixes will be
standardized separately:

1. `[BE-010] fix: run the backend as a virtual uv project on Python 3.12`
   (`pyproject.toml`, `.python-version`, `uv.lock`)
2. `[BE-010] chore: add the backend CI job` (`.github/workflows/backend.yml`)
3. `[BE-010] docs: delivery report`

There is no `test:` commit, because no test is added or changed. The red evidence is
the failing gate command from step 1, recorded in the report as tdd.md §1 requires.

**Rollback:** revert commit 1 (and 2). No runtime code changes, so nothing else is affected.

## Test plan

| ID | Scenario | How it is verified | Expected |
|---|---|---|---|
| BE-010-S01 | Clean checkout: `uv sync --extra dev --locked` then `uv run pytest` | Steps 1 (red) and 5 (green), and the CI job | Red: build error. Green: 7 passed |
| BE-010-S02 | The lock matches `pyproject.toml` | `uv lock --check` locally and as a CI step | Exit 0 |
| BE-010-S03 | No behaviour change | `pytest --collect-only -q` before and after | Same 7 test IDs, all passing |
| BE-010-S04 | Declared floor still works | Step 6 and the 3.10 matrix leg | 7 passed on 3.10 and on 3.12 |
| BE-010-S05 | CI catches a stale lock | One-off check on a throwaway branch (not merged): bump a dependency in `pyproject.toml` without relocking | The "Lock is current" step fails |
| BE-010-S06 | The interpreter is the pinned one | `uv run python -V` locally and in the 3.12 leg | 3.12.x, not 3.15 |

All six results go in the report's Gates and TDD-evidence sections. A step that
cannot run is reported as skipped with the reason, never as passed.

## Anti-scope

No new runtime or dev dependency. No change to endpoints, models or tests (BE-005
removes the dating code and adds warnings-as-errors). No linter (a `ruff` proposal
needs a decisions.md entry). No edit to `ci-cd.md`: correcting its `uv.lock` and CI
text after merge belongs to the ASEM (DOC-002 row 11).

## Engineering Manager acceptance

- [x] The implementation plan is bounded to packaging, Python selection,
      lock regeneration, and the backend CI workflow.
- [x] The test plan covers the failing baseline, green gate, lock freshness,
      test-collection parity, Python 3.10/3.12 support, and interpreter pin.
- [x] The allowed-file list excludes backend runtime code and test changes.
- [x] The plan records red and green evidence requirements and rollback.
- [x] `[BE-010]` is accepted as the scoped commit prefix for this task.

No additional implementation or test plan is required before BE-010 starts.

## Done when

The report shows the red run and the green run, S01–S06 are recorded, and the
`Backend` CI job passes on the PR.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created from the gate failure found in the backend analysis |
| 2026-10-31 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Implementation and test plan from a dry run; the committed `uv.lock` is an artefact to regenerate; upper Python bound dropped; warnings-as-errors moved to BE-005; Python 3.10/3.12 CI matrix |
| 2026-10-31 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Narrow approval recorded; status changed to Ready to code; Engineering Manager accepted the implementation/test plan and scoped `[BE-010]` prefix |
