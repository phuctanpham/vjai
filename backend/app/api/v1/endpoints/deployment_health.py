import secrets
from typing import Any

from fastapi import APIRouter, Query, Request
from fastapi.responses import JSONResponse

router = APIRouter()


def _environment_value(request: Request, name: str) -> str | None:
    environment: Any = request.scope.get("env")
    if environment is None:
        return None
    if isinstance(environment, dict):
        value = environment.get(name)
    else:
        value = getattr(environment, name, None)
    return value if isinstance(value, str) else None


@router.get("/health/deployment")
async def get_deployment_health(
    request: Request,
    commit_id: str = Query(min_length=7, max_length=40, pattern=r"^[0-9a-fA-F]+$"),
    deployment_id: str = Query(min_length=1, max_length=128),
) -> JSONResponse:
    expected_token = _environment_value(request, "HEALTH_CHECK_TOKEN")
    supplied_token = request.headers.get("X-Health-Token", "")
    if not expected_token or not secrets.compare_digest(supplied_token, expected_token):
        return JSONResponse(
            status_code=401,
            content={"status": "unauthorized"},
            headers={"WWW-Authenticate": "Bearer"},
        )

    return JSONResponse(
        status_code=200,
        content={
            "status": "ok",
            "commit_id": commit_id.lower(),
            "deployment_id": deployment_id,
        },
    )
