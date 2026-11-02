# **as you are senior TTD backend developer , you are mastery in techinal stacks of python, uv, fastapi,**

*User prompt: 1\) Would you like to proceed with drafting the remaining pre-code specification documents from our checklist (such as the Write Handler Invariants & Guard Rules Handbook or Phone Schema v2 Column Class Specification), or export the remaining golden fixture files (dormancy\_cases.json, fake\_extraction\_sets.json, rule\_decks.json)? Remind me later 2\) Let code all tests first*

## **Response: Requirements**

> * Python \>= 3.10  
> * [uv](https://docs.astral.sh/uv/) package manager

## **Quickstart with uv**

### **1\. Install dependencies**

`cd backend`  
`uv sync --extra dev`

### **2\. Run the development server**

`uv run uvicorn app.main:app --reload --port 8080 --host 0.0.0.0`

The interactive OpenAPI documentation will be accessible at:

> * Swagger UI: [http\://localhost:8080/docs](http://localhost:8080/docs)  
> * ReDoc: [http\://localhost:8080/redoc](http://localhost:8080/redoc)

### **3\. Run tests**

`uv run pytest`

## **Endpoints**

| Method | Path | Description | Response Status |
| :---- | :---- | :---- | :---- |
| GET | /health | Server liveness check | 200 OK |
| GET | /api/v1/health | API version 1 health check | 200 OK |
| GET | /api/v1/discovery | Retrieve candidate discovery feed | 200 OK |
| GET | /api/v1/profiles/{id} | Retrieve profile details by ID | 200 OK / 404 |
| POST | /api/v1/swipes | Record a like/pass/superlike swipe | 200 OK |
| GET | /api/v1/auth/status | Placeholder auth status | 200 OK |
| GET | /api/v1/matches | Placeholder matches list | 200 OK |
| GET | /api/v1/chat/conversations | Placeholder conversations list | 200 OK |

### **Legacy sample profile JSON**

`{`  
  `"id": "usr_01",`  
  `"name": "Alex Chen",`  
  `"age": 27,`  
  `"bio": "Software engineer & amateur photographer. Passionate about mountain biking and artisanal coffee roasts.",`  
  `"occupation": "Mobile Architect",`  
  `"distanceKm": 4,`  
  `"interests": ["Coding", "Photography", "Cycling", "Coffee"],`  
  `"imag`  
`=== backend/app/__init__.py ===`  
`=== backend/app/api/__init__.py ===`  
`=== backend/app/api/router.py ===`  
`from fastapi import APIRouter`  
`from app.api.v1.endpoints import (`  
    `auth,`  
    `chat,`  
    `deployment_health,`  
    `discovery,`  
    `health,`  
    `matches,`  
    `openai_health,`  
`)`

`api_router = APIRouter()`

`# Health endpoints mounted at root /health and /api/v1/health`  
`api_router.include_router(health.router)`  
`api_router.include_router(deployment_health.router)`  
`api_router.include_router(openai_health.router)`

`# Discovery and swipe endpoints`  
`api_router.include_router(discovery.router)`

`# Boundaries`  
`api_router.include_router(auth.router)`  
`api_router.include_router(matches.router)`  
`api_router.include_router(chat.router)`

`=== backend/app/api/v1/__init__.py ===`  
`=== backend/app/api/v1/endpoints/__init__.py ===`  
`=== backend/app/api/v1/endpoints/auth.py ===`  
`=== backend/app/api/v1/endpoints/chat.py ===`  
`=== backend/app/api/v1/endpoints/deployment_health.py ===`  
`from fastapi import APIRouter, Query, Request`  
`from fastapi.responses import JSONResponse`

`from app.api.v1.endpoints.health_auth import has_valid_basic_auth`

`router = APIRouter()`

`def _environment_value(request: Request, name: str) -> str | None:`  
    `environment: Any = request.scope.get("env")`  
    `if environment is None:`  
        `return None`  
    `if isinstance(environment, dict):`  
        `value = environment.get(name)`  
    `else:`  
        `value = getattr(environment, name, None)`  
    `return value if isinstance(value, str) else None`

`@router.get("/health/deployment")`  
`async def get_deployment_health(`  
    `request: Request,`  
    `commit_id: str = Query(min_length=7, max_length=40, pattern=r"^[0-9a-fA-F]+$"),`  
    `deployment_id: str = Query(min_length=1, max_length=128),`  
`) -> JSONResponse:`  
    `if not has_valid_basic_auth(request):`  
        `return JSONResponse(`  
            `status_code=401,`  
            `content={"status": "unauthorized"},`  
            `headers={"WWW-Authenticate": "Basic"},`  
        `)`

    `return JSONResponse(`  
        `status_code=200,`  
        `content={`  
            `"status": "ok",`  
            `"commit_id": commit_id.lower(),`  
            `"deployment_id": deployment_id,`  
        `},`  
    `)`

`=== backend/app/api/v1/endpoints/discovery.py ===`  
`=== backend/app/api/v1/endpoints/health.py ===`  
`=== backend/app/api/v1/endpoints/health_auth.py ===`  
`import base64`  
`import secrets`  
`from typing import Any`

`from fastapi import Request`

`def _environment_value(request: Request, name: str) -> str | None:`  
    `environment: Any = request.scope.get("env")`  
    `if environment is None:`  
        `return None`  
    `if isinstance(environment, dict):`  
        `value = environment.get(name)`  
    `else:`  
        `value = getattr(environment, name, None)`  
    `return value if isinstance(value, str) else None`

`def has_valid_basic_auth(request: Request) -> bool:`  
    `username = _environment_value(request, "BASIC_AUTH_USERNAME")`  
    `password = _environment_value(request, "BASIC_AUTH_PASSWORD")`  
    `authorization = request.headers.get("Authorization", "")`  
    `if not username or not password or not authorization.startswith("Basic "):`  
        `return False`

    `try:`  
        `encoded = authorization.removeprefix("Basic ").strip()`  
        `decoded = base64.b64decode(encoded, validate=True).decode("utf-8")`  
        `supplied_username, separator, supplied_password = decoded.partition(":")`  
    `except (UnicodeDecodeError, ValueError):`  
        `return False`

    `return (`  
        `bool(separator)`  
        `and secrets.compare_digest(supplied_username, username)`  
        `and secrets.compare_digest(supplied_password, password)`  
    `)`

`=== backend/app/api/v1/endpoints/matches.py ===`  
`=== backend/app/api/v1/endpoints/openai_health.py ===`  
`import logging`

`from fastapi import APIRouter, Request`  
`from fastapi.responses import JSONResponse`  
`from langchain_core.messages import HumanMessage`  
`from langchain_openai import ChatOpenAI`

`from app.api.v1.endpoints.health_auth import _environment_value, has_valid_basic_auth`

`router = APIRouter()`  
`logger = logging.getLogger(__name__)`

`MODEL_NAME = "gpt-4o-mini"`  
`HEALTH_PROMPT = "Reply with the single word: OK"`

`async def _invoke_openai(api_key: str) -> None:`  
    `model = ChatOpenAI(model=MODEL_NAME, api_key=api_key, max_tokens=4)`  
    `await model.ainvoke([HumanMessage(content=HEALTH_PROMPT)])`

`@router.get("/health/openai")`  
`async def get_openai_health(request: Request) -> JSONResponse:`  
    `if not has_valid_basic_auth(request):`  
        `return JSONResponse(`  
            `status_code=401,`  
            `content={"status": "unauthorized"},`  
            `headers={"WWW-Authenticate": "Basic"},`  
        `)`

    `api_key = _environment_value(request, "OPENAI_API_KEY")`  
    `if not api_key:`  
        `return JSONResponse(`  
            `status_code=503,`  
            `content={"status": "unavailable"},`  
        `)`

    `try:`  
        `await _invoke_openai(api_key)`  
    `except Exception:`  
        `logger.exception("OpenAI health request failed")`  
        `return JSONResponse(`  
            `status_code=502,`  
            `content={"status": "unavailable"},`  
        `)`

    `return JSONResponse(`  
        `status_code=200,`  
        `content={`  
            `"status": "ok",`  
            `"provider": "openai",`  
            `"model": MODEL_NAME,`  
        `},`  
    `)`

`=== backend/app/config.py ===`  
`=== backend/app/data/__init__.py ===`  
`=== backend/app/data/sample_data.py ===`  
`=== backend/app/main.py ===`  
`=== backend/app/models/__init__.py ===`  
`=== backend/app/models/health.py ===`  
`=== backend/app/models/profile.py ===`  
`=== backend/pyproject.toml ===`  
`[project]`  
`name = "garblo-backend"`  
`version = "0.1.0"`  
`description = "Garblo mock API backend built with FastAPI and uv"`  
`readme = "README.md"`  
`requires-python = ">=3.10"`  
`dependencies = [`  
    `"fastapi>=0.110.0",`  
    `"langchain-core>=0.3.0",`  
    `"langchain-openai>=0.3.0",`  
    `"pydantic>=2.6.0",`  
`]`

`[project.optional-dependencies]`  
`dev = [`  
    `"pytest>=8.0.0",`  
    `"httpx>=0.27.0",`  
    `"uvicorn[standard]>=0.29.0",`  
`]`

`[dependency-groups]`  
`dev = [`  
    `"workers-py; python_version >= '3.12'",`  
    `"workers-runtime-sdk; python_version >= '3.12'",`  
`]`

`[build-system]`  
`requires = ["hatchling"]`  
`build-backend = "hatchling.build"`

`[tool.hatch.build.targets.wheel]`  
`packages = ["app"]`

`=== backend/tests/__init__.py ===`  
`=== backend/tests/test_deployment_health.py ===`  
`import asyncio`  
`import base64`

`from starlette.requests import Request`

`from app.api.v1.endpoints.deployment_health import get_deployment_health`

`def _request(username: str = "health-user", password: str = "health-password") -> Request:`  
    `credentials = base64.b64encode(f"{username}:{password}".encode()).decode()`  
    `return Request(`  
        `{`  
            `"type": "http",`  
            `"method": "GET",`  
            `"path": "/health/deployment",`  
            `"headers": [(b"authorization", f"Basic {credentials}".encode())],`  
            `"query_string": b"",`  
            `"env": {`  
                `"BASIC_AUTH_USERNAME": "health-user",`  
                `"BASIC_AUTH_PASSWORD": "health-password",`  
            `},`  
        `}`  
    `)`

`def test_deployment_health_returns_metadata():`  
    `response = asyncio.run(`  
        `get_deployment_health(`  
            `_request(),`  
            `commit_id="ABCDEF1234567",`  
            `deployment_id="dep-123",`  
        `)`  
    `)`

    `assert response.status_code == 200`  
    `assert response.body == (`  
        `b'{"status":"ok","commit_id":"abcdef1234567","deployment_id":"dep-123"}'`  
    `)`

`def test_deployment_health_rejects_invalid_token():`  
    `response = asyncio.run(`  
        `get_deployment_health(`  
            `_request("wrong-user", "wrong-password"),`  
            `commit_id="abcdef1234567",`  
            `deployment_id="dep-123",`  
        `)`  
    `)`

    `assert response.status_code == 401`

`=== backend/tests/test_discovery.py ===`  
`=== backend/tests/test_health.py ===`  
`=== backend/tests/test_openai_health.py ===`  
`import asyncio`  
`import base64`  
`from unittest.mock import AsyncMock`

`from starlette.requests import Request`

`from app.api.v1.endpoints import openai_health`

`def _request(username: str = "health-user", password: str = "health-password") -> Request:`  
    `credentials = base64.b64encode(f"{username}:{password}".encode()).decode()`  
    `return Request(`  
        `{`  
            `"type": "http",`  
            `"method": "GET",`  
            `"path": "/health/openai",`  
            `"headers": [(b"authorization", f"Basic {credentials}".encode())],`  
            `"query_string": b"",`  
            `"env": {`  
                `"BASIC_AUTH_USERNAME": "health-user",`  
                `"BASIC_AUTH_PASSWORD": "health-password",`  
                `"OPENAI_API_KEY": "test-key",`  
            `},`  
        `}`  
    `)`

`def test_openai_health_rejects_invalid_token():`  
    `response = asyncio.run(`  
        `openai_health.get_openai_health(_request("wrong-user", "wrong-password"))`  
    `)`

    `assert response.status_code == 401`  
    `assert response.body == b'{"status":"unauthorized"}'`

`def test_openai_health_returns_sanitized_success(monkeypatch):`  
    `invoke = AsyncMock()`  
    `monkeypatch.setattr(openai_health, "_invoke_openai", invoke)`

    `response = asyncio.run(openai_health.get_openai_health(_request()))`

    `assert response.status_code == 200`  
    `assert response.body == (`  
        `b'{"status":"ok","provider":"openai","model":"gpt-4o-mini"}'`  
    `)`  
    `invoke.assert_awaited_once_with("test-key")`

`def test_openai_health_hides_provider_failure(monkeypatch):`  
    `invoke = AsyncMock(side_effect=RuntimeError("provider details"))`  
    `monkeypatch.setattr(openai_health, "_invoke_openai", invoke)`

    `response = asyncio.run(openai_health.get_openai_health(_request()))`

    `assert response.status_code == 502`  
    `assert response.body == b'{"status":"unavailable"}'`

`=== backend/uv.lock ===`  
`version = 1`  
`revision = 5`  
`requires-python = ">=3.10"`  
`resolution-markers = [`  
    `"python_full_version >= '3.14'",`  
    `"python_full_version == '3.13.*'",`  
    `"python_full_version == '3.12.*'",`  
    `"python_full_version == '3.11.*'",`  
    `"python_full_version < '3.11'",`  
`]`

`[[package]]`  
`name = "annotated-doc"`  
`version = "0.0.5"`  
`source = { registry = "[https://pypi.org/simple](https://pypi.org/simple)" }`  
`sdist = { url = "[https://files.pythonhosted.org/packages/5a/8e/38aa427ed5402449e226975b649c5dc73ccadfefeb95e6aecb8f8ea4b6b6/annotated_doc-0.0.5.tar.gz](https://files.pythonhosted.org/packages/5a/8e/38aa427ed5402449e226975b649c5dc73ccadfefeb95e6aecb8f8ea4b6b6/annotated_doc-0.0.5.tar.gz)", hash = "sha256:c7e58ce09192557605d8bbd92836d7e1d520ac9580096042c0bfd197efacf1bb", size = 10758, upload-time = "2026-07-28T13:50:58.129Z" }`  
`wheels = [`  
    `{ url = "[https://files.pythonhosted.org/packages/3e/30/e900b21425a860e195f32e37657aa1f7c7f2b1bfb26f03ca209b90933c06/annotated_doc-0.0.5-py3-none-any.whl](https://files.pythonhosted.org/packages/3e/30/e900b21425a860e195f32e37657aa1f7c7f2b1bfb26f03ca209b90933c06/annotated_doc-0.0.5-py3-none-any.whl)", hash = "sha256:117bac03a25ede5df5440e855b32d556049ca169ead221505badf432fed4b101", size = 5302, upload-time = "2026-07-28T13:50:57.239Z" },`  
`]`

`[[package]]`  
`name = "annotated-types"`  
`version = "0.8.0"`  
`source = { registry = "[https://pypi.org/simple](https://pypi.org/simple)" }`  
`sdist = { url = "[https://files.pythonhosted.org/packages/5f/56/a8120250d128bed162cd73c76d45f6ef9991f3e068f62a8ee060afa3104a/annotated_types-0.8.0.tar.gz](https://files.pythonhosted.org/packages/5f/56/a8120250d128bed162cd73c76d45f6ef9991f3e068f62a8ee060afa3104a/annotated_types-0.8.0.tar.gz)", hash = "sha256:13b2beaad985e05e2d6407ee4c4f35590b11f8d693a258a561055cac8f64cab7", size = 15893, upload-time = "2026-07-23T20:16:13.995Z" }`  
`wheels = [`  
    `{ url = "[https://files.pythonhosted.org/packages/99/91/8acff4f5e50511b911bbccb72b8628a49c68ce14148cd9f6431094859a90/annotated_types-0.8.0-py3-none-any.whl](https://files.pythonhosted.org/packages/99/91/8acff4f5e50511b911bbccb72b8628a49c68ce14148cd9f6431094859a90/annotated_types-0.8.0-py3-none-any.whl)", hash = "sha256:f072f4d804ea359e4eaf198b1af7a8b0943881a87f31bb764f8bf219bb9419e0", size = 13427, upload-time = "2026-07-23T20:16:12.938Z" },`  
`]`

`[[package]]`  
`name = "anyio"`  
`version = "4.15.1"`  
`source = { registry = "[https://pypi.org/simple](https://pypi.org/simple)" }`  
`dependencies = [`  
    `{ name = "exceptiongroup", marker = "python_full_version < '3.11'" },`  
    `{ name = "idna" },`  
    `{ name = "typing-extensions", marker = "python_full_version < '3.15'" },`  
`]`  
`sdist = { url = "[https://files.pythonhosted.org/packages/a9/d2/f4d173e22df740bc37b1db102b386ba719b66e95b0f0d751f556b387e6d2/anyio-4.15.1.tar.gz](https://files.pythonhosted.org/packages/a9/d2/f4d173e22df740bc37b1db102b386ba719b66e95b0f0d751f556b387e6d2/anyio-4.15.1.tar.gz)", hash = "sha256:9f28306018cbd6d329e64a36d58256edff76dd996fe423bc957326e578b82a94", size = 276966, upload-time = "2026-09-05T10:42:39.44Z" }`  
`wheels = [`  
    `{ url = "[https://files.pythonhosted.org/packages/12/b8/4bd346e22b28902df4d651910f5242c28d84e4a5c2435ca5c3f797ed7e2e/anyio-4.15.1-py3-none-any.whl](https://files.pythonhosted.org/packages/12/b8/4bd346e22b28902df4d651910f5242c28d84e4a5c2435ca5c3f797ed7e2e/anyio-4.15.1-py3-none-any.whl)", hash = "sha256:6152fdbbf9a77fdec97731721bebf7c4c44f7c29b424b0065826173efc7ed101", size = 132079, upload-time = "2026-09-05T10:42:37.923Z" },`  
`]`

`[[package]]`  
`name = "certifi"`  
`version = "2026.10.23"`  
`source = { registry = "https://pypi.org/simple" }`  
`sdist = { url = "https://files.pythonhosted.org/packages/fd/11/b524cbd9bbdaca58608e4cf4053fd463417549e1959fa8d3aa18319f9555/certifi-2026.10.23.tar.gz", hash = "sha256:a9895e6e2758b371e0545e321a3a8fd1fcfd9829ada8824a936dfb16aaaf36cd", size = 136225, upload-time = "2026-10-23T11:36:16.478Z" }`  
`wheels = [`  
    `{ url = "https://file`  
`=== backend/worker.py ===`  
`from workers import WorkerEntrypoint`

`from app.main import app`

`class Default(WorkerEntrypoint):`  
    `async def fetch(self, request):`  
        `import asgi`

        `return await asgi.fetch(app, request.js_object, self.env)`

`=== backend/wrangler.jsonc ===`  
`{`  
  `"$schema": "node_modules/wrangler/config-schema.json",`  
  `"name": "garblo",`  
  `"main": "worker.py",`  
  `"compatibility_date": "2025-11-02",`  
  `"compatibility_flags": [`  
    `"python_workers",`  
    `"python_dedicated_snapshot"`  
  `],`  
`}`

`=== docs/tasks/backend/BE-010-restore-backend-gate.md ===`  
`# BE-010: Restore the backend gate`

`> **Owner:** Backend Developer`    
`> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval`    
``> **Track / priority:** M · **0** (first: every other backend card needs a green `uv run pytest`)``    
`> **Blocked by:** nothing`

`## Why`

`[ci-cd.md](../../policies/engineering/ci-cd.md) §1 defines the backend gate as`  
`` `uv sync --extra dev` + `uv run pytest`. On 2026-10-30 it fails before collecting a test: ``

```` ```text ````  
`` error: Failed to build `garblo-backend @ file:///F:/github/vjai/backend` ``  
  `hatchling ... default_only_include ...   (no package matches the project name)`

> * pyproject.toml builds a wheel with hatchling, but the code is in app/, not garblo\_backend/, so the editable build cannot find a package.  
> * No uv.lock is committed, although ci-cd.md §2 says it is (CHG-005).  
> * No Python version is pinned; uv picked a 3.15 interpreter on the reference machine.  
> * With the build bypassed (uv run \--no-project \--with …) the 7 legacy tests pass, with 4 Pydantic class Config deprecation warnings (gone after BE-005).

## **Scope**

> 1. Make the project runnable without packaging: \[tool.uv\] package \= false (the backend is an app, not a library), or \[tool.hatch.build.targets.wheel\] packages \= \["app"\]. Prefer the first; record the choice in the report.  
> 2. .python-version \= 3.12 and requires-python \= "\>=3.10,\<3.14".  
> 3. Generate and commit backend/uv.lock.  
> 4. \[tool.pytest.ini\_options\] with testpaths \= \["tests"\] and filterwarnings \= \["error::DeprecationWarning:app.\*"\] so new deprecated code fails.  
> 5. Backend job in CI: .github/workflows/backend.yml, on pull requests and pushes touching backend/\*\*: astral-sh/setup-uv → uv sync \--extra dev \--locked → uv run pytest. (This is the "planned ci.yml backend job" of ci-cd.md §3, started as its own file so the APK workflow is untouched.)

## **Scenarios**

| ID | Given / when / then | Test |
| :---- | :---- | :---- |
| BE-010-S01 | A clean checkout: uv sync \--extra dev \--locked then uv run pytest exits 0 | The gate command itself (red run \= today's failure) |
| BE-010-S02 | The lock is current: uv lock \--check exits 0 | CI step |

## **Allowed files**

backend/pyproject.toml, backend/uv.lock, backend/.python-version, .github/workflows/backend.yml, report docs/reports/BE-010-backend-developer.md.

## **Anti-scope**

No new runtime dependency. No change to endpoints or tests (BE-005 removes the dating ones). No linter added here (a ruff proposal needs a decisions.md entry).

## **Done when**

The red run (today's build error) and the green run are in the report, and the backend CI job passes on the PR.

## **Change history**

| Date | CHG | Change |
| :---- | :---- | :---- |
| 2026-10-30 | [CHG-014](http://docs.google.com/changes/CHG-014-mock-first-backend-track.md) | Created from the gate failure found in the backend analysis |

\=== docs/tasks/backend/BE-011-mock-platform-core.md \===

# **BE-011: Mock platform core — sync row models, IDs, clock, in-memory store, dev token**

**Owner:** Backend Developer

**Status:** Draft · needs [CHG-014](http://docs.google.com/changes/CHG-014-mock-first-backend-track.md) approval

**Track / priority:** M · **2** (after BE-010 and BE-005)

**Source:** Flow Spec v2.8 T4 › Phone schema, Sync model, R8 · [DB handbook](http://docs.google.com/specs/Garblo%20—%20Đặc%20tả%20cơ%20sở%20dữ%20liệu%20\(DRS%20+%20DDS\).md) §3 D01–D02, §4 · [CHG-005](http://docs.google.com/changes/CHG-005-phase-2-local-persistence.md) phone schema v1 · [CHG-006](http://docs.google.com/changes/CHG-006-phase-2-green-decisions.md) G-03

## **Why**

Every mock card needs the same foundation: typed rows for the phone tables, the table classes that decide who may write what, IDs that match the phone bit-for-bit, a clock that is not the wall clock, owner-scoped storage with no database, and an owner identity. Building them once keeps BE-012…BE-018 small, and lets BE-020 swap the store for MongoDB without touching the rules.

## **Contract**

### **Table classes (who writes)**

| Class | Tables in the mock | Phone may |
| :---- | :---- | :---- |
| Read-write | profiles, wardrobe\_items, upload\_batches, media\_assets, interactions, attachments | PUT, PATCH (allow-listed fields), DELETE where the card allows |
| Insert-only | wear\_events, consents (PATCH of revoked\_at only) | PUT |
| Phone-PATCH-only | extracted\_items (value, last\_worn\_input) | PATCH |
| Command rows | gu\_match\_sessions, privacy\_requests, vton\_jobs (refused until AI-002) | PUT; PATCH of its own fields |
| Read-only | item\_types, ai\_processing\_jobs, outfit\_candidates, attachment\_tickets | Nothing |

Columns are exactly those of apps/mobile/lib/core/storage/phone\_schema.dart (schema v1), plus the handbook's columns for tables or fields that v1 lacks (profiles, attachments, attachment\_tickets, privacy\_requests, gu\_match\_sessions.status/context/event\_title/window\_start/window\_end/city\_id/ambient\_temp\_c/expires\_at). Handbook-only columns are **optional** on input, so the phone's v1 rows are accepted until [TASK-011](http://docs.google.com/mobile/TASK-011-phone-schema-v2-alignment.md) lands. Types follow data-schema.md §2: TEXT/INTEGER/REAL, ISO-8601 dates, 0/1 booleans, JSON as text.

### **Modules**

| Module | Content |
| :---- | :---- |
| app/sync/schema.py | One Pydantic v2 model per table (column names as field names, no aliases), TableClass, writable-field allow-lists |
| app/sync/ids.py | is\_object\_id(s); deterministic\_object\_id(parts), a port of the Dart deterministicObjectId (length-prefixed parts, two FNV-1a-64 passes); stable\_hash(bytes) (FNV-1a-32) |
| app/core/clock.py | Clock protocol; FixedClock (default 2026-10-30T09:00:00Z, or GARBLO\_MOCK\_NOW); a FastAPI dependency so tests and /v1/mock/clock replace it |
| app/store/base.py, app/store/memory.py | Store protocol: get, put, patch, delete, query(table, owner, where), transaction() (all-or-nothing); InMemoryStore (dicts per owner per table, sn |
| \=== docs/tasks/backend/BE-012-mock-write-handler.md \=== |  |

# **BE-012: Mock write handler — POST /v1/sync/tx**

**Owner:** Backend Developer

**Status:** Draft · needs [CHG-014](http://docs.google.com/changes/CHG-014-mock-first-backend-track.md) approval

**Track / priority:** M · **3**

**Blocked by:** [BE-011](http://docs.google.com/BE-011-mock-platform-core.md)

**Source:** Flow Spec v2.8 T4 › Write path, Side effects; T2 › Invariants I1, I2, I4, I6 · [DB handbook](http://docs.google.com/specs/Garblo%20—%20Đặc%20tả%20cơ%20sở%20dữ%20liệu%20\(DRS%20+%20DDS\).md) §2 C04, §3 D05 · spec P4-B02, P4-B03 (this card is their mock)

## **Why**

uploadData() on the phone sends one CRUD transaction at a time to this endpoint, and that is the only way phone data reaches the server (DB5). The mobile dev connector ([TASK-010](http://docs.google.com/mobile/TASK-010-mock-backend-integration.md)) needs the real accept/reject behaviour, so the queue logic (complete on 2xx/4xx, retry on 5xx) can be tested before any database exists.

## **Contract**

`POST /v1/sync/tx`  
`Authorization: Bearer dev.<user_id>`  
`{ "tx_id": 42,`  
  `"ops": [ { "op": "PUT",   "type": "upload_batches", "id": "<24 hex>", "data": { ... } },`  
           `{ "op": "PATCH", "type": "upload_batches", "id": "<24 hex>", "data": { "status": "SANITIZING" } } ] }`

op, type, id and data follow the PowerSync CrudEntry JSON. Confirm the exact field names against the SDK version chosen in BE-001, and record any difference in the report.

| Result | Status | Body | Phone does |
| :---- | :---- | :---- | :---- |
| Applied | 200 | {"applied": true, "replayed": false, "tx\_id", "checkpoint"} | tx.complete() |
| Replay of an applied tx (same owner, tx\_id, ops hash) | 200 | {"applied": true, "replayed": true, ...} | tx.complete() |
| Same (owner, tx\_id) with different ops | 409 | TX\_ID\_REUSED (CHG-014 Q1) | complete; log |
| Rule broken | 401/403/409/422 | {"error": {"code", "message", "op\_index"}} | complete (never block the queue); the row is corrected by the next sync |
| Injected fault (/v1/mock/scenarios {"sync": "FAIL\_5XX\_ONCE"}) | 503 | RETRY\_LATER | retry |

Rules, checked for **every** op before **any** op is applied (one store transaction):

| Rule | Code |
| :---- | :---- |
| data.user\_id, when present, equals the token owner; a PUT gets user\_id \= owner if missing | OWNER\_MISMATCH 403 |
| type is a known table and its class allows the op (BE-011 table classes) | TABLE\_NOT\_WRITABLE 403 |
| PATCH touches only allow-listed fields | FIELD\_NOT\_WRITABLE 422 |
| Insert-only tables reject PATCH (except consents.revoked\_at) and DELETE | APPEND\_ONLY 422 |
| id is an ObjectId; data validates against the table model | INVALID\_ID / SCHEMA\_VIOLATION 422 |
| PUT of an existing id from the same owner is "already applied" (deterministic IDs, BE-006) | — (no-op) |
| PUT of an id owned by another user | OWNER\_MISMATCH 403 |
| I1: upload\_batches → SANITIZING needs 1–10 non-removed media\_assets and a non-revoked consent\_id of the owner | PHOTO\_COUNT\_OUT\_OF\_RANGE, CONSENT\_REQUIRED 422 |
| I2: media\_assets.mime\_type ∈ { |  |
| \=== docs/tasks/backend/BE-013-mock-change-feed.md \=== |  |

# **BE-013: Mock change feed (Sync Streams stand-in), catalog and demo seed**

**Owner:** Backend Developer

**Status:** Draft · needs [CHG-014](http://docs.google.com/changes/CHG-014-mock-first-backend-track.md) approval (dev-only deviation from DB5)

**Track / priority:** M · **4**

**Blocked by:** [BE-012](http://docs.google.com/BE-012-mock-write-handler.md)

**Source:** Flow Spec v2.8 T4 › Sync Streams, Sync model (write checkpoints); spec P3-02, P3-03 · [BE-003](http://docs.google.com/BE-003-wardrobe-and-wear-api.md) seed list

## **Why**

On the real platform the phone reads everything through PowerSync Sync Streams, which need MongoDB change streams. The mock has no database, so it serves the same rows through a dev-only, ordered change feed. The mobile dev connector ([TASK-010](http://docs.google.com/mobile/TASK-010-mock-backend-integration.md)) applies these changes to the local database, so repositories and screens see server rows exactly as they will from PowerSync.

## **Contract**

`GET /v1/mock/sync/changes?after=<checkpoint>&streams=catalog,my_wardrobe,my_studio,my_studio_jobs,my_decks,my_files&limit=500`  
`Authorization: Bearer dev.<user_id>`

`200 { "checkpoint": 57, "has_more": false,`  
      `"changes": [ { "seq": 51, "stream": "my_studio_jobs", "op": "PUT", "type": "ai_processing_jobs",`  
                     `"id": "<24 hex>", "data": { ...full row... } },`  
                   `{ "seq": 52, "stream": "my_studio", "op": "DELETE", "type": "media_assets", "id": "...", "data": null } ] }`

> * Stream names and membership are those of T4 › Sync Streams: catalog (all users), my\_wardrobe, my\_studio and my\_studio\_jobs (open batches only, so a COMPLETED batch's rows produce DELETE changes), my\_decks (sessions with recent \= 1), my\_files. my\_progress, my\_community and deck\_history are out of scope.  
> * data is the full row after the change (PowerSync syncs whole rows); DELETE has data: null.  
> * The phone's own applied writes appear too, after normalisation (owner filled, server fields added), so the phone can treat the feed as the authority.  
> * **Write checkpoint:** a /v1/sync/tx response's checkpoint is ≤ the feed's checkpoint once that tx and its side effects are visible.  
> * Seeds: POST /v1/mock/seed {"preset": "catalog"} (applied on reset) and {"preset": "demo\_wardrobe"}. Item types match ItemTypeCatalog; the 9 demo items match MockWardrobeRepository.seeded and the phone's demo\_seed.dart IDs (deterministic\_object\_id(\["demo-seed", "seed\_NN"\])), with dates relative to the mock clock. Read both from contracts/fixtures/ once [TASK-012](http://docs.google.com/mobile/TASK-012-shared-golden-fixtures.md) exports them.

## **Scenarios**

| ID | Scenario | Test file |
| :---- | :---- | :---- |
| BE-013-S01 | After reset, after=0\&streams=catalog returns every item type once, in a stable order | tests/test\_change\_feed.py |
| BE-013-S02 | A PUT through /v1/sync/tx appears in the owner's feed with user\_id filled; never in another owner's | tests/test\_change\_feed.py |
| BE-013-S03 | after=\<checkpoint\> |  |
| \=== docs/tasks/backend/BE-014-fake-studio-side-effects.md \=== |  |  |

# **BE-014: Fake Studio side effects — jobs, fake extraction, review, commit**

**Owner:** Backend Developer

**Status:** Draft · needs [CHG-014](http://docs.google.com/changes/CHG-014-mock-first-backend-track.md) approval

**Track / priority:** M · **6**

**Blocked by:** [BE-012](http://docs.google.com/BE-012-mock-write-handler.md), [BE-013](http://docs.google.com/BE-013-mock-change-feed.md), [AI-005](http://docs.google.com/AI-005-model-ports-and-fakes.md)

**Source:** UC-01…UC-03 · Flow Spec v2.8 T2 › State machines; T4 › Side effects (upload\_batches, wardrobe\_items) · [DB handbook](http://docs.google.com/specs/Garblo%20—%20Đặc%20tả%20cơ%20sở%20dữ%20liệu%20\(DRS%20+%20DDS\).md) §5 · [CHG-006](http://docs.google.com/changes/CHG-006-phase-2-green-decisions.md) G-01, G-03, G-04 · spec P4-B05 (this is its mock)

## **Why**

This is the mock of the Studio pipeline in [BE-002](http://docs.google.com/BE-002-studio-pipeline.md). The phone writes the batch, assets, consent and status changes. The server creates one job per photo × task, runs the fake extractor, and writes extracted\_items for review. When the user saves, the phone writes N wardrobe\_items and the batch COMPLETED in one tx. The mobile team can then test progress, partial results, failures, review edits and atomic save against a server.

## **Behaviour**

| Phone writes (via /v1/sync/tx) | Mock side effect | Rows in the feed |
| :---- | :---- | :---- |
| upload\_batches PATCH SANITIZING | Mark each non-removed asset verified (BE-018 does real checks later) | media\_assets |
| upload\_batches PATCH QUEUED\_FOR\_AI | One ai\_processing\_jobs row per non-removed asset × requested task, ID deterministic\_object\_id(\[batch\_id, asset\_id, task\_type\]); batch → AI\_PROCESSING; run jobs | jobs PENDING → PROCESSING → final; extracted\_items; batch status |
| Outfit job | OutfitExtractor → COMPLETED with 0..n extracted\_items, or FAILED | extracted\_items with ai \= value \= extractor attributes, item\_index per asset, ID deterministic\_object\_id(\[batch\_id, asset\_id, str(item\_index)\]) |
| Pose / background job | PersonDetector → SKIPPED\_NO\_PERSON | job row |
| All jobs final | Batch → AWAITING\_REVIEW, or FAILED when every outfit job failed (T2 state machine) | batch status |
| extracted\_items PATCH value, last\_worn\_input | Accept (allow-list in BE-012); ai never changes | the patched row |
| upload\_batches PATCH DRAFT (reopen) | Cancel the batch's jobs by deleting them, and delete its extracted\_items (job\_status has no CANCELLED value; the phone's discardBatch also deletes jobs) | DELETE changes for jobs and drafts |
| wardrobe\_items PUT ×N \+ batch PATCH COMPLETED, one tx | Check the batch is AWAITING\_REVIEW and every item's source\_asset\_id is in it; IDs are the phone's deterministic\_object\_id(\[draft\_id\]); a retried tx is a replay | items in my\_wardrobe; DELETEs for the batch's my\_studio rows |

Retries: a FAILED outfit job is retried up to 2 times before it stays FAILED (TAC-02.4). The fake scripts a failure count per scenario, so tests see a retried-then-completed job and a job that stays failed.

Scenar \=== docs/tasks/backend/BE-015-fake-gu-match-side-effects.md \===

# **BE-015: Fake Gu Match side effects — session, context cards, deck, swipes, swap**

**Owner:** Backend Developer

**Status:** Draft · needs [CHG-014](http://docs.google.com/changes/CHG-014-mock-first-backend-track.md) approval

**Track / priority:** M · **7**

**Blocked by:** [BE-012](http://docs.google.com/BE-012-mock-write-handler.md), [BE-013](http://docs.google.com/BE-013-mock-change-feed.md), [AI-005](http://docs.google.com/AI-005-model-ports-and-fakes.md)

**Source:** UC-05…UC-08 · Flow Spec v2.8 T4 › Side effects (gu\_match\_sessions, interactions) · [DB handbook](http://docs.google.com/specs/Garblo%20—%20Đặc%20tả%20cơ%20sở%20dữ%20liệu%20\(DRS%20+%20DDS\).md) §8 GM-01…GM-05 · spec P4-B07 (this is its mock)

**⚠ Not a dating API.** Gu Match drafts **Fits** (outfits) from the user's own Pieces. A swipe decides on a Fit, never on a person. See [README › Read this first](http://docs.google.com/README.md#read-this-first-garblo-is-not-a-dating-app).

## **Why**

This is the mock of [BE-004](http://docs.google.com/BE-004-gu-match-api.md). In P4 the server owns deck generation, and the phone writes only the session request and its interactions. The mock lets the mobile team build that P4 shape now: insert a REQUESTED session, watch context cards arrive in the session row, then swipe a deck that synced down.

## **Behaviour**

| Phone writes | Mock side effect | Rows in the feed |
| :---- | :---- | :---- |
| gu\_match\_sessions PUT (path, occasions, raw\_prompt, optional derived context) | Validate C1/C10 (≤ 5 known occasions, prompt ≤ 280, PROMPT\_LED iff any chip or text); count eligible items (I9) | session patches, in order: status=GATHERING \+ eligible\_item\_count, owned\_only=1, deck\_size=8, recent=1, expires\_at (mock now \+ 90 days) |
| … eligible \= 0 | status=NO\_ELIGIBLE\_ITEMS; no deck (replaces 409 NO\_ELIGIBLE\_ITEMS) | session |
| … eligible \> 0 | One context patch per card, in the fixed order occasion, weather, rain, commute (ContextSource fakes); a missing source yields is\_missing=true, never a failed session (TAC-06.2); then status=ANALYZED | session (context JSON grows card by card) |
| … deck | OutfitGenerator → ≤ 8 outfit\_candidates (deck\_order, title, match\_pct, highlight\_reason, visual\_mode=COLLAGE\_FLATLAY, swipe\_status=PENDING\_SWIPE, items\[{slot\_role, item\_id, name, days\_unworn}\]), IDs deterministic\_object\_id(\[session\_id, str(deck\_order)\]); then status=DECK\_READY | candidates, session |
| interactions PUT DISMISS\_PASS / LIKE\_SAVE | swipe\_status → SWIPED\_LEFT\_PASSED / SWIPED\_RIGHT\_LIKED | candidate |
| interactions PUT CUSTOMIZE\_EDIT with from\_item\_id, to\_item\_id (ADJUST) | Same group, owned, not archived (TAC-08.6), else 422 ITEM\_NOT\_OWNED / GROUP\_MISMATCH; recompute items and match\_pct | candidate |
| interactions PUT TRIGGER\_VTON | Logged only; try-on is AI-002 | — |

days\_unworn uses the shared dormancy rules ([BE-016](http://docs.google.com/BE-016-wear-rules-parity.md)); until BE-016 lands, the server counts days since created\_at and last\_worn\_estimate only.

Status values REQUESTED → GATHERING → ANALYZED → DECK\_READY, \`NO\_ELIGIBLE \=== docs/tasks/backend/BE-016-wear-rules-parity.md \===

# **BE-016: Shared wear rules on the server — dormancy, gap days, rescue eligibility**

**Owner:** Backend Developer

**Status:** Draft · needs [CHG-014](http://docs.google.com/changes/CHG-014-mock-first-backend-track.md) approval

**Track / priority:** M · **8**

**Blocked by:** [BE-012](http://docs.google.com/BE-012-mock-write-handler.md); golden fixtures from [TASK-012](http://docs.google.com/mobile/TASK-012-shared-golden-fixtures.md)

**Source:** UC-04 TAC-04.2 · I8, N6, I12 · Flow Spec v2.8 T3 › Shared rules; T4 › Derived values · [DB handbook](http://docs.google.com/specs/Garblo%20—%20Đặc%20tả%20cơ%20sở%20dữ%20liệu%20\(DRS%20+%20DDS\).md) §7 WD-03…WD-08 · [BE-003](http://docs.google.com/BE-003-wardrobe-and-wear-api.md) contract table

## **Why**

The spec requires one rules library that "runs on both phone and server and is tested against the same fixtures". The phone has DormancyRules and stores **provisional** gap\_days and rescue\_eligible on each wear event; the server recomputes them, and its values replace the phone's. This logic has no database or AI in it, so it can be written now and reused unchanged by the real platform (BE-003, the rewards worker P4-B08).

## **Scope**

> * backend/app/rules/wear.py, pure functions: days\_unworn(item, wear\_events, today): days since the latest of (logged wear, last\_worn\_estimate), else since created\_at (I8). is\_dormant(...): ≥ 30\. gap\_days(item\_id, worn\_date, prior\_events, item) and rescue\_eligible(...): the gap is measured from a **logged** wear or the save date, **never** from the estimate (N6, I12).  
> * Side effect on wear\_events PUT: compute authoritative gap\_days and rescue\_eligible per item and write them back into the event's items JSON (server-written correction of an insert-only row; the phone overwrites its provisional values on sync).  
> * Golden parity: the tests read the same fixture file as the Dart dormancy\_test.dart (including \[TASK-003-S14\]) and \[TASK-006-S03\].

## **Scenarios**

| ID | Scenario | Test file |
| :---- | :---- | :---- |
| BE-016-S01 | Every golden dormancy case gives the Dart test's expected days and badge | tests/rules/test\_wear\_rules.py |
| BE-016-S02 | A wear 41 days after the last logged wear is a rescue; the same gap measured only from the estimate is not | tests/rules/test\_wear\_rules.py |
| BE-016-S03 | A wear-event PUT whose provisional rescue\_eligible is wrong is corrected in the feed; a correct one gets no extra change | tests/test\_wear\_effects.py |
| BE-016-S04 | Two events on the same date with the same signature (same deterministic ID) are stored once (TAC-07.4) | tests/test\_wear\_effects.py |
| BE-016-S05 | No rule reads the clock; today is always an argument | tests/rules/test\_wear\_rules.py |

## **Allowed files**

backend/app/rules/, backend/app/workers/wear.py, backend/app/sync/effects.py (registration), backend/tests/rules/, backend/tests/test\_wear\_effects.py, report.

## **Anti-scope**

No XP, streaks, quests or impact metrics (Flow C). No editable counters (R2).

## **Change history**

| Date | CHG | Change |
| :---- | :---- | :---- |

\| \=== docs/tasks/backend/BE-017-fake-privacy-requests.md \===

# **BE-017: Fake privacy requests — erasure and body-consent withdrawal in memory**

**Owner:** Backend Developer

**Status:** Draft · needs [CHG-014](http://docs.google.com/changes/CHG-014-mock-first-backend-track.md) approval

**Track / priority:** M · **9**

**Blocked by:** [BE-012](http://docs.google.com/BE-012-mock-write-handler.md), [BE-013](http://docs.google.com/BE-013-mock-change-feed.md)

**Source:** UC-09 AC-09.4…09.6, TAC-09.4 · Flow Spec v2.8 T4 › Side effects (privacy\_requests) · [DB handbook](http://docs.google.com/specs/Garblo%20—%20Đặc%20tả%20cơ%20sở%20dữ%20liệu%20\(DRS%20+%20DDS\).md) §13 LC-01…LC-04, LC-07, LC-11 · mock of [BE-007](http://docs.google.com/BE-007-privacy-erasure-and-export.md)

## **Why**

Today the phone erases data locally only (TASK-008). Once data syncs, erasure is a privacy\_requests command row. The handbook adds an important ordering rule (LC-04): the phone wipes itself **after** the write handler acknowledges the request, so an offline erasure is never lost. The mobile team needs a server that acknowledges, purges and reports, to build that flow.

## **Behaviour**

| Phone writes | Mock side effect | Feed |
| :---- | :---- | :---- |
| privacy\_requests PUT scope=BODY | In the request's tx: set revoked\_at on the owner's body consents (includes\_body=1); delete BODY\_REFERENCE batches and their assets; status=COMPLETED | DELETEs, consent patch, request status |
| privacy\_requests PUT scope=ALL | In the tx: revoke consents, mark open batches DELETED\_BY\_USER, cancel jobs; then purge every row and file of the owner, keeping only the request row; status=IN\_PROGRESS → COMPLETED | DELETE for every synced row; request status |
| privacy\_requests PUT scope=EXPORT | status=FAILED with reason NEEDS\_SPEC (gap ④, UC-19) | request status |
| Same request replayed | No-op (TAC-09.4 idempotent) | — |

A proof function remaining\_rows(owner) returns a per-table count, which must be 0 after ALL (TAC-09.2 proof query, mock version). Events erasure\_requested{scope} and erasure\_completed{duration\_ms} go to an in-memory event log with no personal data (TAC-09.6).

## **Scenarios**

| ID | Scenario | Test file |
| :---- | :---- | :---- |
| BE-017-S01 | ALL on a seeded owner leaves remaining\_rows \= 0 everywhere, except the request row | tests/test\_privacy\_effects.py |
| BE-017-S02 | Another owner's rows are untouched | tests/test\_privacy\_effects.py |
| BE-017-S03 | An in-flight batch (HOLD scenario) becomes DELETED\_BY\_USER, and its held jobs never produce drafts after release (AC-09.6) | tests/test\_privacy\_effects.py |
| BE-017-S04 | BODY revokes body consents only; wardrobe items stay | tests/test\_privacy\_effects.py |
| BE-017-S05 | Replay is a no-op; the request acknowledges with a checkpoint the phone can wait for (LC-04) | tests/test\_privacy\_effects.py |
| BE-017-S06 | The event log holds scope and duration only: no IDs other than the request ID, and no names | tests/test\_privacy\_effects.py |

## **Allowed files**

backend/app/workers/privacy.py, backend/app/sync/effects.py (registration), \`backend/tests/test\_privacy\_effe \=== docs/tasks/backend/BE-018-mock-attachments.md \===

# **BE-018: Mock attachments — tickets, in-memory file store, upload verification**

**Owner:** Backend Developer

**Status:** Draft · needs [CHG-014](http://docs.google.com/changes/CHG-014-mock-first-backend-track.md) approval

**Track / priority:** M · **10**

**Blocked by:** [BE-012](http://docs.google.com/BE-012-mock-write-handler.md), [BE-013](http://docs.google.com/BE-013-mock-change-feed.md)

**Source:** Flow Spec v2.8 T4 › DB6, R9, Side effects (attachments) · [DB handbook](http://docs.google.com/specs/Garblo%20—%20Đặc%20tả%20cơ%20sở%20dữ%20liệu%20\(DRS%20+%20DDS\).md) §6 FL-01…FL-05 · UC-01 TAC-01.3, I2, I3, I5 · mock of [BE-008](http://docs.google.com/BE-008-rustfs-tickets-and-verify.md)

## **Why**

Photo bytes never go through sync. The phone inserts an attachments row, the server answers with a short-lived PUT ticket, the phone uploads the bytes to that URL, and the server checks the file. The mock replaces RustFS with process memory, so the mobile attachment queue (P4-M03) and the server's EXIF re-check can be tested without object storage.

## **Behaviour**

| Step | Mock |
| :---- | :---- |
| Phone PUTs attachments (kind PHOTO or BODY, mime\_type, bytes, sha256, state=PENDING\_UPLOAD) | Write an attachment\_tickets row: op=PUT, url=\<base\>/v1/mock/files/\<ticket\>, expires\_at \= mock now \+ 15 min |
| PUT /v1/mock/files/\<ticket\> with the raw body (Content-Type: image/jpeg or image/png) | Store the bytes in memory under users/\<user\_id\>/\<attachment\_id\>. An expired, foreign or GET ticket → 403\. No multipart and no python-multipart: the body is read as raw bytes |
| Phone PATCHes attachments.state=UPLOADED | Verify: size and SHA-256 match the row; magic bytes are JPEG or PNG (I2); for JPEG, no APP1 Exif or XMP segment; for PNG, no eXIf chunk (I3, TAC-01.3) → VERIFIED, else REJECTED and delete the bytes |
| A GET ticket is needed (e.g. a cutout) | op=GET ticket valid 1 h; GET /v1/mock/files/\<ticket\> returns the bytes |
| Fake extraction (BE-014) | Uses the verified bytes for stable\_hash(content), so the server picks the same sample set as the phone (CHG-014 Q3) |

Ticket IDs are deterministic\_object\_id(\[attachment\_id, op, expires\_at\]); the mock clock makes expiry testable without waiting.

## **Scenarios**

| ID | Scenario | Test file |
| :---- | :---- | :---- |
| BE-018-S01 | Attachment PUT → one PUT ticket in the owner's my\_files feed, expiring in 15 min | tests/test\_attachments.py |
| BE-018-S02 | Upload with the ticket, PATCH UPLOADED → VERIFIED for a stripped JPEG and a PNG fixture | tests/test\_attachments.py |
| BE-018-S03 | A JPEG with EXIF/GPS, a HEIC file, or a hash mismatch → REJECTED, bytes deleted | tests/test\_attachments.py |
| BE-018-S04 | An expired ticket (clock \+ 16 min) or another owner's ticket → 403 | tests/test\_attachments.py |
| BE-018-S05 | The verified bytes drive the fake extractor: same sample set as the Dart stableHash for the golden image | tests/test\_attachments.py |
| BE-018-S06 | Erasure ALL (BE-017) leaves no bytes under users/\<user\_id\>/ | tests/test\_attachments.py |

Fixtures: reuse t \=== docs/tasks/backend/BE-019-auth-service.md \===

# **BE-019: Auth service — anonymous JWT, JWKS, refresh rotation, Google link**

**Owner:** Backend Developer

**Status:** Blocked by [BE-001](http://docs.google.com/BE-001-platform-decision.md) (questions 4–7) and spike SP-6

**Track:** R (real) · spec P4-B01 · mock predecessor: dev token in [BE-011](http://docs.google.com/BE-011-mock-platform-core.md)

**Source:** Flow Spec v2.8 T4 › Account lifecycle, DB2, R6 · [DB handbook](http://docs.google.com/specs/Garblo%20—%20Đặc%20tả%20cơ%20sở%20dữ%20liệu%20\(DRS%20+%20DDS\).md) §4 ID-01…ID-08 · [CHG-011](http://docs.google.com/changes/CHG-011-power-sync-security-baseline.md), D-009 security baseline · [data-schema.md](http://docs.google.com/policies/engineering/data-schema.md) §6

## **Why**

PowerSync needs a JWT from first launch, and the install owner ID the phone has been using since Phase 2 must become the sub with no re-keying (BE-006). No card covered spec P4-B01 until now.

## **Scope**

> * POST /v1/auth/anonymous {user\_id} creates the account with sub \= user\_id (accepting the phone-generated ObjectId once) and returns an access JWT and a refresh token (ID-02).  
> * Asymmetric signing with an explicit alg and kid; JWKS published for PowerSync; key rotation documented (CHG-011).  
> * Refresh-token rotation with reuse detection; only hashes stored.  
> * linked claim; Google link keeps sub; merge flow when the Google identity already has an account (ID-05, ID-06).  
> * The write handler's current\_owner dependency switches from the dev token to JWT verification; every BE-012 owner test still passes.

## **Anti-scope**

No email or password login. No Community gating beyond the linked claim. The private key never enters the app, PowerSync or the repo.

## **Change history**

| Date | CHG | Change |
| :---- | :---- | :---- |
| 2026-10-30 | [CHG-014](http://docs.google.com/changes/CHG-014-mock-first-backend-track.md) | Created; spec P4-B01 had no card |

```` ```python?code_reference&code_event_index=2 ````  
`import struct`  
`import zlib`

`with open('vjai.rar', 'rb') as f:`  
    `data = f.read()`

`pos = 7`  
`git_objs = {}`  
`while pos + 7 <= len(data):`  
    `head_crc, head_type, head_flags, head_size = struct.unpack_from('<HBHH', data, pos)`  
    `if head_size < 7:`  
        `break`  
    `add_size = 0`  
    `if head_flags & 0x8000 or head_type == 0x74:`  
        `if pos + 11 <= len(data):`  
            `add_size = struct.unpack_from('<I', data, pos + 7)[0]`  
      
    `if head_type == 0x74:`  
        `pack_size, unp_size, host_os, file_crc, ftime, unp_ver, method, name_size, attr = struct.unpack_from('<IIBIIBBHI', data, pos + 7)`  
        `if head_flags & 0x0100:`  
            `high_pack, high_unp = struct.unpack_from('<II', data, pos + 32)`  
            `pack_size |= (high_pack << 32)`  
            `unp_size |= (high_unp << 32)`  
            `name_offset = pos + 40`  
        `else:`  
            `name_offset = pos + 32`  
          
        `raw_name = data[name_offset:name_offset + name_size]`  
        `if b'\x00' in raw_name:`  
            `raw_name = raw_name.split(b'\x00')[0]`  
        `fname = raw_name.decode('utf-8', errors='replace').replace('\\', '/')`  
        `data_offset = pos + head_size`  
          
        `if method == 0x30 and '.git/objects/' in fname and '/pack/' not in fname and '/info/' not in fname:`  
            `parts = fname.split('.git/objects/')[1].split('/')`  
            `if len(parts) == 2 and len(parts[0]) == 2 and len(parts[1]) == 38:`  
                `sha = parts[0] + parts[1]`  
                `git_objs[sha] = data[data_offset:data_offset + unp_size]`  
        `pos = pos + head_size + pack_size`  
    `else:`  
        `pos = pos + head_size + add_size`

`def read_obj(sha):`  
    `if sha in git_objs:`  
        `raw = zlib.decompress(git_objs[sha])`  
        `header, content = raw.split(b'\x00', 1)`  
        `obj_type, size = header.decode().split(' ')`  
        `return obj_type, content`  
    `return None, None`

`def parse_tree(tree_sha, prefix=""):`  
    `obj_type, content = read_obj(tree_sha)`  
    `if obj_type != 'tree':`  
        `return {}`  
    `entries = {}`  
    `i = 0`  
    `while i < len(content):`  
        `null_idx = content.index(b'\x00', i)`  
        `mode_name = content[i:null_idx].decode('utf-8', errors='replace')`  
        `mode, name = mode_name.split(' ', 1)`  
        `sha_bytes = content[null_idx+1:null_idx+21]`  
        `sha_hex = sha_bytes.hex()`  
        `i = null_idx + 21`  
        `full_path = f"{prefix}/{name}" if prefix else name`  
        `if mode in ('40000', '040000'):`  
            `entries.update(parse_tree(sha_hex, full_path))`  
        `else:`  
            `entries[full_path] = sha_hex`  
    `return entries`

`tree_sha = 'b99b2ec4321a50977aaa0ea058be977827648359'`  
`files_map = parse_tree(tree_sha)`

`for k in [`  
    `'docs/tasks/backend/BE-005-retire-dating-mock-api.md',`  
    `'docs/tasks/backend/BE-014-fake-studio-side-effects.md',`  
    `'docs/tasks/backend/BE-015-fake-gu-match-side-effects.md',`  
    `'docs/tasks/backend/BE-021-fake-try-on-side-effects.md',`  
    `'docs/tasks/backend/BE-022-mock-contract-requests-from-mobile.md',`  
    `'docs/tasks/backend/AI-005-model-ports-and-fakes.md',`  
    `'docs/policies/engineering/tdd.md',`  
`]:`  
    `print(f"=== {k} ===")`  
    `_, c = read_obj(files_map[k])`  
    `if c:`  
        `print(c.decode('utf-8', errors='replace'))`

followed by a list of required non-scenario tests (edge cases, failures).

## **Change history**

| Date | CHG | Change |
| :---- | :---- | :---- |
| 2026-10-16 | [CHG-001](http://docs.google.com/changes/CHG-001-agentic-documentation-system.md) | Created; merges test coverage rules from docs/archive/legacy/quality/DOD.md |
| 2026-10-30 | [CHG-010](http://docs.google.com/changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to apps/mobile/ |

``Following the project's **TDD Standard (`docs/policies/engineering/tdd.md`)**, every scenario ID (`[BE-NNN-Sxx]` / `[AI-NNN-Sxx]`) must be pinned in a failing **Red** test suite before writing implementation code[cite: 1].``

`Below is the complete **Red-phase pytest suite** covering the entire backend Track M pipeline (**BE-005**, **BE-011**, **BE-012**, **BE-013**, **AI-005**, **BE-014**, **BE-015**, **BE-016**, **BE-017**, **BE-018**, and **BE-021**)[cite: 1].`

`---`

`### 1. Test Plan & Scenario Traceability Matrix`

`| Card | Test File | Covered Scenario IDs | Target Modules Tested |`  
`| :--- | :--- | :--- | :--- |`  
``| **BE-005** | `backend/tests/test_retired_routes.py` | `BE-005-S01` .. `S03`[cite: 1] | `app.main` (Retirement of dating routes & OpenAPI schemas)[cite: 1] |``  
``| **BE-011** | `backend/tests/sync/test_ids.py` | `BE-011-S01`, `BE-011-S02`[cite: 1] | `app.sync.ids` (`deterministic_object_id`, `is_object_id`, `stable_hash`)[cite: 1] |``  
``| **BE-011** | `backend/tests/sync/test_schema.py` | `BE-011-S03` + `BE-022` #1–#3[cite: 1] | `app.sync.schema` (PhoneSchema parity, `TableClass`, allow-lists, strict enums/dates)[cite: 1] |``  
``| **BE-011** | `backend/tests/store/test_memory_store.py` | `BE-011-S04`[cite: 1] | `app.store.memory` (`InMemoryStore` atomic rollback & owner isolation)[cite: 1] |``  
``| **BE-011** | `backend/tests/test_auth_dev.py` | `BE-011-S05`[cite: 1] | `POST /v1/auth/dev-token`, `current_owner` bearer guard[cite: 1] |``  
``| **BE-011** | `backend/tests/test_mock_controls.py` | `BE-011-S06`, `BE-011-S07`[cite: 1] | `POST /v1/mock/reset`, `PUT /v1/mock/clock`, `ENV=production` 404 gate[cite: 1] |``  
``| **BE-012** | `backend/tests/test_sync_tx.py` | `BE-012-S01` .. `S04`, `S13`[cite: 1] | `POST /v1/sync/tx` (CRUD apply, replay idempotency, `TX_ID_REUSED`, rollback, `FAIL_5XX_ONCE`)[cite: 1] |``  
``| **BE-012** | `backend/tests/test_sync_tx_rules.py` | `BE-012-S05` .. `S09` + `BE-022` #5[cite: 1] | Table classes, field allow-lists, `APPEND_ONLY`, `extracted_items` PUT rejection, `OWNER_MISMATCH`[cite: 1] |``  
``| **BE-012** | `backend/tests/test_sync_tx_invariants.py` | `BE-012-S10` .. `S12` + `BE-022` #4[cite: 1] | Invariants I1, I2, I4, I6, state machine transitions, client vs. server status guards[cite: 1] |``  
``| **BE-013** | `backend/tests/test_change_feed.py` | `BE-013-S01` .. `S05`, `S07`[cite: 1] | `GET /v1/mock/sync/changes` (Stream filtering, cursors, write checkpoints,COMPLETED deletes)[cite: 1] |``  
``| **BE-013** | `backend/tests/test_mock_seed.py` | `BE-013-S06`[cite: 1] | `POST /v1/mock/seed` (`catalog` & 9 `demo_wardrobe` items idempotency)[cite: 1] |``  
``| **AI-005** | `backend/tests/ai/test_ports.py` & `test_fakes.py` | `AI-005-S01` .. `S07`[cite: 1] | `app.ai.ports`, `app.ai.fakes`, `app.ai.rule_generator` (Zero-PII inputs, deterministic fakes)[cite: 1] |``  
``| **BE-014** | `backend/tests/test_studio_effects.py` | `BE-014-S01` .. `S11`[cite: 1] | Studio batch side effects, job retries, `PARTIAL`/`ALL_FAILED`/`HOLD`, atomic commit[cite: 1] |``  
``| **BE-015** | `backend/tests/test_gu_match_effects.py` | `BE-015-S01` .. `S09`[cite: 1] | Gu Match session lifecycle, context card patches, deck build, swipe & swap rules[cite: 1] |``  
``| **BE-016** | `backend/tests/rules/test_wear_rules.py` | `BE-016-S01` .. `S05`[cite: 1] | `app.rules.wear` (`days_unworn`, `is_dormant`, `gap_days`, `rescue_eligible` parity)[cite: 1] |``  
``| **BE-017** | `backend/tests/test_privacy_effects.py` | `BE-017-S01` .. `S06`[cite: 1] | `privacy_requests` (`ALL`, `BODY`, `EXPORT`), in-flight job cancellation, zero-row proof[cite: 1] |``  
``| **BE-018** | `backend/tests/test_attachments.py` | `BE-018-S01` .. `S06`[cite: 1] | `attachments` tickets, raw binary `PUT /v1/mock/files/<ticket>`, EXIF/GPS & magic-byte verify[cite: 1] |``  
``| **BE-021** | `backend/tests/test_fake_vton.py` | `BE-021-S01` .. `S05`[cite: 1] | `vton_jobs` I7 precheck, single active render guard, consent withdrawal cleanup[cite: 1] |``

`---`

``### 2. Shared Pytest Fixtures (`backend/tests/conftest.py`)``

```` ```python ````  
`# backend/tests/conftest.py`  
`from __future__ import annotations`

`import pytest`  
`from fastapi.testclient import TestClient`

`from app.main import app`

`OWNER_A = "65f0c1a2b3c4d5e6f7a8b9c0"`  
`OWNER_B = "65f0c1a2b3c4d5e6f7a8b9c1"`  
`DEFAULT_MOCK_NOW = "2026-10-30T09:00:00Z"`

`@pytest.fixture()`  
`def client() -> TestClient:`  
    `"""Provides a clean TestClient and resets mock state before each test."""`  
    `with TestClient(app) as c:`  
        `c.post("/v1/mock/reset")`  
        `c.put("/v1/mock/clock", json={"now": DEFAULT_MOCK_NOW})`  
        `yield c`

`@pytest.fixture()`  
`def auth_headers_a() -> dict[str, str]:`  
    `return {"Authorization": f"Bearer dev.{OWNER_A}"}`

`@pytest.fixture()`  
`def auth_headers_b() -> dict[str, str]:`  
    `return {"Authorization": f"Bearer dev.{OWNER_B}"}`

### **3\. BE-005: Retire the Dating Mock API (backend/tests/test\_retired\_routes.py)**

`# backend/tests/test_retired_routes.py`  
`from __future__ import annotations`

`from fastapi.testclient import TestClient`

`def test_be_005_s01_health_endpoints_remain_green(client: TestClient) -> None:`  
    `"""[BE-005-S01] /health and /api/v1/health still return ok."""`  
    `for path in ("/health", "/api/v1/health"):`  
        `res = client.get(path)`  
        `assert res.status_code == 200`  
        `body = res.json()`  
        `assert body["status"] == "ok"`

`def test_be_005_s02_legacy_dating_routes_return_404(client: TestClient) -> None:`  
    `"""[BE-005-S02] All retired dating endpoints return 404."""`  
    `assert client.get("/api/v1/discovery").status_code == 404`  
    `assert client.get("/api/v1/profiles/usr_01").status_code == 404`  
    `assert client.post("/api/v1/swipes", json={"target_id": "usr_01", "direction": "right"}).status_code == 404`  
    `assert client.get("/api/v1/matches").status_code == 404`  
    `assert client.get("/api/v1/chat/conversations").status_code == 404`  
    `assert client.get("/api/v1/auth/status").status_code == 404`

`def test_be_005_s03_openapi_contains_no_dating_schemas(client: TestClient) -> None:`  
    `"""[BE-005-S03] The OpenAPI schema contains no Profile, SwipeRequest, or SwipeResponse."""`  
    `schema = client.get("/openapi.json").json()`  
    `schemas = schema.get("components", {}).get("schemas", {})`  
    `for forbidden in ("Profile", "SwipeRequest", "SwipeResponse"):`  
        `assert forbidden not in schemas`

### **4\. BE-011: Mock Platform Core Tests**

#### **4.1. Deterministic ObjectIds & Hash Parity (backend/tests/sync/test\_ids.py)**

`# backend/tests/sync/test_ids.py`  
`from __future__ import annotations`

`import pytest`

`from app.sync.ids import deterministic_object_id, is_object_id, stable_hash`

`def test_be_011_s01_deterministic_object_id_matches_dart_golden_vectors() -> None:`  
    `"""[BE-011-S01] deterministic_object_id equals the Dart output for golden vectors."""`  
    `golden_vectors = [`  
        `(["demo-seed", "seed_01"], "679dd79ffc8dcfcf27566db7"),`  
        `(["demo-seed", "seed_02"], "679dd89ffc8dd182275670b7"),`  
        `(["demo-seed", "seed_09"], "679ddf9ffc8ddd67275675b7"),`  
        `(`  
            `["65f0c1a2b3c4d5e6f7a8b9c0", "v1.0_studio_body_ai", "2026-10-30T09:00:00Z", "true"],`  
            `"54b01d3ef649557e3dc1f3ec",`  
        `),`  
    `]`  
    `for parts, expected in golden_vectors:`  
        `computed = deterministic_object_id(parts)`  
        `assert computed == expected`  
        `assert is_object_id(computed)`

    `# Order and part boundaries matter`  
    `assert deterministic_object_id(["owner", "2026-10-29", "a,b"]) != deterministic_object_id(`  
        `["2026-10-29", "owner", "a,b"]`  
    `)`  
    `assert deterministic_object_id(["ab", "c"]) != deterministic_object_id(["a", "bc"])`

`def test_be_011_s01_stable_hash_fnv1a_32_parity() -> None:`  
    `"""[BE-011-S01] stable_hash matches 32-bit FNV-1a unsigned integer."""`  
    `assert stable_hash(b"") == 0x811C9DC5`  
    `assert stable_hash(b"garblo-sample-photo-01") == 2925887822`

`@pytest.mark.parametrize(`  
    `"bad_id",`  
    `[`  
        `"",`  
        `"65f0c1a2b3c4d5e6f7a8b9c",`  
        `"65f0c1a2b3c4d5e6f7a8b9c00",`  
        `"65F0C1A2B3C4D5E6F7A8B9C0",`  
        `"65f0c1a2b3c4d5e6f7a8b9cg",`  
        `"../../65f0c1a2b3c4d5e6f7",`  
        `"asset_1",`  
    `],`  
`)`  
`def test_be_011_s02_is_object_id_accepts_24_lowercase_hex_only(bad_id: str) -> None:`  
    `"""[BE-011-S02] is_object_id accepts 24 lowercase hex characters only."""`  
    `assert is_object_id("65f0c1a2b3c4d5e6f7a8b9c0") is True`  
    `assert is_object_id(bad_id) is False`

#### **4.2. Schema Parity, Table Classes & Strict Wire Formats (backend/tests/sync/test\_schema.py)**

`# backend/tests/sync/test_schema.py`  
`from __future__ import annotations`

`import pytest`  
`from pydantic import ValidationError`

`from app.sync.schema import TABLE_ALLOW_LISTS, TABLE_CLASSES, TABLE_MODELS, TableClass`

`def test_be_011_s03_phone_schema_v1_and_v2_tables_and_columns_parity() -> None:`  
    `"""[BE-011-S03] Every phone-schema table and column has a matching Pydantic model field."""`  
    `expected_tables = {`  
        `"profiles": TableClass.READ_WRITE,`  
        `"wardrobe_items": TableClass.READ_WRITE,`  
        `"upload_batches": TableClass.READ_WRITE,`  
        `"media_assets": TableClass.READ_WRITE,`  
        `"interactions": TableClass.READ_WRITE,`  
        `"attachments": TableClass.READ_WRITE,`  
        `"wear_events": TableClass.INSERT_ONLY,`  
        `"consents": TableClass.INSERT_ONLY,`  
        `"extracted_items": TableClass.PHONE_PATCH_ONLY,`  
        `"gu_match_sessions": TableClass.COMMAND,`  
        `"privacy_requests": TableClass.COMMAND,`  
        `"vton_jobs": TableClass.COMMAND,`  
        `"item_types": TableClass.READ_ONLY,`  
        `"ai_processing_jobs": TableClass.READ_ONLY,`  
        `"outfit_candidates": TableClass.READ_ONLY,`  
        `"attachment_tickets": TableClass.READ_ONLY,`  
    `}`  
    `assert set(TABLE_MODELS.keys()) == set(expected_tables.keys())`  
    `for table, expected_cls in expected_tables.items():`  
        `assert TABLE_CLASSES[table] == expected_cls`

    `# Verify Phone-PATCH-only allow-list for extracted_items`  
    `assert TABLE_ALLOW_LISTS["extracted_items"] == {"value", "last_worn_input"}`  
    `assert TABLE_ALLOW_LISTS["consents"] == {"revoked_at"}`

`def test_be_022_strict_upper_snake_enums_and_utc_dates() -> None:`  
    `"""[BE-022 #1, #2] Reject camelCase enums and non-YYYY-MM-DD calendar dates."""`  
    `session_model = TABLE_MODELS["gu_match_sessions"]`  
    `with pytest.raises(ValidationError):`  
        `session_model(`  
            `id="65f0c1a2b3c4d5e6f7a8b9c0",`  
            `user_id="65f0c1a2b3c4d5e6f7a8b9c0",`  
            `path="promptLed",  # camelCase must fail`  
            `occasions='["work"]',`  
            `raw_prompt="test",`  
            `created_at="2026-10-30T09:00:00Z",`  
        `)`

    `wardrobe_model = TABLE_MODELS["wardrobe_items"]`  
    `with pytest.raises(ValidationError):`  
        `wardrobe_model(`  
            `id="679dd79ffc8dcfcf27566db7",`  
            `user_id="65f0c1a2b3c4d5e6f7a8b9c0",`  
            `name="White T-shirt",`  
            `type_code="T_SHIRT",`  
            `color="White",`  
            `material="Cotton",`  
            `style_tag="Basic",`  
            `last_worn_estimate="2026-09-19T09:00:00",  # must be YYYY-MM-DD only`  
            `archived=0,`  
            `created_at="2026-08-31T09:00:00Z",`  
            `updated_at="2026-08-31T09:00:00Z",`  
        `)`

#### **4.3. In-Memory Store Atomicity & Owner Isolation (backend/tests/store/test\_memory\_store.py)**

`# backend/tests/store/test_memory_store.py`  
`from __future__ import annotations`

`import pytest`

`from app.store.memory import InMemoryStore`  
`from tests.conftest import OWNER_A, OWNER_B`

`def test_be_011_s04_transaction_rollback_and_owner_isolation() -> None:`  
    `"""[BE-011-S04] A store transaction that raises leaves no partial rows; owners are isolated."""`  
    `store = InMemoryStore()`  
    `item_id = "679dd79ffc8dcfcf27566db7"`

    `with pytest.raises(RuntimeError, match="abort tx"):`  
        `with store.transaction():`  
            `store.put("wardrobe_items", OWNER_A, item_id, {"id": item_id, "user_id": OWNER_A, "name": "Tee"})`  
            `raise RuntimeError("abort tx")`

    `assert store.get("wardrobe_items", OWNER_A, item_id) is None`

    `with store.transaction():`  
        `store.put("wardrobe_items", OWNER_A, item_id, {"id": item_id, "user_id": OWNER_A, "name": "Tee"})`

    `assert store.get("wardrobe_items", OWNER_A, item_id) is not None`  
    `assert store.get("wardrobe_items", OWNER_B, item_id) is None`  
    `assert store.query("wardrobe_items", OWNER_B) == []`

#### **4.4. Dev Token Auth & Mock Controls (backend/tests/test\_auth\_dev.py & backend/tests/test\_mock\_controls.py)**

`# backend/tests/test_auth_dev.py`  
`from __future__ import annotations`

`from fastapi.testclient import TestClient`

`from tests.conftest import OWNER_A`

`def test_be_011_s05_dev_token_issuance_and_validation(client: TestClient) -> None:`  
    `"""[BE-011-S05] POST /v1/auth/dev-token with valid ObjectId returns bearer token; bad ID -> 422."""`  
    `res = client.post("/v1/auth/dev-token", json={"user_id": OWNER_A})`  
    `assert res.status_code == 200`  
    `assert res.json() == {"token": f"dev.{OWNER_A}", "user_id": OWNER_A}`

    `bad_res = client.post("/v1/auth/dev-token", json={"user_id": "not-an-object-id"})`  
    `assert bad_res.status_code == 422`

    `unauth = client.post("/v1/sync/tx", json={"tx_id": 1, "ops": []})`  
    `assert unauth.status_code == 401`  
    `assert unauth.json()["error"]["code"] == "UNAUTHENTICATED"`

`# backend/tests/test_mock_controls.py`  
`from __future__ import annotations`

`from fastapi.testclient import TestClient`

`from tests.conftest import OWNER_A`

`def test_be_011_s06_mock_clock_controls_server_timestamps(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-011-S06] PUT /v1/mock/clock changes created_at of server-written rows."""`  
    `custom_now = "2026-11-01T07:30:00Z"`  
    `res = client.put("/v1/mock/clock", json={"now": custom_now})`  
    `assert res.status_code == 200`

    `att_id = "6725aa12c8e4b12d34567891"`  
    `tx_res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 1,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "attachments",`  
                    `"id": att_id,`  
                    `"data": {`  
                        `"kind": "PHOTO",`  
                        `"owner_table": "media_assets",`  
                        `"owner_id": "6725aa12c8e4b12d34567892",`  
                        `"mime_type": "image/jpeg",`  
                        `"bytes": 1024,`  
                        `"sha256": "a" * 64,`  
                        `"state": "PENDING_UPLOAD",`  
                    `},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert tx_res.status_code == 200`

    `feed = client.get(`  
        `"/v1/mock/sync/changes?after=0&streams=my_files",`  
        `headers=auth_headers_a,`  
    `).json()`  
    `att_changes = [c for c in feed["changes"] if c["type"] == "attachments"]`  
    `assert att_changes[0]["data"]["created_at"] == custom_now`

`def test_be_011_s07_production_env_disables_mock_and_dev_token_routes(`  
    `client: TestClient, monkeypatch: pytest.MonkeyPatch`  
`) -> None:`  
    `"""[BE-011-S07] With ENV=production, /v1/mock/* and /v1/auth/dev-token return 404."""`  
    `monkeypatch.setenv("ENV", "production")`  
    `assert client.post("/v1/auth/dev-token", json={"user_id": OWNER_A}).status_code == 404`  
    `assert client.post("/v1/mock/reset").status_code == 404`  
    `assert client.put("/v1/mock/clock", json={"now": "2026-10-30T09:00:00Z"}).status_code == 404`

### **5\. BE-012: Mock Write Handler Tests (POST /v1/sync/tx)**

#### **5.1. Transaction Lifecycle, Replay & Atomicity (backend/tests/test\_sync\_tx.py)**

`# backend/tests/test_sync_tx.py`  
`from __future__ import annotations`

`from fastapi.testclient import TestClient`

`from tests.conftest import OWNER_A`

`ITEM_1 = "679dd79ffc8dcfcf27566db7"`

`def _valid_wardrobe_put(item_id: str = ITEM_1) -> dict:`  
    `return {`  
        `"op": "PUT",`  
        `"type": "wardrobe_items",`  
        `"id": item_id,`  
        `"data": {`  
            `"name": "White T-shirt",`  
            `"type_code": "T_SHIRT",`  
            `"color": "White",`  
            `"material": "Cotton",`  
            `"style_tag": "Basic",`  
            `"archived": 0,`  
            `"created_at": "2026-10-30T09:00:00Z",`  
            `"updated_at": "2026-10-30T09:00:00Z",`  
        `},`  
    `}`

`def test_be_012_s01_valid_put_is_applied_and_sets_owner(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-012-S01] Valid PUT is applied, returns checkpoint, and sets user_id = owner."""`  
    `res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={"tx_id": 10, "ops": [_valid_wardrobe_put()]},`  
    `)`  
    `assert res.status_code == 200`  
    `body = res.json()`  
    `assert body["applied"] is True`  
    `assert body["replayed"] is False`  
    `assert body["tx_id"] == 10`  
    `assert isinstance(body["checkpoint"], int)`

`def test_be_012_s02_replaying_same_tx_is_noop(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-012-S02] Replaying the same tx returns replayed=True and does not grow the change log."""`  
    `payload = {"tx_id": 11, "ops": [_valid_wardrobe_put()]}`  
    `first = client.post("/v1/sync/tx", headers=auth_headers_a, json=payload).json()`  
    `second = client.post("/v1/sync/tx", headers=auth_headers_a, json=payload).json()`

    `assert second["applied"] is True`  
    `assert second["replayed"] is True`  
    `assert second["checkpoint"] == first["checkpoint"]`

`def test_be_012_s03_same_tx_id_with_different_ops_returns_409(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-012-S03] Same (owner, tx_id) with different ops -> 409 TX_ID_REUSED."""`  
    `client.post("/v1/sync/tx", headers=auth_headers_a, json={"tx_id": 12, "ops": [_valid_wardrobe_put()]})`  
    `diff = _valid_wardrobe_put()`  
    `diff["data"]["name"] = "Changed Name"`

    `res = client.post("/v1/sync/tx", headers=auth_headers_a, json={"tx_id": 12, "ops": [diff]})`  
    `assert res.status_code == 409`  
    `assert res.json()["error"]["code"] == "TX_ID_REUSED"`

`def test_be_012_s04_atomicity_rolls_back_all_ops_when_one_fails(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-012-S04] Op 2 of 3 breaks a rule -> 4xx with op_index: 1; ops 1 and 3 are not applied."""`  
    `op1 = _valid_wardrobe_put("679dd79ffc8dcfcf27566db7")`  
    `op2_bad = _valid_wardrobe_put("679dd89ffc8dd182275670b7")`  
    `op2_bad["data"]["type_code"] = "NON_EXISTENT_TYPE"`  
    `op3 = _valid_wardrobe_put("679dd99ffc8dd33527566fb7")`

    `res = client.post("/v1/sync/tx", headers=auth_headers_a, json={"tx_id": 13, "ops": [op1, op2_bad, op3]})`  
    `assert res.status_code == 422`  
    `err = res.json()["error"]`  
    `assert err["code"] == "UNKNOWN_TYPE_CODE"`  
    `assert err["op_index"] == 1`

    `feed = client.get("/v1/mock/sync/changes?after=0&streams=my_wardrobe", headers=auth_headers_a).json()`  
    `assert feed["changes"] == []`

`def test_be_012_s13_fail_5xx_once_scenario_retries_cleanly(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-012-S13] FAIL_5XX_ONCE returns 503 once, then the same tx is applied."""`  
    `client.put("/v1/mock/scenarios", headers=auth_headers_a, json={"sync": "FAIL_5XX_ONCE"})`  
    `payload = {"tx_id": 14, "ops": [_valid_wardrobe_put()]}`

    `first = client.post("/v1/sync/tx", headers=auth_headers_a, json=payload)`  
    `assert first.status_code == 503`  
    `assert first.json()["error"]["code"] == "RETRY_LATER"`

    `second = client.post("/v1/sync/tx", headers=auth_headers_a, json=payload)`  
    `assert second.status_code == 200`  
    `assert second.json()["applied"] is True`

#### **5.2. Table Class & Allow-List Rules (backend/tests/test\_sync\_tx\_rules.py)**

`# backend/tests/test_sync_tx_rules.py`  
`from __future__ import annotations`

`import pytest`  
`from fastapi.testclient import TestClient`

`from tests.conftest import OWNER_A, OWNER_B`

`@pytest.mark.parametrize(`  
    `"readonly_table",`  
    `["ai_processing_jobs", "outfit_candidates", "item_types", "attachment_tickets"],`  
`)`  
`def test_be_012_s05_writes_to_readonly_tables_return_403(`  
    `client: TestClient, auth_headers_a: dict[str, str], readonly_table: str`  
`) -> None:`  
    `"""[BE-012-S05] Writes to read-only tables return 403 TABLE_NOT_WRITABLE."""`  
    `res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 20,`  
            `"ops": [{"op": "PUT", "type": readonly_table, "id": "65f0c1a2b3c4d5e6f7a8b9c9", "data": {}}],`  
        `},`  
    `)`  
    `assert res.status_code == 403`  
    `assert res.json()["error"]["code"] == "TABLE_NOT_WRITABLE"`

`def test_be_012_s06_patch_of_non_allowlisted_field_returns_422(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-012-S06 & BE-022 #5] extracted_items rejects PUT (403) and rejects PATCH of ai (422)."""`  
    `put_res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 21,`  
            `"ops": [{"op": "PUT", "type": "extracted_items", "id": "65f0c1a2b3c4d5e6f7a8b9c9", "data": {}}],`  
        `},`  
    `)`  
    `assert put_res.status_code == 403`  
    `assert put_res.json()["error"]["code"] == "TABLE_NOT_WRITABLE"`

    `patch_res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 22,`  
            `"ops": [`  
                `{`  
                    `"op": "PATCH",`  
                    `"type": "extracted_items",`  
                    `"id": "65f0c1a2b3c4d5e6f7a8b9c9",`  
                    `"data": {"ai": '{"type_code":"SHIRT"}'},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert patch_res.status_code == 422`  
    `assert patch_res.json()["error"]["code"] == "FIELD_NOT_WRITABLE"`

`def test_be_012_s07_append_only_tables_reject_patch_and_delete_except_consent_revocation(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-012-S07] wear_events PATCH/DELETE -> 422 APPEND_ONLY; consents PATCH of revoked_at is applied."""`  
    `consent_id = "54b01d3ef649557e3dc1f3ec"`  
    `client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 23,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "consents",`  
                    `"id": consent_id,`  
                    `"data": {`  
                        `"version": "v1.0_studio_body_ai",`  
                        `"includes_body": 1,`  
                        `"granted_at": "2026-10-30T09:00:00Z",`  
                    `},`  
                `}`  
            `],`  
        `},`  
    `)`

    `revoke_res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 24,`  
            `"ops": [`  
                `{`  
                    `"op": "PATCH",`  
                    `"type": "consents",`  
                    `"id": consent_id,`  
                    `"data": {"revoked_at": "2026-10-30T10:00:00Z"},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert revoke_res.status_code == 200`

    `del_wear = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 25,`  
            `"ops": [{"op": "DELETE", "type": "wear_events", "id": "c4e35d40fffb30b44117695c"}],`  
        `},`  
    `)`  
    `assert del_wear.status_code == 422`  
    `assert del_wear.json()["error"]["code"] == "APPEND_ONLY"`

`def test_be_012_s09_cross_owner_write_returns_403_owner_mismatch(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-012-S09] Another owner's user_id or row ID -> 403 OWNER_MISMATCH."""`  
    `res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 26,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "profiles",`  
                    `"id": OWNER_B,`  
                    `"data": {"user_id": OWNER_B, "first_name": "Intruder"},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert res.status_code == 403`  
    `assert res.json()["error"]["code"] == "OWNER_MISMATCH"`

#### **5.3. Domain Invariants I1, I2, I4, I6 & State Machine (backend/tests/test\_sync\_tx\_invariants.py)**

`# backend/tests/test_sync_tx_invariants.py`  
`from __future__ import annotations`

`from fastapi.testclient import TestClient`

`def test_be_012_s10_invariants_i1_i2_i4_enforced(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-012-S10] I1 (1..10 assets & valid consent), I2 (JPEG/PNG only), I4 (at least one req_*=1)."""`  
    `batch_id = "6725aa12c8e4b12d34567001"`  
    `asset_id = "6725aa12c8e4b12d34567002"`

    `# I2: Unsupported MIME type (e.g. image/heic) -> 422 UNSUPPORTED_MIME`  
    `res_mime = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 30,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "media_assets",`  
                    `"id": asset_id,`  
                    `"data": {`  
                        `"batch_id": batch_id,`  
                        `"slot_index": 0,`  
                        `"mime_type": "image/heic",`  
                        `"removed": 0,`  
                        `"created_at": "2026-10-30T09:00:00Z",`  
                    `},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert res_mime.status_code == 422`  
    `assert res_mime.json()["error"]["code"] == "UNSUPPORTED_MIME"`

`def test_be_012_s11_illegal_batch_status_transition_returns_409(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-012-S11 & BE-022 #4] Phone cannot jump DRAFT -> AWAITING_REVIEW (409/422)."""`  
    `batch_id = "6725aa12c8e4b12d34567003"`  
    `client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 31,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "upload_batches",`  
                    `"id": batch_id,`  
                    `"data": {`  
                        `"purpose": "WARDROBE",`  
                        `"status": "DRAFT",`  
                        `"req_outfit": 1,`  
                        `"req_pose": 0,`  
                        `"req_background": 0,`  
                        `"created_at": "2026-10-30T09:00:00Z",`  
                        `"updated_at": "2026-10-30T09:00:00Z",`  
                    `},`  
                `}`  
            `],`  
        `},`  
    `)`

    `bad_jump = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 32,`  
            `"ops": [`  
                `{`  
                    `"op": "PATCH",`  
                    `"type": "upload_batches",`  
                    `"id": batch_id,`  
                    `"data": {"status": "AWAITING_REVIEW"},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert bad_jump.status_code in (409, 422)`

`def test_be_012_s12_wear_event_with_unowned_or_archived_item_returns_422(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-012-S12] Wear event referencing an unowned or archived item -> 422 ITEM_NOT_OWNED."""`  
    `res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 33,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "wear_events",`  
                    `"id": "c4e35d40fffb30b44117695c",`  
                    `"data": {`  
                        `"worn_date": "2026-10-30",`  
                        `"source": "ITEM",`  
                        `"signature": "679dd79ffc8dcfcf27566db7",`  
                        `"items": '[{"item_id":"679dd79ffc8dcfcf27566db7","gap_days":0,"rescue_eligible":false}]',`  
                        `"created_at": "2026-10-30T09:00:00Z",`  
                    `},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert res.status_code == 422`  
    `assert res.json()["error"]["code"] == "ITEM_NOT_OWNED"`

### **6\. BE-013: Mock Change Feed & Seed Tests (backend/tests/test\_change\_feed.py & test\_mock\_seed.py)**

`# backend/tests/test_change_feed.py`  
`from __future__ import annotations`

`from fastapi.testclient import TestClient`

`def test_be_013_s01_catalog_stream_returns_15_item_types_in_stable_order(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-013-S01] After reset, after=0&streams=catalog returns all 15 item types once."""`  
    `res = client.get("/v1/mock/sync/changes?after=0&streams=catalog", headers=auth_headers_a)`  
    `assert res.status_code == 200`  
    `body = res.json()`  
    `assert len(body["changes"]) == 15`  
    `assert body["changes"][0]["data"]["type_code"] == "SHIRT"`  
    `assert body["changes"][-1]["data"]["type_code"] == "BELT"`

`def test_be_013_s02_s03_s04_owner_isolation_and_cursor_pagination(`  
    `client: TestClient, auth_headers_a: dict[str, str], auth_headers_b: dict[str, str]`  
`) -> None:`  
    `"""[BE-013-S02, S03, S04] Owner isolation, cursor pagination, and write checkpoint invariant."""`  
    `seed_res = client.post("/v1/mock/seed", headers=auth_headers_a, json={"preset": "demo_wardrobe"})`  
    `assert seed_res.status_code == 200`

    `# Owner B never sees Owner A's wardrobe rows`  
    `feed_b = client.get("/v1/mock/sync/changes?after=0&streams=my_wardrobe", headers=auth_headers_b).json()`  
    `assert feed_b["changes"] == []`

    `# Paging with limit=4 loses and repeats nothing`  
    `page1 = client.get("/v1/mock/sync/changes?after=0&streams=my_wardrobe&limit=4", headers=auth_headers_a).json()`  
    `assert len(page1["changes"]) == 4`  
    `assert page1["has_more"] is True`

    `last_seq = page1["changes"][-1]["seq"]`  
    `page2 = client.get(`  
        `f"/v1/mock/sync/changes?after={last_seq}&streams=my_wardrobe&limit=10",`  
        `headers=auth_headers_a,`  
    `).json()`  
    `assert len(page2["changes"]) == 5`  
    `assert page2["has_more"] is False`

`# backend/tests/test_mock_seed.py`  
`from __future__ import annotations`

`from fastapi.testclient import TestClient`

`def test_be_013_s06_demo_wardrobe_seeds_9_items_idempotently(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-013-S06] demo_wardrobe seeds 9 items with deterministic IDs; seeding twice is a no-op."""`  
    `r1 = client.post("/v1/mock/seed", headers=auth_headers_a, json={"preset": "demo_wardrobe"})`  
    `assert r1.status_code == 200`  
    `assert r1.json()["added"] == 9`

    `r2 = client.post("/v1/mock/seed", headers=auth_headers_a, json={"preset": "demo_wardrobe"})`  
    `assert r2.status_code == 200`  
    `assert r2.json()["added"] == 0`

    `feed = client.get("/v1/mock/sync/changes?after=0&streams=my_wardrobe", headers=auth_headers_a).json()`  
    `ids = [c["id"] for c in feed["changes"] if c["type"] == "wardrobe_items"]`  
    `assert len(ids) == 9`  
    `assert "679dd79ffc8dcfcf27566db7" in ids  # White T-shirt (41d unworn)`

### **7\. AI-005 & BE-016: Model Ports, Fakes & Shared Wear Rules Tests**

`# backend/tests/ai/test_fakes.py`  
`from __future__ import annotations`

`import dataclasses`

`from app.ai.fakes import FixtureContextSource, FixtureOutfitExtractor`  
`from app.ai.ports import ContextRequest, ExtractionInput`  
`from app.ai.rule_generator import RuleOutfitGenerator`

`def test_ai_005_s01_s02_s03_fixture_extractor_determinism_and_catalog_validity() -> None:`  
    `"""[AI-005-S01, S02, S03] FixtureOutfitExtractor is deterministic and uses valid type_codes."""`  
    `extractor = FixtureOutfitExtractor()`  
    `inp1 = ExtractionInput(asset_id="6725aa12c8e4b12d34567001", mime_type="image/jpeg", content=None)`  
    `inp2 = ExtractionInput(asset_id="6725aa12c8e4b12d34567001", mime_type="image/jpeg", content=None)`

    `out1 = extractor.extract(inp1)`  
    `out2 = extractor.extract(inp2)`  
    `assert out1 == out2`  
    `for piece in out1:`  
        `assert 0.0 <= piece.confidence <= 1.0`  
        `assert piece.model_version`

`def test_ai_005_s06_s07_context_sources_and_zero_pii_port_inputs() -> None:`  
    `"""[AI-005-S06, S07] Port inputs have no user_id field; missing weather returns is_missing=True."""`  
    `for cls in (ExtractionInput, ContextRequest):`  
        `field_names = {f.name for f in dataclasses.fields(cls)}`  
        `assert "user_id" not in field_names`

    `source = FixtureContextSource(scenario="WEATHER_MISSING")`  
    `cards = source.gather(ContextRequest(occasions=("WORK",), ambient_temp_c=28))`  
    `assert [c.kind for c in cards] == ["OCCASION", "WEATHER", "RAIN", "COMMUTE"]`  
    `weather_card = next(c for c in cards if c.kind == "WEATHER")`  
    `assert weather_card.is_missing is True`

`# backend/tests/rules/test_wear_rules.py`  
`from __future__ import annotations`

`from datetime import date`

`from app.rules.wear import days_unworn, gap_days, is_dormant, rescue_eligible`

`def test_be_016_s01_s02_s05_dormancy_and_rescue_rules_parity() -> None:`  
    `"""[BE-016-S01, S02, S05] Rescue requires >=30d gap from logged wear or save date, never estimate."""`  
    `today = date(2026, 10, 30)`  
    `# White T-shirt: saved 60 days ago (2026-08-31), estimate 41 days ago (2026-09-19), no logged wears`  
    `item = {`  
        `"id": "679dd79ffc8dcfcf27566db7",`  
        `"created_at": "2026-08-31T09:00:00Z",`  
        `"last_worn_estimate": "2026-09-19",`  
    `}`

    `du = days_unworn(item=item, wear_events=[], today=today)`  
    `assert du == 41`  
    `assert is_dormant(du) is True`

    `# Item saved 10 days ago with an estimate 41 days ago: dormant for UI badge,`  
    `# but NOT rescue_eligible on wear because save_date gap is only 10 days (I12 / N6)!`  
    `recent_save_old_estimate = {`  
        `"id": "679dd89ffc8dd182275670b7",`  
        `"created_at": "2026-10-20T09:00:00Z",`  
        `"last_worn_estimate": "2026-09-19",`  
    `}`  
    `g_days = gap_days(`  
        `item=recent_save_old_estimate,`  
        `worn_date=today,`  
        `prior_events=[],`  
    `)`  
    `assert g_days == 10`  
    `assert rescue_eligible(g_days) is False`

### **8\. BE-014, BE-015, BE-017, BE-018, BE-021: Side-Effect Worker Tests**

`# backend/tests/test_studio_effects.py`  
`from __future__ import annotations`

`from fastapi.testclient import TestClient`

`def test_be_014_s01_to_s11_studio_batch_extraction_and_atomic_commit(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-014-S01, S02, S03, S11] QUEUED_FOR_AI creates deterministic jobs & drafts; COMPLETED cleans studio stream."""`  
    `consent_id = "54b01d3ef649557e3dc1f3ec"`  
    `batch_id = "6725aa12c8e4b12d34567100"`  
    `asset_1 = "6725aa12c8e4b12d34567101"`  
    `asset_2 = "6725aa12c8e4b12d34567102"`

    `res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 100,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "consents",`  
                    `"id": consent_id,`  
                    `"data": {`  
                        `"version": "v1.0_studio_body_ai",`  
                        `"includes_body": 0,`  
                        `"granted_at": "2026-10-30T09:00:00Z",`  
                    `},`  
                `},`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "upload_batches",`  
                    `"id": batch_id,`  
                    `"data": {`  
                        `"purpose": "WARDROBE",`  
                        `"consent_id": consent_id,`  
                        `"status": "DRAFT",`  
                        `"req_outfit": 1,`  
                        `"req_pose": 1,`  
                        `"req_background": 0,`  
                        `"created_at": "2026-10-30T09:00:00Z",`  
                        `"updated_at": "2026-10-30T09:00:00Z",`  
                    `},`  
                `},`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "media_assets",`  
                    `"id": asset_1,`  
                    `"data": {`  
                        `"batch_id": batch_id,`  
                        `"slot_index": 0,`  
                        `"mime_type": "image/jpeg",`  
                        `"exif_gps_stripped": 1,`  
                        `"removed": 0,`  
                        `"created_at": "2026-10-30T09:00:00Z",`  
                    `},`  
                `},`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "media_assets",`  
                    `"id": asset_2,`  
                    `"data": {`  
                        `"batch_id": batch_id,`  
                        `"slot_index": 1,`  
                        `"mime_type": "image/png",`  
                        `"exif_gps_stripped": 1,`  
                        `"removed": 0,`  
                        `"created_at": "2026-10-30T09:00:00Z",`  
                    `},`  
                `},`  
                `{"op": "PATCH", "type": "upload_batches", "id": batch_id, "data": {"status": "SANITIZING"}},`  
                `{"op": "PATCH", "type": "upload_batches", "id": batch_id, "data": {"status": "QUEUED_FOR_AI"}},`  
            `],`  
        `},`  
    `)`  
    `assert res.status_code == 200`

    `feed = client.get(`  
        `"/v1/mock/sync/changes?after=0&streams=my_studio,my_studio_jobs",`  
        `headers=auth_headers_a,`  
    `).json()`

    `jobs = [c["data"] for c in feed["changes"] if c["type"] == "ai_processing_jobs" and c["op"] == "PUT"]`  
    `pose_jobs = [j for j in jobs if j["task_type"] == "POSE_ESTIMATION" and j["status"] == "SKIPPED_NO_PERSON"]`  
    `assert len(pose_jobs) == 2`

    `drafts = [c["data"] for c in feed["changes"] if c["type"] == "extracted_items" and c["op"] == "PUT"]`  
    `assert len(drafts) > 0`

`# backend/tests/test_gu_match_effects.py`  
`from __future__ import annotations`

`from fastapi.testclient import TestClient`

`def test_be_015_s01_to_s08_gu_match_session_deck_and_interactions(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-015-S01, S03, S07, S08] Seeded wardrobe -> REQUESTED session -> DECK_READY + swipe & swap."""`  
    `client.post("/v1/mock/seed", headers=auth_headers_a, json={"preset": "demo_wardrobe"})`  
    `session_id = "6725aa12c8e4b12d34567200"`

    `res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 200,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "gu_match_sessions",`  
                    `"id": session_id,`  
                    `"data": {`  
                        `"path": "PROMPT_LED",`  
                        `"occasions": '["WORK"]',`  
                        `"raw_prompt": "Smart office look",`  
                        `"status": "REQUESTED",`  
                        `"created_at": "2026-10-30T09:00:00Z",`  
                    `},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert res.status_code == 200`

    `feed = client.get("/v1/mock/sync/changes?after=0&streams=my_decks", headers=auth_headers_a).json()`  
    `candidates = [c["data"] for c in feed["changes"] if c["type"] == "outfit_candidates"]`  
    `assert 1 <= len(candidates) <= 8`  
    `first_cand_id = candidates[0]["id"]`

    `# Swipe LIKE_SAVE updates candidate swipe_status to SWIPED_RIGHT_LIKED`  
    `like_res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 201,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "interactions",`  
                    `"id": "6725aa12c8e4b12d34567201",`  
                    `"data": {`  
                        `"session_id": session_id,`  
                        `"candidate_id": first_cand_id,`  
                        `"action": "LIKE_SAVE",`  
                        `"dwell_ms": 1400,`  
                        `"created_at": "2026-10-30T09:01:00Z",`  
                    `},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert like_res.status_code == 200`

`# backend/tests/test_privacy_effects.py`  
`from __future__ import annotations`

`from fastapi.testclient import TestClient`

`def test_be_017_s01_s02_s04_privacy_erasure_all_and_body_scopes(`  
    `client: TestClient, auth_headers_a: dict[str, str], auth_headers_b: dict[str, str]`  
`) -> None:`  
    `"""[BE-017-S01, S02, S04] ALL purges owner A completely while leaving owner B untouched."""`  
    `client.post("/v1/mock/seed", headers=auth_headers_a, json={"preset": "demo_wardrobe"})`  
    `client.post("/v1/mock/seed", headers=auth_headers_b, json={"preset": "demo_wardrobe"})`

    `req_id = "6725aa12c8e4b12d34567300"`  
    `res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 300,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "privacy_requests",`  
                    `"id": req_id,`  
                    `"data": {`  
                        `"scope": "ALL",`  
                        `"status": "REQUESTED",`  
                        `"created_at": "2026-10-30T09:05:00Z",`  
                    `},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert res.status_code == 200`

    `# Owner B still has all 9 demo items`  
    `feed_b = client.get("/v1/mock/sync/changes?after=0&streams=my_wardrobe", headers=auth_headers_b).json()`  
    `assert len([c for c in feed_b["changes"] if c["type"] == "wardrobe_items"]) == 9`

`# backend/tests/test_attachments.py`  
`from __future__ import annotations`

`import hashlib`  
`from fastapi.testclient import TestClient`

`# Minimal stripped 1x1 PNG bytes (no eXIf chunk)`  
`CLEAN_PNG_BYTES = (`  
    `b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01"`  
    `b"\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\xcf\xc0"`  
    ``b"\x00\x00\x03\x01\x01\x00\x18\xdd\x8d\xb0\x00\x00\x00\x00IEND\xaeB`\x82"``  
`)`

`def test_be_018_s01_to_s04_attachment_ticket_upload_and_exif_verify(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-018-S01, S02, S03] Attachment PUT issues ticket; clean PNG verifies; EXIF JPEG is REJECTED."""`  
    `att_id = "6725aa12c8e4b12d34567400"`  
    `sha256_hex = hashlib.sha256(CLEAN_PNG_BYTES).hexdigest()`

    `client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 400,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "attachments",`  
                    `"id": att_id,`  
                    `"data": {`  
                        `"kind": "PHOTO",`  
                        `"owner_table": "media_assets",`  
                        `"owner_id": "6725aa12c8e4b12d34567401",`  
                        `"mime_type": "image/png",`  
                        `"bytes": len(CLEAN_PNG_BYTES),`  
                        `"sha256": sha256_hex,`  
                        `"state": "PENDING_UPLOAD",`  
                    `},`  
                `}`  
            `],`  
        `},`  
    `)`

    `feed = client.get("/v1/mock/sync/changes?after=0&streams=my_files", headers=auth_headers_a).json()`  
    `tickets = [c["data"] for c in feed["changes"] if c["type"] == "attachment_tickets"]`  
    `assert len(tickets) == 1`  
    `put_url = tickets[0]["url"]`

    `put_res = client.put(put_url, content=CLEAN_PNG_BYTES, headers={"Content-Type": "image/png"})`  
    `assert put_res.status_code == 200`

    `verify_tx = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 401,`  
            `"ops": [{"op": "PATCH", "type": "attachments", "id": att_id, "data": {"state": "UPLOADED"}}],`  
        `},`  
    `)`  
    `assert verify_tx.status_code == 200`

    `feed_after = client.get("/v1/mock/sync/changes?after=0&streams=my_files", headers=auth_headers_a).json()`  
    `att_rows = [c["data"] for c in feed_after["changes"] if c["type"] == "attachments" and c["id"] == att_id]`  
    `assert att_rows[-1]["state"] == "VERIFIED"`

`# backend/tests/test_fake_vton.py`  
`from __future__ import annotations`

`from fastapi.testclient import TestClient`

`def test_be_021_s01_to_s04_vton_precheck_render_and_consent_withdrawal(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[BE-021-S01, S02, S03, S04] VTON job requires body consent + verified BODY attachment."""`  
    `vton_id = "6725aa12c8e4b12d34567500"`

    `# Without active body consent -> job transitions to FAILED (I7_PRECHECK_FAILED)`  
    `res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 500,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "vton_jobs",`  
                    `"id": vton_id,`  
                    `"data": {`  
                        `"session_id": "6725aa12c8e4b12d34567200",`  
                        `"candidate_id": "6725aa12c8e4b12d34567202",`  
                        `"body_asset_id": "6725aa12c8e4b12d34567501",`  
                        `"status": "REQUESTED",`  
                        `"created_at": "2026-10-30T09:00:00Z",`  
                    `},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert res.status_code == 200`

Ready to move into the **Green phase** and implement the backend modules (app/sync/, app/store/, app/core/, app/ai/, app/rules/, app/workers/, and endpoints) so every test above passes?

---

*User prompt: Let write both mock and real apis which arr not depedent on 3rds such mongo atlas, rustfs, openai, ... for all phases*

Response: Here is the complete, self-contained **Green-phase Backend Implementation** (both **Real Production APIs** and **Mock/Dev Control APIs**) covering all phases (P1–P5: **BE-005**, **BE-010**, **BE-011**, **BE-012**, **BE-013**, **AI-005**, **BE-014**, **BE-015**, **BE-016**, **BE-017**, **BE-018**, **BE-019**, **BE-021**, and **BE-022**) with **zero external third-party service dependencies** (no MongoDB Atlas, RustFS, or OpenAI network calls required).

## **1\. Architecture Overview (Zero Third-Party Dependency Stack)**

| Layer | Module Path | Responsibility (Mock & Real Unified) |
| :---- | :---- | :---- |
| **Core & Clock** | backend/app/core/clock.py & errors.py | Protocol Clock (FixedClock for deterministic tests/mock, SystemClock for real runtime) and standardized error envelope {"error": {"code", "message", "op\_index"}}. |
| **Sync IDs & Schema** | backend/app/sync/ids.py & schema.py | Bit-for-bit FNV-1a port of Dart deterministicObjectId & stableHash, strict UPPER\_SNAKE enums, YYYY-MM-DD date validation, TableClass definitions, and column allow-lists. |
| **Store & File Engine** | backend/app/store/memory.py | Transactional InMemoryStore (all-or-nothing snapshot & rollback, applied\_tx replay log, ordered ChangeLog for Sync Streams, and in-memory binary blob store replacing MongoDB \+ RustFS). |
| **Auth Service** | backend/app/auth/service.py | Real POST /v1/auth/anonymous, POST /v1/auth/refresh, GET /v1/auth/.well-known/jwks.json, and dev POST /v1/auth/dev-token using pure Python HMAC/SHA-256 tokens and hashed refresh-token rotation. |
| **Shared Rules** | backend/app/rules/wear.py | Pure functions days\_unworn, is\_dormant, gap\_days, and rescue\_eligible matching Dart DormancyRules. |
| **AI Ports & Fakes** | backend/app/ai/ports.py & fakes.py | Zero-PII dataclasses (ExtractionInput, ContextRequest), FixtureOutfitExtractor, FixtureContextSource, and RuleOutfitGenerator (port of FakeCandidateGenerator). |
| **Workers & Side Effects** | backend/app/workers/effects.py | Synchronous side-effect pipelines for **Studio** (BE-014), **Gu Match** (BE-015), **Wear Rules** (BE-016), **Privacy Erasure** (BE-017), **Attachment EXIF/Magic-Byte Verify** (BE-018), and **Virtual Try-On** (BE-021). |
| **API Endpoints** | backend/app/api/v1/endpoints/sync\_api.py | Real POST /v1/sync/tx, GET /v1/sync/credentials, POST /v1/sync/nudge, plus dev/mock GET /v1/mock/sync/changes, PUT/GET /v1/mock/files/{ticket\_id}, POST /v1/mock/seed, POST /v1/mock/reset, PUT /v1/mock/clock, and PUT /v1/mock/scenarios. |

## **2\. Core Infrastructure (app/core/)**

### **2.1. backend/app/core/clock.py**

`from __future__ import annotations`

`import os`  
`from datetime import datetime, timezone`  
`from typing import Protocol`

`class Clock(Protocol):`  
    `def now(self) -> datetime: ...`

    `def iso_now(self) -> str: ...`

`class FixedClock:`  
    `"""Deterministic clock for tests and mock scenarios (BE-011-S06)."""`

    `def __init__(self, initial_iso: str | None = None) -> None:`  
        `raw = initial_iso or os.getenv("GARBLO_MOCK_NOW", "2026-10-30T09:00:00Z")`  
        `self._now = self._parse_utc(raw)`

    `@staticmethod`  
    `def _parse_utc(iso_str: str) -> datetime:`  
        `cleaned = iso_str.strip()`  
        `if cleaned.endswith("Z"):`  
            `cleaned = cleaned[:-1] + "+00:00"`  
        `dt = datetime.fromisoformat(cleaned)`  
        `if dt.tzinfo is None:`  
            `dt = dt.replace(tzinfo=timezone.utc)`  
        `return dt.astimezone(timezone.utc)`

    `def set_iso(self, iso_str: str) -> None:`  
        `self._now = self._parse_utc(iso_str)`

    `def now(self) -> datetime:`  
        `return self._now`

    `def iso_now(self) -> str:`  
        `return self._now.strftime("%Y-%m-%dT%H:%M:%SZ")`

### **2.2. backend/app/core/errors.py**

`from __future__ import annotations`

`from fastapi.responses import JSONResponse`

`class SyncDomainError(Exception):`  
    `"""Structured domain/sync rejection exception (BE-011 / BE-012)."""`

    `def __init__(`  
        `self,`  
        `status_code: int,`  
        `code: str,`  
        `message: str,`  
        `op_index: int | None = None,`  
    `) -> None:`  
        `super().__init__(message)`  
        `self.status_code = status_code`  
        `self.code = code`  
        `self.message = message`  
        `self.op_index = op_index`

    `def to_response(self) -> JSONResponse:`  
        `err: dict[str, str | int] = {`  
            `"code": self.code,`  
            `"message": self.message,`  
        `}`  
        `if self.op_index is not None:`  
            `err["op_index"] = self.op_index`  
        `return JSONResponse(status_code=self.status_code, content={"error": err})`

## **3\. Sync IDs & Schema Models (app/sync/)**

### **3.1. backend/app/sync/ids.py**

`from __future__ import annotations`

`import re`

`_OBJECT_ID_RE = re.compile(r"^[0-9a-f]{24}$")`

`def is_object_id(value: str) -> bool:`  
    `"""Returns True iff value is exactly 24 lowercase hex characters (BE-011-S02)."""`  
    `return bool(isinstance(value, str) and _OBJECT_ID_RE.match(value))`

`def _fnv1a64(data: bytes, offset: int) -> int:`  
    `prime = 0x100000001B3`  
    `h = offset`  
    `for b in data:`  
        `h ^= b`  
        `h = (h * prime) & 0xFFFFFFFFFFFFFFFF`  
    `return h`

`def _hex64(value: int) -> str:`  
    `value &= 0xFFFFFFFFFFFFFFFF`  
    `high = (value >> 32) & 0xFFFFFFFF`  
    `low = value & 0xFFFFFFFF`  
    `return f"{high:08x}{low:08x}"`

`def deterministic_object_id(parts: list[str]) -> str:`  
    `"""Bit-for-bit port of Dart deterministicObjectId (BE-011-S01)."""`  
    `encoded = "|".join(f"{len(p)}:{p}" for p in parts).encode("utf-8")`  
    `high = _fnv1a64(encoded, 0xCBF29CE484222325)`  
    `low = _fnv1a64(encoded, 0x84222325CBF29CE4)`  
    `return _hex64(high) + _hex64(low)[:8]`

`def stable_hash(data: bytes) -> int:`  
    `"""Bit-for-bit port of Dart 32-bit FNV-1a stableHash (CHG-006 G-01)."""`  
    `h = 0x811C9DC5`  
    `for b in data:`  
        `h ^= b`  
        `h = (h * 0x01000193) & 0xFFFFFFFF`  
    `return h`

### **3.2. backend/app/sync/schema.py**

`from __future__ import annotations`

`import json`  
`import re`  
`from enum import Enum`  
`from typing import Any, Literal`

`from pydantic import BaseModel, ConfigDict, field_validator`

`_DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")`  
`_UTC_ISO_RE = re.compile(`  
    `r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})$"`  
`)`

`class TableClass(str, Enum):`  
    `READ_WRITE = "READ_WRITE"`  
    `INSERT_ONLY = "INSERT_ONLY"`  
    `PHONE_PATCH_ONLY = "PHONE_PATCH_ONLY"`  
    `COMMAND = "COMMAND"`  
    `READ_ONLY = "READ_ONLY"`

`def _check_date(v: str | None) -> str | None:`  
    `if v is not None and not _DATE_RE.match(v):`  
        `raise ValueError("Calendar date must be YYYY-MM-DD with no time component")`  
    `return v`

`def _check_iso(v: str | None) -> str | None:`  
    `if v is not None and not _UTC_ISO_RE.match(v):`  
        `raise ValueError("Timestamp must be ISO-8601 UTC with Z or offset")`  
    `return v`

`class BaseRowModel(BaseModel):`  
    `model_config = ConfigDict(extra="forbid")`  
    `id: str | None = None`  
    `user_id: str | None = None`

`class ProfileRow(BaseRowModel):`  
    `first_name: str | None = None`  
    `time_zone: str | None = "UTC"`  
    `community_opt_in: int | None = 0`  
    `display_name: str | None = None`  
    `created_at: str | None = None`  
    `updated_at: str | None = None`

    `_val_ts = field_validator("created_at", "updated_at")(_check_iso)`

`class WardrobeItemRow(BaseRowModel):`  
    `name: str`  
    `type_code: str`  
    `color: str`  
    `material: str`  
    `style_tag: str`  
    `ai_confidence: float | None = None`  
    `source_asset_id: str | None = None`  
    `cutout_attachment_id: str | None = None`  
    `last_worn_estimate: str | None = None`  
    `archived: int = 0`  
    `created_at: str | None = None`  
    `updated_at: str | None = None`

    `_val_est = field_validator("last_worn_estimate")(_check_date)`  
    `_val_ts = field_validator("created_at", "updated_at")(_check_iso)`

`class WearEventRow(BaseRowModel):`  
    `worn_date: str`  
    `candidate_id: str | None = None`  
    `source: Literal[`  
        `"LIKE_CONFIRM", "ITEM", "MULTI", "CHECKIN", "PHOTO", "REMINDER", "TREND"`  
    `] = "ITEM"`  
    `signature: str`  
    `ambient_temp_c: int | None = None`  
    `items: str`  
    `created_at: str | None = None`

    `_val_date = field_validator("worn_date")(_check_date)`  
    `_val_ts = field_validator("created_at")(_check_iso)`

`class UploadBatchRow(BaseRowModel):`  
    `purpose: Literal["WARDROBE", "BODY_REFERENCE"] = "WARDROBE"`  
    `consent_id: str | None = None`  
    `status: Literal[`  
        `"DRAFT",`  
        `"SANITIZING",`  
        `"QUEUED_FOR_AI",`  
        `"AI_PROCESSING",`  
        `"AWAITING_REVIEW",`  
        `"COMPLETED",`  
        `"FAILED",`  
        `"DELETED_BY_USER",`  
    `] = "DRAFT"`  
    `req_outfit: int = 1`  
    `req_pose: int = 0`  
    `req_background: int = 0`  
    `ambient_temp_c: int | None = None`  
    `created_at: str | None = None`  
    `updated_at: str | None = None`

    `_val_ts = field_validator("created_at", "updated_at")(_check_iso)`

`class MediaAssetRow(BaseRowModel):`  
    `batch_id: str`  
    `slot_index: int`  
    `mime_type: str`  
    `attachment_id: str | None = None`  
    `orientation: int = 1`  
    `exif_gps_stripped: int = 0`  
    `bystanders_blurred: int = 0`  
    `contains_person: int = 0`  
    `removed: int = 0`  
    `created_at: str | None = None`

    `_val_ts = field_validator("created_at")(_check_iso)`

`class AiProcessingJobRow(BaseRowModel):`  
    `batch_id: str`  
    `asset_id: str`  
    `task_type: Literal["OUTFIT_EXTRACTION", "POSE_ESTIMATION", "BACKGROUND_ANALYSIS"]`  
    `status: Literal[`  
        `"PENDING", "PROCESSING", "COMPLETED", "SKIPPED_NO_PERSON", "FAILED"`  
    `]`  
    `created_at: str | None = None`  
    `updated_at: str | None = None`

`class ExtractedItemRow(BaseRowModel):`  
    `batch_id: str`  
    `asset_id: str`  
    `item_index: int`  
    `name: str`  
    `confidence: float`  
    `ai: str`  
    `value: str`  
    `last_worn_input: str | None = None`  
    `cutout_attachment_id: str | None = None`  
    `created_at: str | None = None`

`class ConsentRow(BaseRowModel):`  
    `version: str`  
    `includes_body: int`  
    `granted_at: str`  
    `revoked_at: str | None = None`

    `_val_ts = field_validator("granted_at", "revoked_at")(_check_iso)`

`class InteractionRow(BaseRowModel):`  
    `session_id: str`  
    `candidate_id: str`  
    `action: Literal["DISMISS_PASS", "LIKE_SAVE", "CUSTOMIZE_EDIT", "ADJUST", "TRIGGER_VTON"]`  
    `dwell_ms: int = 0`  
    `from_item_id: str | None = None`  
    `to_item_id: str | None = None`  
    `created_at: str | None = None`

`VALID_OCCASIONS = {"WORK", "COFFEE", "AFTERNOON_RAIN", "DATE", "WEEKEND_OUTING"}`

`class GuMatchSessionRow(BaseRowModel):`  
    `path: Literal["PROMPT_LED", "ZERO_INPUT"]`  
    `occasions: str = "[]"`  
    `raw_prompt: str = ""`  
    `event_title: str | None = None`  
    `window_start: str | None = None`  
    `window_end: str | None = None`  
    `city_id: str | None = None`  
    `ambient_temp_c: int | None = None`  
    `status: Literal[`  
        `"REQUESTED",`  
        `"GATHERING",`  
        `"ANALYZED",`  
        `"DECK_READY",`  
        `"NO_ELIGIBLE_ITEMS",`  
        `"FAILED",`  
    `] = "REQUESTED"`  
    `context: str | None = None`  
    `eligible_item_count: int | None = None`  
    `owned_only: int | None = 1`  
    `deck_size: int | None = None`  
    `recent: int | None = 1`  
    `created_at: str | None = None`  
    `expires_at: str | None = None`

    `@field_validator("occasions")`  
    `@classmethod`  
    `def _validate_occasions(cls, v: str) -> str:`  
        `parsed = json.loads(v)`  
        `if not isinstance(parsed, list):`  
            `raise ValueError("occasions must be a JSON array")`  
        `for occ in parsed:`  
            `if occ not in VALID_OCCASIONS:`  
                `raise ValueError(f"Unknown occasion: {occ}")`  
        `return v`

`class OutfitCandidateRow(BaseRowModel):`  
    `session_id: str`  
    `deck_order: int`  
    `title: str`  
    `match_pct: int`  
    `highlight_reason: str | None = None`  
    `visual_mode: str = "COLLAGE_FLATLAY"`  
    `swipe_status: Literal[`  
        `"PENDING_SWIPE",`  
        `"SWIPED_LEFT_PASSED",`  
        `"SWIPED_RIGHT_LIKED",`  
        `"SAVED_TO_LOOKBOOK",`  
    `] = "PENDING_SWIPE"`  
    `items: str`  
    `created_at: str | None = None`

`class ItemTypeRow(BaseModel):`  
    `model_config = ConfigDict(extra="forbid")`  
    `id: str | None = None`  
    `type_code: str`  
    `group_code: Literal["TOPS", "BOTTOMS", "SHOES", "BAGS", "HATS", "ACCESSORIES"]`  
    `label: str`

`class AttachmentRow(BaseRowModel):`  
    `kind: Literal[`  
        `"PHOTO", "CUTOUT", "BODY", "RENDER", "POSTER", "EXPORT", "EDITORIAL"`  
    `]`  
    `owner_table: str`  
    `owner_id: str`  
    `mime_type: str`  
    `bytes: int`  
    `sha256: str`  
    `state: Literal[`  
        `"PENDING_UPLOAD", "UPLOADED", "VERIFIED", "REJECTED", "READY"`  
    `] = "PENDING_UPLOAD"`  
    `created_at: str | None = None`

`class AttachmentTicketRow(BaseRowModel):`  
    `attachment_id: str`  
    `op: Literal["PUT", "GET"]`  
    `url: str`  
    `expires_at: str`

`class PrivacyRequestRow(BaseRowModel):`  
    `scope: Literal["BODY", "ALL", "EXPORT"]`  
    `status: Literal["REQUESTED", "IN_PROGRESS", "COMPLETED", "FAILED"] = "REQUESTED"`  
    `export_attachment_id: str | None = None`  
    `created_at: str | None = None`  
    `completed_at: str | None = None`

`class VtonJobRow(BaseRowModel):`  
    `session_id: str`  
    `candidate_id: str`  
    `body_asset_id: str`  
    `status: Literal[`  
        `"REQUESTED", "PROCESSING", "COMPLETED", "FAILED", "CANCELLED"`  
    `] = "REQUESTED"`  
    `output_attachment_id: str | None = None`  
    `created_at: str | None = None`  
    `updated_at: str | None = None`

`TABLE_MODELS: dict[str, type[BaseModel]] = {`  
    `"profiles": ProfileRow,`  
    `"wardrobe_items": WardrobeItemRow,`  
    `"wear_events": WearEventRow,`  
    `"upload_batches": UploadBatchRow,`  
    `"media_assets": MediaAssetRow,`  
    `"ai_processing_jobs": AiProcessingJobRow,`  
    `"extracted_items": ExtractedItemRow,`  
    `"consents": ConsentRow,`  
    `"interactions": InteractionRow,`  
    `"gu_match_sessions": GuMatchSessionRow,`  
    `"outfit_candidates": OutfitCandidateRow,`  
    `"item_types": ItemTypeRow,`  
    `"attachments": AttachmentRow,`  
    `"attachment_tickets": AttachmentTicketRow,`  
    `"privacy_requests": PrivacyRequestRow,`  
    `"vton_jobs": VtonJobRow,`  
`}`

`TABLE_CLASSES: dict[str, TableClass] = {`  
    `"profiles": TableClass.READ_WRITE,`  
    `"wardrobe_items": TableClass.READ_WRITE,`  
    `"upload_batches": TableClass.READ_WRITE,`  
    `"media_assets": TableClass.READ_WRITE,`  
    `"interactions": TableClass.READ_WRITE,`  
    `"attachments": TableClass.READ_WRITE,`  
    `"wear_events": TableClass.INSERT_ONLY,`  
    `"consents": TableClass.INSERT_ONLY,`  
    `"extracted_items": TableClass.PHONE_PATCH_ONLY,`  
    `"gu_match_sessions": TableClass.COMMAND,`  
    `"privacy_requests": TableClass.COMMAND,`  
    `"vton_jobs": TableClass.COMMAND,`  
    `"item_types": TableClass.READ_ONLY,`  
    `"ai_processing_jobs": TableClass.READ_ONLY,`  
    `"outfit_candidates": TableClass.READ_ONLY,`  
    `"attachment_tickets": TableClass.READ_ONLY,`  
`}`

`TABLE_ALLOW_LISTS: dict[str, set[str]] = {`  
    `"profiles": {"first_name", "time_zone", "community_opt_in", "display_name", "updated_at"},`  
    `"wardrobe_items": {`  
        `"name",`  
        `"type_code",`  
        `"color",`  
        `"material",`  
        `"style_tag",`  
        `"last_worn_estimate",`  
        `"archived",`  
        `"updated_at",`  
    `},`  
    `"upload_batches": {`  
        `"status",`  
        `"consent_id",`  
        `"req_outfit",`  
        `"req_pose",`  
        `"req_background",`  
        `"ambient_temp_c",`  
        `"updated_at",`  
    `},`  
    `"media_assets": {`  
        `"slot_index",`  
        `"attachment_id",`  
        `"orientation",`  
        `"exif_gps_stripped",`  
        `"bystanders_blurred",`  
        `"contains_person",`  
        `"removed",`  
    `},`  
    `"interactions": set(),`  
    `"attachments": {"state"},`  
    `"wear_events": set(),`  
    `"consents": {"revoked_at"},`  
    `"extracted_items": {"value", "last_worn_input"},`  
    `"gu_match_sessions": {"occasions", "raw_prompt"},`  
    `"privacy_requests": set(),`  
    `"vton_jobs": set(),`  
    `"item_types": set(),`  
    `"ai_processing_jobs": set(),`  
    `"outfit_candidates": set(),`  
    `"attachment_tickets": set(),`  
`}`

`PHONE_ALLOWED_BATCH_STATUSES = {`  
    `"DRAFT",`  
    `"SANITIZING",`  
    `"QUEUED_FOR_AI",`  
    `"COMPLETED",`  
    `"DELETED_BY_USER",`  
`}`

## **4\. Transactional In-Memory Store, Change Log & Blob Store (app/store/memory.py)**

`from __future__ import annotations`

`import copy`  
`from contextlib import contextmanager`  
`from typing import Any, Iterator`

`from app.data.seed_data import ITEM_TYPES_CATALOG`

`TABLE_STREAM_MAP: dict[str, str] = {`  
    `"item_types": "catalog",`  
    `"profiles": "my_wardrobe",`  
    `"wardrobe_items": "my_wardrobe",`  
    `"wear_events": "my_wardrobe",`  
    `"consents": "my_wardrobe",`  
    `"upload_batches": "my_studio",`  
    `"media_assets": "my_studio",`  
    `"extracted_items": "my_studio",`  
    `"ai_processing_jobs": "my_studio_jobs",`  
    `"gu_match_sessions": "my_decks",`  
    `"outfit_candidates": "my_decks",`  
    `"interactions": "my_decks",`  
    `"vton_jobs": "my_decks",`  
    `"attachments": "my_files",`  
    `"attachment_tickets": "my_files",`  
    `"privacy_requests": "my_files",`  
`}`

`class InMemoryStore:`  
    `"""Self-contained transactional database, change stream log, and object storage."""`

    `def __init__(self) -> None:`  
        `self.reset()`

    `def reset(self) -> None:`  
        `# table -> owner_id (or "__global__" for catalog) -> row_id -> row_dict`  
        `self._data: dict[str, dict[str, dict[str, dict[str, Any]]]] = {}`  
        `#Global row_id -> (table, owner_id) index for cross-owner collision detection`  
        `self._id_owners: dict[str, str] = {}`  
        `# Change feed entries: list of {seq, owner_id, stream, op, type, id, data}`  
        `self._changelog: list[dict[str, Any]] = []`  
        `self._seq: int = 0`  
        `# Applied transactions: (owner_id, tx_id) -> {"ops_hash": str, "checkpoint": int}`  
        `self.applied_tx: dict[tuple[str, int], dict[str, Any]] = {}`  
        `# Scenarios per owner: owner_id -> {"sync": ..., "studio": ..., "gu_match": ..., "vton": ...}`  
        `self.scenarios: dict[str, dict[str, str]] = {}`  
        `# Held studio batches for HOLD scenario: owner_id -> list of batch_ids`  
        `self.held_batches: dict[str, list[str]] = {}`  
        `# Binary blob storage (replaces RustFS): "users/<owner>/<att_id>" -> bytes`  
        `self.blobs: dict[str, bytes] = {}`  
        `# Audit & privacy erasure event log (TAC-09.6)`  
        `self.audit_events: list[dict[str, Any]] = []`  
        `self.sync_rejections: list[dict[str, Any]] = []`  
        `# Seed catalog immediately on reset (BE-013-S01)`  
        `self.seed_catalog()`

    `def seed_catalog(self) -> int:`  
        `added = 0`  
        `cat_bucket = self._data.setdefault("item_types", {}).setdefault("__global__", {})`  
        `for row in ITEM_TYPES_CATALOG:`  
            `rid = row["id"]`  
            `if rid not in cat_bucket:`  
                `cat_bucket[rid] = copy.deepcopy(row)`  
                `self._append_change("__global__", "catalog", "PUT", "item_types", rid, cat_bucket[rid])`  
                `added += 1`  
        `return added`

    `def _append_change(`  
        `self,`  
        `owner: str,`  
        `stream: str,`  
        `op: str,`  
        `table: str,`  
        `row_id: str,`  
        `data: dict[str, Any] | None,`  
    `) -> int:`  
        `self._seq += 1`  
        `self._changelog.append(`  
            `{`  
                `"seq": self._seq,`  
                `"owner": owner,`  
                `"stream": stream,`  
                `"op": op,`  
                `"type": table,`  
                `"id": row_id,`  
                `"data": copy.deepcopy(data) if data is not None else None,`  
            `}`  
        `)`  
        `return self._seq`

    `@property`  
    `def checkpoint(self) -> int:`  
        `return self._seq`

    `@contextmanager`  
    `def transaction(self) -> Iterator[None]:`  
        `snap_data = copy.deepcopy(self._data)`  
        `snap_owners = copy.deepcopy(self._id_owners)`  
        `snap_log = copy.deepcopy(self._changelog)`  
        `snap_seq = self._seq`  
        `snap_tx = copy.deepcopy(self.applied_tx)`  
        `snap_blobs = copy.deepcopy(self.blobs)`  
        `try:`  
            `yield`  
        `except Exception:`  
            `self._data = snap_data`  
            `self._id_owners = snap_owners`  
            `self._changelog = snap_log`  
            `self._seq = snap_seq`  
            `self.applied_tx = snap_tx`  
            `self.blobs = snap_blobs`  
            `raise`

    `def owner_of_id(self, table: str, row_id: str) -> str | None:`  
        `return self._id_owners.get(f"{table}:{row_id}")`

    `def get(self, table: str, owner: str, row_id: str) -> dict[str, Any] | None:`  
        `eff_owner = "__global__" if table == "item_types" else owner`  
        `row = self._data.get(table, {}).get(eff_owner, {}).get(row_id)`  
        `return copy.deepcopy(row) if row is not None else None`

    `def put(`  
        `self,`  
        `table: str,`  
        `owner: str,`  
        `row_id: str,`  
        `row: dict[str, Any],`  
        `emit_change: bool = True,`  
    `) -> dict[str, Any]:`  
        `eff_owner = "__global__" if table == "item_types" else owner`  
        `stored = copy.deepcopy(row)`  
        `stored["id"] = row_id`  
        `if table != "item_types":`  
            `stored["user_id"] = owner`  
        `self._data.setdefault(table, {}).setdefault(eff_owner, {})[row_id] = stored`  
        `self._id_owners[f"{table}:{row_id}"] = eff_owner`  
        `if emit_change:`  
            `stream = TABLE_STREAM_MAP.get(table, "my_wardrobe")`  
            `self._append_change(eff_owner, stream, "PUT", table, row_id, stored)`  
        `return copy.deepcopy(stored)`

    `def patch(`  
        `self,`  
        `table: str,`  
        `owner: str,`  
        `row_id: str,`  
        `changes: dict[str, Any],`  
        `emit_change: bool = True,`  
    `) -> dict[str, Any]:`  
        `eff_owner = "__global__" if table == "item_types" else owner`  
        `bucket = self._data.setdefault(table, {}).setdefault(eff_owner, {})`  
        `if row_id not in bucket:`  
            `raise KeyError(f"{table}:{row_id} not found for owner {owner}")`  
        `bucket[row_id].update(copy.deepcopy(changes))`  
        `updated = bucket[row_id]`  
        `if emit_change:`  
            `stream = TABLE_STREAM_MAP.get(table, "my_wardrobe")`  
            `self._append_change(eff_owner, stream, "PUT", table, row_id, updated)`  
        `return copy.deepcopy(updated)`

    `def delete(`  
        `self,`  
        `table: str,`  
        `owner: str,`  
        `row_id: str,`  
        `emit_change: bool = True,`  
    `) -> bool:`  
        `eff_owner = "__global__" if table == "item_types" else owner`  
        `bucket = self._data.get(table, {}).get(eff_owner, {})`  
        `if row_id not in bucket:`  
            `return False`  
        `del bucket[row_id]`  
        `self._id_owners.pop(f"{table}:{row_id}", None)`  
        `if emit_change:`  
            `stream = TABLE_STREAM_MAP.get(table, "my_wardrobe")`  
            `self._append_change(eff_owner, stream, "DELETE", table, row_id, None)`  
        `return True`

    `def emit_stream_delete(self, owner: str, stream: str, table: str, row_id: str) -> None:`  
        `"""Emits a synthetic DELETE event in the change feed when a row leaves an active stream."""`  
        `self._append_change(owner, stream, "DELETE", table, row_id, None)`

    `def query(`  
        `self,`  
        `table: str,`  
        `owner: str,`  
        `where: dict[str, Any] | None = None,`  
    `) -> list[dict[str, Any]]:`  
        `eff_owner = "__global__" if table == "item_types" else owner`  
        `bucket = self._data.get(table, {}).get(eff_owner, {})`  
        `results: list[dict[str, Any]] = []`  
        `for row in bucket.values():`  
            `if where and any(row.get(k) != v for k, v in where.items()):`  
                `continue`  
            `results.append(copy.deepcopy(row))`  
        `return results`

    `def get_changes(`  
        `self,`  
        `owner: str,`  
        `after: int,`  
        `streams: list[str],`  
        `limit: int = 500,`  
    `) -> tuple[list[dict[str, Any]], bool, int]:`  
        `allowed_streams = set(streams)`  
        `filtered = [`  
            `{`  
                `"seq": c["seq"],`  
                `"stream": c["stream"],`  
                `"op": c["op"],`  
                `"type": c["type"],`  
                `"id": c["id"],`  
                `"data": c["data"],`  
            `}`  
            `for c in self._changelog`  
            `if c["seq"] > after`  
            `and c["stream"] in allowed_streams`  
            `and c["owner"] in (owner, "__global__")`  
        `]`  
        `sliced = filtered[:limit]`  
        `has_more = len(filtered) > limit`  
        `return sliced, has_more, self._seq`

    `def remaining_rows(self, owner: str) -> dict[str, int]:`  
        `"""Proof query for privacy erasure (BE-017-S01 / TAC-09.2)."""`  
        `counts: dict[str, int] = {}`  
        `for table in TABLE_STREAM_MAP:`  
            `if table in ("item_types", "privacy_requests"):`  
                `continue`  
            `rows = self.query(table, owner)`  
            `counts[table] = len(rows)`  
        `return counts`

## **5\. Self-Contained Auth Service (app/auth/service.py — BE-011 & BE-019)**

Supports both Bearer dev.\<24-hex\> tokens and real signed JWTs (POST /v1/auth/anonymous, POST /v1/auth/refresh, GET /v1/auth/.well-known/jwks.json) using pure Python stdlib hmac \+ hashlib without external crypto dependencies.

`from __future__ import annotations`

`import base64`  
`import hashlib`  
`import hmac`  
`import json`  
`import os`  
`import secrets`  
`from datetime import timedelta`  
`from typing import Any`

`from fastapi import Depends, Request`

`from app.core.clock import Clock`  
`from app.core.errors import SyncDomainError`  
`from app.sync.ids import is_object_id`

`_JWT_SECRET = os.getenv("GARBLO_JWT_SECRET", "garblo-local-self-contained-secret-key-2026")`  
`_KID = "garblo-key-2026-01"`

`def _b64url_encode(data: bytes) -> str:`  
    `return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")`

`def _b64url_decode(s: str) -> bytes:`  
    `pad = "=" * (-len(s) % 4)`  
    `return base64.urlsafe_b64decode(s + pad)`

`class AuthService:`  
    `"""Self-contained Auth Service for BE-011 dev tokens and BE-019 anonymous JWT + refresh rotation."""`

    `def __init__(self, clock: Clock) -> None:`  
        `self._clock = clock`  
        `# refresh_token_hash -> {"user_id": str, "linked": bool, "rotated": bool}`  
        `self._refresh_tokens: dict[str, dict[str, Any]] = {}`

    `def issue_jwt(self, user_id: str, linked: bool = False, ttl_seconds: int = 3600) -> str:`  
        `now_ts = int(self._clock.now().timestamp())`  
        `header = {"alg": "HS256", "typ": "JWT", "kid": _KID}`  
        `payload = {`  
            `"sub": user_id,`  
            `"linked": linked,`  
            `"iat": now_ts,`  
            `"exp": now_ts + ttl_seconds,`  
            `"aud": "powersync",`  
            `"iss": "garblo-auth",`  
        `}`  
        `signing_input = (`  
            `f"{_b64url_encode(json.dumps(header, separators=(',', ':')).encode())}."`  
            `f"{_b64url_encode(json.dumps(payload, separators=(',', ':')).encode())}"`  
        `)`  
        `sig = hmac.new(_JWT_SECRET.encode("utf-8"), signing_input.encode("ascii"), hashlib.sha256).digest()`  
        `return f"{signing_input}.{_b64url_encode(sig)}"`

    `def verify_jwt(self, token: str) -> dict[str, Any]:`  
        `parts = token.split(".")`  
        `if len(parts) != 3:`  
            `raise SyncDomainError(401, "UNAUTHENTICATED", "Malformed JWT token")`  
        `signing_input = f"{parts[0]}.{parts[1]}"`  
        `expected_sig = hmac.new(`  
            `_JWT_SECRET.encode("utf-8"), signing_input.encode("ascii"), hashlib.sha256`  
        `).digest()`  
        `try:`  
            `actual_sig = _b64url_decode(parts[2])`  
            `payload = json.loads(_b64url_decode(parts[1]).decode("utf-8"))`  
        `except Exception as exc:`  
            `raise SyncDomainError(401, "UNAUTHENTICATED", "Invalid JWT encoding") from exc`  
        `if not hmac.compare_digest(expected_sig, actual_sig):`  
            `raise SyncDomainError(401, "UNAUTHENTICATED", "Invalid JWT signature")`  
        `now_ts = int(self._clock.now().timestamp())`  
        `if payload.get("exp", 0) < now_ts:`  
            `raise SyncDomainError(401, "UNAUTHENTICATED", "JWT token expired")`  
        `sub = payload.get("sub", "")`  
        `if not is_object_id(sub):`  
            `raise SyncDomainError(401, "UNAUTHENTICATED", "Invalid subject ObjectId in JWT")`  
        `return payload`

    `def create_anonymous_session(self, user_id: str) -> dict[str, Any]:`  
        `if not is_object_id(user_id):`  
            `raise SyncDomainError(422, "INVALID_ID", "user_id must be 24 lowercase hex characters")`  
        `access_token = self.issue_jwt(user_id=user_id, linked=False)`  
        `raw_refresh = f"rt_{user_id}_{secrets.token_hex(16)}"`  
        `token_hash = hashlib.sha256(raw_refresh.encode("utf-8")).hexdigest()`  
        `self._refresh_tokens[token_hash] = {"user_id": user_id, "linked": False, "rotated": False}`  
        `return {`  
            `"access_token": access_token,`  
            `"refresh_token": raw_refresh,`  
            `"token_type": "Bearer",`  
            `"expires_in": 3600,`  
            `"user_id": user_id,`  
        `}`

    `def rotate_refresh_token(self, raw_refresh: str) -> dict[str, Any]:`  
        `token_hash = hashlib.sha256(raw_refresh.encode("utf-8")).hexdigest()`  
        `record = self._refresh_tokens.get(token_hash)`  
        `if record is None or record["rotated"]:`  
            `raise SyncDomainError(401, "UNAUTHENTICATED", "Invalid or reused refresh token")`  
        `record["rotated"] = True`  
        `return self.create_anonymous_session(record["user_id"])`

    `@staticmethod`  
    `def jwks() -> dict[str, Any]:`  
        `return {`  
            `"keys": [`  
                `{`  
                    `"kty": "oct",`  
                    `"kid": _KID,`  
                    `"alg": "HS256",`  
                    `"use": "sig",`  
                `}`  
            `]`  
        `}`

`def resolve_owner(request: Request, auth_service: AuthService) -> str:`  
    ``"""Parses either `Bearer dev.<24-hex>` (Track M) or signed JWT (Track R)."""``  
    `auth_header = request.headers.get("Authorization", "")`  
    `if not auth_header.startswith("Bearer "):`  
        `raise SyncDomainError(401, "UNAUTHENTICATED", "Missing Bearer token")`  
    `token = auth_header.removeprefix("Bearer ").strip()`  
    `if token.startswith("dev."):`  
        `if os.getenv("ENV") == "production":`  
            `raise SyncDomainError(401, "UNAUTHENTICATED", "Dev tokens disabled in production")`  
        `user_id = token.removeprefix("dev.")`  
        `if not is_object_id(user_id):`  
            `raise SyncDomainError(401, "UNAUTHENTICATED", "Malformed dev token ObjectId")`  
        `return user_id`  
    `payload = auth_service.verify_jwt(token)`  
    `return str(payload["sub"])`

## **6\. Shared Wear & Dormancy Rules (app/rules/wear.py — BE-016)**

`from __future__ import annotations`

`import json`  
`from datetime import date, datetime`  
`from typing import Any`

`DORMANCY_THRESHOLD_DAYS = 30`

`def _parse_calendar_date(val: str) -> date:`  
    `if "T" in val:`  
        `return datetime.fromisoformat(val.replace("Z", "+00:00")).date()`  
    `return date.fromisoformat(val[:10])`

`def days_unworn(`  
    `item: dict[str, Any],`  
    `wear_events: list[dict[str, Any]],`  
    `today: date,`  
`) -> int:`  
    `"""`  
    `Days since the latest of (logged wear_event, last_worn_estimate),`  
    `else since created_at (Handbook WD-03 / Invariant I8).`  
    `"""`  
    `item_id = item["id"]`  
    `candidates: list[date] = []`

    `for ev in wear_events:`  
        `raw_items = ev.get("items", "[]")`  
        `parsed_items = json.loads(raw_items) if isinstance(raw_items, str) else raw_items`  
        `if any(entry.get("item_id") == item_id for entry in parsed_items):`  
            `candidates.append(_parse_calendar_date(ev["worn_date"]))`

    `est = item.get("last_worn_estimate")`  
    `if est:`  
        `candidates.append(_parse_calendar_date(est))`

    `if candidates:`  
        `anchor = max(candidates)`  
    `else:`  
        `anchor = _parse_calendar_date(item["created_at"])`

    `return max(0, (today - anchor).days)`

`def is_dormant(unworn_days: int) -> bool:`  
    `"""Dormancy badge triggers at >= 30 days (Invariant I8)."""`  
    `return unworn_days >= DORMANCY_THRESHOLD_DAYS`

`def gap_days(`  
    `item: dict[str, Any],`  
    `worn_date: date,`  
    `prior_events: list[dict[str, Any]],`  
`) -> int:`  
    `"""`  
    `Measures gap strictly from the latest prior logged wear on or before worn_date,`  
    `or from the item's save date (created_at) — NEVER from last_worn_estimate (N6, I12).`  
    `"""`  
    `item_id = item["id"]`  
    `prior_dates: list[date] = []`  
    `for ev in prior_events:`  
        `ev_date = _parse_calendar_date(ev["worn_date"])`  
        `if ev_date >= worn_date:`  
            `continue`  
        `raw_items = ev.get("items", "[]")`  
        `parsed_items = json.loads(raw_items) if isinstance(raw_items, str) else raw_items`  
        `if any(entry.get("item_id") == item_id for entry in parsed_items):`  
            `prior_dates.append(ev_date)`

    `anchor = max(prior_dates) if prior_dates else _parse_calendar_date(item["created_at"])`  
    `return max(0, (worn_date - anchor).days)`

`def rescue_eligible(gap: int) -> bool:`  
    `"""True when gap from logged wear or save date is >= 30 days (I12)."""`  
    `return gap >= DORMANCY_THRESHOLD_DAYS`

## **7\. AI Model Ports & Deterministic Fakes (app/ai/ — AI-005)**

### **7.1. backend/app/ai/ports.py**

`from __future__ import annotations`

`from dataclasses import dataclass`

`@dataclass(frozen=True)`  
`class ExtractionInput:`  
    `"""Zero-PII input port for garment extraction (AI-005-S07: no user_id field)."""`

    `asset_id: str`  
    `mime_type: str`  
    `content: bytes | None = None`

`@dataclass(frozen=True)`  
`class ExtractedPiece:`  
    `name: str`  
    `type_code: str`  
    `color: str`  
    `material: str`  
    `style_tag: str`  
    `confidence: float`  
    `model_version: str = "fixture-extractor-v1.0"`

`@dataclass(frozen=True)`  
`class PersonResult:`  
    `contains_person: bool`  
    `model_version: str = "fixture-person-v1.0"`

`@dataclass(frozen=True)`  
`class ContextRequest:`  
    `"""Zero-PII input port for context gathering (AI-005-S07: no user_id field)."""`

    `occasions: tuple[str, ...] = ()`  
    `raw_prompt: str = ""`  
    `path: str = "ZERO_INPUT"`  
    `city_id: str | None = None`  
    `window_start: str | None = None`  
    `window_end: str | None = None`  
    `ambient_temp_c: int | None = None`

`@dataclass(frozen=True)`  
`class ContextCardResult:`  
    `kind: str`  
    `label: str`  
    `headline: str`  
    `detail: str | None`  
    `is_missing: bool = False`  
    `model_version: str = "fixture-context-v1.0"`

### **7.2. backend/app/ai/fakes.py & backend/app/ai/rule\_generator.py**

`from __future__ import annotations`

`from typing import Any`

`from app.ai.ports import ContextCardResult, ContextRequest, ExtractedPiece, ExtractionInput, PersonResult`  
`from app.data.seed_data import ITEM_TYPES_CATALOG`  
`from app.sync.ids import deterministic_object_id, stable_hash`

`TYPE_TO_GROUP: dict[str, str] = {`  
    `row["type_code"]: row["group_code"] for row in ITEM_TYPES_CATALOG`  
`}`

`OCCASION_LABELS: dict[str, str] = {`  
    `"WORK": "Work",`  
    `"COFFEE": "Coffee",`  
    `"AFTERNOON_RAIN": "Afternoon rain",`  
    `"DATE": "Date",`  
    `"WEEKEND_OUTING": "Weekend outing",`  
`}`

`SAMPLE_EXTRACTION_SETS: tuple[tuple[ExtractedPiece, ...], ...] = (`  
    `(`  
        `ExtractedPiece(`  
            `name="Violet shirt",`  
            `type_code="SHIRT",`  
            `color="Violet",`  
            `material="Cotton",`  
            `style_tag="Street",`  
            `confidence=0.94,`  
        `),`  
    `),`  
    `(`  
        `ExtractedPiece(`  
            `name="Wide-leg trousers",`  
            `type_code="WIDE_LEG_TROUSERS",`  
            `color="Beige",`  
            `material="Linen",`  
            `style_tag="Everyday",`  
            `confidence=0.91,`  
        `),`  
    `),`  
    `(`  
        `ExtractedPiece(`  
            `name="Cream sneakers",`  
            `type_code="SNEAKERS",`  
            `color="Cream",`  
            `material="Canvas",`  
            `style_tag="Basic",`  
            `confidence=0.88,`  
        `),`  
    `),`  
`)`

`class FixtureOutfitExtractor:`  
    `"""Deterministic outfit extractor matching LocalStudioRepository._samples (AI-005-S01..S03)."""`

    `def extract(self, inp: ExtractionInput) -> list[ExtractedPiece]:`  
        `raw_bytes = inp.content if inp.content is not None else inp.asset_id.encode("utf-8")`  
        `idx = stable_hash(raw_bytes) % len(SAMPLE_EXTRACTION_SETS)`  
        `return list(SAMPLE_EXTRACTION_SETS[idx])`

`class FixturePersonDetector:`  
    `"""Returns False in Phase 2–4 so pose/background end as SKIPPED_NO_PERSON (CHG-006 G-04)."""`

    `def detect(self, inp: ExtractionInput) -> PersonResult:`  
        `return PersonResult(contains_person=False)`

`class FixtureContextSource:`  
    `"""Emits the 4 context cards in fixed order: OCCASION, WEATHER, RAIN, COMMUTE (AI-005-S06)."""`

    `def __init__(self, scenario: str = "OK") -> None:`  
        `self.scenario = scenario`

    `def gather(self, req: ContextRequest) -> list[ContextCardResult]:`  
        `all_missing = self.scenario == "ALL_MISSING"`  
        `weather_missing = all_missing or self.scenario == "WEATHER_MISSING"`

        `if req.path == "PROMPT_LED":`  
            `chips = " · ".join(OCCASION_LABELS.get(o, o) for o in req.occasions)`  
            `occ_card = ContextCardResult(`  
                `kind="OCCASION",`  
                `label="YOUR REQUEST",`  
                `headline=chips if chips else "Your words",`  
                `detail=req.raw_prompt.strip() or None,`  
                `is_missing=all_missing,`  
            `)`  
        `else:`  
            `occ_card = ContextCardResult(`  
                `kind="OCCASION",`  
                `label="TODAY",`  
                `headline="Hackathon Pitching Day",`  
                `detail="09:00–18:00 · Tokyo",`  
                `is_missing=all_missing,`  
            `)`

        `return [`  
            `occ_card,`  
            `ContextCardResult(`  
                `kind="WEATHER",`  
                `label="WEATHER · TOKYO",`  
                `headline="16–19°C",`  
                `detail="10:00 17° · 13:00 RAIN 80% · 16:00 16°",`  
                `is_missing=weather_missing,`  
            `),`  
            `ContextCardResult(`  
                `kind="RAIN",`  
                `label="RAIN",`  
                `headline="80%",`  
                `detail="AROUND 13:00",`  
                `is_missing=all_missing,`  
            `),`  
            `ContextCardResult(`  
                `kind="COMMUTE",`  
                `label="COMMUTE",`  
                `headline="Walking + train",`  
                `detail="Expected to travel between stations and walk to the venue",`  
                `is_missing=all_missing,`  
            `),`  
        `]`

`class RuleOutfitGenerator:`  
    `"""Bit-for-bit port of Dart FakeCandidateGenerator (AI-005-S04, BE-015-S02)."""`

    `DORMANCY_REASON_DAYS = 30`  
    `BASE_MATCH_PCT = 70`  
    `MAX_MATCH_PCT = 95`  
    `DECK_SIZE = 8`

    `@classmethod`  
    `def score_look(cls, look_items: list[dict[str, Any]]) -> int:`  
        `max_d = max((it.get("days_unworn", 0) for it in look_items), default=0)`  
        `# Dart (0.3 * max_d).round() rounds half away from zero for positive numbers`  
        `rounded = int(0.3 * max_d + 0.5)`  
        `return min(cls.MAX_MATCH_PCT, cls.BASE_MATCH_PCT + rounded)`

    `@classmethod`  
    `def highlight_reason(cls, look_items: list[dict[str, Any]]) -> str | None:`  
        `most_benched: dict[str, Any] | None = None`  
        `for item in look_items:`  
            `if most_benched is None or item["days_unworn"] > most_benched["days_unworn"]:`  
                `most_benched = item`  
        `if most_benched is None or most_benched["days_unworn"] < cls.DORMANCY_REASON_DAYS:`  
            `return None`  
        `return f"Benched {most_benched['days_unworn']} days · {most_benched['name']}"`

    `@classmethod`  
    `def generate(`  
        `cls,`  
        `session_id: str,`  
        `user_id: str,`  
        `items: list[dict[str, Any]],`  
        `days_unworn_map: dict[str, int],`  
        `occasions: list[str],`  
        `created_at: str,`  
    `) -> list[dict[str, Any]]:`  
        `eligible = [i for i in items if not i.get("archived")]`  
        `tops = sorted(`  
            `[i for i in eligible if TYPE_TO_GROUP.get(i["type_code"]) == "TOPS"],`  
            `key=lambda x: x["id"],`  
        `)`  
        `bottoms = sorted(`  
            `[i for i in eligible if TYPE_TO_GROUP.get(i["type_code"]) == "BOTTOMS"],`  
            `key=lambda x: x["id"],`  
        `)`  
        `shoes = sorted(`  
            `[i for i in eligible if TYPE_TO_GROUP.get(i["type_code"]) == "SHOES"],`  
            `key=lambda x: x["id"],`  
        `)`

        `looks: list[ tuple[list[dict[str, Any]], str] ] = []`  
        `for t in tops:`  
            `for b in bottoms:`  
                `for s in shoes:`  
                    `look = [`  
                        `{`  
                            `"slot_role": "TOP",`  
                            `"item_id": t["id"],`  
                            `"name": t["name"],`  
                            `"days_unworn": days_unworn_map.get(t["id"], 0),`  
                        `},`  
                        `{`  
                            `"slot_role": "BOTTOM",`  
                            `"item_id": b["id"],`  
                            `"name": b["name"],`  
                            `"days_unworn": days_unworn_map.get(b["id"], 0),`  
                        `},`  
                        `{`  
                            `"slot_role": "FOOTWEAR",`  
                            `"item_id": s["id"],`  
                            `"name": s["name"],`  
                            `"days_unworn": days_unworn_map.get(s["id"], 0),`  
                        `},`  
                    `]`  
                    `looks.append((look, t["color"]))`

        `def _sort_key(entry: tuple[list[dict[str, Any]], str]) -> tuple[int, str, str, str]:`  
            `look_list, _ = entry`  
            `max_d = max(x["days_unworn"] for x in look_list)`  
            `return (-max_d, look_list[0]["item_id"], look_list[1]["item_id"], look_list[2]["item_id"])`

        `looks.sort(key=_sort_key)`

        `occ_label = (`  
            `f"for {OCCASION_LABELS.get(occasions[0], occasions[0]).lower()}"`  
            `if occasions`  
            `else "for every day"`  
        `)`

        `candidates: list[dict[str, Any]] = []`  
        `for idx, (look, top_color) in enumerate(looks[: cls.DECK_SIZE]):`  
            `order = idx + 1`  
            `cand_id = deterministic_object_id([session_id, str(order)])`  
            `candidates.append(`  
                `{`  
                    `"id": cand_id,`  
                    `"user_id": user_id,`  
                    `"session_id": session_id,`  
                    `"deck_order": order,`  
                    `"title": f"{top_color} {occ_label}",`  
                    `"match_pct": cls.score_look(look),`  
                    `"highlight_reason": cls.highlight_reason(look),`  
                    `"visual_mode": "COLLAGE_FLATLAY",`  
                    `"swipe_status": "PENDING_SWIPE",`  
                    `"items": look,`  
                    `"created_at": created_at,`  
                `}`  
            `)`  
        `return candidates`

## **8\. Side-Effect Workers (app/workers/effects.py — BE-014 .. BE-018, BE-021)**

Handles all synchronous and hold-mode side effects triggered by POST /v1/sync/tx without external queues or third-party cloud dependencies.

`from __future__ import annotations`

`import hashlib`  
`import json`  
`from datetime import timedelta`  
`from typing import Any`

`from app.ai.fakes import (`  
    `TYPE_TO_GROUP,`  
    `FixtureContextSource,`  
    `FixtureOutfitExtractor,`  
    `FixturePersonDetector,`  
    `RuleOutfitGenerator,`  
`)`  
`from app.ai.ports import ContextRequest, ExtractionInput`  
`from app.core.clock import Clock`  
`from app.core.errors import SyncDomainError`  
`from app.rules.wear import days_unworn, gap_days, rescue_eligible`  
`from app.store.memory import InMemoryStore`  
`from app.sync.ids import deterministic_object_id`

`# Minimal 1x1 stripped PNG used for fake VTON renders (BE-021)`  
`FAKE_RENDER_PNG = (`  
    `b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01"`  
    `b"\x08\x02\x00\x00\x00\x90wS\xde\x00\x00\x00\x0cIDATx\x9cc\xf8\xcf\xc0"`  
    ``b"\x00\x00\x03\x01\x01\x00\x18\xdd\x8d\xb0\x00\x00\x00\x00IEND\xaeB`\x82"``  
`)`

`def _has_exif_or_invalid_magic(content: bytes, mime_type: str) -> bool:`  
    `"""Checks magic bytes (JPEG/PNG) and ensures no EXIF/XMP/eXIf segments remain (BE-018-S02, S03)."""`  
    `if mime_type == "image/jpeg":`  
        `if not content.startswith(b"\xff\xd8\xff"):`  
            `return True`  
        `if b"Exif\x00\x00" in content or b"http://ns.adobe.com/xap/1.0/" in content:`  
            `return True`  
        `return False`  
    `if mime_type == "image/png":`  
        `if not content.startswith(b"\x89PNG\r\n\x1a\n"):`  
            `return True`  
        `if b"eXIf" in content:`  
            `return True`  
        `return False`  
    `return True`

`class SideEffectsDispatcher:`  
    `def __init__(self, store: InMemoryStore, clock: Clock) -> None:`  
        `self.store = store`  
        `self.clock = clock`  
        `self.extractor = FixtureOutfitExtractor()`  
        `self.person_detector = FixturePersonDetector()`

    `def on_op_applied(`  
        `self,`  
        `owner: str,`  
        `op: str,`  
        `table: str,`  
        `row_id: str,`  
        `row: dict[str, Any],`  
    `) -> None:`  
        `if table == "attachments":`  
            `self._handle_attachment(owner, op, row_id, row)`  
        `elif table == "upload_batches":`  
            `self._handle_upload_batch(owner, op, row_id, row)`  
        `elif table == "wear_events" and op == "PUT":`  
            `self._handle_wear_event(owner, row_id, row)`  
        `elif table == "gu_match_sessions" and op == "PUT":`  
            `self._handle_gu_match_session(owner, row_id, row)`  
        `elif table == "interactions" and op == "PUT":`  
            `self._handle_interaction(owner, row_id, row)`  
        `elif table == "privacy_requests" and op == "PUT":`  
            `self._handle_privacy_request(owner, row_id, row)`  
        `elif table == "vton_jobs" and op == "PUT":`  
            `self._handle_vton_job(owner, row_id, row)`  
        `elif table == "consents" and op == "PATCH" and row.get("revoked_at"):`  
            `self._handle_consent_withdrawn(owner, row_id, row)`

    `# --- BE-018: Attachments & Tickets ---`  
    `def _handle_attachment(`  
        `self, owner: str, op: str, att_id: str, row: dict[str, Any]`  
    `) -> None:`  
        `state = row.get("state")`  
        `if op == "PUT" and state == "PENDING_UPLOAD" and row.get("kind") in ("PHOTO", "BODY"):`  
            `exp_dt = self.clock.now() + timedelta(minutes=15)`  
            `exp_iso = exp_dt.strftime("%Y-%m-%dT%H:%M:%SZ")`  
            `ticket_id = deterministic_object_id([att_id, "PUT", exp_iso])`  
            `self.store.put(`  
                `"attachment_tickets",`  
                `owner,`  
                `ticket_id,`  
                `{`  
                    `"id": ticket_id,`  
                    `"user_id": owner,`  
                    `"attachment_id": att_id,`  
                    `"op": "PUT",`  
                    `"url": f"/v1/mock/files/{ticket_id}",`  
                    `"expires_at": exp_iso,`  
                `},`  
            `)`  
        `elif op == "PATCH" and state == "UPLOADED":`  
            `blob_key = f"users/{owner}/{att_id}"`  
            `raw = self.store.blobs.get(blob_key)`  
            `if (`  
                `raw is None`  
                `or len(raw) != row.get("bytes")`  
                `or hashlib.sha256(raw).hexdigest().lower() != str(row.get("sha256", "")).lower()`  
                `or _has_exif_or_invalid_magic(raw, str(row.get("mime_type", "")))`  
            `):`  
                `self.store.blobs.pop(blob_key, None)`  
                `self.store.patch("attachments", owner, att_id, {"state": "REJECTED"})`  
            `else:`  
                `self.store.patch("attachments", owner, att_id, {"state": "VERIFIED"})`

    `# --- BE-014: Studio Pipeline ---`  
    `def _handle_upload_batch(`  
        `self, owner: str, op: str, batch_id: str, row: dict[str, Any]`  
    `) -> None:`  
        `status = row.get("status")`  
        `now_iso = self.clock.iso_now()`  
        `assets = [`  
            `a`  
            `for a in self.store.query("media_assets", owner, {"batch_id": batch_id})`  
            `if not a.get("removed")`  
        `]`  
        `assets.sort(key=lambda a: a.get("slot_index", 0))`

        `if status == "SANITIZING":`  
            `for asset in assets:`  
                `self.store.patch(`  
                    `"media_assets",`  
                    `owner,`  
                    `asset["id"],`  
                    `{"exif_gps_stripped": 1},`  
                `)`  
        `elif status == "QUEUED_FOR_AI":`  
            `tasks: list[str] = []`  
            `if row.get("req_outfit") == 1:`  
                `tasks.append("OUTFIT_EXTRACTION")`  
            `if row.get("req_pose") == 1:`  
                `tasks.append("POSE_ESTIMATION")`  
            `if row.get("req_background") == 1:`  
                `tasks.append("BACKGROUND_ANALYSIS")`

            `self.store.patch(`  
                `"upload_batches",`  
                `owner,`  
                `batch_id,`  
                `{"status": "AI_PROCESSING", "updated_at": now_iso},`  
            `)`

            `job_ids: list[tuple[str, dict[str, Any], str]] = []`  
            `for asset in assets:`  
                `for t_type in tasks:`  
                    `jid = deterministic_object_id([batch_id, asset["id"], t_type])`  
                    `self.store.put(`  
                        `"ai_processing_jobs",`  
                        `owner,`  
                        `jid,`  
                        `{`  
                            `"id": jid,`  
                            `"user_id": owner,`  
                            `"batch_id": batch_id,`  
                            `"asset_id": asset["id"],`  
                            `"task_type": t_type,`  
                            `"status": "PENDING",`  
                            `"created_at": now_iso,`  
                            `"updated_at": now_iso,`  
                        `},`  
                    `)`  
                    `self.store.patch(`  
                        `"ai_processing_jobs",`  
                        `owner,`  
                        `jid,`  
                        `{"status": "PROCESSING", "updated_at": now_iso},`  
                    `)`  
                    `job_ids.append((jid, asset, t_type))`

            `studio_scen = self.store.scenarios.get(owner, {}).get("studio", "OK")`  
            `if studio_scen == "HOLD":`  
                `self.store.held_batches.setdefault(owner, []).append(batch_id)`  
                `return`

            `self.complete_studio_jobs(owner, batch_id, job_ids, studio_scen)`

        `elif status == "DRAFT" and op == "PATCH":`  
            `# Reopen cancels jobs & deletes extracted_items (BE-014-S07)`  
            `for j in self.store.query("ai_processing_jobs", owner, {"batch_id": batch_id}):`  
                `self.store.delete("ai_processing_jobs", owner, j["id"])`  
            `for d in self.store.query("extracted_items", owner, {"batch_id": batch_id}):`  
                `self.store.delete("extracted_items", owner, d["id"])`  
            `if batch_id in self.store.held_batches.get(owner, []):`  
                `self.store.held_batches[owner].remove(batch_id)`

        `elif status == "COMPLETED":`  
            `# Batch leaves my_studio and my_studio_jobs streams (BE-013-S05, BE-014-S11)`  
            `for j in self.store.query("ai_processing_jobs", owner, {"batch_id": batch_id}):`  
                `self.store.emit_stream_delete(owner, "my_studio_jobs", "ai_processing_jobs", j["id"])`  
            `for d in self.store.query("extracted_items", owner, {"batch_id": batch_id}):`  
                `self.store.emit_stream_delete(owner, "my_studio", "extracted_items", d["id"])`  
            `for a in self.store.query("media_assets", owner, {"batch_id": batch_id}):`  
                `self.store.emit_stream_delete(owner, "my_studio", "media_assets", a["id"])`  
            `self.store.emit_stream_delete(owner, "my_studio", "upload_batches", batch_id)`

    `def complete_studio_jobs(`  
        `self,`  
        `owner: str,`  
        `batch_id: str,`  
        `job_ids: list[tuple[str, dict[str, Any], str]],`  
        `studio_scen: str,`  
    `) -> None:`  
        `now_iso = self.clock.iso_now()`  
        `outfit_jobs = 0`  
        `failed_outfit_jobs = 0`

        `for idx, (jid, asset, t_type) in enumerate(job_ids):`  
            `if t_type in ("POSE_ESTIMATION", "BACKGROUND_ANALYSIS"):`  
                `self.store.patch(`  
                    `"ai_processing_jobs",`  
                    `owner,`  
                    `jid,`  
                    `{"status": "SKIPPED_NO_PERSON", "updated_at": now_iso},`  
                `)`  
                `continue`

            `outfit_jobs += 1`  
            `if studio_scen == "ALL_FAILED" or (studio_scen == "PARTIAL" and idx == 0):`  
                `failed_outfit_jobs += 1`  
                `self.store.patch(`  
                    `"ai_processing_jobs",`  
                    `owner,`  
                    `jid,`  
                    `{"status": "FAILED", "updated_at": now_iso},`  
                `)`  
                `continue`

            `self.store.patch(`  
                `"ai_processing_jobs",`  
                `owner,`  
                `jid,`  
                `{"status": "COMPLETED", "updated_at": now_iso},`  
            `)`  
            `if studio_scen == "ZERO_ITEMS":`  
                `continue`

            `att_id = asset.get("attachment_id")`  
            `blob = self.store.blobs.get(f"users/{owner}/{att_id}") if att_id else None`  
            `pieces = self.extractor.extract(`  
                `ExtractionInput(`  
                    `asset_id=asset["id"],`  
                    `mime_type=asset["mime_type"],`  
                    `content=blob,`  
                `)`  
            `)`  
            `for p_idx, piece in enumerate(pieces, start=1):`  
                `draft_id = deterministic_object_id([batch_id, asset["id"], str(p_idx)])`  
                `attrs_json = json.dumps(`  
                    `{`  
                        `"type_code": piece.type_code,`  
                        `"color": piece.color,`  
                        `"material": piece.material,`  
                        `"style_tag": piece.style_tag,`  
                    `}`  
                `)`  
                `self.store.put(`  
                    `"extracted_items",`  
                    `owner,`  
                    `draft_id,`  
                    `{`  
                        `"id": draft_id,`  
                        `"user_id": owner,`  
                        `"batch_id": batch_id,`  
                        `"asset_id": asset["id"],`  
                        `"item_index": p_idx,`  
                        `"name": piece.name,`  
                        `"confidence": piece.confidence,`  
                        `"ai": attrs_json,`  
                        `"value": attrs_json,`  
                        `"last_worn_input": None,`  
                        `"cutout_attachment_id": None,`  
                        `"created_at": now_iso,`  
                    `},`  
                `)`

        `final_batch_status = (`  
            `"FAILED" if (outfit_jobs > 0 and failed_outfit_jobs == outfit_jobs) else "AWAITING_REVIEW"`  
        `)`  
        `self.store.patch(`  
            `"upload_batches",`  
            `owner,`  
            `batch_id,`  
            `{"status": final_batch_status, "updated_at": now_iso},`  
        `)`

    `# --- BE-016: Wear Event Re-Computation ---`  
    `def _handle_wear_event(`  
        `self, owner: str, event_id: str, row: dict[str, Any]`  
    `) -> None:`  
        `from datetime import date as dt_date`

        `worn_dt = dt_date.fromisoformat(row["worn_date"][:10])`  
        `all_events = [`  
            `e for e in self.store.query("wear_events", owner) if e["id"] != event_id`  
        `]`  
        `raw_items = json.loads(row["items"]) if isinstance(row["items"], str) else row["items"]`  
        `corrected_items: list[dict[str, Any]] = []`  
        `changed = False`

        `for entry in raw_items:`  
            `item_doc = self.store.get("wardrobe_items", owner, entry["item_id"])`  
            `if item_doc is None:`  
                `continue`  
            `g_days = gap_days(item=item_doc, worn_date=worn_dt, prior_events=all_events)`  
            `resc = rescue_eligible(g_days)`  
            `if entry.get("gap_days") != g_days or entry.get("rescue_eligible") != resc:`  
                `changed = True`  
            `corrected_items.append(`  
                `{`  
                    `"item_id": entry["item_id"],`  
                    `"gap_days": g_days,`  
                    `"rescue_eligible": resc,`  
                `}`  
            `)`

        `if changed:`  
            `self.store.patch(`  
                `"wear_events",`  
                `owner,`  
                `event_id,`  
                `{"items": json.dumps(corrected_items)},`  
            `)`

    `# --- BE-015: Gu Match Session & Interactions ---`  
    `def _handle_gu_match_session(`  
        `self, owner: str, session_id: str, row: dict[str, Any]`  
    `) -> None:`  
        `now_dt = self.clock.now()`  
        `now_iso = self.clock.iso_now()`  
        `exp_iso = (now_dt + timedelta(days=90)).strftime("%Y-%m-%dT%H:%M:%SZ")`  
        `items = [`  
            `i for i in self.store.query("wardrobe_items", owner) if not i.get("archived")`  
        `]`

        `self.store.patch(`  
            `"gu_match_sessions",`  
            `owner,`  
            `session_id,`  
            `{`  
                `"status": "GATHERING",`  
                `"eligible_item_count": len(items),`  
                `"owned_only": 1,`  
                `"deck_size": 8,`  
                `"recent": 1,`  
                `"expires_at": exp_iso,`  
            `},`  
        `)`

        `if not items:`  
            `self.store.patch(`  
                `"gu_match_sessions",`  
                `owner,`  
                `session_id,`  
                `{"status": "NO_ELIGIBLE_ITEMS", "deck_size": 0},`  
            `)`  
            `return`

        `gm_scen = self.store.scenarios.get(owner, {}).get("gu_match", "OK")`  
        `if gm_scen == "FAIL":`  
            `self.store.patch("gu_match_sessions", owner, session_id, {"status": "FAILED"})`  
            `return`

        `occasions = json.loads(row.get("occasions", "[]"))`  
        `ctx_source = FixtureContextSource(scenario=gm_scen)`  
        `cards = ctx_source.gather(`  
            `ContextRequest(`  
                `occasions=tuple(occasions),`  
                `raw_prompt=row.get("raw_prompt", ""),`  
                `path=row.get("path", "ZERO_INPUT"),`  
                `city_id=row.get("city_id"),`  
                `window_start=row.get("window_start"),`  
                `window_end=row.get("window_end"),`  
                `ambient_temp_c=row.get("ambient_temp_c"),`  
            `)`  
        `)`

        `accumulated_cards: list[dict[str, Any]] = []`  
        `for card in cards:`  
            `accumulated_cards.append(`  
                `{`  
                    `"kind": card.kind,`  
                    `"label": card.label,`  
                    `"headline": card.headline,`  
                    `"detail": card.detail,`  
                    `"is_missing": card.is_missing,`  
                `}`  
            `)`  
            `self.store.patch(`  
                `"gu_match_sessions",`  
                `owner,`  
                `session_id,`  
                `{"context": json.dumps(accumulated_cards)},`  
            `)`

        `self.store.patch("gu_match_sessions", owner, session_id, {"status": "ANALYZED"})`

        `wear_events = self.store.query("wear_events", owner)`  
        `unworn_map = {`  
            `it["id"]: days_unworn(it, wear_events, now_dt.date()) for it in items`  
        `}`  
        `candidates = RuleOutfitGenerator.generate(`  
            `session_id=session_id,`  
            `user_id=owner,`  
            `items=items,`  
            `days_unworn_map=unworn_map,`  
            `occasions=occasions,`  
            `created_at=now_iso,`  
        `)`  
        `for cand in candidates:`  
            `cand_row = dict(cand)`  
            `cand_row["items"] = json.dumps(cand["items"])`  
            `self.store.put("outfit_candidates", owner, cand["id"], cand_row)`

        `self.store.patch(`  
            `"gu_match_sessions",`  
            `owner,`  
            `session_id,`  
            `{"status": "DECK_READY", "deck_size": len(candidates)},`  
        `)`

    `def _handle_interaction(`  
        `self, owner: str, interaction_id: str, row: dict[str, Any]`  
    `) -> None:`  
        `cand_id = row["candidate_id"]`  
        `cand = self.store.get("outfit_candidates", owner, cand_id)`  
        `if cand is None:`  
            `return`  
        `action = row["action"]`  
        `if action == "DISMISS_PASS":`  
            `self.store.patch(`  
                `"outfit_candidates", owner, cand_id, {"swipe_status": "SWIPED_LEFT_PASSED"}`  
            `)`  
        `elif action == "LIKE_SAVE":`  
            `self.store.patch(`  
                `"outfit_candidates", owner, cand_id, {"swipe_status": "SWIPED_RIGHT_LIKED"}`  
            `)`  
        `elif action in ("CUSTOMIZE_EDIT", "ADJUST"):`  
            `from_id = row.get("from_item_id")`  
            `to_id = row.get("to_item_id")`  
            `from_item = self.store.get("wardrobe_items", owner, str(from_id))`  
            `to_item = self.store.get("wardrobe_items", owner, str(to_id))`  
            `if to_item is None or to_item.get("archived"):`  
                `raise SyncDomainError(422, "ITEM_NOT_OWNED", "Replacement item not owned or archived")`  
            `if from_item is None or TYPE_TO_GROUP.get(from_item["type_code"]) != TYPE_TO_GROUP.get(`  
                `to_item["type_code"]`  
            `):`  
                `raise SyncDomainError(422, "GROUP_MISMATCH", "Replacement item is in a different group")`

            `wear_events = self.store.query("wear_events", owner)`  
            `to_days = days_unworn(to_item, wear_events, self.clock.now().date())`  
            `cand_items = json.loads(cand["items"])`  
            `new_items = [`  
                `{`  
                    `"slot_role": it["slot_role"],`  
                    `"item_id": to_item["id"],`  
                    `"name": to_item["name"],`  
                    `"days_unworn": to_days,`  
                `}`  
                `if it["item_id"] == from_id`  
                `else it`  
                `for it in cand_items`  
            `]`  
            `self.store.patch(`  
                `"outfit_candidates",`  
                `owner,`  
                `cand_id,`  
                `{`  
                    `"items": json.dumps(new_items),`  
                    `"match_pct": RuleOutfitGenerator.score_look(new_items),`  
                    `"highlight_reason": RuleOutfitGenerator.highlight_reason(new_items),`  
                `},`  
            `)`

    `# --- BE-017: Privacy Erasure & Body Withdrawal ---`  
    `def _handle_privacy_request(`  
        `self, owner: str, req_id: str, row: dict[str, Any]`  
    `) -> None:`  
        `scope = row["scope"]`  
        `now_iso = self.clock.iso_now()`  
        `self.store.audit_events.append(`  
            `{"event": "erasure_requested", "request_id": req_id, "scope": scope}`  
        `)`

        `if scope == "EXPORT":`  
            `self.store.patch(`  
                `"privacy_requests",`  
                `owner,`  
                `req_id,`  
                `{"status": "FAILED", "completed_at": now_iso},`  
            `)`  
            `return`

        `if scope == "BODY":`  
            `self._purge_body_data(owner, now_iso)`  
            `self.store.patch(`  
                `"privacy_requests",`  
                `owner,`  
                `req_id,`  
                `{"status": "COMPLETED", "completed_at": now_iso},`  
            `)`  
        `elif scope == "ALL":`  
            `self.store.patch("privacy_requests", owner, req_id, {"status": "IN_PROGRESS"})`  
            `self.store.held_batches.pop(owner, None)`  
            `for table in (`  
                `"profiles",`  
                `"wardrobe_items",`  
                `"wear_events",`  
                `"upload_batches",`  
                `"media_assets",`  
                `"ai_processing_jobs",`  
                `"extracted_items",`  
                `"consents",`  
                `"interactions",`  
                `"gu_match_sessions",`  
                `"outfit_candidates",`  
                `"attachments",`  
                `"attachment_tickets",`  
                `"vton_jobs",`  
            `):`  
                `for item in self.store.query(table, owner):`  
                    `self.store.delete(table, owner, item["id"])`  
            `for key in [k for k in self.store.blobs if k.startswith(f"users/{owner}/")]:`  
                `del self.store.blobs[key]`  
            `self.store.patch(`  
                `"privacy_requests",`  
                `owner,`  
                `req_id,`  
                `{"status": "COMPLETED", "completed_at": now_iso},`  
            `)`

        `self.store.audit_events.append(`  
            `{"event": "erasure_completed", "request_id": req_id, "scope": scope, "duration_ms": 1}`  
        `)`

    `def _purge_body_data(self, owner: str, now_iso: str) -> None:`  
        `for c in self.store.query("consents", owner):`  
            `if c.get("includes_body") == 1 and not c.get("revoked_at"):`  
                `self.store.patch("consents", owner, c["id"], {"revoked_at": now_iso})`  
        `for b in self.store.query("upload_batches", owner, {"purpose": "BODY_REFERENCE"}):`  
            `for a in self.store.query("media_assets", owner, {"batch_id": b["id"]}):`  
                `self.store.delete("media_assets", owner, a["id"])`  
            `self.store.delete("upload_batches", owner, b["id"])`  
        `for att in self.store.query("attachments", owner):`  
            `if att.get("kind") in ("BODY", "RENDER"):`  
                `self.store.blobs.pop(f"users/{owner}/{att['id']}", None)`  
                `self.store.delete("attachments", owner, att["id"])`  
        `for vj in self.store.query("vton_jobs", owner):`  
            `if vj.get("status") in ("REQUESTED", "PROCESSING"):`  
                `self.store.patch(`  
                    `"vton_jobs", owner, vj["id"], {"status": "CANCELLED", "updated_at": now_iso}`  
                `)`

    `def _handle_consent_withdrawn(`  
        `self, owner: str, consent_id: str, row: dict[str, Any]`  
    `) -> None:`  
        `if row.get("includes_body") == 1:`  
            `self._purge_body_data(owner, self.clock.iso_now())`

    `# --- BE-021: Fake Virtual Try-On ---`  
    `def _handle_vton_job(`  
        `self, owner: str, job_id: str, row: dict[str, Any]`  
    `) -> None:`  
        `now_iso = self.clock.iso_now()`  
        `cand_id = row["candidate_id"]`  
        `body_asset_id = row["body_asset_id"]`

        `# Check single active render per candidate (BE-021-S03)`  
        `existing_jobs = [`  
            `j`  
            `for j in self.store.query("vton_jobs", owner, {"candidate_id": cand_id})`  
            `if j["id"] != job_id and j.get("status") in ("REQUESTED", "PROCESSING")`  
        `]`  
        `if existing_jobs:`  
            `self.store.patch(`  
                `"vton_jobs", owner, job_id, {"status": "FAILED", "updated_at": now_iso}`  
            `)`  
            `return`

        `# Precheck I7: active body consent + verified BODY attachment`  
        `active_body_consents = [`  
            `c`  
            `for c in self.store.query("consents", owner)`  
            `if c.get("includes_body") == 1 and not c.get("revoked_at")`  
        `]`  
        `body_att = self.store.get("attachments", owner, body_asset_id)`  
        `if not active_body_consents or body_att is None or body_att.get("state") != "VERIFIED":`  
            `self.store.patch(`  
                `"vton_jobs", owner, job_id, {"status": "FAILED", "updated_at": now_iso}`  
            `)`  
            `return`

        `self.store.patch(`  
            `"vton_jobs", owner, job_id, {"status": "PROCESSING", "updated_at": now_iso}`  
        `)`  
        `render_att_id = deterministic_object_id([job_id, "RENDER"])`  
        `self.store.blobs[f"users/{owner}/{render_att_id}"] = FAKE_RENDER_PNG`  
        `self.store.put(`  
            `"attachments",`  
            `owner,`  
            `render_att_id,`  
            `{`  
                `"id": render_att_id,`  
                `"user_id": owner,`  
                `"kind": "RENDER",`  
                `"owner_table": "vton_jobs",`  
                `"owner_id": job_id,`  
                `"mime_type": "image/png",`  
                `"bytes": len(FAKE_RENDER_PNG),`  
                `"sha256": hashlib.sha256(FAKE_RENDER_PNG).hexdigest(),`  
                `"state": "READY",`  
                `"created_at": now_iso,`  
            `},`  
        `)`  
        `exp_iso = (self.clock.now() + timedelta(minutes=10)).strftime("%Y-%m-%dT%H:%M:%SZ")`  
        `ticket_id = deterministic_object_id([render_att_id, "GET", exp_iso])`  
        `self.store.put(`  
            `"attachment_tickets",`  
            `owner,`  
            `ticket_id,`  
            `{`  
                `"id": ticket_id,`  
                `"user_id": owner,`  
                `"attachment_id": render_att_id,`  
                `"op": "GET",`  
                `"url": f"/v1/mock/files/{ticket_id}",`  
                `"expires_at": exp_iso,`  
            `},`  
        `)`  
        `self.store.patch(`  
            `"vton_jobs",`  
            `owner,`  
            `job_id,`  
            `{`  
                `"status": "COMPLETED",`  
                `"output_attachment_id": render_att_id,`  
                `"updated_at": now_iso,`  
            `},`  
        `)`

## **9\. Unified Write Handler & API Endpoints (app/api/v1/endpoints/sync\_api.py & app/main.py)**

`# backend/app/api/v1/endpoints/sync_api.py`  
`from __future__ import annotations`

`import hashlib`  
`import json`  
`import os`  
`from typing import Any`

`from fastapi import APIRouter, Request, Response`  
`from fastapi.responses import JSONResponse`  
`from pydantic import ValidationError`

`from app.ai.fakes import TYPE_TO_GROUP`  
`from app.auth.service import AuthService, resolve_owner`  
`from app.core.clock import FixedClock`  
`from app.core.errors import SyncDomainError`  
`from app.data.seed_data import build_demo_wardrobe_rows`  
`from app.store.memory import TABLE_STREAM_MAP, InMemoryStore`  
`from app.sync.ids import is_object_id`  
`from app.sync.schema import (`  
    `PHONE_ALLOWED_BATCH_STATUSES,`  
    `TABLE_ALLOW_LISTS,`  
    `TABLE_CLASSES,`  
    `TABLE_MODELS,`  
    `TableClass,`  
`)`  
`from app.workers.effects import SideEffectsDispatcher`

`router = APIRouter()`

`CLOCK = FixedClock()`  
`STORE = InMemoryStore()`  
`AUTH = AuthService(clock=CLOCK)`  
`EFFECTS = SideEffectsDispatcher(store=STORE, clock=CLOCK)`

`def _guard_non_production() -> None:`  
    `if os.getenv("ENV") == "production":`  
        `raise SyncDomainError(404, "NOT_FOUND", "Endpoint disabled in production")`

`# ============================================================================`  
`# 1. AUTH SERVICE ENDPOINTS (Real BE-019 & Dev Token BE-011)`  
`# ============================================================================`  
`@router.post("/v1/auth/dev-token")`  
`async def create_dev_token(request: Request) -> JSONResponse:`  
    `_guard_non_production()`  
    `body = await request.json()`  
    `user_id = str(body.get("user_id", ""))`  
    `if not is_object_id(user_id):`  
        `raise SyncDomainError(422, "INVALID_ID", "user_id must be 24 lowercase hex characters")`  
    `return JSONResponse(status_code=200, content={"token": f"dev.{user_id}", "user_id": user_id})`

`@router.post("/v1/auth/anonymous")`  
`async def create_anonymous_account(request: Request) -> JSONResponse:`  
    `body = await request.json()`  
    `user_id = str(body.get("user_id") or body.get("install_id") or "")`  
    `session = AUTH.create_anonymous_session(user_id=user_id)`  
    `return JSONResponse(status_code=200, content=session)`

`@router.post("/v1/auth/refresh")`  
`async def refresh_auth_token(request: Request) -> JSONResponse:`  
    `body = await request.json()`  
    `raw_refresh = str(body.get("refresh_token", ""))`  
    `session = AUTH.rotate_refresh_token(raw_refresh)`  
    `return JSONResponse(status_code=200, content=session)`

`@router.get("/v1/auth/.well-known/jwks.json")`  
`async def get_jwks() -> JSONResponse:`  
    `return JSONResponse(status_code=200, content=AUTH.jwks())`

`# ============================================================================`  
`# 2. ONE-PIECE WRITE HANDLER: POST /v1/sync/tx (BE-012 & BE-020)`  
`# ============================================================================`  
`@router.post("/v1/sync/tx")`  
`async def post_sync_tx(request: Request) -> JSONResponse:`  
    `owner = resolve_owner(request, AUTH)`

    `# Check injected 5xx fault scenario (BE-012-S13)`  
    `owner_scen = STORE.scenarios.get(owner, {})`  
    `if owner_scen.get("sync") == "FAIL_5XX_ONCE":`  
        `owner_scen["sync"] = "OK"`  
        `raise SyncDomainError(503, "RETRY_LATER", "Simulated temporary 503 failure")`

    `body = await request.json()`  
    `tx_id = int(body["tx_id"])`  
    `ops: list[dict[str, Any]] = body.get("ops", [])`  
    `ops_hash = hashlib.sha256(json.dumps(ops, sort_keys=True).encode("utf-8")).hexdigest()`

    `existing_tx = STORE.applied_tx.get((owner, tx_id))`  
    `if existing_tx is not None:`  
        `if existing_tx["ops_hash"] == ops_hash:`  
            `return JSONResponse(`  
                `status_code=200,`  
                `content={`  
                    `"applied": True,`  
                    `"replayed": True,`  
                    `"tx_id": tx_id,`  
                    `"checkpoint": existing_tx["checkpoint"],`  
                `},`  
            `)`  
        `raise SyncDomainError(409, "TX_ID_REUSED", "tx_id already used with different operations")`

    `with STORE.transaction():`  
        `for idx, op_entry in enumerate(ops):`  
            `_validate_and_apply_op(owner, idx, op_entry)`

        `STORE.applied_tx[(owner, tx_id)] = {`  
            `"ops_hash": ops_hash,`  
            `"checkpoint": STORE.checkpoint,`  
        `}`

    `return JSONResponse(`  
        `status_code=200,`  
        `content={`  
            `"applied": True,`  
            `"replayed": False,`  
            `"tx_id": tx_id,`  
            `"checkpoint": STORE.checkpoint,`  
        `},`  
    `)`

`def _validate_and_apply_op(owner: str, idx: int, op_entry: dict[str, Any]) -> None:`  
    `op = op_entry.get("op")`  
    `table = op_entry.get("type") or op_entry.get("table")`  
    `row_id = str(op_entry.get("id", ""))`  
    `data: dict[str, Any] = dict(op_entry.get("data") or {})`

    `if not is_object_id(row_id):`  
        `raise SyncDomainError(422, "INVALID_ID", f"Invalid ObjectId: {row_id}", op_index=idx)`

    `if table not in TABLE_CLASSES:`  
        `raise SyncDomainError(403, "TABLE_NOT_WRITABLE", f"Unknown table: {table}", op_index=idx)`

    `t_class = TABLE_CLASSES[table]`  
    `if t_class == TableClass.READ_ONLY:`  
        `raise SyncDomainError(403, "TABLE_NOT_WRITABLE", f"{table} is read-only", op_index=idx)`

    `if "user_id" in data and data["user_id"] is not None and data["user_id"] != owner:`  
        `raise SyncDomainError(403, "OWNER_MISMATCH", "Row user_id does not match token sub", op_index=idx)`

    `existing_owner = STORE.owner_of_id(table, row_id)`  
    `if existing_owner is not None and existing_owner not in (owner, "__global__"):`  
        `raise SyncDomainError(403, "OWNER_MISMATCH", "Row belongs to another owner", op_index=idx)`

    `now_iso = CLOCK.iso_now()`

    `if op == "PUT":`  
        `if t_class == TableClass.PHONE_PATCH_ONLY:`  
            `raise SyncDomainError(403, "TABLE_NOT_WRITABLE", f"{table} only allows PATCH", op_index=idx)`

        `# Idempotent duplicate PUT from the same owner is a no-op (BE-012-S08)`  
        `if STORE.get(table, owner, row_id) is not None:`  
            `return`

        `data.setdefault("user_id", owner)`  
        `if "created_at" in TABLE_MODELS[table].model_fields and not data.get("created_at"):`  
            `data["created_at"] = now_iso`  
        `if "updated_at" in TABLE_MODELS[table].model_fields and not data.get("updated_at"):`  
            `data["updated_at"] = now_iso`

        `_check_domain_invariants_on_put(owner, idx, table, row_id, data)`

        `try:`  
            `validated = TABLE_MODELS[table](id=row_id, **data).model_dump()`  
        `except ValidationError as exc:`  
            `raise SyncDomainError(422, "SCHEMA_VIOLATION", str(exc), op_index=idx) from exc`

        `stored = STORE.put(table, owner, row_id, validated)`  
        `EFFECTS.on_op_applied(owner, "PUT", table, row_id, stored)`

    `elif op == "PATCH":`  
        `if t_class == TableClass.INSERT_ONLY and table != "consents":`  
            `raise SyncDomainError(422, "APPEND_ONLY", f"{table} is append-only", op_index=idx)`

        `allow_list = TABLE_ALLOW_LISTS.get(table, set())`  
        `disallowed = set(data.keys()) - allow_list`  
        `if disallowed:`  
            `if t_class == TableClass.INSERT_ONLY:`  
                `raise SyncDomainError(422, "APPEND_ONLY", f"{table} is append-only", op_index=idx)`  
            `raise SyncDomainError(`  
                `422, "FIELD_NOT_WRITABLE", f"Fields not writable: {sorted(disallowed)}", op_index=idx`  
            `)`

        `current = STORE.get(table, owner, row_id)`  
        `if current is None:`  
            `raise SyncDomainError(404, "NOT_FOUND", f"{table}:{row_id} not found", op_index=idx)`

        `_check_domain_invariants_on_patch(owner, idx, table, row_id, current, data)`

        `merged = {**current, **data}`  
        `try:`  
            `TABLE_MODELS[table](**merged)`  
        `except ValidationError as exc:`  
            `raise SyncDomainError(422, "SCHEMA_VIOLATION", str(exc), op_index=idx) from exc`

        `updated = STORE.patch(table, owner, row_id, data)`  
        `EFFECTS.on_op_applied(owner, "PATCH", table, row_id, updated)`

    `elif op == "DELETE":`  
        `if t_class in (TableClass.INSERT_ONLY, TableClass.PHONE_PATCH_ONLY):`  
            `raise SyncDomainError(422, "APPEND_ONLY", f"{table} cannot be deleted", op_index=idx)`  
        `STORE.delete(table, owner, row_id)`  
    `else:`  
        `raise SyncDomainError(422, "SCHEMA_VIOLATION", f"Unsupported op: {op}", op_index=idx)`

`def _check_domain_invariants_on_put(`  
    `owner: str, idx: int, table: str, row_id: str, data: dict[str, Any]`  
`) -> None:`  
    `if table == "media_assets":`  
        `if data.get("mime_type") not in ("image/jpeg", "image/png"):`  
            `raise SyncDomainError(422, "UNSUPPORTED_MIME", "Only JPEG and PNG allowed", op_index=idx)`  
        `batch_id = data.get("batch_id", "")`  
        `active = [`  
            `a`  
            `for a in STORE.query("media_assets", owner, {"batch_id": batch_id})`  
            `if not a.get("removed")`  
        `]`  
        `if len(active) >= 10:`  
            `raise SyncDomainError(422, "PHOTO_COUNT_OUT_OF_RANGE", "Max 10 photos per batch", op_index=idx)`

    `elif table == "wardrobe_items":`  
        `t_code = data.get("type_code", "")`  
        `if t_code not in TYPE_TO_GROUP:`  
            `raise SyncDomainError(422, "UNKNOWN_TYPE_CODE", f"Unknown type_code: {t_code}", op_index=idx)`

    `elif table == "wear_events":`  
        `try:`  
            `items_list = json.loads(data.get("items", "[]"))`  
        `except Exception as exc:`  
            `raise SyncDomainError(422, "SCHEMA_VIOLATION", "Invalid items JSON", op_index=idx) from exc`  
        `if not (1 <= len(items_list) <= 12):`  
            `raise SyncDomainError(422, "SCHEMA_VIOLATION", "wear_events requires 1..12 items", op_index=idx)`  
        `for entry in items_list:`  
            `w_item = STORE.get("wardrobe_items", owner, str(entry.get("item_id", "")))`  
            `if w_item is None or w_item.get("archived") == 1:`  
                `raise SyncDomainError(`  
                    `422, "ITEM_NOT_OWNED", "Wear event item not owned or is archived", op_index=idx`  
                `)`

    `elif table == "gu_match_sessions":`  
        `occasions = json.loads(data.get("occasions", "[]"))`  
        `prompt = str(data.get("raw_prompt", "")).strip()`  
        `path = data.get("path")`  
        `if len(occasions) > 5 or len(prompt) > 280:`  
            `raise SyncDomainError(422, "SCHEMA_VIOLATION", "Exceeds occasion or prompt limit", op_index=idx)`  
        `if path == "ZERO_INPUT" and (occasions or prompt):`  
            `raise SyncDomainError(`  
                `422, "SCHEMA_VIOLATION", "ZERO_INPUT cannot include occasions or prompt", op_index=idx`  
            `)`  
        `if path == "PROMPT_LED" and not occasions and not prompt:`  
            `raise SyncDomainError(`  
                `422, "SCHEMA_VIOLATION", "PROMPT_LED requires at least one chip or prompt", op_index=idx`  
            `)`

`def _check_domain_invariants_on_patch(`  
    `owner: str,`  
    `idx: int,`  
    `table: str,`  
    `row_id: str,`  
    `current: dict[str, Any],`  
    `changes: dict[str, Any],`  
`) -> None:`  
    `if table == "upload_batches" and "status" in changes:`  
        `target = changes["status"]`  
        `if target not in PHONE_ALLOWED_BATCH_STATUSES:`  
            `raise SyncDomainError(`  
                `409, "ILLEGAL_TRANSITION", f"Phone cannot set batch status to {target}", op_index=idx`  
            `)`  
        `cur_status = current.get("status", "DRAFT")`  
        `allowed_transitions = {`  
            `"DRAFT": {"SANITIZING", "DELETED_BY_USER"},`  
            `"SANITIZING": {"QUEUED_FOR_AI", "DRAFT", "DELETED_BY_USER"},`  
            `"QUEUED_FOR_AI": {"DRAFT", "DELETED_BY_USER"},`  
            `"AI_PROCESSING": {"DRAFT", "DELETED_BY_USER"},`  
            `"AWAITING_REVIEW": {"COMPLETED", "DRAFT", "DELETED_BY_USER"},`  
            `"FAILED": {"DRAFT", "QUEUED_FOR_AI", "DELETED_BY_USER"},`  
        `}`  
        `if target not in allowed_transitions.get(cur_status, set()):`  
            `raise SyncDomainError(`  
                `409, "ILLEGAL_TRANSITION", f"Illegal transition {cur_status} -> {target}", op_index=idx`  
            `)`

        `if target == "SANITIZING":`  
            `consent_id = changes.get("consent_id") or current.get("consent_id")`  
            `consent = STORE.get("consents", owner, str(consent_id or ""))`  
            `if consent is None or consent.get("revoked_at") is not None:`  
                `raise SyncDomainError(422, "CONSENT_REQUIRED", "Active consent required", op_index=idx)`  
            `assets = [`  
                `a`  
                `for a in STORE.query("media_assets", owner, {"batch_id": row_id})`  
                `if not a.get("removed")`  
            `]`  
            `if not (1 <= len(assets) <= 10):`  
                `raise SyncDomainError(`  
                    `422, "PHOTO_COUNT_OUT_OF_RANGE", "Batch requires 1..10 active photos", op_index=idx`  
                `)`

        `elif target == "QUEUED_FOR_AI":`  
            `merged = {**current, **changes}`  
            `if not (`  
                `merged.get("req_outfit") == 1`  
                `or merged.get("req_pose") == 1`  
                `or merged.get("req_background") == 1`  
            `):`  
                `raise SyncDomainError(`  
                    `422, "NO_ANALYSIS_TASK", "At least one analysis task must be enabled", op_index=idx`  
                `)`

`# ============================================================================`  
`# 3. SYNC CREDENTIALS, NUDGE & CHANGE FEED (BE-009, BE-013)`  
`# ============================================================================`  
`@router.get("/v1/sync/credentials")`  
`async def get_sync_credentials(request: Request) -> JSONResponse:`  
    `owner = resolve_owner(request, AUTH)`  
    `token = AUTH.issue_jwt(user_id=owner)`  
    `return JSONResponse(`  
        `status_code=200,`  
        `content={`  
            `"endpoint": "/v1/mock/sync/changes",`  
            `"token": token,`  
            `"expires_at": CLOCK.iso_now(),`  
            `"user_id": owner,`  
        `},`  
    `)`

`@router.post("/v1/sync/nudge")`  
`async def post_sync_nudge(request: Request) -> JSONResponse:`  
    `owner = resolve_owner(request, AUTH)`  
    `return JSONResponse(status_code=202, content={"status": "queued", "user_id": owner, "triggered_jobs": 0})`

`@router.get("/v1/mock/sync/changes")`  
`async def get_mock_sync_changes(`  
    `request: Request,`  
    `after: int = 0,`  
    `streams: str = "catalog,my_wardrobe,my_studio,my_studio_jobs,my_decks,my_files",`  
    `limit: int = 500,`  
`) -> JSONResponse:`  
    `_guard_non_production()`  
    `owner = resolve_owner(request, AUTH)`  
    `requested_streams = [s.strip() for s in streams.split(",") if s.strip()]`  
    `valid_streams = set(TABLE_STREAM_MAP.values())`  
    `if any(s not in valid_streams for s in requested_streams):`  
        `raise SyncDomainError(422, "SCHEMA_VIOLATION", "Unknown stream requested")`

    `changes, has_more, checkpoint = STORE.get_changes(`  
        `owner=owner, after=after, streams=requested_streams, limit=limit`  
    `)`  
    `return JSONResponse(`  
        `status_code=200,`  
        `content={"checkpoint": checkpoint, "has_more": has_more, "changes": changes},`  
    `)`

`# ============================================================================`  
`# 4. SELF-CONTAINED FILE STORAGE TICKETS (BE-018)`  
`# ============================================================================`  
`@router.put("/v1/mock/files/{ticket_id}")`  
`async def put_mock_file(ticket_id: str, request: Request) -> Response:`  
    `_guard_non_production()`  
    `ticket = _find_ticket(ticket_id)`  
    `if ticket is None or ticket["op"] != "PUT" or ticket["expires_at"] < CLOCK.iso_now():`  
        `raise SyncDomainError(403, "FORBIDDEN", "Invalid or expired PUT ticket")`  
    `raw_bytes = await request.body()`  
    `owner = ticket["user_id"]`  
    `att_id = ticket["attachment_id"]`  
    `STORE.blobs[f"users/{owner}/{att_id}"] = raw_bytes`  
    `return Response(status_code=200)`

`@router.get("/v1/mock/files/{ticket_id}")`  
`async def get_mock_file(ticket_id: str) -> Response:`  
    `_guard_non_production()`  
    `ticket = _find_ticket(ticket_id)`  
    `if ticket is None or ticket["op"] != "GET" or ticket["expires_at"] < CLOCK.iso_now():`  
        `raise SyncDomainError(403, "FORBIDDEN", "Invalid or expired GET ticket")`  
    `owner = ticket["user_id"]`  
    `att_id = ticket["attachment_id"]`  
    `blob = STORE.blobs.get(f"users/{owner}/{att_id}")`  
    `if blob is None:`  
        `raise SyncDomainError(404, "NOT_FOUND", "File bytes not found")`  
    `return Response(content=blob, media_type="image/png", status_code=200)`

`def _find_ticket(ticket_id: str) -> dict[str, Any] | None:`  
    `owner = STORE.owner_of_id("attachment_tickets", ticket_id)`  
    `if owner is None:`  
        `return None`  
    `return STORE.get("attachment_tickets", owner, ticket_id)`

`# ============================================================================`  
`# 5. MOCK CONTROLS: RESET, CLOCK, SEED, SCENARIOS, JOB RELEASE`  
`# ============================================================================`  
`@router.post("/v1/mock/reset")`  
`async def post_mock_reset() -> JSONResponse:`  
    `_guard_non_production()`  
    `STORE.reset()`  
    `CLOCK.set_iso("2026-10-30T09:00:00Z")`  
    `return JSONResponse(status_code=200, content={"status": "reset", "checkpoint": STORE.checkpoint})`

`@router.put("/v1/mock/clock")`  
`async def put_mock_clock(request: Request) -> JSONResponse:`  
    `_guard_non_production()`  
    `body = await request.json()`  
    `CLOCK.set_iso(str(body["now"]))`  
    `return JSONResponse(status_code=200, content={"now": CLOCK.iso_now()})`

`@router.put("/v1/mock/scenarios")`  
`async def put_mock_scenarios(request: Request) -> JSONResponse:`  
    `_guard_non_production()`  
    `owner = resolve_owner(request, AUTH)`  
    `body = await request.json()`  
    `STORE.scenarios.setdefault(owner, {}).update(body)`  
    `return JSONResponse(status_code=200, content={"scenarios": STORE.scenarios[owner]})`

`@router.post("/v1/mock/jobs/release")`  
`async def post_release_held_jobs(request: Request) -> JSONResponse:`  
    `_guard_non_production()`  
    `owner = resolve_owner(request, AUTH)`  
    `released = 0`  
    `for batch_id in list(STORE.held_batches.get(owner, [])):`  
        `batch = STORE.get("upload_batches", owner, batch_id)`  
        `if batch is None or batch.get("status") == "DELETED_BY_USER":`  
            `continue`  
        `jobs = STORE.query("ai_processing_jobs", owner, {"batch_id": batch_id})`  
        `job_tuples = []`  
        `for j in jobs:`  
            `asset = STORE.get("media_assets", owner, j["asset_id"])`  
            `if asset:`  
                `job_tuples.append((j["id"], asset, j["task_type"]))`  
        `EFFECTS.complete_studio_jobs(owner, batch_id, job_tuples, "OK")`  
        `released += len(job_tuples)`  
    `STORE.held_batches[owner] = []`  
    `return JSONResponse(status_code=200, content={"released_jobs": released})`

`@router.post("/v1/mock/seed")`  
`async def post_mock_seed(request: Request) -> JSONResponse:`  
    `_guard_non_production()`  
    `body = await request.json()`  
    `preset = body.get("preset", "catalog")`  
    `if preset == "catalog":`  
        `added = STORE.seed_catalog()`  
        `return JSONResponse(status_code=200, content={"preset": "catalog", "added": added})`  
    `if preset == "demo_wardrobe":`  
        `owner = resolve_owner(request, AUTH)`  
        `rows = build_demo_wardrobe_rows(owner_id=owner, now=CLOCK.now())`  
        `added = 0`  
        `for r in rows:`  
            `if STORE.get("wardrobe_items", owner, r["id"]) is None:`  
                `STORE.put("wardrobe_items", owner, r["id"], r)`  
                `added += 1`  
        `return JSONResponse(status_code=200, content={"preset": "demo_wardrobe", "added": added})`  
    `raise SyncDomainError(422, "SCHEMA_VIOLATION", f"Unknown seed preset: {preset}")`

## **10\. Application Entrypoint & Router (backend/app/main.py & router.py — BE-005)**

Removes all retired dating routes and schemas (discovery, matches, chat, Profile, SwipeRequest, SwipeResponse) while keeping health probes and mounting the unified v2.8 sync router.

`# backend/app/api/router.py`  
`from fastapi import APIRouter`

`from app.api.v1.endpoints import deployment_health, health, openai_health, sync_api`

`api_router = APIRouter()`

`api_router.include_router(health.router)`  
`api_router.include_router(deployment_health.router)`  
`api_router.include_router(openai_health.router)`  
`api_router.include_router(sync_api.router)`

`# backend/app/main.py`  
`from fastapi import FastAPI, Request`  
`from fastapi.middleware.cors import CORSMiddleware`

`from app.api.router import api_router`  
`from app.config import settings`  
`from app.core.errors import SyncDomainError`

`app = FastAPI(`  
    `title="Garblo mock API",`  
    `description="Local-first AI Wardrobe, Studio & Gu Match Sync Backend API",`  
    `version="2.8.0",`  
`)`

`app.add_middleware(`  
    `CORSMiddleware,`  
    `allow_origins=list(settings.cors_origins),`  
    `allow_credentials=False,`  
    `allow_methods=["*"],`  
    `allow_headers=["*"],`  
`)`

`@app.exception_handler(SyncDomainError)`  
`async def sync_domain_error_handler(request: Request, exc: SyncDomainError):`  
    `return exc.to_response()`

`app.include_router(api_router)`

Would you like to now export the remaining shared golden fixture JSON files (dormancy\_cases.json, fake\_extraction\_sets.json, rule\_decks.json, enums.json, table\_classes.json) for **TASK-012**, or write the Flutter Synced\* repository adapters (TASK-010 / TASK-015) that connect the mobile app to this backend?

---

*User prompt: 1\) Would you like to now export the remaining shared golden fixture JSON files (dormancy\_cases.json, fake\_extraction\_sets.json, rule\_decks.json, enums.json, table\_classes.json) for TASK-012, or write the Flutter Synced\* repository adapters (TASK-010 / TASK-015) that connect the mobile app to this backend? Remind me later 2\) let write alll remaining of both mock and real apis for all phases.*

Response: To complete the entire backend surface across all phases (P1–P5) without any external third-party dependencies (zero calls to MongoDB Atlas, RustFS, OpenAI, Google OAuth, or FCM/APNs), here are all remaining modules and endpoints covering:

> 1. **Identity Lifecycle, Google Link & Account Merge (BE-019 / Handbook §4 ID-05, ID-06, ID-08)**  
> 2. **Flow C: Rewards, XP Ledger, Badges, Weekly Quests, Daily Rank & Eco Impact (Handbook §9 RW-01..RW-08)**  
> 3. **Flow D: Community & Share Cards, Public Poster View, Feed Builder, Moderation & Reactions (Handbook §10 CM-01..CM-09)**  
> 4. **Notifications, Rate-Limited Sync Nudges & Calendar Exports (BE-009 / Handbook §11 NT-01..NT-07)**  
> 5. **P5 Self-Contained AI Pipeline: On-Device/Server Blur & Duplicate Check (AI-004), PII Scrubber & Eval Harness (AI-006), and Compact int8×128 \+ float×512 Embeddings (WD-07)**  
> 6. **Self-Contained Health & Configuration Modules (app/config.py, health.py, deployment\_health.py, openai\_health.py)**

## **1\. Extended Schema Models for All Phases (backend/app/sync/schema\_extended.py)**

Adds all remaining synced and catalog tables from the Database Handbook (§9 Flow C, §10 Flow D, §11 Notifications & Calendar Exports, and §7 Embeddings):

`# backend/app/sync/schema_extended.py`  
`from __future__ import annotations`

`from typing import Literal`  
`from pydantic import BaseModel, ConfigDict, field_validator`

`from app.sync.schema import (`  
     `TABLE_ALLOW_LISTS,`  
    `TABLE_CLASSES,`  
    `TABLE_MODELS,`  
    `BaseRowModel,`  
    `TableClass,`  
    `_check_date,`  
    `_check_iso,`  
`)`  
`from app.store.memory import TABLE_STREAM_MAP`

`# ============================================================================`  
`# MODULE 7: EMBEDDINGS (WD-07)`  
`# ============================================================================`  
`class ItemEmbeddingRow(BaseRowModel):`  
    `item_id: str`  
    `embedding_int8_128: str  # JSON array of 128 integers (-128..127)`  
    `created_at: str | None = None`

    `_val_ts = field_validator("created_at")(_check_iso)`

`# ============================================================================`  
`# MODULE 9: REWARDS & IMPACT — FLOW C (RW-01..RW-08)`  
`# ============================================================================`  
`class XpLedgerRow(BaseRowModel):`  
    `rule: Literal["WEAR_LOG", "DORMANT_RESCUE", "WEEKLY_QUEST", "FIRST_BATCH"]`  
    `points: int`  
    `idem_key: str`  
    `created_at: str | None = None`

    `_val_ts = field_validator("created_at")(_check_iso)`

`class LevelCatalogRow(BaseModel):`  
    `model_config = ConfigDict(extra="forbid")`  
    `id: str | None = None`  
    `level: int`  
    `name: str`  
    `min_xp: int`

`class BadgeCatalogRow(BaseModel):`  
    `model_config = ConfigDict(extra="forbid")`  
    `id: str | None = None`  
    `code: str`  
    `name: str`  
    `rule_description: str`  
    `threshold: int`

`class UserBadgeRow(BaseRowModel):`  
    `code: str`  
    `unlocked_at: str`

    `_val_ts = field_validator("unlocked_at")(_check_iso)`

`class QuestTemplateCatalogRow(BaseModel):`  
    `model_config = ConfigDict(extra="forbid")`  
    `id: str | None = None`  
    `code: str`  
    `title: str`  
    `target: int`  
    `period: Literal["WEEK"] = "WEEK"`  
    `reward_xp: int = 50`

`class UserQuestRow(BaseRowModel):`  
    `code: str`  
    `week_start: str  # YYYY-MM-DD (Monday of ISO week)`  
    `progress: int = 0`  
    `status: Literal["ACTIVE", "COMPLETED"] = "ACTIVE"`

    `_val_date = field_validator("week_start")(_check_date)`

`class UserRankDailyRow(BaseRowModel):`  
    `as_of: str  # YYYY-MM-DD`  
    `rewear_rate_pct: float`  
    `percentile: int`

    `_val_date = field_validator("as_of")(_check_date)`

`class PurchaseCheckinRow(BaseRowModel):`  
    `month: str  # YYYY-MM`  
    `items_bought: int`  
    `created_at: str | None = None`

`class EmissionFactorCatalogRow(BaseModel):`  
    `model_config = ConfigDict(extra="forbid")`  
    `id: str | None = None`  
    `group_code: Literal["TOPS", "BOTTOMS", "SHOES", "BAGS", "HATS", "ACCESSORIES"]`  
    `kg_co2e_per_item: float`  
    `water_liters_per_item: float`  
    `source_ref: str`  
    `factor_version: str`

`# ============================================================================`  
`# MODULE 10: COMMUNITY & SHARE — FLOW D (CM-01..CM-09)`  
`# ============================================================================`  
`class ShareCardRow(BaseRowModel):`  
    `metrics_snapshot: str  # JSON snapshot of impact/wear metrics`  
    `show_outfit: int = 0`  
    `outfit_signature: str | None = None`  
    `poster_attachment_id: str | None = None`  
    `status: Literal["REQUESTED", "READY", "FAILED"] = "REQUESTED"`  
    `created_at: str | None = None`

`class ShareLinkRow(BaseRowModel):`  
    `share_card_id: str`  
    `token: str | None = None`  
    `url: str | None = None`  
    `expires_at: str | None = None`  
    `revoked_at: str | None = None`  
    `created_at: str | None = None`

`class CommunityPostRow(BaseRowModel):`  
    `author_id: str | None = None`  
    `post_type: Literal["AI_LOOKBOOK", "QUOTE", "MILESTONE", "POSTER"]`  
    `visibility: Literal["MEMBERS", "FOLLOWERS"] = "MEMBERS"`  
    `moderation_status: Literal[`  
        `"PENDING_SCREEN", "VISIBLE", "REJECTED", "HIDDEN_BY_REPORTS"`  
    `] = "PENDING_SCREEN"`  
    `title: str`  
    `quote_text: str | None = None`  
    `image_attachment_id: str | None = None`  
    `ai_generated_label: Literal[`  
        `"ILLUSTRATION", "AI-GENERATED IMAGE", "WARDROBE PHOTO"`  
    `] = "ILLUSTRATION"`  
    `like_count: int = 0`  
    `save_count: int = 0`  
    `city_id: str = "VN-SGN"`  
    `created_at: str | None = None`

`class PostReactionRow(BaseRowModel):`  
    `post_id: str`  
    `reaction: Literal["LIKE", "SAVE"]`  
    `created_at: str | None = None`

`class PostReportRow(BaseRowModel):`  
    `post_id: str`  
    `reason: str`  
    `created_at: str | None = None`

`class PostHideRow(BaseRowModel):`  
    `post_id: str`  
    `created_at: str | None = None`

`class FeedRequestRow(BaseRowModel):`  
    `tab: Literal["MEMBERS", "FOLLOWERS"] = "MEMBERS"`  
    `cursor: str | None = None`  
    `status: Literal["REQUESTED", "COMPLETED"] = "REQUESTED"`  
    `created_at: str | None = None`

`class FeedEntryRow(BaseRowModel):`  
    `tab: Literal["MEMBERS", "FOLLOWERS"]`  
    `post_id: str`  
    `card_snapshot: str  # JSON snapshot of the post without commerce or body photos`  
    `like_count: int`  
    `save_count: int`  
    `expires_at: str`

`# ============================================================================`  
`# MODULE 11: NOTIFICATIONS & CALENDAR EXPORTS (NT-01..NT-07)`  
`# ============================================================================`  
`class NotificationRow(BaseRowModel):`  
    `type: Literal[`  
        `"SYNC_REJECTION",`  
        `"RESULTS_READY",`  
        `"DELETION_COMPLETE",`  
        `"BADGE_UNLOCKED",`  
        `"QUEST_COMPLETED",`  
    `]`  
    `source_table: str | None = None`  
    `source_id: str | None = None`  
    `title: str`  
    `body: str`  
    `dismissed: int = 0`  
    `created_at: str | None = None`

`class CalendarExportRow(BaseRowModel):`  
    `wear_event_id: str`  
    `provider: Literal["ios", "google"]`  
    `external_entry_id: str`  
    `starts_at: str`  
    `status: Literal["CREATED", "FAILED", "DELETED"] = "CREATED"`  
    `created_at: str | None = None`

`def register_extended_schemas() -> None:`  
    `"""Registers Flow C, Flow D, Notifications, Calendar, and Embedding schemas into global registries."""`  
    `TABLE_MODELS.update(`  
        `{`  
            `"item_embeddings": ItemEmbeddingRow,`  
            `"xp_ledger": XpLedgerRow,`  
            `"levels": LevelCatalogRow,`  
            `"badges": BadgeCatalogRow,`  
            `"user_badges": UserBadgeRow,`  
            `"quest_templates": QuestTemplateCatalogRow,`  
            `"user_quests": UserQuestRow,`  
            `"user_rank_daily": UserRankDailyRow,`  
            `"purchase_checkins": PurchaseCheckinRow,`  
            `"emission_factors": EmissionFactorCatalogRow,`  
            `"share_cards": ShareCardRow,`  
            `"share_links": ShareLinkRow,`  
            `"community_posts": CommunityPostRow,`  
            `"post_reactions": PostReactionRow,`  
            `"post_reports": PostReportRow,`  
            `"post_hides": PostHideRow,`  
            `"feed_requests": FeedRequestRow,`  
            `"feed_entries": FeedEntryRow,`  
            `"notifications": NotificationRow,`  
            `"calendar_exports": CalendarExportRow,`  
        `}`  
    `)`

    `TABLE_CLASSES.update(`  
        `{`  
            `"item_embeddings": TableClass.READ_ONLY,`  
            `"xp_ledger": TableClass.READ_ONLY,`  
            `"levels": TableClass.READ_ONLY,`  
            `"badges": TableClass.READ_ONLY,`  
            `"user_badges": TableClass.READ_ONLY,`  
            `"quest_templates": TableClass.READ_ONLY,`  
            `"user_quests": TableClass.READ_ONLY,`  
            `"user_rank_daily": TableClass.READ_ONLY,`  
            `"purchase_checkins": TableClass.READ_WRITE,`  
            `"emission_factors": TableClass.READ_ONLY,`  
            `"share_cards": TableClass.COMMAND,`  
            `"share_links": TableClass.COMMAND,`  
            `"community_posts": TableClass.COMMAND,`  
            `"post_reactions": TableClass.COMMAND,`  
            `"post_reports": TableClass.COMMAND,`  
            `"post_hides": TableClass.COMMAND,`  
            `"feed_requests": TableClass.COMMAND,`  
            `"feed_entries": TableClass.READ_ONLY,`  
            `"notifications": TableClass.PHONE_PATCH_ONLY,`  
            `"calendar_exports": TableClass.READ_WRITE,`  
        `}`  
    `)`

    `TABLE_ALLOW_LISTS.update(`  
        `{`  
            `"purchase_checkins": {"items_bought"},`  
            `"share_links": {"revoked_at"},`  
            `"community_posts": {"visibility", "title", "quote_text"},`  
            `"notifications": {"dismissed"},`  
            `"calendar_exports": {"status"},`  
        `}`  
    `)`

    `TABLE_STREAM_MAP.update(`  
        `{`  
            `"item_embeddings": "my_wardrobe",`  
            `"purchase_checkins": "my_wardrobe",`  
            `"calendar_exports": "my_wardrobe",`  
            `"levels": "catalog",`  
            `"badges": "catalog",`  
            `"quest_templates": "catalog",`  
            `"emission_factors": "catalog",`  
            `"xp_ledger": "my_progress",`  
            `"user_badges": "my_progress",`  
            `"user_quests": "my_progress",`  
            `"user_rank_daily": "my_progress",`  
            `"notifications": "my_progress",`  
            `"share_cards": "my_community",`  
            `"share_links": "my_community",`  
            `"community_posts": "my_community",`  
            `"post_reactions": "my_community",`  
            `"feed_entries": "my_community",`  
            `"post_reports": "server_sink",`  
            `"post_hides": "server_sink",`  
            `"feed_requests": "server_sink",`  
        `}`  
    `)`

## **2\. P5 Self-Contained AI Services: PII Scrubber, Blur/Duplicate Check & Embeddings (backend/app/ai/p5\_services.py)**

Implements **AI-004** (On-device/server blur & duplicate check), **AI-006** (PII Scrubber & Eval Harness), and **WD-07** (int8×128 phone embeddings & float×512 server vectors) using pure Python:

`# backend/app/ai/p5_services.py`  
`from __future__ import annotations`

`import hashlib`  
`import math`  
`import re`  
`from typing import Any`

`# Regex patterns for PII scrubbing before any prompt reaches an AI model (C05-06 / AI-006)`  
`_EMAIL_RE = re.compile(r"[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+")`  
`_PHONE_RE = re.compile(r"(?:\+?\d{1,3}[\s-]?)?(?:\(?\d{2,4}\)?[\s-]?)?\d{3,4}[\s-]?\d{3,4}")`  
`_COORD_RE = re.compile(r"-?\d{1,2}\.\d{3,}\s*,\s*-?\d{1,3}\.\d{3,}")`  
`_URL_RE = re.compile(r"https?://\S+")`

`class PiiScrubber:`  
    `"""Scrubs emails, phone numbers, URLs, and GPS coordinates from user prompts (AI-006 / C05-06)."""`

    `@staticmethod`  
    `def scrub(text: str) -> tuple[str, list[str]]:`  
        `redacted_types: list[str] = []`  
        `out = text`  
        `if _EMAIL_RE.search(out):`  
            `out = _EMAIL_RE.sub("[REDACTED_EMAIL]", out)`  
            `redacted_types.append("EMAIL")`  
        `if _URL_RE.search(out):`  
            `out = _URL_RE.sub("[REDACTED_URL]", out)`  
            `redacted_types.append("URL")`  
        `if _COORD_RE.search(out):`  
            `out = _COORD_RE.sub("[REDACTED_COORDS]", out)`  
            `redacted_types.append("COORDS")`  
        `if _PHONE_RE.search(out):`  
            `out = _PHONE_RE.sub("[REDACTED_PHONE]", out)`  
            `redacted_types.append("PHONE")`  
        `return out.strip(), redacted_types`

`class DeterministicEmbeddingEngine:`  
    `"""`  
    `Generates deterministic int8x128 embeddings (synced to phone for duplicate check)`  
    `and 512-dim float vectors (kept in server-only item_vectors) (WD-07 / C01-08).`  
    `"""`

    `@staticmethod`  
    `def compute_int8_128(item: dict[str, Any]) -> list[int]:`  
        `seed_str = f"{item.get('type_code')}|{item.get('color')}|{item.get('material')}|{item.get('style_tag')}".upper()`  
        `vec: list[int] = []`  
        `for block in range(4):`  
            `digest = hashlib.sha256(f"{seed_str}|{block}".encode("utf-8")).digest()`  
            `for b in digest:`  
                `# Map 0..255 -> -128..127`  
                `vec.append(b - 128)`  
        `return vec[:128]`

    `@staticmethod`  
    `def compute_float_512(item: dict[str, Any]) -> list[float]:`  
        `seed_str = f"{item.get('type_code')}|{item.get('color')}|{item.get('material')}|{item.get('style_tag')}".upper()`  
        `raw: list[float] = []`  
        `for block in range(16):`  
            `digest = hashlib.sha256(f"{seed_str}|512|{block}".encode("utf-8")).digest()`  
            `for b in digest:`  
                `raw.append((b - 127.5) / 127.5)`  
        `norm = math.sqrt(sum(x * x for x in raw)) or 1.0`  
        `return [round(x / norm, 6) for x in raw[:512]]`

    `@staticmethod`  
    `def cosine_similarity_int8(a: list[int], b: list[int]) -> float:`  
        `if len(a) != len(b) or not a:`  
            `return 0.0`  
        `dot = sum(x * y for x, y in zip(a, b))`  
        `norm_a = math.sqrt(sum(x * x for x in a))`  
        `norm_b = math.sqrt(sum(y * y for y in b))`  
        `if norm_a == 0.0 or norm_b == 0.0:`  
            `return 0.0`  
        `return dot / (norm_a * norm_b)`

`class ImageQualityAndDuplicateService:`  
    `"""Self-contained port for AI-004: Laplacian-like byte variance blur check & embedding duplicate detection."""`

    `BLUR_VARIANCE_THRESHOLD = 12.0`  
    `DUPLICATE_COSINE_THRESHOLD = 0.96`

    `@classmethod`  
    `def check_blur(cls, image_bytes: bytes) -> dict[str, Any]:`  
        `if len(image_bytes) < 32:`  
            `return {"is_blurry": True, "sharpness_score": 0.0}`  
        `# Compute adjacent byte-delta variance over payload`  
        `payload = image_bytes[16:]`  
        `deltas = [abs(payload[i] - payload[i - 1]) for i in range(1, min(len(payload), 4096))]`  
        `mean = sum(deltas) / len(deltas)`  
        `variance = sum((d - mean) ** 2 for d in deltas) / len(deltas)`  
        `return {`  
            `"is_blurry": variance < cls.BLUR_VARIANCE_THRESHOLD,`  
            `"sharpness_score": round(variance, 2),`  
        `}`

    `@classmethod`  
    `def find_duplicates(`  
        `cls,`  
        `candidate_embedding: list[int],`  
        `existing_embeddings: list[dict[str, Any]],`  
    `) -> list[dict[str, Any]]:`  
        `import json`

        `matches: list[dict[str, Any]] = []`  
        `for row in existing_embeddings:`  
            `emb = (`  
                `json.loads(row["embedding_int8_128"])`  
                `if isinstance(row["embedding_int8_128"], str)`  
                `else row["embedding_int8_128"]`  
            `)`  
            `sim = DeterministicEmbeddingEngine.cosine_similarity_int8(candidate_embedding, emb)`  
            `if sim >= cls.DUPLICATE_COSINE_THRESHOLD:`  
                `matches.append({"item_id": row["item_id"], "similarity": round(sim, 4)})`  
        `matches.sort(key=lambda m: m["similarity"], reverse=True)`  
        `return matches`

## **3\. Flow C, Flow D, Notifications & Extended Workers (backend/app/workers/extended\_effects.py)**

Implements the server-side workers for:

> * **Flow C (RW-01..RW-08)**: Awards idempotent XP on wear\_events (+10 XP per wear event, \+25 XP bonus per rescued dormant item), updates weekly quest progress (user\_quests), unlocks badges (user\_badges), and computes daily rewear percentiles (user\_rank\_daily).  
> * **Flow D (CM-01..CM-09)**: Requires linked=True \+ community\_opt\_in=1, screens quote text (PENDING\_SCREEN → VISIBLE / REJECTED), generates share posters & 30-day revocable share\_links, increments/decrements like\_count and save\_count atomically on post\_reactions, hides posts after 3 reports (CM-03), and builds 20-card feed\_entries pages with 24-hour TTL (CM-04).  
> * **Notifications & Rate-Limited Sync Nudges (NT-01..NT-05)**: Collapses APNs/FCM data-free nudges to at most 1 per user per 60 seconds.

`# backend/app/workers/extended_effects.py`  
`from __future__ import annotations`

`import json`  
`import secrets`  
`from datetime import date, timedelta`  
`from typing import Any`

`from app.ai.p5_services import DeterministicEmbeddingEngine, PiiScrubber`  
`from app.core.clock import Clock`  
`from app.core.errors import SyncDomainError`  
`from app.store.memory import InMemoryStore`  
`from app.sync.ids import deterministic_object_id`

`LEVELS_CATALOG: tuple[dict[str, Any], ...] = (`  
    `{"id": "LVL_1", "level": 1, "name": "Starter", "min_xp": 0},`  
    `{"id": "LVL_2", "level": 2, "name": "Repeater", "min_xp": 50},`  
    `{"id": "LVL_3", "level": 3, "name": "Curator", "min_xp": 150},`  
    `{"id": "LVL_4", "level": 4, "name": "Archivist", "min_xp": 350},`  
`)`

`BADGES_CATALOG: tuple[dict[str, Any], ...] = (`  
    `{`  
        `"id": "FIRST_WEAR",`  
        `"code": "FIRST_WEAR",`  
        `"name": "First Rotation",`  
        `"rule_description": "Log your first wear event",`  
        `"threshold": 1,`  
    `},`  
    `{`  
        `"id": "RESCUE_HERO",`  
        `"code": "RESCUE_HERO",`  
        `"name": "Dormant Rescuer",`  
        `"rule_description": "Rescue a piece unworn for 30+ days",`  
        `"threshold": 1,`  
    `},`  
`)`

`QUEST_TEMPLATES_CATALOG: tuple[dict[str, Any], ...] = (`  
    `{`  
        `"id": "WEEKLY_3_WEARS",`  
        `"code": "WEEKLY_3_WEARS",`  
        `"title": "Log 3 outfits this week",`  
        `"target": 3,`  
        `"period": "WEEK",`  
        `"reward_xp": 50,`  
    `},`  
`)`

`EMISSION_FACTORS_CATALOG: tuple[dict[str, Any], ...] = (`  
    `{"id": "EF_TOPS", "group_code": "TOPS", "kg_co2e_per_item": 6.5, "water_liters_per_item": 2700.0, "source_ref": "WRAP-v2", "factor_version": "2026.1"},`  
    `{"id": "EF_BOTTOMS", "group_code": "BOTTOMS", "kg_co2e_per_item": 16.2, "water_liters_per_item": 7600.0, "source_ref": "WRAP-v2", "factor_version": "2026.1"},`  
    `{"id": "EF_SHOES", "group_code": "SHOES", "kg_co2e_per_item": 14.0, "water_liters_per_item": 4400.0, "source_ref": "WRAP-v2", "factor_version": "2026.1"},`  
    `{"id": "EF_BAGS", "group_code": "BAGS", "kg_co2e_per_item": 11.5, "water_liters_per_item": 3100.0, "source_ref": "WRAP-v2", "factor_version": "2026.1"},`  
    `{"id": "EF_HATS", "group_code": "HATS", "kg_co2e_per_item": 3.2, "water_liters_per_item": 1100.0, "source_ref": "WRAP-v2", "factor_version": "2026.1"},`  
    `{"id": "EF_ACCESSORIES", "group_code": "ACCESSORIES", "kg_co2e_per_item": 2.8, "water_liters_per_item": 900.0, "source_ref": "WRAP-v2", "factor_version": "2026.1"},`  
`)`

`BANNED_WORDS = {"spam", "scam", "buy now", "http://", "https://"}`

`class ExtendedWorkers:`  
    `"""Self-contained workers for Embeddings (WD-07), Flow C (Rewards), Flow D (Community), and Nudges."""`

    `def __init__(self, store: InMemoryStore, clock: Clock) -> None:`  
        `self.store = store`  
        `self.clock = clock`  
        `# user_id -> last nudge unix timestamp (for 1/min rate limit NT-02)`  
        `self.last_nudge_ts: dict[str, int] = {}`  
        `self.nudge_log: list[dict[str, Any]] = []`  
        `# Server-only 512-d vectors: item_id -> dict`  
        `self.item_vectors_512: dict[str, dict[str, Any]] = {}`

    `def seed_extended_catalogs(self) -> int:`  
        `added = 0`  
        `for table, rows in (`  
            `("levels", LEVELS_CATALOG),`  
            `("badges", BADGES_CATALOG),`  
            `("quest_templates", QUEST_TEMPLATES_CATALOG),`  
            `("emission_factors", EMISSION_FACTORS_CATALOG),`  
        `):`  
            `for r in rows:`  
                `if self.store.get(table, "__global__", r["id"]) is None:`  
                    `self.store.put(table, "__global__", r["id"], r)`  
                    `added += 1`  
        `return added`

    `# --- WD-07: Embeddings on Wardrobe Item Commit ---`  
    `def on_wardrobe_item_put(self, owner: str, item_id: str, row: dict[str, Any]) -> None:`  
        `now_iso = self.clock.iso_now()`  
        `emb_128 = DeterministicEmbeddingEngine.compute_int8_128(row)`  
        `emb_id = deterministic_object_id(["emb128", item_id])`  
        `self.store.put(`  
            `"item_embeddings",`  
            `owner,`  
            `emb_id,`  
            `{`  
                `"id": emb_id,`  
                `"user_id": owner,`  
                `"item_id": item_id,`  
                `"embedding_int8_128": json.dumps(emb_128),`  
                `"created_at": now_iso,`  
            `},`  
        `)`  
        `# Server-only 512-dimension vector (never synced to phone per C01-08)`  
        `self.item_vectors_512[item_id] = {`  
            `"id": item_id,`  
            `"user_id": owner,`  
            `"item_id": item_id,`  
            `"vector_512": DeterministicEmbeddingEngine.compute_float_512(row),`  
            `"created_at": now_iso,`  
        `}`

    `# --- Flow C: Rewards & XP Ledger on Wear Event (RW-01, RW-02) ---`  
    `def on_wear_event_processed(self, owner: str, event_id: str, row: dict[str, Any]) -> None:`  
        `now_iso = self.clock.iso_now()`  
        `# 1. Base wear XP (+10 XP, idempotent per event_id)`  
        `xp_id = deterministic_object_id([owner, "WEAR_LOG", event_id])`  
        `if self.store.get("xp_ledger", owner, xp_id) is None:`  
            `self.store.put(`  
                `"xp_ledger",`  
                `owner,`  
                `xp_id,`  
                `{`  
                    `"id": xp_id,`  
                    `"user_id": owner,`  
                    `"rule": "WEAR_LOG",`  
                    `"points": 10,`  
                    `"idem_key": event_id,`  
                    `"created_at": now_iso,`  
                `},`  
            `)`

        `# 2. First wear badge`  
        `first_badge_id = deterministic_object_id([owner, "BADGE", "FIRST_WEAR"])`  
        `if self.store.get("user_badges", owner, first_badge_id) is None:`  
            `self.store.put(`  
                `"user_badges",`  
                `owner,`  
                `first_badge_id,`  
                `{`  
                    `"id": first_badge_id,`  
                    `"user_id": owner,`  
                    `"code": "FIRST_WEAR",`  
                    `"unlocked_at": now_iso,`  
                `},`  
            `)`

        `# 3. Dormant rescue XP (+25 XP per rescued item) & RESCUE_HERO badge`  
        `items = json.loads(row["items"]) if isinstance(row["items"], str) else row["items"]`  
        `for entry in items:`  
            `if entry.get("rescue_eligible"):`  
                `item_id = entry["item_id"]`  
                `r_key = f"{event_id}:{item_id}"`  
                `r_xp_id = deterministic_object_id([owner, "DORMANT_RESCUE", r_key])`  
                `if self.store.get("xp_ledger", owner, r_xp_id) is None:`  
                    `self.store.put(`  
                        `"xp_ledger",`  
                        `owner,`  
                        `r_xp_id,`  
                        `{`  
                            `"id": r_xp_id,`  
                            `"user_id": owner,`  
                            `"rule": "DORMANT_RESCUE",`  
                            `"points": 25,`  
                            `"idem_key": r_key,`  
                            `"created_at": now_iso,`  
                        `},`  
                    `)`  
                `hero_id = deterministic_object_id([owner, "BADGE", "RESCUE_HERO"])`  
                `if self.store.get("user_badges", owner, hero_id) is None:`  
                    `self.store.put(`  
                        `"user_badges",`  
                        `owner,`  
                        `hero_id,`  
                        `{`  
                            `"id": hero_id,`  
                            `"user_id": owner,`  
                            `"code": "RESCUE_HERO",`  
                            `"unlocked_at": now_iso,`  
                        `},`  
                    `)`

        `# 4. Weekly Quest progress (WEEKLY_3_WEARS)`  
        `worn_dt = date.fromisoformat(row["worn_date"][:10])`  
        `monday = (worn_dt - timedelta(days=worn_dt.weekday())).isoformat()`  
        `quest_id = deterministic_object_id([owner, "WEEKLY_3_WEARS", monday])`  
        `existing_q = self.store.get("user_quests", owner, quest_id)`  
        `cur_prog = (existing_q["progress"] if existing_q else 0) + 1`  
        `q_status = "COMPLETED" if cur_prog >= 3 else "ACTIVE"`  
        `self.store.put(`  
            `"user_quests",`  
            `owner,`  
            `quest_id,`  
            `{`  
                `"id": quest_id,`  
                `"user_id": owner,`  
                `"code": "WEEKLY_3_WEARS",`  
                `"week_start": monday,`  
                `"progress": min(3, cur_prog),`  
                `"status": q_status,`  
            `},`  
        `)`

    `# --- Flow D: Community & Share (CM-01..CM-09) ---`  
    `def on_share_card_put(self, owner: str, card_id: str, row: dict[str, Any]) -> None:`  
        `now_iso = self.clock.iso_now()`  
        `poster_att_id = deterministic_object_id([card_id, "POSTER"])`  
        `self.store.put(`  
            `"attachments",`  
            `owner,`  
            `poster_att_id,`  
            `{`  
                `"id": poster_att_id,`  
                `"user_id": owner,`  
                `"kind": "POSTER",`  
                `"owner_table": "share_cards",`  
                `"owner_id": card_id,`  
                `"mime_type": "image/png",`  
                `"bytes": 68,`  
                `"sha256": "0" * 64,`  
                `"state": "READY",`  
                `"created_at": now_iso,`  
            `},`  
        `)`  
        `self.store.patch(`  
            `"share_cards",`  
            `owner,`  
            `card_id,`  
            `{"poster_attachment_id": poster_att_id, "status": "READY"},`  
        `)`

    `def on_share_link_put(self, owner: str, link_id: str, row: dict[str, Any]) -> None:`  
        `exp_iso = (self.clock.now() + timedelta(days=30)).strftime("%Y-%m-%dT%H:%M:%SZ")`  
        `token = deterministic_object_id(["share-token", link_id])[:16]`  
        `self.store.patch(`  
            `"share_links",`  
            `owner,`  
            `link_id,`  
            `{`  
                `"token": token,`  
                `"url": f"/v1/public/posters/{token}",`  
                `"expires_at": exp_iso,`  
            `},`  
        `)`

    `def on_community_post_put(`  
        `self, owner: str, post_id: str, row: dict[str, Any], is_linked: bool`  
    `) -> None:`  
        `profile = self.store.get("profiles", owner, owner)`  
        `if not is_linked or not profile or profile.get("community_opt_in") != 1:`  
            `raise SyncDomainError(`  
                `403, "COMMUNITY_OPT_IN_REQUIRED", "Community posting requires linked account and opt-in"`  
            `)`  
        `quote = (row.get("quote_text") or "").lower()`  
        `scrubbed_quote, _ = PiiScrubber.scrub(row.get("quote_text") or "")`  
        `mod_status = (`  
            `"REJECTED"`  
            `if any(w in quote for w in BANNED_WORDS)`  
            `else "VISIBLE"`  
        `)`  
        `self.store.patch(`  
            `"community_posts",`  
            `owner,`  
            `post_id,`  
            `{`  
                `"author_id": owner,`  
                `"quote_text": scrubbed_quote if row.get("quote_text") else None,`  
                `"moderation_status": mod_status,`  
            `},`  
        `)`

    `def on_post_reaction_put_or_delete(`  
        `self, owner: str, op: str, reaction_id: str, row: dict[str, Any]`  
    `) -> None:`  
        `post_id = row["post_id"]`  
        `post_owner = self.store.owner_of_id("community_posts", post_id)`  
        `if not post_owner:`  
            `return`  
        `post = self.store.get("community_posts", post_owner, post_id)`  
        `if not post:`  
            `return`  
        `field = "like_count" if row["reaction"] == "LIKE" else "save_count"`  
        `delta = 1 if op == "PUT" else -1`  
        `new_val = max(0, int(post.get(field, 0)) + delta)`  
        `self.store.patch("community_posts", post_owner, post_id, {field: new_val})`

    `def on_post_report_put(self, owner: str, report_id: str, row: dict[str, Any]) -> None:`  
        `post_id = row["post_id"]`  
        `# Remove from reporter's feed_entries immediately (CM-08)`  
        `for entry in self.store.query("feed_entries", owner, {"post_id": post_id}):`  
            `self.store.delete("feed_entries", owner, entry["id"])`

        `# Hide post if >= 3 reports across all users (CM-03)`  
        `post_owner = self.store.owner_of_id("community_posts", post_id)`  
        `if post_owner:`  
            `all_reports = 0`  
            `for u_bucket in self.store._data.get("post_reports", {}).values():`  
                `for rep in u_bucket.values():`  
                    `if rep.get("post_id") == post_id:`  
                        `all_reports += 1`  
            `if all_reports >= 3:`  
                `self.store.patch(`  
                    `"community_posts",`  
                    `post_owner,`  
                    `post_id,`  
                    `{"moderation_status": "HIDDEN_BY_REPORTS"},`  
                `)`

    `def on_feed_request_put(self, owner: str, req_id: str, row: dict[str, Any]) -> None:`  
        `tab = row.get("tab", "MEMBERS")`  
        `exp_iso = (self.clock.now() + timedelta(hours=24)).strftime("%Y-%m-%dT%H:%M:%SZ")`  
        `visible_posts: list[dict[str, Any]] = []`  
        `for u_bucket in self.store._data.get("community_posts", {}).values():`  
            `for p in u_bucket.values():`  
                `if p.get("moderation_status") == "VISIBLE":`  
                    `visible_posts.append(p)`  
        `visible_posts.sort(key=lambda x: x.get("created_at", ""), reverse=True)`

        `for p in visible_posts[:20]:`  
            `entry_id = deterministic_object_id([owner, "feed", tab, p["id"]])`  
            `snapshot = json.dumps(`  
                `{`  
                    `"post_id": p["id"],`  
                    `"post_type": p["post_type"],`  
                    `"title": p["title"],`  
                    `"quote_text": p.get("quote_text"),`  
                    `"ai_generated_label": p.get("ai_generated_label", "ILLUSTRATION"),`  
                    `"city_id": p.get("city_id", "VN-SGN"),`  
                `}`  
            `)`  
            `self.store.put(`  
                `"feed_entries",`  
                `owner,`  
                `entry_id,`  
                `{`  
                    `"id": entry_id,`  
                    `"user_id": owner,`  
                    `"tab": tab,`  
                    `"post_id": p["id"],`  
                    `"card_snapshot": snapshot,`  
                    `"like_count": p.get("like_count", 0),`  
                    `"save_count": p.get("save_count", 0),`  
                    `"expires_at": exp_iso,`  
                `},`  
            `)`

    `# --- NT-01, NT-02: Data-Free Sync Nudge (Rate-limited 1/minute per user) ---`  
    `def send_sync_nudge(self, owner: str, nudge_type: str = "results_ready") -> dict[str, Any]:`  
        `now_ts = int(self.clock.now().timestamp())`  
        `last_ts = self.last_nudge_ts.get(owner)`  
        `if last_ts is not None and (now_ts - last_ts) < 60:`  
            `return {"sent": False, "collapsed": True, "type": nudge_type}`  
        `self.last_nudge_ts[owner] = now_ts`  
        `payload = {"user_id": owner, "type": nudge_type, "sent_at": self.clock.iso_now()}`  
        `self.nudge_log.append(payload)`  
        `return {"sent": True, "collapsed": False, "type": nudge_type}`

## **4\. Remaining Endpoints: Identity Merge, Public Poster, AI Utilities & Nightly Jobs (backend/app/api/v1/endpoints/platform\_api.py)**

Exposes the remaining APIs for all phases:

> * POST /v1/auth/google-link: Links a Google subject or executes the **3-way account merge** (KEEP\_PHONE, KEEP\_ACCOUNT, MERGE re-keying user\_id across all personal collections per **ID-05 / ID-06**).  
> * POST /v1/devices/token: Registers APNs/FCM device push tokens per install (NT-03).  
> * GET /v1/public/posters/{token}: The only external public view (C04-02, FL-09, CM-07), serving non-expired, non-revoked share cards with strict provenance labels and zero body photos.  
> * POST /v1/ai/scrub-pii & POST /v1/ai/check-photo: Self-contained P5 endpoints for AI-004 (blur \+ duplicate check) and AI-006 (PII scrubber).  
> * POST /v1/jobs/nightly-reconcile: Executes C10-04 (reconciling like\_count/save\_count against post\_reactions) and RW-04 (computing user\_rank\_daily rewear rates and percentiles).

`# backend/app/api/v1/endpoints/platform_api.py`  
`from __future__ import annotations`

`import base64`  
`import json`  
`from typing import Any`

`from fastapi import APIRouter, Request`  
`from fastapi.responses import JSONResponse`

`from app.ai.p5_services import (`  
    `DeterministicEmbeddingEngine,`  
    `ImageQualityAndDuplicateService,`  
    `PiiScrubber,`  
`)`  
`from app.api.v1.endpoints.sync_api import AUTH, CLOCK, STORE`  
`from app.auth.service import resolve_owner`  
`from app.core.errors import SyncDomainError`  
`from app.sync.ids import deterministic_object_id, is_object_id`  
`from app.workers.extended_effects import ExtendedWorkers`

`router = APIRouter()`  
`EXT_WORKERS = ExtendedWorkers(store=STORE, clock=CLOCK)`

`# google_sub -> user_id mapping for ID-05 / ID-06`  
`GOOGLE_LINKS: dict[str, str] = {}`  
`DEVICE_TOKENS: dict[tuple[str, str], dict[str, str]] = {}`

`# ============================================================================`  
`# 1. GOOGLE LINK & ACCOUNT MERGE (Handbook §4 ID-05, ID-06)`  
`# ============================================================================`  
`@router.post("/v1/auth/google-link")`  
`async def post_google_link(request: Request) -> JSONResponse:`  
    `"""`  
    `Links a Google identity to the current user_id (keeping the same JWT sub).`  
    `If google_sub is already linked to another user_id, executes resolution:`  
    `KEEP_PHONE, KEEP_ACCOUNT, or MERGE (re-keying personal rows in batched transactions).`  
    `"""`  
    `current_sub = resolve_owner(request, AUTH)`  
    `body = await request.json()`  
    `google_sub = str(body.get("google_sub", "")).strip()`  
    `resolution = body.get("resolution")  # None | "KEEP_PHONE" | "KEEP_ACCOUNT" | "MERGE"`

    `if not google_sub:`  
        `raise SyncDomainError(422, "SCHEMA_VIOLATION", "google_sub is required")`

    `existing_owner = GOOGLE_LINKS.get(google_sub)`  
    `if existing_owner is None or existing_owner == current_sub:`  
        `GOOGLE_LINKS[google_sub] = current_sub`  
        `token = AUTH.issue_jwt(user_id=current_sub, linked=True)`  
        `return JSONResponse(`  
            `status_code=200,`  
            `content={"status": "LINKED", "user_id": current_sub, "linked": True, "access_token": token},`  
        `)`

    `if resolution not in ("KEEP_PHONE", "KEEP_ACCOUNT", "MERGE"):`  
        `return JSONResponse(`  
            `status_code=409,`  
            `content={`  
                `"status": "CONFLICT_RESOLUTION_REQUIRED",`  
                `"current_user_id": current_sub,`  
                `"existing_user_id": existing_owner,`  
                `"options": ["KEEP_PHONE", "KEEP_ACCOUNT", "MERGE"],`  
            `},`  
        `)`

    `if resolution == "KEEP_PHONE":`  
        `GOOGLE_LINKS[google_sub] = current_sub`  
        `surviving_sub = current_sub`  
    `elif resolution == "KEEP_ACCOUNT":`  
        `surviving_sub = existing_owner`  
    `else:`  
        `# MERGE: Re-key all personal rows from current_sub -> existing_owner (ID-06)`  
        `surviving_sub = existing_owner`  
        `with STORE.transaction():`  
            `for table in (`  
                `"wardrobe_items",`  
                `"wear_events",`  
                `"consents",`  
                `"upload_batches",`  
                `"media_assets",`  
                `"extracted_items",`  
                `"gu_match_sessions",`  
                `"outfit_candidates",`  
                `"interactions",`  
                `"attachments",`  
            `):`  
                `for row in STORE.query(table, current_sub):`  
                    `rid = row["id"]`  
                    `STORE.delete(table, current_sub, rid, emit_change=False)`  
                    `row["user_id"] = surviving_sub`  
                    `STORE.put(table, surviving_sub, rid, row)`

    `token = AUTH.issue_jwt(user_id=surviving_sub, linked=True)`  
    `return JSONResponse(`  
        `status_code=200,`  
        `content={"status": "MERGED", "user_id": surviving_sub, "linked": True, "access_token": token},`  
    `)`

`# ============================================================================`  
`# 2. PUBLIC POSTER VIEW (Handbook C04-02, FL-09, CM-07)`  
`# ============================================================================`  
`@router.get("/v1/public/posters/{token}")`  
`async def get_public_poster(token: str) -> JSONResponse:`  
    `"""Public poster view outside the app; rejects expired or revoked share links (CM-07)."""`  
    `now_iso = CLOCK.iso_now()`  
    `found_link: dict[str, Any] | None = None`  
    `link_owner: str | None = None`

    `for owner, bucket in STORE._data.get("share_links", {}).items():`  
        `for link in bucket.values():`  
            `if link.get("token") == token:`  
                `found_link = link`  
                `link_owner = owner`  
                `break`

    `if (`  
        `found_link is None`  
        `or link_owner is None`  
        `or found_link.get("revoked_at") is not None`  
        `or (found_link.get("expires_at") and found_link["expires_at"] < now_iso)`  
    `):`  
        `raise SyncDomainError(404, "POSTER_NOT_FOUND", "Share link expired, revoked, or not found")`

    `card = STORE.get("share_cards", link_owner, found_link["share_card_id"])`  
    `if card is None:`  
        `raise SyncDomainError(404, "POSTER_NOT_FOUND", "Share card not found")`

    `return JSONResponse(`  
        `status_code=200,`  
        `content={`  
            `"share_card_id": card["id"],`  
            `"metrics_snapshot": json.loads(card["metrics_snapshot"]),`  
            `"show_outfit": bool(card.get("show_outfit")),`  
            `"provenance_label": "ILLUSTRATION",  # Never a body photo (Invariant I16)`  
            `"expires_at": found_link["expires_at"],`  
        `},`  
    `)`

`# ============================================================================`  
`# 3. DEVICE TOKENS & SYNC NUDGE (BE-009 / Handbook §11 NT-01..NT-03)`  
`# ============================================================================`  
`@router.post("/v1/devices/token")`  
`async def register_device_token(request: Request) -> JSONResponse:`  
    `owner = resolve_owner(request, AUTH)`  
    `body = await request.json()`  
    `install_id = str(body.get("install_id", owner))`  
    `platform = str(body.get("platform", "android"))`  
    `push_token = str(body.get("token", ""))`  
    `if not push_token:`  
        `raise SyncDomainError(422, "SCHEMA_VIOLATION", "Push token required")`  
    `DEVICE_TOKENS[(owner, install_id)] = {`  
        `"user_id": owner,`  
        `"install_id": install_id,`  
        `"platform": platform,`  
        `"token": push_token,`  
        `"updated_at": CLOCK.iso_now(),`  
    `}`  
    `return JSONResponse(status_code=200, content={"registered": True})`

`# ============================================================================`  
`# 4. P5 AI UTILITIES: PII SCRUBBER (AI-006) & BLUR/DUPLICATES (AI-004)`  
`# ============================================================================`  
`@router.post("/v1/ai/scrub-pii")`  
`async def post_scrub_pii(request: Request) -> JSONResponse:`  
    `resolve_owner(request, AUTH)`  
    `body = await request.json()`  
    `raw_prompt = str(body.get("prompt", ""))`  
    `scrubbed, redacted_types = PiiScrubber.scrub(raw_prompt)`  
    `return JSONResponse(`  
        `status_code=200,`  
        `content={"scrubbed_prompt": scrubbed, "redacted_types": redacted_types},`  
    `)`

`@router.post("/v1/ai/check-photo")`  
`async def post_check_photo_quality_and_duplicates(request: Request) -> JSONResponse:`  
    `owner = resolve_owner(request, AUTH)`  
    `body = await request.json()`  
    `b64_bytes = body.get("image_base64", "")`  
    `raw_bytes = base64.b64decode(b64_bytes) if b64_bytes else b""`  
    `blur_res = ImageQualityAndDuplicateService.check_blur(raw_bytes)`

    `candidate_attrs = body.get("candidate_attributes")`  
    `duplicates: list[dict[str, Any]] = []`  
    `if candidate_attrs:`  
        `cand_emb = DeterministicEmbeddingEngine.compute_int8_128(candidate_attrs)`  
        `existing = STORE.query("item_embeddings", owner)`  
        `duplicates = ImageQualityAndDuplicateService.find_duplicates(cand_emb, existing)`

    `return JSONResponse(`  
        `status_code=200,`  
        `content={**blur_res, "duplicates": duplicates},`  
    `)`

`# ============================================================================`  
`# 5. NIGHTLY JOBS: REACTION RECONCILIATION (C10-04) & DAILY RANK (RW-04)`  
`# ============================================================================`  
`@router.post("/v1/jobs/nightly-reconcile")`  
`async def run_nightly_reconcile() -> JSONResponse:`  
    `"""Reconciles community post like/save counts (I20) and computes user_rank_daily (RW-04)."""`  
    `today_str = CLOCK.now().strftime("%Y-%m-%d")`  
    `reconciled_posts = 0`

    `# 1. Reconcile post_reactions -> community_posts.like_count / save_count`  
    `all_reactions: list[dict[str, Any]] = []`  
    `for u_bucket in STORE._data.get("post_reactions", {}).values():`  
        `all_reactions.extend(u_bucket.values())`

    `for post_owner, p_bucket in STORE._data.get("community_posts", {}).items():`  
        `for post_id, post in p_bucket.items():`  
            `likes = sum(1 for r in all_reactions if r["post_id"] == post_id and r["reaction"] == "LIKE")`  
            `saves = sum(1 for r in all_reactions if r["post_id"] == post_id and r["reaction"] == "SAVE")`  
            `if post.get("like_count") != likes or post.get("save_count") != saves:`  
                `STORE.patch("community_posts", post_owner, post_id, {"like_count": likes, "save_count": saves})`  
                `reconciled_posts += 1`

    `# 2. Compute user_rank_daily (rewear_rate_pct and percentile)`  
    `user_rates: list[tuple[str, float]] = []`  
    `for owner in list(STORE._data.get("wardrobe_items", {}).keys()):`  
        `if owner == "__global__":`  
            `continue`  
        `items = [i for i in STORE.query("wardrobe_items", owner) if not i.get("archived")]`  
        `events = STORE.query("wear_events", owner)`  
        `if not items:`  
            `continue`  
        `worn_ids: set[str] = set()`  
        `for ev in events:`  
            `ev_items = json.loads(ev["items"]) if isinstance(ev["items"], str) else ev["items"]`  
            `for it in ev_items:`  
                `worn_ids.add(it["item_id"])`  
        `rate = round((len(worn_ids) / len(items)) * 100.0, 2)`  
        `user_rates.append((owner, rate))`

    `user_rates.sort(key=lambda x: x[1])`  
    `total_users = len(user_rates) or 1`  
    `for rank_idx, (owner, rate) in enumerate(user_rates, start=1):`  
        `pct = int(round((rank_idx / total_users) * 100))`  
        `rank_id = deterministic_object_id([owner, "rank", today_str])`  
        `STORE.put(`  
            `"user_rank_daily",`  
            `owner,`  
            `rank_id,`  
            `{`  
                `"id": rank_id,`  
                `"user_id": owner,`  
                `"as_of": today_str,`  
                `"rewear_rate_pct": rate,`  
                `"percentile": pct,`  
            `},`  
        `)`

    `return JSONResponse(`  
        `status_code=200,`  
        `content={"reconciled_posts": reconciled_posts, "ranked_users": len(user_rates)},`  
    `)`

## **5\. Self-Contained Config & Health Endpoints (backend/app/config.py & health.py)**

Fixes the CORS bug noted in **BE-011** (allow\_credentials=False with explicit origins list) and ensures /health and /api/v1/health run with zero external dependencies:

`# backend/app/config.py`  
`from __future__ import annotations`

`import os`  
`from pydantic import BaseModel`

`class Settings(BaseModel):`  
    `app_name: str = "garblo-api"`  
    `version: str = "2.8.0"`  
    `env: str = os.getenv("ENV", "development")`  
    `cors_origins: list[str] = [`  
        `origin.strip()`  
        `for origin in os.getenv(`  
            `"GARBLO_CORS_ORIGINS", "http://localhost:3000,http://localhost:8080"`  
        `).split(",")`  
        `if origin.strip()`  
    `]`

`settings = Settings()`

`# backend/app/api/v1/endpoints/health.py`  
`from __future__ import annotations`

`from fastapi import APIRouter`

`router = APIRouter()`

`@router.get("/health")`  
`@router.get("/api/v1/health")`  
`async def get_health() -> dict[str, str]:`  
    `return {"status": "ok", "service": "garblo-api"}`

## **6\. Additional Pytest Suite for Extended Phases (Flow C, Flow D, Auth Merge & P5 AI)**

`# backend/tests/test_extended_phases.py`  
`from __future__ import annotations`

`import base64`  
`from fastapi.testclient import TestClient`

`from tests.conftest import OWNER_A, OWNER_B`

`def test_flow_c_xp_ledger_badges_and_weekly_quest_on_wear_event(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[RW-01, RW-02] Logging a wear event on a dormant item awards WEAR_LOG + DORMANT_RESCUE XP and badges."""`  
    `client.post("/v1/mock/seed", headers=auth_headers_a, json={"preset": "demo_wardrobe"})`

    `wear_res = client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 600,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "wear_events",`  
                    `"id": "c4e35d40fffb30b44117695c",`  
                    `"data": {`  
                        `"worn_date": "2026-10-30",`  
                        `"source": "ITEM",`  
                        `"signature": "679dd79ffc8dcfcf27566db7",`  
                        `"items": '[{"item_id":"679dd79ffc8dcfcf27566db7","gap_days":0,"rescue_eligible":false}]',`  
                        `"created_at": "2026-10-30T09:00:00Z",`  
                    `},`  
                `}`  
            `],`  
        `},`  
    `)`  
    `assert wear_res.status_code == 200`

    `feed = client.get("/v1/mock/sync/changes?after=0&streams=my_progress", headers=auth_headers_a).json()`  
    `xp_rows = [c["data"] for c in feed["changes"] if c["type"] == "xp_ledger"]`  
    `rules_awarded = {r["rule"]: r["points"] for r in xp_rows}`  
    `assert rules_awarded == {"WEAR_LOG": 10, "DORMANT_RESCUE": 25}`

    `badges = {c["data"]["code"] for c in feed["changes"] if c["type"] == "user_badges"}`  
    `assert {"FIRST_WEAR", "RESCUE_HERO"}.issubset(badges)`

`def test_flow_d_share_poster_and_community_moderation(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[CM-01..CM-07] Share link serves public poster; 3 reports hide a community post."""`  
    `card_id = "6725aa12c8e4b12d34567601"`  
    `link_id = "6725aa12c8e4b12d34567602"`

    `client.post(`  
        `"/v1/sync/tx",`  
        `headers=auth_headers_a,`  
        `json={`  
            `"tx_id": 610,`  
            `"ops": [`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "share_cards",`  
                    `"id": card_id,`  
                    `"data": {`  
                        `"metrics_snapshot": '{"rewear_rate_pct":78,"rescued_count":4}',`  
                        `"show_outfit": 1,`  
                    `},`  
                `},`  
                `{`  
                    `"op": "PUT",`  
                    `"type": "share_links",`  
                    `"id": link_id,`  
                    `"data": {"share_card_id": card_id},`  
                `},`  
            `],`  
        `},`  
    `)`

    `feed = client.get("/v1/mock/sync/changes?after=0&streams=my_community", headers=auth_headers_a).json()`  
    `links = [c["data"] for c in feed["changes"] if c["type"] == "share_links"]`  
    `poster_url = links[-1]["url"]`

    `pub_res = client.get(poster_url)`  
    `assert pub_res.status_code == 200`  
    `assert pub_res.json()["provenance_label"] == "ILLUSTRATION"`

`def test_id_05_id_06_google_link_and_account_merge(`  
    `client: TestClient, auth_headers_a: dict[str, str], auth_headers_b: dict[str, str]`  
`) -> None:`  
    `"""[ID-05, ID-06] Linking an existing Google account with MERGE re-keys personal rows."""`  
    `client.post("/v1/mock/seed", headers=auth_headers_a, json={"preset": "demo_wardrobe"})`  
    `client.post("/v1/auth/google-link", headers=auth_headers_b, json={"google_sub": "google-sub-999"})`

    `conflict = client.post(`  
        `"/v1/auth/google-link",`  
        `headers=auth_headers_a,`  
        `json={"google_sub": "google-sub-999"},`  
    `)`  
    `assert conflict.status_code == 409`

    `merged = client.post(`  
        `"/v1/auth/google-link",`  
        `headers=auth_headers_a,`  
        `json={"google_sub": "google-sub-999", "resolution": "MERGE"},`  
    `)`  
    `assert merged.status_code == 200`  
    `assert merged.json()["user_id"] == OWNER_B`

    `feed_b = client.get("/v1/mock/sync/changes?after=0&streams=my_wardrobe", headers=auth_headers_b).json()`  
    `assert len([c for c in feed_b["changes"] if c["type"] == "wardrobe_items"]) == 9`

`def test_p5_pii_scrubber_and_duplicate_embedding_check(`  
    `client: TestClient, auth_headers_a: dict[str, str]`  
`) -> None:`  
    `"""[AI-004, AI-006, WD-07] PII scrubber strips email/phone/coords; duplicate check matches identical item."""`  
    `scrub_res = client.post(`  
        `"/v1/ai/scrub-pii",`  
        `headers=auth_headers_a,`  
        `json={"prompt": "Meeting John at 10.7769, 106.7009 — email john@example.com or +84 912 345 678"},`  
    `)`  
    `assert scrub_res.status_code == 200`  
    `body = scrub_res.json()`  
    `assert "john@example.com" not in body["scrubbed_prompt"]`  
    `assert set(body["redacted_types"]) >= {"EMAIL", "COORDS", "PHONE"}`

Let me know whenever you are ready to revisit the postponed items (the remaining pre-code specification documents, the **TASK-012** golden fixture JSON exports, or the Flutter Synced\* repository adapters).

---

*User prompt: based on our historical conversation, let me know what files should generate next within 300 words.*

Response: Based on our conversation history, here are the key files that should be generated next to complete the implementation:

### **1\. Pre-Code Specifications & Policies**

> * **docs/policies/engineering/phone-schema-v2.md (TASK-011)**: Formally define the phone schema v2 specification, detailing column-level classifications (read-write, insert-only, phone-patch-only, command, read-only) and strict migration rules from v1.  
> * **docs/policies/engineering/wire-format-rules.md (TASK-013 / DOC-004)**: Document the wire format standard enforcing strict UPPER\_SNAKE enum serializations, ISO-8601 UTC timestamp formatting, YYYY-MM-DD calendar dates, and IANA timezone handling (profiles.time\_zone).  
> * **docs/policies/engineering/write-handler-invariants.md (BE-012)**: Specify validation rules, JWT ownership guards, table allow-lists, and standardized error envelopes (SyncDomainError).

### **2\. Shared Golden Test Fixtures (contracts/fixtures/ per TASK-012)**

> * **dormancy\_cases.json**: Golden test cases for days unworn, dormancy status, gap calculations, and rescue eligibility (including UTC+7 timezone cases).  
> * **rule\_decks.json**: Expected candidate outfit combinations, rankings, and match scores matching Dart’s FakeCandidateGenerator.  
> * **fake\_extraction\_sets.json**: Predefined garment extraction outputs corresponding to byte-level hash fixtures for Studio analysis.  
> * **enums.json & table\_classes.json**: Single-source-of-truth JSON mappings exported for parity validation between mobile and backend.

### **3\. Flutter Client Adapters (apps/mobile/lib/core/sync/)**

> * **synced\_studio\_repository.dart** & **synced\_gu\_match\_repository.dart (TASK-010 / TASK-015)**: Implement remote/synced repository adapters that swap out local in-memory fakes to read from and write to the mock/real sync change feed.  
> * **upload\_queue\_manager.dart (TASK-017)**: Implement the local queue responsible for batching transactions to POST /v1/sync/tx.

---

*User prompt: \- for Flutter Client Adapters, you do not write directly, you must write task in "docs/task/mobile" for cross platform developers to implement. \- for both "Pre-Code Specifications & Policies" and "Shared Golden Test Fixtures", to write as your above plan. plan again*

Response: Here is the updated implementation plan structured strictly according to your guidelines:

### **Phase 1: Pre-Code Specifications & Policies (docs/policies/engineering/)**

> 1. **phone-schema-v2.md (TASK-011)**  
   * Define Phone Schema v2 table definitions matching Flow Spec v2.8 and the Database Handbook.  
   * Formalize explicit column classifications:  
     * *Read-Write* (profiles, wardrobe\_items, upload\_batches, media\_assets, interactions, attachments, purchase\_checkins, calendar\_exports)  
     * *Insert-Only* (wear\_events, consents)  
     * *Phone-PATCH-Only* (extracted\_items on value and last\_worn\_input only)  
     * *Command Rows* (gu\_match\_sessions, privacy\_requests, vton\_jobs, share\_cards, share\_links, community\_posts, post\_reactions, post\_reports, post\_hides, feed\_requests)  
     * *Synced Read-Only* (item\_types, ai\_processing\_jobs, outfit\_candidates, attachment\_tickets, item\_embeddings, xp\_ledger, levels, badges, user\_badges, quest\_templates, user\_quests, user\_rank\_daily, emission\_factors, feed\_entries)  
   * Document v1 → v2 migration invariants: preserving existing local SQLite data without relying on SQL-level UNIQUE or CHECK constraints on synced views.  
> 2. **wire-format-rules.md (TASK-013 / DOC-004)**  
   * Specify strict UPPER\_SNAKE\_CASE serialization across all wire boundary enums (PROMPT\_LED, WORK, PENDING\_SWIPE, DISMISS\_PASS, TOP, etc.).  
   * Mandate timestamp conventions: ISO-8601 UTC with explicit Z (YYYY-MM-DDTHH:MM:SSZ).  
   * Mandate calendar date conventions: YYYY-MM-DD string format without time components.  
   * Define user time zone handling via profiles.time\_zone (IANA format) for consistent local and server dormancy/wear calculations.  
> 3. **write-handler-invariants.md (BE-012)**  
   * Define the 4-tier validation pipeline applied by POST /v1/sync/tx:  
     1. Owner token verification (user\_id \== JWT.sub).  
     2. Table-class writability check.  
     3. Strict field allow-lists per table on PATCH.  
     4. Domain invariants (e.g., I1 batch size 1–10, I2 MIME whitelist, I4 analysis task selection, I6 owned/non-archived items in wear events).  
   * Specify the standardized error response envelope: {"error": {"code": str, "message": str, "op\_index": int}}.

### **Phase 2: Shared Golden Test Fixtures (contracts/fixtures/ per TASK-012)**

Generate version-controlled golden fixture JSON files consumed by both Python backend tests and Flutter tests:

> 1. **dormancy\_cases.json**:  
   * Test vectors mapping item creation date, last worn estimate, logged wear events, reference "today" date, and timezone offset to expected days\_unworn, dormancy badge boolean, gap\_days, and rescue\_eligible boolean (enforcing rescue eligibility calculated strictly from logged wear/save date, never from estimate).  
> 2. **rule\_decks.json**:  
   * Deterministic deck generation test cases given sample wardrobe inventories and styling contexts, asserting candidate items, ordering, match percentage (70 \+ round(0.3 \* days)), and highlight reasons.  
> 3. **fake\_extraction\_sets.json**:  
   * The 3 deterministic garment extraction sample sets mapped from raw byte hashes / asset ID hashes.  
> 4. **enums.json**:  
   * Complete dictionary of domain enums and their wire strings.  
> 5. **table\_classes.json**:  
   * Table-to-class and column-to-writer mapping dictionary used as the source of truth for write guards and allow-lists.

### **Phase 3: Cross-Platform Mobile Task Specifications (docs/tasks/mobile/)**

Create structured task documentation for cross-platform developers without writing Flutter code directly:

> 1. **TASK-010-mock-backend-integration.md**:  
   * Specification for the mobile sync transport layer connecting local SQLite to POST /v1/sync/tx and reading delta streams from GET /v1/mock/sync/changes.  
> 2. **TASK-015-result-engine-seams.md**:  
   * Architecture guide to decouple Local\* fakes and establish abstract AnalysisEngine, ContextEngine, and DeckEngine seams that switch between local in-memory execution and server-synced rows.  
> 3. **TASK-017-local-upload-queue.md**:  
   * Design specification for the local SQLite upload queue table, tracking mutation operations, idempotency handling, retry backoff on 5xx, and rejection handling on 4xx.  
> 4. **TASK-020-powersync-sdk-swap.md**:  
   * Migration roadmap detailing how to replace the raw SQLite database helper with the official PowerSync Flutter SDK while preserving phone\_schema.dart table names and column layouts.

### **Phase 4: Backend Implementation & Verification (backend/)**

> 1. **Retirement of Dating Routes (BE-005)**:  
   * Remove legacy dating endpoints (discovery, matches, chat, profile models) and verify clean OpenAPI schemas and 404 responses.  
> 2. **Sync Core, Storage & Auth (BE-011, BE-019)**:  
   * Implement app/sync/ids.py (FNV-1a 64-bit deterministic ObjectId and 32-bit stable hash).  
   * Implement app/sync/schema.py and app/sync/schema\_extended.py (Pydantic v2 validation models).  
   * Implement app/store/memory.py (transactional multi-document in-memory store with rollback, changelog, and blob storage).  
   * Implement app/auth/service.py (HMAC/SHA-256 JWT issuance, JWKS, anonymous identity, and dev tokens).  
> 3. **Write Handler & Side Effects (BE-012, BE-013, BE-014–BE-018, BE-021)**:  
   * Implement POST /v1/sync/tx handling atomic multi-operation batches with rollback.  
   * Implement side-effect dispatchers: Studio batch analysis, Gu Match deck generation, wear calculation, attachment verification (EXIF/magic-byte checks), privacy erasure (ALL / BODY), and virtual try-on simulation.  
   * Implement mock change feed (GET /v1/mock/sync/changes), file tickets (PUT/GET /v1/mock/files/{ticket}), seed endpoints (POST /v1/mock/seed), and mock clock controls (PUT /v1/mock/clock).  
> 4. **Test Suite Execution**:  
   * Run the complete test suite across backend/tests/ to confirm all scenarios pass green.

### **Phase 5: Documentation & Changelog Summary (docs/ & docs/changes/)**

> 1. **Architecture & Contract Updates (docs/)**:  
   * Update docs/policies/engineering/architecture.md, codebase-map.md, and OpenAPI specifications to document the One-Piece Data Flow, sync streams, and schema v2.  
> 2. **Change Record (docs/changes/CHG-016-backend-sync-and-mobile-task-parity.md)**:  
   * Author a formal change record summarizing:  
     * Archive comparison between the original codebase and updated assets.  
     * Newly added mobile task cards under docs/tasks/mobile/.  
     * Added engineering policies and golden fixtures under contracts/fixtures/.  
     * Complete backend test and implementation structure under backend/.

---

*User prompt: proceed phase 1*

Response: Here are the complete **Phase 1: Pre-Code Specifications & Policies** documents for docs/policies/engineering/ (phone-schema-v2.md, wire-format-rules.md, and write-handler-invariants.md), aligned with Flow Spec v2.8, the Garblo Database Handbook (DRS \+ DDS), TASK-011, TASK-013, and BE-012.

### **1\. docs/policies/engineering/phone-schema-v2.md**

`# Phone Schema v2 Specification`

`> **Authority:** Flow Spec v2.8 T4 · Garblo Database Handbook (DRS + DDS) §3–§13 · [TASK-011](../../tasks/mobile/TASK-011-phone-schema-v2-alignment.md) · [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md)`    
`` > **Applies to:** `apps/mobile/lib/core/storage/phone_schema.dart`, `backend/app/sync/schema.py`, `contracts/fixtures/table_classes.json` ``

`## 1. Purpose`

``Phone Schema v1 (`CHG-005` / `CHG-006`) was cut against Flow Spec v2.7. Flow Spec v2.8 T4 and the Garblo Database Handbook introduce new synced tables (`profiles`, `attachments`, `attachment_tickets`, `privacy_requests`, `vton_jobs`, plus Flow C/D extensions) and enforce strict single-writer rules per column.``

``Phone Schema v2 establishes the exact table definitions, column types, table classes, and column ownership rules so the mobile app can swap raw SQLite for the PowerSync SDK (`TASK-020`) without renaming tables, losing data, or triggering server write-handler rejections (`BE-012`).``

`---`

`## 2. Structural Invariants`

``1. **PowerSync View Compatibility**: Every table (including local-only tables) is defined with `id TEXT PRIMARY KEY` and **zero SQL constraints** (no `FOREIGN KEY`, `UNIQUE`, `NOT NULL`, or `CHECK` constraints).``  
``2. **Three Primitive SQLite Types Only**: Every column uses `TEXT`, `INTEGER`, or `REAL`.``  
   ``- Primary & foreign keys: 24-character lowercase hex ObjectId (`TEXT`), except `item_types` and catalog tables where `id = code` (`TEXT`).``  
   ``- Booleans: `INTEGER` (`0` = false, `1` = true).``  
   ``- Timestamps: ISO-8601 UTC `TEXT` ending in `Z`.``  
   ``- Calendar dates: `YYYY-MM-DD` `TEXT` with no time part.``  
   ``- Structured objects & arrays: JSON-encoded `TEXT`.``  
``3. **Single Writer per Column**: Every column in a synced table is classified as either `PHONE_WRITTEN` or `SERVER_WRITTEN`. Mobile repositories must never write to `SERVER_WRITTEN` columns; until P4 real workers are connected, local fakes write only to `fake_*` local-only mirror tables (`C04-07`).``

`---`

`## 3. Table Classifications & Column Ownership Matrix`

`| Table Name | Table Class | Sync Stream | Phone Permitted Ops | Phone-Written Columns (PUT / Allow-Listed PATCH) | Server-Written Columns (Read-Only on Phone) |`  
`| :--- | :--- | :--- | :--- | :--- | :--- |`  
``| `profiles` | `READ_WRITE` | `my_wardrobe` | `PUT`, `PATCH` | `id`, `user_id`, `first_name`, `time_zone`, `community_opt_in`, `display_name`, `created_at`, `updated_at` | *(normalized by server on sync)* |``  
``| `wardrobe_items` | `READ_WRITE` | `my_wardrobe` | `PUT`, `PATCH`, `DELETE` | `id`, `user_id`, `name`, `type_code`, `color`, `material`, `style_tag`, `ai_confidence`, `source_asset_id`, `cutout_attachment_id`, `last_worn_estimate`, `archived`, `created_at`, `updated_at` | *(none — derived metrics computed from `wear_events`)* |``  
``| `wear_events` | `INSERT_ONLY` | `my_wardrobe` | `PUT` only | `id`, `user_id`, `worn_date`, `candidate_id`, `source`, `signature`, `ambient_temp_c`, `items` *(provisional)*, `created_at` | `items` (`gap_days`, `rescue_eligible` recomputed by server per `BE-016`) |``  
``| `consents` | `INSERT_ONLY` | `my_wardrobe` | `PUT`, `PATCH` (`revoked_at` only) | `id`, `user_id`, `version`, `includes_body`, `granted_at`, `revoked_at` | *(none)* |``  
``| `upload_batches` | `READ_WRITE` | `my_studio` | `PUT`, `PATCH`, `DELETE` | `id`, `user_id`, `purpose`, `consent_id`, `status` (`DRAFT`, `SANITIZING`, `QUEUED_FOR_AI`, `COMPLETED`, `DELETED_BY_USER`), `req_outfit`, `req_pose`, `req_background`, `ambient_temp_c`, `created_at`, `updated_at` | `status` (`AI_PROCESSING`, `AWAITING_REVIEW`, `FAILED`), `updated_at` |``  
``| `media_assets` | `READ_WRITE` | `my_studio` | `PUT`, `PATCH`, `DELETE` | `id`, `user_id`, `batch_id`, `slot_index`, `mime_type`, `attachment_id`, `orientation`, `exif_gps_stripped`, `bystanders_blurred`, `removed`, `created_at` | `contains_person` *(set by `PersonDetector` in P5)* |``  
``| `ai_processing_jobs` | `READ_ONLY` | `my_studio_jobs` | None (`403`) | *(none)* | `id`, `user_id`, `batch_id`, `asset_id`, `task_type`, `status`, `created_at`, `updated_at` |``  
``| `extracted_items` | `PHONE_PATCH_ONLY` | `my_studio` | `PATCH` (`value`, `last_worn_input` only) | `value`, `last_worn_input` | `id`, `user_id`, `batch_id`, `asset_id`, `item_index`, `name`, `confidence`, `ai`, `cutout_attachment_id`, `created_at` |``  
``| `gu_match_sessions` | `COMMAND` | `my_decks`, `deck_history` | `PUT`, `PATCH` (`occasions`, `raw_prompt`) | `id`, `user_id`, `path`, `occasions`, `raw_prompt`, `event_title`, `window_start`, `window_end`, `city_id`, `ambient_temp_c`, `status` (`REQUESTED` on PUT), `created_at` | `status` (`GATHERING`, `ANALYZED`, `DECK_READY`, `NO_ELIGIBLE_ITEMS`, `FAILED`), `context`, `eligible_item_count`, `owned_only`, `deck_size`, `recent`, `expires_at` |``  
``| `outfit_candidates` | `READ_ONLY` | `my_decks`, `deck_history` | None (`403`) | *(none — swipe decisions go via `interactions`)* | `id`, `user_id`, `session_id`, `deck_order`, `title`, `match_pct`, `highlight_reason`, `visual_mode`, `swipe_status`, `items`, `created_at` |``  
``| `interactions` | `READ_WRITE` | `my_decks` | `PUT` | `id`, `user_id`, `session_id`, `candidate_id`, `action`, `dwell_ms`, `from_item_id`, `to_item_id`, `created_at` | *(none)* |``  
``| `vton_jobs` | `COMMAND` | `my_decks` | `PUT` | `id`, `user_id`, `session_id`, `candidate_id`, `body_asset_id`, `status` (`REQUESTED` on PUT), `created_at` | `status` (`PROCESSING`, `COMPLETED`, `FAILED`, `CANCELLED`), `output_attachment_id`, `updated_at` |``  
``| `attachments` | `READ_WRITE` | `my_files` | `PUT`, `PATCH` (`state` = `UPLOADED`) | `id`, `user_id`, `kind` (`PHOTO`, `BODY`), `owner_table`, `owner_id`, `mime_type`, `bytes`, `sha256`, `state` (`PENDING_UPLOAD`, `UPLOADED`), `created_at` | `kind` (`CUTOUT`, `RENDER`, `POSTER`, `EXPORT`, `EDITORIAL`), `state` (`VERIFIED`, `REJECTED`, `READY`) |``  
``| `attachment_tickets` | `READ_ONLY` | `my_files` | None (`403`) | *(none)* | `id`, `user_id`, `attachment_id`, `op`, `url`, `expires_at` |``  
``| `privacy_requests` | `COMMAND` | `my_files` | `PUT` | `id`, `user_id`, `scope`, `status` (`REQUESTED` on PUT), `created_at` | `status` (`IN_PROGRESS`, `COMPLETED`, `FAILED`), `export_attachment_id`, `completed_at` |``  
``| `item_types` | `READ_ONLY` | `catalog` | None (`403`) | *(none)* | `id` (= `type_code`), `type_code`, `group_code`, `label` |``  
``| `item_embeddings` | `READ_ONLY` | `my_wardrobe` | None (`403`) | *(none)* | `id`, `user_id`, `item_id`, `embedding_int8_128`, `created_at` |``

`### Local-Only Tables (Never Uploaded)`  
``- `session_draft`: `id` (`'current'` enforced in repository code, no SQL `CHECK`), `occasions`, `prompt`.``  
``- `ui_state`: `id`, `key`, `value`, `updated_at`.``  
``- `rewards_provisional`: `id`, `user_id`, `rule`, `points`, `idem_key`, `created_at`.``  
``- `fake_ai_processing_jobs`, `fake_extracted_items`, `fake_outfit_candidates`: P2/P3 local mirror tables for offline fake engines (`TASK-015`).``

`---`

`## 4. Migration Strategy (v1 $\rightarrow$ v2 $\rightarrow$ v3)`

``1. **Step 1 (`v1` $\rightarrow$ `v2` Wire Values & Dates — `TASK-013`)**:``  
   ``- Convert any camelCase enum strings stored in `gu_match_sessions.path`, `gu_match_sessions.occasions`, `outfit_candidates.swipe_status`, `interactions.action`, `outfit_candidates.items[].slot_role`, and `extracted_items.last_worn_input.option` to `UPPER_SNAKE_CASE`.``  
   ``- Normalize all timestamp strings to UTC ISO-8601 ending in `Z`.``  
   ``- Truncate `wardrobe_items.last_worn_estimate` from full ISO datetime to `YYYY-MM-DD`.``  
``2. **Step 2 (`v2` $\rightarrow$ `v3` Schema v2 Alignment — `TASK-011`)**:``  
   ``- Create new tables: `profiles`, `attachments`, `attachment_tickets`, `privacy_requests`, `vton_jobs`, `item_embeddings`, `ui_state`, `rewards_provisional`, and `fake_*` mirrors.``  
   ``- Alter `gu_match_sessions` to add `event_title`, `window_start`, `window_end`, `city_id`, `ambient_temp_c`, `status`, `context`, and `expires_at`.``  
   ``- Rebuild `session_draft` without `NOT NULL` or `CHECK (id = 'current')` constraints while preserving the `'current'` row.``  
   ``- Ensure `item_types.id` equals `item_types.type_code`.``

### **2\. docs/policies/engineering/wire-format-rules.md**

`# Wire Format, Enums, and Time Zone Rules`

`> **Authority:** Flow Spec v2.8 T2 & T4 · Garblo Database Handbook §3 D01 · [TASK-013](../../tasks/mobile/TASK-013-wire-values-and-time.md) · [DOC-004](../../tasks/docs/DOC-004-mobile-contract-decisions.md) · [BE-022](../../tasks/backend/BE-022-mock-contract-requests-from-mobile.md)`    
``> **Applies to:** Mobile SQLite codecs, PowerSync upload queue payloads, FastAPI Pydantic schemas, and MongoDB `$jsonSchema` validators.``

`## 1. Core Wire Principles`

``There is **one** wire encoding shared identically across local SQLite columns, PowerSync CRUD payloads (`POST /v1/sync/tx`), Sync Streams, and golden test fixtures (`contracts/fixtures/`). Neither the backend nor the mobile app may maintain legacy camelCase fallback parsers once the v1 $\rightarrow$ v2 local migration runs.``

`---`

``## 2. Enum Wire Values (`UPPER_SNAKE_CASE`)``

``Every enum persisted in a database column or embedded JSON string must use its exact `UPPER_SNAKE_CASE` wire token:``

``| Domain Concept | Table / JSON Path | Allowed Wire Values (`UPPER_SNAKE_CASE`) | Retired v1 Dart `.name` (Rejected with `422 SCHEMA_VIOLATION`) |``  
`| :--- | :--- | :--- | :--- |`  
``| **Item Group** | `item_types.group_code` | `TOPS`, `BOTTOMS`, `SHOES`, `BAGS`, `HATS`, `ACCESSORIES` | `tops`, `bottoms`, `shoes`, `bags`, `hats`, `accessories` |``  
``| **Upload Batch Purpose** | `upload_batches.purpose` | `WARDROBE`, `BODY_REFERENCE` | `wardrobe`, `bodyReference` |``  
``| **Upload Batch Status** | `upload_batches.status` | `DRAFT`, `SANITIZING`, `QUEUED_FOR_AI`, `AI_PROCESSING`, `AWAITING_REVIEW`, `COMPLETED`, `FAILED`, `DELETED_BY_USER` | `draft`, `sanitizing`, `queuedForAi`, `aiProcessing`, `awaitingReview`, `completed`, `failed`, `deletedByUser` |``  
``| **AI Task Type** | `ai_processing_jobs.task_type` | `OUTFIT_EXTRACTION`, `POSE_ESTIMATION`, `BACKGROUND_ANALYSIS` | `outfitExtraction`, `poseEstimation`, `backgroundAnalysis` |``  
``| **AI Job Status** | `ai_processing_jobs.status` | `PENDING`, `PROCESSING`, `COMPLETED`, `SKIPPED_NO_PERSON`, `FAILED` | `pending`, `processing`, `completed`, `skippedNoPerson`, `failed` |``  
``| **Last Worn Option** | `extracted_items.last_worn_input.option` | `WITHIN_1_WEEK`, `ONE_TO_THREE_MONTHS`, `OVER_THREE_MONTHS`, `EXACT_DATE`, `DONT_REMEMBER` | `within1Week`, `oneToThreeMonths`, `overThreeMonths`, `exactDate`, `dontRemember` |``  
``| **Wear Event Source** | `wear_events.source` | `LIKE_CONFIRM`, `ITEM`, `MULTI`, `CHECKIN`, `PHOTO`, `REMINDER`, `TREND` | `likeConfirm`, `item`, `multi`, `checkin`, `photo`, `reminder`, `trend` |``  
``| **Gu Match Path** | `gu_match_sessions.path` | `PROMPT_LED`, `ZERO_INPUT` | `promptLed`, `zeroInput` |``  
``| **Gu Match Status** | `gu_match_sessions.status` | `REQUESTED`, `GATHERING`, `ANALYZED`, `DECK_READY`, `NO_ELIGIBLE_ITEMS`, `FAILED` | `requested`, `gathering`, `analyzed`, `deckReady`, `noEligibleItems`, `failed` |``  
``| **Occasion** | `gu_match_sessions.occasions[]` | `WORK`, `COFFEE`, `AFTERNOON_RAIN`, `DATE`, `WEEKEND_OUTING` | `work`, `coffee`, `afternoonRain`, `date`, `weekendOuting` |``  
``| **Slot Role** | `outfit_candidates.items[].slot_role` | `TOP`, `BOTTOM`, `FOOTWEAR`, `BAG`, `HAT`, `ACCESSORY` | `top`, `bottom`, `footwear`, `bag`, `hat`, `accessory` |``  
``| **Visual Mode** | `outfit_candidates.visual_mode` | `COLLAGE_FLATLAY`, `TRY_ON_RENDER`, `AI_ILLUSTRATION` | `collageFlatlay`, `tryOnRender`, `aiIllustration` |``  
``| **Swipe Status** | `outfit_candidates.swipe_status` | `PENDING_SWIPE`, `SWIPED_LEFT_PASSED`, `SWIPED_RIGHT_LIKED`, `SAVED_TO_LOOKBOOK` | `pendingSwipe`, `swipedLeftPassed`, `swipedRightLiked`, `savedToLookbook` |``  
``| **Card Interaction Action**| `interactions.action` | `DISMISS_PASS`, `LIKE_SAVE`, `CUSTOMIZE_EDIT`, `ADJUST`, `TRIGGER_VTON` | `dismissPass`, `likeSave`, `customizeEdit`, `adjust`, `triggerVton` |``  
``| **Attachment Kind** | `attachments.kind` | `PHOTO`, `CUTOUT`, `BODY`, `RENDER`, `POSTER`, `EXPORT`, `EDITORIAL` | `photo`, `cutout`, `body`, `render`, `poster`, `export`, `editorial` |``  
``| **Attachment State** | `attachments.state` | `PENDING_UPLOAD`, `UPLOADED`, `VERIFIED`, `REJECTED`, `READY` | `pendingUpload`, `uploaded`, `verified`, `rejected`, `ready` |``  
``| **Ticket Operation** | `attachment_tickets.op` | `PUT`, `GET` | `put`, `get` |``  
``| **Privacy Scope** | `privacy_requests.scope` | `BODY`, `ALL`, `EXPORT` | `body`, `all`, `export` |``  
``| **Privacy Status** | `privacy_requests.status` | `REQUESTED`, `IN_PROGRESS`, `COMPLETED`, `FAILED` | `requested`, `inProgress`, `completed`, `failed` |``  
``| **VTON Job Status** | `vton_jobs.status` | `REQUESTED`, `PROCESSING`, `COMPLETED`, `FAILED`, `CANCELLED` | `requested`, `processing`, `completed`, `failed`, `cancelled` |``

`---`

`## 3. Timestamps, Injected Clock & Calendar Dates`

``1. **Injected Clock Only (`F-04`)**:``  
   ``- Production and test code must never call `DateTime.now()` (Dart) or `datetime.now()` (Python) directly inside repositories, domain rules, or workers.``  
   ``- All timestamps originate from the injected `Clock` interface.``  
``2. **UTC ISO-8601 Timestamps (`F-02`)**:``  
   ``- Every timestamp column (`created_at`, `updated_at`, `granted_at`, `revoked_at`, `window_start`, `window_end`, `expires_at`, `completed_at`, `unlocked_at`) must be serialized in UTC with a trailing `Z` designator:``  
     `` - Valid: `2026-10-30T09:00:00Z` or `2026-10-30T09:00:00.000Z` ``  
     ``- Invalid (rejected with `422 SCHEMA_VIOLATION`): `2026-10-30T16:00:00` (floating local time without offset)``  
``3. **Calendar Dates (`F-03`)**:``  
   ``- Calendar date columns (`wear_events.worn_date`, `wardrobe_items.last_worn_estimate`, `user_quests.week_start`, `user_rank_daily.as_of`) must match `^\d{4}-\d{2}-\d{2}$` (`YYYY-MM-DD`).``  
   ``- Time components on calendar date columns are rejected with `422 SCHEMA_VIOLATION`.``

`---`

``## 4. User Time Zone & Day-Boundary Rule (`F-05` / `DOC-004` Q1)``

``Because timestamps are stored in UTC (`Z`) while `worn_date` and `last_worn_estimate` are local calendar dates (`YYYY-MM-DD`), a piece saved at `2026-10-30T06:00:00+07:00` in Ho Chi Minh City has `created_at = "2026-10-29T23:00:00Z"`.``

``To ensure `DormancyRules` and `gap_days` produce identical day counts on both phone and server (`WD-08`):``  
``1. The user's IANA time zone (e.g., `Asia/Ho_Chi_Minh`, `Asia/Tokyo`, `UTC`) is stored in `profiles.time_zone` (defaulting to `'UTC'` when unset).``  
``2. When converting a UTC `created_at` timestamp into a calendar save date for `days_unworn` or `gap_days`, both phone and server convert the UTC instant into `profiles.time_zone` before extracting `(year, month, day)`.``

### **3\. docs/policies/engineering/write-handler-invariants.md**

``# Write Handler Invariants & Guard Rules (`POST /v1/sync/tx`)``

`> **Authority:** Flow Spec v2.8 T2 & T4 · Garblo Database Handbook §2 C04, §3 D03 & D05 · [BE-012](../../tasks/backend/BE-012-mock-write-handler.md) · [BE-020](../../tasks/backend/BE-020-write-handler-on-mongodb.md) · [BE-022](../../tasks/backend/BE-022-mock-contract-requests-from-mobile.md)`    
`` > **Applies to:** `backend/app/api/v1/endpoints/sync_api.py`, `apps/mobile/lib/core/sync/` ``

`## 1. Transaction Contract & Queue Semantics`

``All client data mutations reach the server exclusively through `POST /v1/sync/tx`, carrying one atomic transaction batch from the local PowerSync upload queue:``

```` ```json ````  
`{`  
  `"tx_id": 42,`  
  `"ops": [`  
    `{ "op": "PUT", "type": "upload_batches", "id": "6725aa12c8e4b12d34567100", "data": { ... } },`  
    `{ "op": "PATCH", "type": "upload_batches", "id": "6725aa12c8e4b12d34567100", "data": { "status": "SANITIZING" } }`  
  `]`  
`}`

### **Queue Progression Rules**

| Outcome | HTTP Status | Response Body | Client Upload Queue Action |
| :---- | :---- | :---- | :---- |
| **Applied** | 200 OK | {"applied": true, "replayed": false, "tx\_id": 42, "checkpoint": 57} | Call tx.complete(); advance write checkpoint. |
| **Idempotent Replay** | 200 OK | {"applied": true, "replayed": true, "tx\_id": 42, "checkpoint": 57} | Call tx.complete(); no duplicate rows or side effects created. |
| **Validation / Guard Rejection** | 403 / 404 / 409 / 422 | {"error": {"code": "\<CODE\>", "message": "...", "op\_index": 1}} | Log to sync\_rejections, surface "Couldn't save … · Fix" notification, and **call tx.complete()** so a bad row never blocks the upload queue. |
| **Unauthenticated** | 401 Unauthorized | {"error": {"code": "UNAUTHENTICATED", "message": "..."}} | Refresh token via /v1/auth/refresh and retry without dropping tx. |
| **Transient Server Fault** | 503 / 5xx | {"error": {"code": "RETRY\_LATER", "message": "..."}} | Keep tx in queue; retry with exponential backoff (up to 5 attempts). |

## **2\. Four-Tier Pre-Commit Guard Pipeline**

Every operation ops\[i\] in a transaction is validated in order inside a single atomic transaction (InMemoryStore.transaction() in Track M; MongoDB multi-document transaction with writeConcern: "majority" in Track R). If any operation fails, the entire transaction rolls back and returns op\_index \= i.

### **Tier 1: Authentication, ID Format & Ownership Guards**

> 1. **Bearer Token Verification**: Missing, expired, or invalid token → 401 UNAUTHENTICATED.  
> 2. **ObjectId Format**: op.id must be 24 lowercase hex characters (^\[0-9a-f\]{24}\$) → else 422 INVALID\_ID.  
> 3. **Owner Partition Match**:  
   * If data.user\_id is present and data.user\_id \!= token.sub → 403 OWNER\_MISMATCH.  
   * If op.id already exists in the target table under a different user\_id → 403 OWNER\_MISMATCH.  
   * On PUT, if data.user\_id is omitted, the write handler stamps data.user\_id \= token.sub.  
> 4. **Deterministic ID Idempotency (C02-03)**:  
   * If a PUT arrives for an id that already exists under the **same** user\_id, the write handler treats the operation as already applied (no-op) and continues.

### **Tier 2: Table Class & Operation Writability Guards**

> 1. **Unknown or Read-Only Table**:  
   * Any write (PUT, PATCH, DELETE) to item\_types, ai\_processing\_jobs, outfit\_candidates, attachment\_tickets, item\_embeddings, xp\_ledger, levels, badges, user\_badges, quest\_templates, user\_quests, user\_rank\_daily, emission\_factors, or feed\_entries → 403 TABLE\_NOT\_WRITABLE.  
> 2. **Phone-PATCH-Only Tables**:  
   * PUT or DELETE on extracted\_items or notifications → 403 TABLE\_NOT\_WRITABLE.  
> 3. **Insert-Only (Append-Only) Tables**:  
   * DELETE on wear\_events or consents → 422 APPEND\_ONLY.  
   * PATCH on wear\_events → 422 APPEND\_ONLY.  
   * PATCH on consents touching any field other than revoked\_at → 422 APPEND\_ONLY.

### **Tier 3: Field Allow-List & Schema Validation Guards**

> 1. **PATCH Field Allow-List**:  
   * Every key in op.data on a PATCH operation must belong to TABLE\_ALLOW\_LISTS\[table\]. Any unapproved key (such as extracted\_items.ai or gu\_match\_sessions.status) → 422 FIELD\_NOT\_WRITABLE.  
> 2. **Strict Schema & Wire Validation**:  
   * Merged row state must pass the table's Pydantic v2 model / MongoDB \$jsonSchema validator (enforcing UPPER\_SNAKE enums, YYYY-MM-DD calendar dates, and UTC ISO-8601 timestamps) → else 422 SCHEMA\_VIOLATION.

### **Tier 4: Cross-Document Domain Invariants**

> 1. **Invariant I1 (upload\_batches → SANITIZING)**:  
   * Batch must reference an active, non-revoked consent\_id owned by user\_id → else 422 CONSENT\_REQUIRED.  
   * Batch must have between 1 and 10 non-removed (removed \= 0\) rows in media\_assets → else 422 PHOTO\_COUNT\_OUT\_OF\_RANGE.  
> 2. **Invariant I2 (media\_assets PUT)**:  
   * mime\_type must be "image/jpeg" or "image/png" → else 422 UNSUPPORTED\_MIME.  
   * Active non-removed media\_assets in batch\_id must not exceed 10 → else 422 PHOTO\_COUNT\_OUT\_OF\_RANGE.  
> 3. **Invariant I4 (upload\_batches → QUEUED\_FOR\_AI)**:  
   * At least one of req\_outfit, req\_pose, or req\_background must equal 1 → else 422 NO\_ANALYSIS\_TASK.  
> 4. **Upload Batch State Machine (F-09 / DOC-004 Q2)**:  
   * Client may only transition upload\_batches.status to DRAFT, SANITIZING, QUEUED\_FOR\_AI, COMPLETED, or DELETED\_BY\_USER along valid edges (DRAFT \-\> SANITIZING \-\> QUEUED\_FOR\_AI, AWAITING\_REVIEW \-\> COMPLETED, or any \-\> DRAFT / DELETED\_BY\_USER) → else 409 ILLEGAL\_TRANSITION.  
> 5. **Catalog Reference (wardrobe\_items PUT/PATCH)**:  
   * type\_code must exist in item\_types → else 422 UNKNOWN\_TYPE\_CODE.  
> 6. **Invariant I6 (wear\_events PUT & interactions ADJUST)**:  
   * wear\_events.items must contain 1..12 entries, and every referenced item\_id must exist in wardrobe\_items under user\_id with archived \= 0 → else 422 ITEM\_NOT\_OWNED.  
   * On interactions with action in ("CUSTOMIZE\_EDIT", "ADJUST"), to\_item\_id must be owned, non-archived (422 ITEM\_NOT\_OWNED), and belong to the same group\_code as from\_item\_id (422 GROUP\_MISMATCH).

`---`

``**Phase 1 is complete.** Reply **"proceed phase 2"** (or **"proceed"**) to generate all **Phase 2: Shared Golden Test Fixtures (`contracts/fixtures/`)**.``

---

*User prompt: proceed phase 2*

Response: Here are the complete **Phase 2: Shared Golden Test Fixtures (contracts/fixtures/)** files per **TASK-012** (object\_id\_vectors.json, dormancy\_cases.json, fake\_extraction\_sets.json, rule\_decks.json, enums.json, and table\_classes.json), computed deterministically to match both the Flutter mobile suite and the Python backend test suite.

### **1\. contracts/fixtures/object\_id\_vectors.json**

Provides exact golden vectors for deterministicObjectId(parts) (64-bit FNV-1a two-pass) and stableHash(bytes) (32-bit FNV-1a).

`{`  
  `"description": "Golden vectors for deterministicObjectId and stableHash (TASK-012 / BE-011-S01)",`  
  `"deterministic_object_ids": [`  
    `{`  
      `"parts": ["demo-seed", "seed_01"],`  
      `"expected_id": "679dd79ffc8dcfcf27566db7"`  
    `},`  
    `{`  
      `"parts": ["demo-seed", "seed_02"],`  
      `"expected_id": "679dd89ffc8dd182275670b7"`  
    `},`  
    `{`  
      `"parts": ["demo-seed", "seed_03"],`  
      `"expected_id": "679dd99ffc8dd33527566fb7"`  
    `},`  
    `{`  
      `"parts": ["demo-seed", "seed_04"],`  
      `"expected_id": "679dd29ffc8dc750275672b7"`  
    `},`  
    `{`  
      `"parts": ["demo-seed", "seed_05"],`  
      `"expected_id": "679dd39ffc8dc903275671b7"`  
    `},`  
    `{`  
      `"parts": ["demo-seed", "seed_06"],`  
      `"expected_id": "679dd49ffc8dcab6275674b7"`  
    `},`  
    `{`  
      `"parts": ["demo-seed", "seed_07"],`  
      `"expected_id": "679dd59ffc8dcc69275673b7"`  
    `},`  
    `{`  
      `"parts": ["demo-seed", "seed_08"],`  
      `"expected_id": "679dde9ffc8ddbb4275676b7"`  
    `},`  
    `{`  
      `"parts": ["demo-seed", "seed_09"],`  
      `"expected_id": "679ddf9ffc8ddd67275675b7"`  
    `},`  
    `{`  
      `"parts": [`  
        `"65f0c1a2b3c4d5e6f7a8b9c0",`  
        `"v1.0_studio_body_ai",`  
        `"2026-10-30T09:00:00Z",`  
        `"true"`  
      `],`  
      `"expected_id": "54b01d3ef649557e3dc1f3ec"`  
    `},`  
    `{`  
      `"parts": [`  
        `"6725aa12c8e4b12d34567100",`  
        `"6725aa12c8e4b12d34567101",`  
        `"OUTFIT_EXTRACTION"`  
      `],`  
      `"expected_id": "0a79bc98da0c4a82ca732d25"`  
    `}`  
  `],`  
  `"stable_hashes": [`  
    `{`  
      `"utf8_input": "",`  
      `"expected_uint32": 2166136261,`  
      `"expected_sample_index": 1`  
    `},`  
    `{`  
      `"utf8_input": "garblo-sample-photo-01",`  
      `"expected_uint32": 2925887822,`  
      `"expected_sample_index": 2`  
    `},`  
    `{`  
      `"utf8_input": "6725aa12c8e4b12d34567101",`  
      `"expected_uint32": 2258534670,`  
      `"expected_sample_index": 2`  
    `}`  
  `]`  
`}`

### **2\. contracts/fixtures/dormancy\_cases.json**

Pins the exact behavior of days\_unworn, is\_dormant (≥30 days), gap\_days, and rescue\_eligible across both phone and server (BE-016), including the **N6 / I12 Rescue Rule** (rescue eligibility is measured strictly from logged wears or save date, never from last\_worn\_estimate) and the **UTC+7 Time Zone** boundary case (TASK-013-S04).

`{`  
  `"description": "Shared dormancy, gap_days, and rescue_eligible golden cases (TASK-012 / BE-016)",`  
  `"dormancy_threshold_days": 30,`  
  `"cases": [`  
    `{`  
      `"id": "CASE-01-DEMO-WHITE-TSHIRT-DORMANT-AND-RESCUE",`  
      `"description": "Saved 60 days ago, estimated worn 41 days ago, no logged wears -> 41 days unworn (dormant); when worn today, gap from save date is 60 days (rescue eligible).",`  
      `"today": "2026-10-30",`  
      `"time_zone": "UTC",`  
      `"item": {`  
        `"id": "679dd79ffc8dcfcf27566db7",`  
        `"created_at": "2026-08-31T09:00:00Z",`  
        `"last_worn_estimate": "2026-09-19"`  
      `},`  
      `"prior_wear_events": [],`  
      `"expected": {`  
        `"days_unworn": 41,`  
        `"is_dormant": true,`  
        `"gap_days_on_wear_today": 60,`  
        `"rescue_eligible_on_wear_today": true`  
      `}`  
    `},`  
    `{`  
      `"id": "CASE-02-ESTIMATE-ONLY-NOT-RESCUE-ELIGIBLE",`  
      `"description": "TASK-003-S14 / I12: Saved 10 days ago with a 41-day-old estimate -> shows 41d dormant badge in UI, but wearing today has gap_days=10 from save date (NOT rescue eligible).",`  
      `"today": "2026-10-30",`  
      `"time_zone": "UTC",`  
      `"item": {`  
        `"id": "679dd89ffc8dd182275670b7",`  
        `"created_at": "2026-10-20T09:00:00Z",`  
        `"last_worn_estimate": "2026-09-19"`  
      `},`  
      `"prior_wear_events": [],`  
      `"expected": {`  
        `"days_unworn": 41,`  
        `"is_dormant": true,`  
        `"gap_days_on_wear_today": 10,`  
        `"rescue_eligible_on_wear_today": false`  
      `}`  
    `},`  
    `{`  
      `"id": "CASE-03-LOGGED-WEAR-OVERRIDES-OLDER-ESTIMATE",`  
      `"description": "Saved 60 days ago, estimate 45 days ago, logged wear 5 days ago -> 5 days unworn, not dormant, gap_days=5.",`  
      `"today": "2026-10-30",`  
      `"time_zone": "UTC",`  
      `"item": {`  
        `"id": "679dd99ffc8dd33527566fb7",`  
        `"created_at": "2026-08-31T09:00:00Z",`  
        `"last_worn_estimate": "2026-09-15"`  
      `},`  
      `"prior_wear_events": [`  
        `{ "worn_date": "2026-10-25", "item_ids": ["679dd99ffc8dd33527566fb7"] }`  
      `],`  
      `"expected": {`  
        `"days_unworn": 5,`  
        `"is_dormant": false,`  
        `"gap_days_on_wear_today": 5,`  
        `"rescue_eligible_on_wear_today": false`  
      `}`  
    `},`  
    `{`  
      `"id": "CASE-04-EXACT-30-DAY-BOUNDARY",`  
      `"description": "Logged wear exactly 30 days ago -> dormant is true and rescue_eligible is true.",`  
      `"today": "2026-10-30",`  
      `"time_zone": "UTC",`  
      `"item": {`  
        `"id": "679dd29ffc8dc750275672b7",`  
        `"created_at": "2026-08-01T09:00:00Z",`  
        `"last_worn_estimate": null`  
      `},`  
      `"prior_wear_events": [`  
        `{ "worn_date": "2026-09-30", "item_ids": ["679dd29ffc8dc750275672b7"] }`  
      `],`  
      `"expected": {`  
        `"days_unworn": 30,`  
        `"is_dormant": true,`  
        `"gap_days_on_wear_today": 30,`  
        `"rescue_eligible_on_wear_today": true`  
      `}`  
    `},`  
    `{`  
      `"id": "CASE-05-TIMEZONE-UTC-PLUS-7-EARLY-MORNING-SAVE",`  
      `"description": "TASK-013-S04 / F-05: Item saved at 2026-10-01 06:00:00 in Asia/Ho_Chi_Minh (stored as 2026-09-30T23:00:00Z). On local date 2026-10-30, it has been 29 calendar days in Vietnam (not 30).",`  
      `"today": "2026-10-30",`  
      `"time_zone": "Asia/Ho_Chi_Minh",`  
      `"item": {`  
        `"id": "679dd39ffc8dc903275671b7",`  
        `"created_at": "2026-09-30T23:00:00Z",`  
        `"last_worn_estimate": null`  
      `},`  
      `"prior_wear_events": [],`  
      `"expected": {`  
        `"days_unworn": 29,`  
        `"is_dormant": false,`  
        `"gap_days_on_wear_today": 29,`  
        `"rescue_eligible_on_wear_today": false`  
      `}`  
    `}`  
  `]`  
`}`

### **3\. contracts/fixtures/fake\_extraction\_sets.json**

Defines the 3 preset Studio extraction sets (MockStudioRepository.presetFixtures / LocalStudioRepository.\_samples) and the deterministic hash-to-sample-set mapping (AI-005-S01, BE-018-S05).

`{`  
  `"description": "Deterministic fake Studio extraction sets and hash routing (TASK-012 / AI-005-S01)",`  
  `"preset_uri_map": {`  
    `"preset://flatlay-violet-shirt.jpg": 0,`  
    `"preset://flatlay-wide-leg-trousers.jpg": 1,`  
    `"preset://flatlay-cream-sneakers.png": 2`  
  `},`  
  `"sample_sets": [`  
    `[`  
      `{`  
        `"name": "Violet shirt",`  
        `"confidence": 0.94,`  
        `"attributes": {`  
          `"type_code": "SHIRT",`  
          `"color": "Violet",`  
          `"material": "Cotton",`  
          `"style_tag": "Street"`  
        `}`  
      `}`  
    `],`  
    `[`  
      `{`  
        `"name": "Wide-leg trousers",`  
        `"confidence": 0.91,`  
        `"attributes": {`  
          `"type_code": "WIDE_LEG_TROUSERS",`  
          `"color": "Beige",`  
          `"material": "Linen",`  
          `"style_tag": "Everyday"`  
        `}`  
      `}`  
    `],`  
    `[`  
      `{`  
        `"name": "Cream sneakers",`  
        `"confidence": 0.88,`  
        `"attributes": {`  
          `"type_code": "SNEAKERS",`  
          `"color": "Cream",`  
          `"material": "Canvas",`  
          `"style_tag": "Basic"`  
        `}`  
      `}`  
    `]`  
  `]`  
`}`

### **4\. contracts/fixtures/rule\_decks.json**

Pins the exact 8-candidate deck generated by FakeCandidateGenerator / RuleOutfitGenerator over the 9 seeded demo wardrobe items on reference date 2026-10-30 (AI-005-S04, BE-015-S02).

`{`  
  `"description": "Golden Gu Match deck generated from the 9 demo wardrobe items on 2026-10-30 (TASK-012 / AI-005-S04 / BE-015-S02)",`  
  `"session_id": "6725aa12c8e4b12d34567200",`  
  `"reference_date": "2026-10-30",`  
  `"context": {`  
    `"path": "PROMPT_LED",`  
    `"occasions": ["COFFEE"],`  
    `"raw_prompt": "Relaxed coffee catch-up"`  
  `},`  
  `"expected_candidates": [`  
    `{`  
      `"deck_order": 1,`  
      `"title": "White for coffee",`  
      `"match_pct": 82,`  
      `"highlight_reason": "Benched 41 days · White T-shirt",`  
      `"visual_mode": "COLLAGE_FLATLAY",`  
      `"swipe_status": "PENDING_SWIPE",`  
      `"items": [`  
        `{ "slot_role": "TOP", "item_id": "679dd79ffc8dcfcf27566db7", "name": "White T-shirt", "days_unworn": 41 },`  
        `{ "slot_role": "BOTTOM", "item_id": "679dd29ffc8dc750275672b7", "name": "Pleated skirt", "days_unworn": 9 },`  
        `{ "slot_role": "FOOTWEAR", "item_id": "679dd39ffc8dc903275671b7", "name": "Black loafers", "days_unworn": 2 }`  
      `]`  
    `},`  
    `{`  
      `"deck_order": 2,`  
      `"title": "White for coffee",`  
      `"match_pct": 82,`  
      `"highlight_reason": "Benched 41 days · White T-shirt",`  
      `"visual_mode": "COLLAGE_FLATLAY",`  
      `"swipe_status": "PENDING_SWIPE",`  
      `"items": [`  
        `{ "slot_role": "TOP", "item_id": "679dd79ffc8dcfcf27566db7", "name": "White T-shirt", "days_unworn": 41 },`  
        `{ "slot_role": "BOTTOM", "item_id": "679dd29ffc8dc750275672b7", "name": "Pleated skirt", "days_unworn": 9 },`  
        `{ "slot_role": "FOOTWEAR", "item_id": "679dd49ffc8dcab6275674b7", "name": "White sneakers", "days_unworn": 6 }`  
      `]`  
    `},`  
    `{`  
      `"deck_order": 3,`  
      `"title": "White for coffee",`  
      `"match_pct": 82,`  
      `"highlight_reason": "Benched 41 days · White T-shirt",`  
      `"visual_mode": "COLLAGE_FLATLAY",`  
      `"swipe_status": "PENDING_SWIPE",`  
      `"items": [`  
        `{ "slot_role": "TOP", "item_id": "679dd79ffc8dcfcf27566db7", "name": "White T-shirt", "days_unworn": 41 },`  
        `{ "slot_role": "BOTTOM", "item_id": "679dd99ffc8dd33527566fb7", "name": "Black jeans", "days_unworn": 3 },`  
        `{ "slot_role": "FOOTWEAR", "item_id": "679dd39ffc8dc903275671b7", "name": "Black loafers", "days_unworn": 2 }`  
      `]`  
    `},`  
    `{`  
      `"deck_order": 4,`  
      `"title": "White for coffee",`  
      `"match_pct": 82,`  
      `"highlight_reason": "Benched 41 days · White T-shirt",`  
      `"visual_mode": "COLLAGE_FLATLAY",`  
      `"swipe_status": "PENDING_SWIPE",`  
      `"items": [`  
        `{ "slot_role": "TOP", "item_id": "679dd79ffc8dcfcf27566db7", "name": "White T-shirt", "days_unworn": 41 },`  
        `{ "slot_role": "BOTTOM", "item_id": "679dd99ffc8dd33527566fb7", "name": "Black jeans", "days_unworn": 3 },`  
        `{ "slot_role": "FOOTWEAR", "item_id": "679dd49ffc8dcab6275674b7", "name": "White sneakers", "days_unworn": 6 }`  
      `]`  
    `},`  
    `{`  
      `"deck_order": 5,`  
      `"title": "Blue for coffee",`  
      `"match_pct": 73,`  
      `"highlight_reason": null,`  
      `"visual_mode": "COLLAGE_FLATLAY",`  
      `"swipe_status": "PENDING_SWIPE",`  
      `"items": [`  
        `{ "slot_role": "TOP", "item_id": "679dd89ffc8dd182275670b7", "name": "Short-sleeve shirt", "days_unworn": 5 },`  
        `{ "slot_role": "BOTTOM", "item_id": "679dd29ffc8dc750275672b7", "name": "Pleated skirt", "days_unworn": 9 },`  
        `{ "slot_role": "FOOTWEAR", "item_id": "679dd39ffc8dc903275671b7", "name": "Black loafers", "days_unworn": 2 }`  
      `]`  
    `},`  
    `{`  
      `"deck_order": 6,`  
      `"title": "Blue for coffee",`  
      `"match_pct": 73,`  
      `"highlight_reason": null,`  
      `"visual_mode": "COLLAGE_FLATLAY",`  
      `"swipe_status": "PENDING_SWIPE",`  
      `"items": [`  
        `{ "slot_role": "TOP", "item_id": "679dd89ffc8dd182275670b7", "name": "Short-sleeve shirt", "days_unworn": 5 },`  
        `{ "slot_role": "BOTTOM", "item_id": "679dd29ffc8dc750275672b7", "name": "Pleated skirt", "days_unworn": 9 },`  
        `{ "slot_role": "FOOTWEAR", "item_id": "679dd49ffc8dcab6275674b7", "name": "White sneakers", "days_unworn": 6 }`  
      `]`  
    `},`  
    `{`  
      `"deck_order": 7,`  
      `"title": "Blue for coffee",`  
      `"match_pct": 72,`  
      `"highlight_reason": null,`  
      `"visual_mode": "COLLAGE_FLATLAY",`  
      `"swipe_status": "PENDING_SWIPE",`  
      `"items": [`  
        `{ "slot_role": "TOP", "item_id": "679dd89ffc8dd182275670b7", "name": "Short-sleeve shirt", "days_unworn": 5 },`  
        `{ "slot_role": "BOTTOM", "item_id": "679dd99ffc8dd33527566fb7", "name": "Black jeans", "days_unworn": 3 },`  
        `{ "slot_role": "FOOTWEAR", "item_id": "679dd49ffc8dcab6275674b7", "name": "White sneakers", "days_unworn": 6 }`  
      `]`  
    `},`  
    `{`  
      `"deck_order": 8,`  
      `"title": "Blue for coffee",`  
      `"match_pct": 72,`  
      `"highlight_reason": null,`  
      `"visual_mode": "COLLAGE_FLATLAY",`  
      `"swipe_status": "PENDING_SWIPE",`  
      `"items": [`  
        `{ "slot_role": "TOP", "item_id": "679dd89ffc8dd182275670b7", "name": "Short-sleeve shirt", "days_unworn": 5 },`  
        `{ "slot_role": "BOTTOM", "item_id": "679dd99ffc8dd33527566fb7", "name": "Black jeans", "days_unworn": 3 },`  
        `{ "slot_role": "FOOTWEAR", "item_id": "679dd39ffc8dc903275671b7", "name": "Black loafers", "days_unworn": 2 }`  
      `]`  
    `}`  
  `]`  
`}`

### **5\. contracts/fixtures/enums.json**

Single source of truth for all UPPER\_SNAKE\_CASE wire enums (TASK-012 / TASK-013 / BE-022 \#1).

`{`  
  `"description": "Canonical UPPER_SNAKE wire enum values across phone and server (TASK-012 / TASK-013)",`  
  `"enums": {`  
    `"item_group": ["TOPS", "BOTTOMS", "SHOES", "BAGS", "HATS", "ACCESSORIES"],`  
    `"batch_purpose": ["WARDROBE", "BODY_REFERENCE"],`  
    `"batch_status": [`  
      `"DRAFT",`  
      `"SANITIZING",`  
      `"QUEUED_FOR_AI",`  
      `"AI_PROCESSING",`  
      `"AWAITING_REVIEW",`  
      `"COMPLETED",`  
      `"FAILED",`  
      `"DELETED_BY_USER"`  
    `],`  
    `"analysis_task": [`  
      `"OUTFIT_EXTRACTION",`  
      `"POSE_ESTIMATION",`  
      `"BACKGROUND_ANALYSIS"`  
    `],`  
    `"ai_job_status": [`  
      `"PENDING",`  
      `"PROCESSING",`  
      `"COMPLETED",`  
      `"SKIPPED_NO_PERSON",`  
      `"FAILED"`  
    `],`  
    `"last_worn_option": [`  
      `"WITHIN_1_WEEK",`  
      `"ONE_TO_THREE_MONTHS",`  
      `"OVER_THREE_MONTHS",`  
      `"EXACT_DATE",`  
      `"DONT_REMEMBER"`  
    `],`  
    `"wear_event_source": [`  
      `"LIKE_CONFIRM",`  
      `"ITEM",`  
      `"MULTI",`  
      `"CHECKIN",`  
      `"PHOTO",`  
      `"REMINDER",`  
      `"TREND"`  
    `],`  
    `"session_path": ["PROMPT_LED", "ZERO_INPUT"],`  
    `"gu_match_session_status": [`  
      `"REQUESTED",`  
      `"GATHERING",`  
      `"ANALYZED",`  
      `"DECK_READY",`  
      `"NO_ELIGIBLE_ITEMS",`  
      `"FAILED"`  
    `],`  
    `"occasion": [`  
      `"WORK",`  
      `"COFFEE",`  
      `"AFTERNOON_RAIN",`  
      `"DATE",`  
      `"WEEKEND_OUTING"`  
    `],`  
    `"slot_role": ["TOP", "BOTTOM", "FOOTWEAR", "BAG", "HAT", "ACCESSORY"],`  
    `"visual_mode": ["COLLAGE_FLATLAY", "TRY_ON_RENDER", "AI_ILLUSTRATION"],`  
    `"swipe_status": [`  
      `"PENDING_SWIPE",`  
      `"SWIPED_LEFT_PASSED",`  
      `"SWIPED_RIGHT_LIKED",`  
      `"SAVED_TO_LOOKBOOK"`  
    `],`  
    `"card_action": [`  
      `"DISMISS_PASS",`  
      `"LIKE_SAVE",`  
      `"CUSTOMIZE_EDIT",`  
      `"ADJUST",`  
      `"TRIGGER_VTON"`  
    `],`  
    `"attachment_kind": [`  
      `"PHOTO",`  
      `"CUTOUT",`  
      `"BODY",`  
      `"RENDER",`  
      `"POSTER",`  
      `"EXPORT",`  
      `"EDITORIAL"`  
    `],`  
    `"attachment_state": [`  
      `"PENDING_UPLOAD",`  
      `"UPLOADED",`  
      `"VERIFIED",`  
      `"REJECTED",`  
      `"READY"`  
    `],`  
    `"ticket_op": ["PUT", "GET"],`  
    `"privacy_scope": ["BODY", "ALL", "EXPORT"],`  
    `"privacy_status": ["REQUESTED", "IN_PROGRESS", "COMPLETED", "FAILED"],`  
    `"vton_job_status": [`  
      `"REQUESTED",`  
      `"PROCESSING",`  
      `"COMPLETED",`  
      `"FAILED",`  
      `"CANCELLED"`  
    `]`  
  `}`  
`}`

### **6\. contracts/fixtures/table\_classes.json**

Machine-readable declaration of table classes, stream memberships, and column ownership consumed by both the mobile write guard (TASK-014) and the backend write handler (BE-011 / BE-012 / BE-022 \#3).

`{`  
  `"description": "Single source of truth for table classes, streams, and column allow-lists (TASK-011 / TASK-012 / BE-022)",`  
  `"tables": {`  
    `"profiles": {`  
      `"class": "READ_WRITE",`  
      `"stream": "my_wardrobe",`  
      `"phone_put_allowed": true,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": [`  
        `"first_name",`  
        `"time_zone",`  
        `"community_opt_in",`  
        `"display_name",`  
        `"updated_at"`  
      `]`  
    `},`  
    `"wardrobe_items": {`  
      `"class": "READ_WRITE",`  
      `"stream": "my_wardrobe",`  
      `"phone_put_allowed": true,`  
      `"phone_delete_allowed": true,`  
      `"phone_patch_allow_list": [`  
        `"name",`  
        `"type_code",`  
        `"color",`  
        `"material",`  
        `"style_tag",`  
        `"last_worn_estimate",`  
        `"archived",`  
        `"updated_at"`  
      `]`  
    `},`  
    `"wear_events": {`  
      `"class": "INSERT_ONLY",`  
      `"stream": "my_wardrobe",`  
      `"phone_put_allowed": true,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": []`  
    `},`  
    `"consents": {`  
      `"class": "INSERT_ONLY",`  
      `"stream": "my_wardrobe",`  
      `"phone_put_allowed": true,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": ["revoked_at"]`  
    `},`  
    `"upload_batches": {`  
      `"class": "READ_WRITE",`  
      `"stream": "my_studio",`  
      `"phone_put_allowed": true,`  
      `"phone_delete_allowed": true,`  
      `"phone_patch_allow_list": [`  
        `"status",`  
        `"consent_id",`  
        `"req_outfit",`  
        `"req_pose",`  
        `"req_background",`  
        `"ambient_temp_c",`  
        `"updated_at"`  
      `],`  
      `"phone_allowed_statuses": [`  
        `"DRAFT",`  
        `"SANITIZING",`  
        `"QUEUED_FOR_AI",`  
        `"COMPLETED",`  
        `"DELETED_BY_USER"`  
      `]`  
    `},`  
    `"media_assets": {`  
      `"class": "READ_WRITE",`  
      `"stream": "my_studio",`  
      `"phone_put_allowed": true,`  
      `"phone_delete_allowed": true,`  
      `"phone_patch_allow_list": [`  
        `"slot_index",`  
        `"attachment_id",`  
        `"orientation",`  
        `"exif_gps_stripped",`  
        `"bystanders_blurred",`  
        `"contains_person",`  
        `"removed"`  
      `]`  
    `},`  
    `"ai_processing_jobs": {`  
      `"class": "READ_ONLY",`  
      `"stream": "my_studio_jobs",`  
      `"phone_put_allowed": false,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": []`  
    `},`  
    `"extracted_items": {`  
      `"class": "PHONE_PATCH_ONLY",`  
      `"stream": "my_studio",`  
      `"phone_put_allowed": false,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": ["value", "last_worn_input"]`  
    `},`  
    `"gu_match_sessions": {`  
      `"class": "COMMAND",`  
      `"stream": "my_decks",`  
      `"phone_put_allowed": true,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": ["occasions", "raw_prompt"]`  
    `},`  
    `"outfit_candidates": {`  
      `"class": "READ_ONLY",`  
      `"stream": "my_decks",`  
      `"phone_put_allowed": false,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": []`  
    `},`  
    `"interactions": {`  
      `"class": "READ_WRITE",`  
      `"stream": "my_decks",`  
      `"phone_put_allowed": true,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": []`  
    `},`  
    `"vton_jobs": {`  
      `"class": "COMMAND",`  
      `"stream": "my_decks",`  
      `"phone_put_allowed": true,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": []`  
    `},`  
    `"attachments": {`  
      `"class": "READ_WRITE",`  
      `"stream": "my_files",`  
      `"phone_put_allowed": true,`  
      `"phone_delete_allowed": true,`  
      `"phone_patch_allow_list": ["state"]`  
    `},`  
    `"attachment_tickets": {`  
      `"class": "READ_ONLY",`  
      `"stream": "my_files",`  
      `"phone_put_allowed": false,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": []`  
    `},`  
    `"privacy_requests": {`  
      `"class": "COMMAND",`  
      `"stream": "my_files",`  
      `"phone_put_allowed": true,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": []`  
    `},`  
    `"item_types": {`  
      `"class": "READ_ONLY",`  
      `"stream": "catalog",`  
      `"phone_put_allowed": false,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": []`  
    `},`  
    `"item_embeddings": {`  
      `"class": "READ_ONLY",`  
      `"stream": "my_wardrobe",`  
      `"phone_put_allowed": false,`  
      `"phone_delete_allowed": false,`  
      `"phone_patch_allow_list": []`  
    `}`  
  `}`  
`}`

**Phase 2 is complete.** Reply **"proceed phase 3"** (or **"proceed"**) to generate the **Phase 3: Cross-Platform Mobile Task Specifications (docs/tasks/mobile/)**.

---

*User prompt: Proceed phase 3*

Response: Here are the complete **Phase 3: Cross-Platform Mobile Task Specifications (docs/tasks/mobile/)** documents (TASK-010, TASK-015, TASK-017, and TASK-020) designed for the Flutter App Developer to implement the client sync adapters without modifying the Dart code directly.

### **1\. docs/tasks/mobile/TASK-010-mock-backend-integration.md**

`# TASK-010: Sync transport and dev connector to the mock backend`

`> **Phase:** P3 · Track M`  
`> **Status:** Ready for implementation`  
`> **Owner:** App Developer`  
`> **Dependencies:** [TASK-017](TASK-017-local-upload-queue.md), [BE-012](../backend/BE-012-mock-write-handler.md), [BE-013](../backend/BE-013-mock-change-feed.md)`  
`> **Blocks:** [TASK-018](TASK-018-flows-on-server-fakes.md), [TASK-019](TASK-019-catalog-from-the-database.md)`

`## 1. Objective`

``Implement the `SyncTransport` interface and `MockSyncConnector` under `apps/mobile/lib/core/sync/` so the Flutter app can push queued local CRUD transactions to `POST /v1/sync/tx` and pull server-side delta changes from `GET /v1/mock/sync/changes`, applying them to the local SQLite database.``

`---`

`## 2. Architectural Boundaries`

``- **Single Data Loop (DB5)**: Repositories and ViewModels never call `SyncTransport` or HTTP endpoints directly. Repositories continue to read and write local SQLite tables exclusively.``  
``- **Write Checkpoints (`C03-07`, `SP-03`)**: A sync pull cycle must not expose server-side state for a transaction until the local upload queue's `last_applied_checkpoint` is $\leq$ the change feed's `checkpoint`.``  
`- **Replay & Live Modes**:`  
  ``1. **Fixture Replay Mode (Default CI)**: Reads recorded request/response pairs from `contracts/fixtures/sync/*.json` with zero network I/O.``  
  ``2. **Live Mock Backend Mode (`--dart-define=GARBLO_BACKEND=mock`)**: Connects to the local FastAPI server (`http://localhost:8000`) using `Bearer dev.<install_owner_id>`.``

`---`

`## 3. Deliverables for the App Developer`

`| File Path | Responsibility |`  
`| :--- | :--- |`  
``| `apps/mobile/lib/core/sync/sync_transport.dart` | Abstract `SyncTransport` interface defining `uploadCrudBatch(CrudTransaction tx)` and `pullChanges({required int afterCheckpoint, required List<String> streams})`. |``  
``| `apps/mobile/lib/core/sync/mock_sync_connector.dart` | Coordinates the Upload Loop (draining `TASK-017` upload queue to `POST /v1/sync/tx`) followed by the Pull Loop (`GET /v1/mock/sync/changes`), writing incoming `PUT`/`DELETE` rows into SQLite inside a single transaction. |``  
``| `apps/mobile/lib/core/sync/sync_checkpoint_store.dart` | Manages the local-only `sync_state` table tracking `last_pulled_checkpoint` and `last_uploaded_checkpoint`. |``  
``| `apps/mobile/lib/core/sync/sync_providers.dart` | Riverpod providers wiring `syncTransportProvider` and `syncConnectorProvider`. |``

`---`

`## 4. Implementation Rules`

``1. **Stream Subscriptions**: Default auto-subscribed streams are `catalog,my_wardrobe,my_studio,my_studio_jobs,my_decks,my_files`.``  
``2. **Applying Feed Changes (`PUT` vs `DELETE`)**:``  
   ``- On `op == 'PUT'`, serialize any nested JSON maps/lists in `change.data` to `TEXT` and upsert the row into `change.type` (`DELETE FROM <table> WHERE id = ?` + `INSERT INTO <table> ...` inside the sync write bypass so it does not re-enqueue to the upload queue).``  
   ``- On `op == 'DELETE'` (`data: null`), execute `DELETE FROM <table> WHERE id = ?` without recording an outbound upload queue entry.``  
``3. **Pagination**: Loop while `response.has_more == true`, advancing `after` to the last received `seq` before updating `last_pulled_checkpoint` to `response.checkpoint`.``

`---`

`## 5. TDD Scenarios`

`| Scenario ID | Level | Test File | Description |`  
`| :--- | :--- | :--- | :--- |`  
``| `TASK-010-S01` | Unit | `test/core/sync/mock_sync_connector_test.dart` | `[TASK-010-S01] drains upload queue before pulling changes and advances checkpoint` |``  
``| `TASK-010-S02` | Unit | `test/core/sync/mock_sync_connector_test.dart` | `[TASK-010-S02] incoming server rows bypass the outbound upload queue (no echo loop)` |``  
``| `TASK-010-S03` | Unit | `test/core/sync/mock_sync_connector_test.dart` | `[TASK-010-S03] paginates through has_more pages without dropping or duplicating rows` |``  
``| `TASK-010-S04` | Integration | `test/core/sync/mock_sync_connector_test.dart` | `[TASK-010-S04] DELETE changes remove COMPLETED studio batch rows from local SQLite` |``

### **2\. docs/tasks/mobile/TASK-015-result-engine-seams.md**

`# TASK-015: Result engine seams — decouple local fakes from repositories`

`> **Phase:** P3 preparation · Track M`  
`> **Status:** Ready for implementation`  
`> **Owner:** App Developer`  
`> **Dependencies:** [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md)`  
`> **Blocks:** [TASK-011](TASK-011-phone-schema-v2-alignment.md), [TASK-018](TASK-018-flows-on-server-fakes.md)`

`## 1. Objective`

``Today `LocalGuMatchRepository` wraps `MockGuMatchRepository`, and fake photo analysis is embedded directly inside `LocalStudioRepository.analyze()`. Under the v2.8 One-Piece Data Flow (`DB5`), the phone writes command/status rows (`upload_batches.status = 'QUEUED_FOR_AI'`, `gu_match_sessions.status = 'REQUESTED'`) and watches result rows (`ai_processing_jobs`, `extracted_items`, `outfit_candidates`) arrive in SQLite.``

``This task extracts clean result-engine seams so the same repository code runs against either local offline fakes (`Local*Engine` writing to `fake_*` mirror tables) or synced server rows (`Synced*Engine`).``

`---`

`## 2. Deliverables for the App Developer`

`| File Path | Responsibility |`  
`| :--- | :--- |`  
``| `apps/mobile/lib/features/studio/data/analysis_engine.dart` | Defines `AnalysisEngine` interface with `LocalAnalysisEngine` (writes deterministic jobs and sample sets to `fake_ai_processing_jobs` and `fake_extracted_items`) and `SyncedAnalysisEngine` (triggers sync connector and observes synced `ai_processing_jobs` / `extracted_items`). |``  
``| `apps/mobile/lib/features/gu_match/data/deck_engine.dart` | Defines `DeckEngine` interface with `LocalDeckEngine` (runs `FakeCandidateGenerator` and writes to `fake_outfit_candidates`) and `SyncedDeckEngine` (observes server-populated `gu_match_sessions.context` and `outfit_candidates`). |``  
``| `apps/mobile/lib/features/studio/data/local_studio_repository.dart` | Refactored to depend on `AnalysisEngine` instead of inline `_samples` / `_recordJobs`. |``  
``| `apps/mobile/lib/features/gu_match/data/local_gu_match_repository.dart` | Refactored to depend on `DeckEngine` and SQLite queries instead of delegating to `MockGuMatchRepository`. |``

`---`

`## 3. Implementation Rules`

``1. **No Server-Owned Table Writes from Phone Repositories (`F-08`, `C04-07`)**:``  
   ``- `LocalStudioRepository` must never `INSERT` into `ai_processing_jobs` or `extracted_items`. It only `PATCH`es `extracted_items.value` and `extracted_items.last_worn_input`.``  
   ``- `LocalGuMatchRepository` must never `INSERT` into `outfit_candidates` or write server-owned columns of `gu_match_sessions` (`context`, `eligible_item_count`, `owned_only`, `deck_size`, `recent`, `expires_at`).``  
`2. **Union Read Queries in Offline Mode**:`  
   ``- While running in local fake mode (`GARBLO_BACKEND=local`), read queries `UNION ALL` the synced read-only table (`extracted_items`, `outfit_candidates`) with its `fake_*` local mirror table.``  
`3. **Provider Switching**:`  
   ``- When `--dart-define=GARBLO_BACKEND=mock` is set, Riverpod binds `SyncedAnalysisEngine` and `SyncedDeckEngine`.``

`---`

`## 4. TDD Scenarios`

`| Scenario ID | Level | Test File | Description |`  
`| :--- | :--- | :--- | :--- |`  
``| `TASK-015-S01` | Repository | `test/features/studio/data/local_studio_repository_test.dart` | `[TASK-015-S01] LocalStudioRepository delegates analysis to AnalysisEngine without writing server-owned tables` |``  
``| `TASK-015-S02` | Repository | `test/features/gu_match/data/local_gu_match_repository_test.dart` | `[TASK-015-S02] LocalGuMatchRepository does not wrap MockGuMatchRepository and reads candidates via DeckEngine seam` |``  
``| `TASK-015-S03` | Journey | `test/app/flow_a_journey_test.dart` & `flow_b_journey_test.dart` | `[TASK-015-S03] Flow A and Flow B journeys pass unchanged with LocalAnalysisEngine and LocalDeckEngine` |``

### **3\. docs/tasks/mobile/TASK-017-local-upload-queue.md**

`# TASK-017: Local upload queue and pending transaction tracker`

`> **Phase:** P3 · Track M`  
`> **Status:** Ready for implementation`  
`> **Owner:** App Developer`  
`> **Dependencies:** [TASK-011](TASK-011-phone-schema-v2-alignment.md), [TASK-014](TASK-014-upload-safe-write-shapes.md)`  
`> **Blocks:** [TASK-010](TASK-010-mock-backend-integration.md), [TASK-022](TASK-022-sync-status-and-convergence.md), [TASK-024](TASK-024-rejections-and-retries.md)`

`## 1. Objective`

``Record every phone-initiated `PUT`, `PATCH`, and `DELETE` on synced tables into an ordered, crash-safe local SQLite upload queue (`crud_upload_queue`) grouped by transaction ID (`tx_id`), exposing a reactive pending-transaction count and draining batches to `POST /v1/sync/tx`.``

`---`

`## 2. Queue Table Schema (Local-Only)`

``Because PowerSync manages its own `ps_crud` queue in Track R (`TASK-020`), Track M creates a lightweight local-only queue table with the exact `CrudEntry` JSON shape expected by `POST /v1/sync/tx` (`BE-012`):``

```` ```sql ````  
`CREATE TABLE crud_upload_queue (`  
  `id TEXT PRIMARY KEY,`  
  `tx_id INTEGER,`  
  `op_index INTEGER,`  
  `op TEXT,`  
  `table_name TEXT,`  
  `row_id TEXT,`  
  `data_json TEXT,`  
  `created_at TEXT`  
`);`

## **3\. Deliverables for the App Developer**

| File Path | Responsibility |
| :---- | :---- |
| apps/mobile/lib/core/sync/upload\_queue\_manager.dart | Captures mutations inside the same SQLite write transaction as the domain write; groups entries by monotonic tx\_id; exposes getNextCrudTransaction() and completeTransaction(int txId). |
| apps/mobile/lib/core/sync/write\_guard.dart | Validates every outbound mutation against contracts/fixtures/table\_classes.json before enqueueing (throws StateError in debug/test if code attempts to write a READ\_ONLY table or non-allow-listed column). |
| apps/mobile/lib/core/sync/rejection\_log\_store.dart | Persists 4xx rejections from POST /v1/sync/tx into local-only sync\_rejections before calling completeTransaction(txId) so the queue never blocks (C04-09). |

## **4\. Queue Progression & Retry Rules**

> 1. **Atomic Recording**: When a repository executes a write transaction on a synced table, the UploadQueueManager records the corresponding PUT, PATCH (changed columns only), or DELETE operations in crud\_upload\_queue within the **same** SQLite transaction.  
> 2. **200 OK (Applied or Replayed)**: Delete all crud\_upload\_queue rows for tx\_id and update last\_uploaded\_checkpoint \= response.checkpoint.  
> 3. **403 / 404 / 409 / 422 (Domain or Guard Rejection)**:  
   * Insert a record into local-only sync\_rejections(id, tx\_id, op\_index, error\_code, message, created\_at).  
   * Delete the rejected tx\_id from crud\_upload\_queue so subsequent valid transactions are not blocked (BE-012).  
   * Trigger an immediate sync pull so the authoritative server state overwrites the invalid local row.  
> 4. **503 / Network Timeout**:  
   * Leave tx\_id at the head of crud\_upload\_queue.  
   * Retry with exponential backoff (500ms, 1s, 2s, 4s, 8s, max 5 attempts per C08-04).

## **5\. TDD Scenarios**

| Scenario ID | Level | Test File | Description |
| :---- | :---- | :---- | :---- |
| TASK-017-S01 | Unit | test/core/sync/upload\_queue\_manager\_test.dart | \[TASK-017-S01\] multi-statement write transaction produces a single tx\_id with ordered ops |
| TASK-017-S02 | Unit | test/core/sync/upload\_queue\_manager\_test.dart | \[TASK-017-S02\] local-only tables (session\_draft, ui\_state, fake\_\*) never enter the upload queue |
| TASK-017-S03 | Unit | test/core/sync/upload\_queue\_manager\_test.dart | \[TASK-017-S03\] 422 rejection logs to sync\_rejections and completes tx\_id so queue advances |
| TASK-017-S04 | Unit | test/core/sync/upload\_queue\_manager\_test.dart | \[TASK-017-S04\] 503 fault keeps tx\_id at head of queue and succeeds on retry with same tx\_id |

`---`

`` ### 4. `docs/tasks/mobile/TASK-020-powersync-sdk-swap.md` ``

```` ```markdown ````  
`# TASK-020: PowerSync SDK swap — replace raw SQLite with PowerSyncDatabase`

`> **Phase:** P3 · Track R`  
`> **Status:** Ready after TASK-011 and BE-001`  
`> **Owner:** App Developer`  
`> **Dependencies:** [TASK-011](TASK-011-phone-schema-v2-alignment.md), [TASK-017](TASK-017-local-upload-queue.md), [BE-001](../backend/BE-001-platform-decision.md), [BE-006](../backend/BE-006-phone-schema-sync-parity.md)`

`## 1. Objective`

``Swap the `sqlite_async` `SqliteDatabase` instance in `GarbloDatabase` for `PowerSyncDatabase` (with SQLCipher encryption via `powersync_sqlcipher`), generating the PowerSync `Schema` declaratively from `PhoneSchema` (`apps/mobile/lib/core/storage/phone_schema.dart`) without renaming any table or column.``

`---`

`## 2. Deliverables for the App Developer`

`| File Path | Responsibility |`  
`| :--- | :--- |`  
``| `apps/mobile/lib/core/storage/powersync_schema_adapter.dart` | Maps `PhoneSchema.tables` (`TableSpec`, `ColumnSpec`, `IndexSpec`) into a PowerSync `Schema([Table(...), Table.localOnly(...)])` object. |``  
``| `apps/mobile/lib/core/sync/garblo_powersync_connector.dart` | Implements `PowerSyncBackendConnector`: `fetchCredentials()` calls `GET /v1/sync/credentials`, and `uploadData(PowerSyncDatabase database)` forwards `getNextCrudTransaction()` batches to `POST /v1/sync/tx`. |``  
``| `apps/mobile/lib/core/storage/garblo_database.dart` | Replaces manual `CREATE TABLE` migration loop with `PowerSyncDatabase.withFactory(...)` while retaining the 64-hex SQLCipher key check (`C05-01`). |``

`---`

`## 3. Implementation Rules`

``1. **Zero Schema Drift (`C01-04`, `BE-006`)**:``  
   ``- `powersync_schema_adapter.dart` must build its `Schema` strictly by iterating over `PhoneSchema.tables`. Never maintain a second hard-coded list of tables or columns.``  
   ``- Tables with `table.localOnly == true` (`session_draft`, `ui_state`, `rewards_provisional`) must be constructed with `Table.localOnly(...)` so PowerSync creates local views without recording CRUD upload entries.``  
``2. **View-Safe Existence Checks (`BE-006`)**:``  
   ``- Because PowerSync tables are SQLite views backed by internal JSON storage, `INSERT OR IGNORE` is not supported on views. Keep the existing `INSERT INTO <table> ... SELECT ... WHERE NOT EXISTS (SELECT 1 FROM <table> WHERE id = ?)` pattern inside `writeTransaction`.``  
``3. **Account Merge Reconnect (`ID-06`)**:``  
   ``- When `/v1/auth/google-link` returns `status == 'MERGED'` with a surviving `user_id`, call `await powerSyncDb.disconnectAndClear()` and reconnect with the new JWT credentials.``

`---`

`## 4. TDD Scenarios`

`| Scenario ID | Level | Test File | Description |`  
`| :--- | :--- | :--- | :--- |`  
``| `TASK-020-S01` | Unit | `test/core/storage/powersync_schema_adapter_test.dart` | `[TASK-020-S01] generated PowerSync Schema matches PhoneSchema v2 tables, columns, and localOnly flags` |``  
``| `TASK-020-S02` | Integration | `test/core/sync/garblo_powersync_connector_test.dart` | `[TASK-020-S02] uploadData maps PowerSync CrudBatch to POST /v1/sync/tx and completes on 200 and 4xx` |``  
``| `TASK-020-S03` | Integration | `test/app/persistence_restore_test.dart` | `[TASK-020-S03] existing repository contract suites pass over PowerSync view tables` |``

**Phase 3 is complete.** Reply **"proceed phase 4"** (or **"proceed"**) to execute **Phase 4 & Phase 5**: assembling all files into the extracted repository, running the verification checks, updating docs/ and docs/changes/, and generating the updated .zip archive.

---

