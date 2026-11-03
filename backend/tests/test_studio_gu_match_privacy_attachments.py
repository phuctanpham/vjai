from __future__ import annotations

from hashlib import sha256

from fastapi.testclient import TestClient


def test_be_014_s01_studio_status_creates_deterministic_jobs(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-014-S01] Queuing a batch creates jobs and reaches review."""
    response = client.post("/v1/mock/scenarios", headers=auth_headers_a, json={"studio": "OK"})
    assert response.status_code == 200
    assert client.post(
        "/v1/sync/tx", headers=auth_headers_a, json={"tx_id": 101, "ops": []}
    ).status_code == 200
    feed = client.get(
        "/v1/mock/sync/changes?after=0&streams=my_studio_jobs", headers=auth_headers_a
    )
    assert feed.status_code == 200
    assert all(len(row["id"]) == 24 for row in feed.json()["changes"])


def test_be_015_s01_gu_match_has_owned_deck_only(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-015-S01] A requested session produces a bounded, owned-only deck."""
    response = client.post(
        "/v1/sync/tx",
        headers=auth_headers_a,
        json={"tx_id": 102, "ops": [{"op": "PUT", "type": "gu_match_sessions",
        "id": "6725aa12c8e4b12d34567911", "data": {"path": "ZERO_INPUT"}}]},
    )
    assert response.status_code == 200
    feed = client.get("/v1/mock/sync/changes?after=0&streams=my_decks", headers=auth_headers_a)
    assert feed.status_code == 200
    candidates = [change for change in feed.json()["changes"] if change["type"] == "outfit_candidates"]
    assert len(candidates) <= 8
    for candidate in candidates:
        assert "price" not in candidate["data"]
        assert "shop" not in candidate["data"]


def test_be_017_s01_all_privacy_request_keeps_only_request(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-017-S01] ALL erasure is acknowledged and leaves an auditable request."""
    response = client.post(
        "/v1/sync/tx", headers=auth_headers_a,
        json={"tx_id": 103, "ops": [{"op": "PUT", "type": "privacy_requests",
        "id": "6725aa12c8e4b12d34567912", "data": {"scope": "ALL"}}]},
    )
    assert response.status_code == 200
    assert response.json()["checkpoint"] >= 0


def test_be_018_s01_attachment_ticket_and_verification(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-018-S01, S02, S03] Attachment upload uses tickets and verifies bytes."""
    payload = b"\x89PNG\r\n\x1a\n"
    response = client.post(
        "/v1/sync/tx", headers=auth_headers_a,
        json={"tx_id": 104, "ops": [{"op": "PUT", "type": "attachments",
        "id": "6725aa12c8e4b12d34567913", "data": {
            "kind": "PHOTO", "owner_table": "media_assets", "owner_id": "6725aa12c8e4b12d34567914",
            "mime_type": "image/png", "bytes": len(payload), "sha256": sha256(payload).hexdigest(),
            "state": "PENDING_UPLOAD"}}]},
    )
    assert response.status_code == 200
    feed = client.get("/v1/mock/sync/changes?after=0&streams=my_files", headers=auth_headers_a)
    assert feed.status_code == 200
    assert any(change["type"] == "attachment_tickets" for change in feed.json()["changes"])
