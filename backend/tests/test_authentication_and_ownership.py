from __future__ import annotations

from importlib import import_module

import pytest
from fastapi.testclient import TestClient

from tests.conftest import OWNER_A, OWNER_B


def test_be_011_s05_dev_token_and_unauthenticated_error(client: TestClient) -> None:
    """[BE-011-S05] Auth issuance and structured unauthenticated errors."""
    issued = client.post("/v1/auth/dev-token", json={"user_id": OWNER_A})
    assert issued.status_code == 200
    assert issued.json() == {"token": f"dev.{OWNER_A}", "user_id": OWNER_A}

    invalid = client.post("/v1/auth/dev-token", json={"user_id": "not-an-object-id"})
    assert invalid.status_code == 422
    denied = client.post("/v1/sync/tx", json={"tx_id": 1, "ops": []})
    assert denied.status_code == 401
    assert denied.json()["error"]["code"] == "UNAUTHENTICATED"


def test_be_012_s09_owner_id_and_user_id_are_enforced(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-012-S09] A foreign row id or payload owner is rejected."""
    response = client.post(
        "/v1/sync/tx",
        headers=auth_headers_a,
        json={
            "tx_id": 9,
            "ops": [
                {
                    "op": "PUT",
                    "type": "profiles",
                    "id": OWNER_B,
                    "data": {"user_id": OWNER_B, "display_name": "foreign"},
                }
            ],
        },
    )
    assert response.status_code == 403
    assert response.json()["error"]["code"] == "OWNER_MISMATCH"


def test_be_011_s06_injected_clock_controls_server_written_timestamps(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-011-S06] Server timestamps use the mock clock, never wall time."""
    clock = client.put("/v1/mock/clock", json={"now": "2026-11-01T07:30:00Z"})
    assert clock.status_code == 200
    response = client.post(
        "/v1/sync/tx",
        headers=auth_headers_a,
        json={
            "tx_id": 10,
            "ops": [
                {
                    "op": "PUT",
                    "type": "profiles",
                    "id": "6725aa12c8e4b12d34567895",
                    "data": {"display_name": "clock-controlled"},
                }
            ],
        },
    )
    assert response.status_code == 200
    feed = client.get(
        "/v1/mock/sync/changes?after=0&streams=my_wardrobe",
        headers=auth_headers_a,
    )
    assert feed.status_code == 200
    profile = next(row for row in feed.json()["changes"] if row["type"] == "profiles")
    assert profile["data"]["created_at"] == "2026-11-01T07:30:00Z"


def test_be_011_s07_dev_controls_are_unavailable_in_production(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """[BE-011-S07] Production configuration never exposes mock controls."""
    monkeypatch.setenv("ENV", "production")
    try:
        factory = getattr(import_module("app.main"), "create_app")
        application = factory(adapter="mock")
    except (ImportError, AttributeError) as exc:
        pytest.fail(f"planned app factory is missing: {exc}")
    with TestClient(application) as production_client:
        response = production_client.put("/v1/mock/clock", json={"now": "2026-11-01T07:30:00Z"})
    assert response.status_code == 404
