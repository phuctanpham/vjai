import asyncio
import base64
from unittest.mock import AsyncMock

from starlette.requests import Request

from app.api.v1.endpoints import openai_health


def _request(username: str = "health-user", password: str = "health-password") -> Request:
    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
    return Request(
        {
            "type": "http",
            "method": "GET",
            "path": "/health/openai",
            "headers": [(b"authorization", f"Basic {credentials}".encode())],
            "query_string": b"",
            "env": {
                "BASIC_AUTH_USERNAME": "health-user",
                "BASIC_AUTH_PASSWORD": "health-password",
                "OPENAI_API_KEY": "test-key",
            },
        }
    )


def test_openai_health_rejects_invalid_token():
    response = asyncio.run(
        openai_health.get_openai_health(_request("wrong-user", "wrong-password"))
    )

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
