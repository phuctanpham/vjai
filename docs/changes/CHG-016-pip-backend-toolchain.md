# CHG-016: Migrate backend tooling from uv to pip

| Status | Source | Date |
|---|---|---|
| Approved | Human request to use pip for Phase 4 backend implementation | 2026-11-03 |

## Decision

The backend uses standard Python virtual environments and `pip`. Backend
dependencies are declared in `requirements.txt` and
`requirements-dev.txt`. The canonical test command is:

```bash
python -m pytest
```

The previous package-manager-specific backend workflow and lockfile are
retired. No replacement lockfile is introduced by this change.

## Scope

- Update active setup, architecture, agent, task, and CI documentation.
- Rewrite BE-010 to define the pip-based backend gate.
- Refactor Phase 4 into nine ordered implementation and verification steps in
  [PHASE-4-implementation-plan.md](../tasks/backend/PHASE-4-implementation-plan.md).
- Use `python -m pip` and `python -m pytest` in new backend instructions.
- Preserve historical archive documents as immutable project history.

## Guardrails

- This change does not authorize backend feature implementation.
- Dependencies remain limited to the approved FastAPI, Uvicorn, Pydantic,
  pytest, and httpx stack unless a later decision approves additions.
- Credentials and third-party service configuration remain out of source
  control.
- Docker and deployment work remain separate Phase 4 steps.
- No Phase 4 runtime code is authorized until the backend source tree and
  approved task implementation files are present.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-11-03 | CHG-016 | Replaced the active backend uv workflow with pip and virtual environments |
| 2026-11-03 | CHG-016 | Refactored Phase 4 into nine ordered steps, ending with non-Docker and Docker localhost verification |
