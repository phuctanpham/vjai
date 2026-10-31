import asyncio
import base64

from starlette.requests import Request

from app.api.v1.endpoints.deployment_health import get_deployment_health


def _request(username: str = "health-user", password: str = "health-password") -> Request:
    credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
    return Request(
        {
            "type": "http",
            "method": "GET",
            "path": "/health/deployment",
            "headers": [(b"authorization", f"Basic {credentials}".encode())],
            "query_string": b"",
            "env": {
                "BASIC_AUTH_USERNAME": "health-user",
                "BASIC_AUTH_PASSWORD": "health-password",
            },
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
            _request("wrong-user", "wrong-password"),
            commit_id="abcdef1234567",
            deployment_id="dep-123",
        )
    )

    assert response.status_code == 401
