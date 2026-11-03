from __future__ import annotations

from fastapi.testclient import TestClient

from app.main import create_app


def test_phase4_step8_health_is_local_and_non_sensitive() -> None:
    with TestClient(create_app(adapter="mock")) as client:
        response = client.get("/health")
        versioned = client.get("/api/v1/health")

    assert response.status_code == 200
    assert response.json() == {
        "status": "ok",
        "service": "garblo-backend",
    }
    assert versioned.status_code == 200
    assert versioned.json() == response.json()


def test_phase4_step8_self_test_runs_seed_and_migration_checks(
    capsys: object,
) -> None:
    from app.self_test import main

    assert main([]) == 0
    assert "health=ok" in capsys.readouterr().out  # type: ignore[attr-defined]


def test_powersync_token_endpoint_issues_direct_client_token(
    monkeypatch,
) -> None:
    from app.main import OWNER_A, create_app

    monkeypatch.setenv("ENV", "test")
    monkeypatch.setenv("GARBLO_POWERSYNC_URL", "https://sync.example")
    monkeypatch.setenv("GARBLO_POWERSYNC_KEY_ID", "test-key")
    monkeypatch.setenv("GARBLO_POWERSYNC_PRIVATE_KEY", "test-private-key")
    monkeypatch.setenv("GARBLO_POWERSYNC_AUDIENCE", "https://sync.example")
    with TestClient(create_app(adapter="mock")) as client:
        response = client.post(
            "/v1/auth/powersync-token",
            headers={"Authorization": f"Bearer {OWNER_A}"},
        )
    assert response.status_code == 200
    assert response.json()["expires_in"] == 300
    assert response.json()["token"].count(".") == 2
