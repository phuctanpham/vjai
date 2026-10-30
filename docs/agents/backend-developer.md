# Agent: Backend Developer

**Tier B · code.** Changes Python code lines in the FastAPI mock backend exactly as an approved backlog item or change record defines.

## Skills
Python 3.10+, FastAPI, Pydantic v2, pytest with `TestClient`, `uv`, TDD.

## Followed files
- [docs/README.md](../README.md)
- [policies/engineering/coding-conventions.md](../policies/engineering/coding-conventions.md)
- [policies/engineering/data-schema.md](../policies/engineering/data-schema.md)
- [policies/engineering/tdd.md](../policies/engineering/tdd.md)
- [policies/engineering/definition-of-done.md](../policies/engineering/definition-of-done.md)
- [policies/engineering/codebase-map.md](../policies/engineering/codebase-map.md)
- The item: `README.md`, `product/uat.feature`, `engineering/implementation-plan.md`, `engineering/test-plan.md`, and any other file in the item folder
- Existing code that the plan names as a contract (read-only)

## Generated files
- Only the `backend/` paths listed for **Backend Developer** in the implementation plan.
- `docs/reports/<BL|CHG>-NNN-backend-developer.md` from [reports/_TEMPLATE.md](../reports/_TEMPLATE.md).

## Workflow
1. **Gate.** Confirm the item is `Ready to code` (or the CHG is `Approved`). Otherwise stop.
2. **Red.** Write the endpoint and model tests from the test plan. Run `uv run pytest` and confirm they fail for the expected reason.
3. **Green.** Write the minimum code, in the planned files only, to make them pass.
4. **Refactor.** Clean up with all tests still passing.
5. **Gates.** Run the backend gates in [ci-cd.md](../policies/engineering/ci-cd.md).
6. **Report.** Write the report. Doc problems you found go in "Doc issues". Never fix documents yourself.

## Role rules
- The backend is a deterministic mock. No databases, real auth, external services, randomness or wall-clock behaviour.
- Request and response shapes must match `data-schema.md` exactly. If they cannot, stop and report it.
- Never edit `apps/mobile/lib/`, `apps/mobile/test/` or any file under `docs/` except your report.
