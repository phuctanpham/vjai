import asyncio
from unittest.mock import AsyncMock

from starlette.requests import Request

from app.api.v1.endpoints import openai_health


def _request(token: str = "health-token") -> Request:
    return Request(
        {
            "type": "http",
            "method": "GET",
            "path": "/health/openai",
            "headers": [(b"x-health-token", token.encode())],
            "query_string": b"",
            "env": {
                "HEALTH_CHECK_TOKEN": "health-token",
                "OPENAI_API_KEY": "test-key",
            },
        }
    )


def test_openai_health_rejects_invalid_token():
    response = asyncio.run(openai_health.get_openai_health(_request("wrong-token")))

    assert response.status_code == 401
    assert response.body == b'{"status":"unauthorized"}'


def test_openai_health_returns_sanitized_success(monkeypatch):
    invoke = AsyncMock()
    monkeypatch.setattr(openai_health, "_invoke_openai", invoke)

    response = asyncio.run(openai_health.get_openai_health(_request()))

    assert response.status_code == 200
    assert response.body == (
        b'{"status":"ok","provider":"openai","model":"gpt-4o-mini"}'
    )
    invoke.assert_awaited_once_with("test-key")


def test_openai_health_hides_provider_failure(monkeypatch):
    invoke = AsyncMock(side_effect=RuntimeError("provider details"))
    monkeypatch.setattr(openai_health, "_invoke_openai", invoke)

    response = asyncio.run(openai_health.get_openai_health(_request()))

    assert response.status_code == 502
    assert response.body == b'{"status":"unavailable"}'
