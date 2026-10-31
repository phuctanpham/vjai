import logging

from fastapi import APIRouter, Request
from fastapi.responses import JSONResponse
from langchain_core.messages import HumanMessage
from langchain_openai import ChatOpenAI

from app.api.v1.endpoints.health_auth import (
    _environment_value,
    has_valid_basic_auth,
)

router = APIRouter()
logger = logging.getLogger(__name__)

MODEL_NAME = "gpt-4o-mini"
HEALTH_PROMPT = "Reply with the single word: OK"


def _environment_value(request: Request, name: str) -> str | None:
    environment: Any = request.scope.get("env")
    if environment is None:
        return None
    if isinstance(environment, dict):
        value = environment.get(name)
    else:
        value = getattr(environment, name, None)
    return value if isinstance(value, str) else None


async def _invoke_openai(api_key: str) -> None:
    model = ChatOpenAI(model=MODEL_NAME, api_key=api_key, max_tokens=4)
    await model.ainvoke([HumanMessage(content=HEALTH_PROMPT)])


@router.get("/health/openai")
async def get_openai_health(request: Request) -> JSONResponse:
    if not has_valid_basic_auth(request):
        return JSONResponse(
            status_code=401,
            content={"status": "unauthorized"},
            headers={"WWW-Authenticate": "Basic"},
        )

    api_key = _environment_value(request, "OPENAI_API_KEY")
    if not api_key:
        return JSONResponse(
            status_code=503,
            content={"status": "unavailable"},
        )

    try:
        await _invoke_openai(api_key)
    except Exception:
        logger.exception("OpenAI health request failed")
        return JSONResponse(
            status_code=502,
            content={"status": "unavailable"},
        )

    return JSONResponse(
        status_code=200,
        content={
            "status": "ok",
            "provider": "openai",
            "model": MODEL_NAME,
        },
    )
