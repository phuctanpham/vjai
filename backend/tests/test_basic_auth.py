from __future__ import annotations

import base64

from fastapi.testclient import TestClient

from app.main import create_app


def _basic(username: str, password: str) -> str:
    value = base64.b64encode(f"{username}:{password}".encode()).decode()
    return f"Basic {value}"


def test_basic_auth_protects_backend_service(monkeypatch) -> None:
    monkeypatch.setenv("BASIC_AUTH_USERNAME", "service-user")
    monkeypatch.setenv("BASIC_AUTH_PASSWORD", "service-password")
    monkeypatch.setenv("ENV", "test")
    monkeypatch.setenv("GARBLO_POWERSYNC_URL", "https://sync.example")
    monkeypatch.setenv("GARBLO_POWERSYNC_KEY_ID", "test-key")
    monkeypatch.setenv("GARBLO_POWERSYNC_AUDIENCE", "https://sync.example")
    monkeypatch.setenv("GARBLO_POWERSYNC_PRIVATE_KEY", "test-private-key")
    with TestClient(create_app()) as client:
        assert client.get("/health").status_code == 200
        assert client.get("/v1/mock/reset").status_code == 401
        assert client.get(
            "/health",
            headers={"Authorization": _basic("wrong", "wrong")},
        ).status_code == 200
        assert client.post(
            "/v1/auth/dev-token",
            json={"user_id": "65f0c1a2b3c4d5e6f7a8b9c0"},
            headers={"Authorization": _basic("service-user", "service-password")},
        ).status_code == 200
        assert client.post(
            "/v1/auth/powersync-token",
            headers={
                "Authorization": "Bearer 65f0c1a2b3c4d5e6f7a8b9c0",
                "X-Backend-Authorization": _basic("service-user", "service-password"),
            },
        ).status_code == 200


def test_basic_auth_rejects_bad_credentials(monkeypatch) -> None:
    monkeypatch.setenv("BASIC_AUTH_USERNAME", "service-user")
    monkeypatch.setenv("BASIC_AUTH_PASSWORD", "service-password")
    with TestClient(create_app()) as client:
        response = client.post(
            "/v1/auth/dev-token",
            json={"user_id": "65f0c1a2b3c4d5e6f7a8b9c0"},
            headers={"Authorization": _basic("service-user", "wrong")},
        )
    assert response.status_code == 401
    assert response.headers["www-authenticate"] == 'Basic realm="garblo-backend"'
