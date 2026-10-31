import asyncio

from starlette.requests import Request

from app.api.v1.endpoints.deployment_health import get_deployment_health


def _request(token: str = "health-token") -> Request:
    return Request(
        {
            "type": "http",
            "method": "GET",
            "path": "/health/deployment",
            "headers": [(b"x-health-token", token.encode())],
            "query_string": b"",
            "env": {"HEALTH_CHECK_TOKEN": "health-token"},
        }
    )


def test_deployment_health_returns_metadata():
    response = asyncio.run(
        get_deployment_health(
            _request(),
            commit_id="ABCDEF1234567",
            deployment_id="dep-123",
        )
    )

    assert response.status_code == 200
    assert response.body == (
        b'{"status":"ok","commit_id":"abcdef1234567","deployment_id":"dep-123"}'
    )


def test_deployment_health_rejects_invalid_token():
    response = asyncio.run(
        get_deployment_health(
            _request("wrong-token"),
            commit_id="abcdef1234567",
            deployment_id="dep-123",
        )
    )

    assert response.status_code == 401
