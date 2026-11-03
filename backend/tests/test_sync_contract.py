from __future__ import annotations

from fastapi.testclient import TestClient


def test_be_012_s01_s02_valid_write_and_replay_are_idempotent(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-012-S01, BE-012-S02] Apply once, replay without a new checkpoint."""
    payload = {
        "tx_id": 42,
        "ops": [
            {
                "op": "PUT",
                "type": "profiles",
                "id": "6725aa12c8e4b12d34567890",
                "data": {"display_name": "Demo"},
            }
        ],
    }
    first = client.post("/v1/sync/tx", headers=auth_headers_a, json=payload)
    assert first.status_code == 200
    assert first.json()["applied"] is True
    assert first.json()["replayed"] is False
    replay = client.post("/v1/sync/tx", headers=auth_headers_a, json=payload)
    assert replay.status_code == 200
    assert replay.json()["replayed"] is True
    assert replay.json()["checkpoint"] == first.json()["checkpoint"]


def test_be_012_s03_tx_id_cannot_be_reused_with_different_ops(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-012-S03] Same owner and tx_id with another operation is rejected."""
    base = {
        "tx_id": 43,
        "ops": [
            {
                "op": "PUT",
                "type": "profiles",
                "id": "6725aa12c8e4b12d34567891",
                "data": {"display_name": "one"},
            }
        ],
    }
    assert client.post("/v1/sync/tx", headers=auth_headers_a, json=base).status_code == 200
    changed = {**base, "ops": [{**base["ops"][0], "data": {"display_name": "two"}}]}
    response = client.post("/v1/sync/tx", headers=auth_headers_a, json=changed)
    assert response.status_code == 409
    assert response.json()["error"]["code"] == "TX_ID_REUSED"


def test_be_012_s04_transaction_is_atomic_and_reports_op_index(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-012-S04] A failing operation applies neither its siblings nor itself."""
    response = client.post(
        "/v1/sync/tx",
        headers=auth_headers_a,
        json={
            "tx_id": 44,
            "ops": [
                {"op": "PUT", "type": "profiles", "id": "6725aa12c8e4b12d34567892", "data": {}},
                {
                    "op": "PUT",
                    "type": "item_types",
                    "id": "6725aa12c8e4b12d34567893",
                    "data": {"type_code": "SHIRT", "group_code": "TOPS", "label": "Shirt"},
                },
                {"op": "PUT", "type": "profiles", "id": "6725aa12c8e4b12d34567894", "data": {}},
            ],
        },
    )
    assert response.status_code == 403
    assert response.json()["error"]["op_index"] == 1


def test_be_012_s05_s06_s07_write_guards_return_contract_errors(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-012-S05..S07] Read-only, field, and append-only guards are explicit."""
    cases = (
        ("item_types", "PUT", 403, "TABLE_NOT_WRITABLE"),
        ("profiles", "PATCH", 422, "FIELD_NOT_WRITABLE"),
        ("wear_events", "PATCH", 422, "APPEND_ONLY"),
    )
    for index, (table, operation, status, code) in enumerate(cases):
        response = client.post(
            "/v1/sync/tx",
            headers=auth_headers_a,
            json={
                "tx_id": 50 + index,
                "ops": [
                    {
                        "op": operation,
                        "type": table,
                        "id": f"6725aa12c8e4b12d3456790{index}",
                        "data": {"server_owned": "no"},
                    }
                ],
            },
        )
        assert response.status_code == status
        assert response.json()["error"]["code"] == code
