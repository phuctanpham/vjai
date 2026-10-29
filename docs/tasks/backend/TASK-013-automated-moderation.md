# TASK-013: Automated Content Moderation

> **Phase:** 5 — Safety and engagement  
> **Status:** Planned  
> **Target:** `backend/app/api/v1/`  
> **Dependency:** TASK-012

## Objective

Add a deterministic mock moderation decision endpoint for development and contract testing.

## Allowed files

- `backend/app/api/v1/endpoints/moderation.py`
- `backend/app/models/`
- `backend/tests/test_moderation.py`
- `backend/README.md`

## Locked files

Flutter presentation code and production infrastructure configuration.

## In scope

- Typed Pydantic moderation request and response models.
- Deterministic fixture-based safe/review/rejected decisions.
- Input validation and explicit HTTP error responses.
- Endpoint tests.

## Anti-scope

No machine-learning model, third-party scanning service, user profiling, data retention system, or automatic account suspension.

## Acceptance criteria

- Valid content receives a typed decision.
- Invalid payloads return a documented validation error.
- Fixture outcomes are deterministic and tested.

## Technical implementation contract

- **Boundary:** moderation endpoint logic remains in `backend/app/api/v1/endpoints/`; Pydantic models define the API boundary.
- **Serialization:** response decisions are limited to the documented safe/review/rejected values and include a stable request reference.
- **Failure behavior:** malformed input returns explicit validation errors; unsupported fixture content never produces an ambiguous success.
- **Test matrix:** schema validation, each deterministic decision, malformed payloads, and HTTP status/body assertions.

## Verification

Run `cd backend; uv sync --extra dev; uv run pytest`.
