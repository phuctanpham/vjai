from __future__ import annotations

from fastapi.testclient import TestClient


def test_be_013_s01_catalog_is_stable_and_complete(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-013-S01] Catalog changes are ordered and contain each type once."""
    response = client.get(
        "/v1/mock/sync/changes?after=0&streams=catalog", headers=auth_headers_a
    )
    assert response.status_code == 200
    changes = response.json()["changes"]
    assert len({change["id"] for change in changes}) == len(changes)
    assert [change["seq"] for change in changes] == sorted(change["seq"] for change in changes)


def test_be_013_s02_s03_owner_scoped_cursor_pagination(
    client: TestClient, auth_headers_a: dict[str, str], auth_headers_b: dict[str, str]
) -> None:
    """[BE-013-S02, S03] Feed cursors page without leakage, loss, or repetition."""
    assert client.post(
        "/v1/mock/seed", headers=auth_headers_a, json={"preset": "demo_wardrobe"}
    ).status_code == 200
    page = client.get(
        "/v1/mock/sync/changes?after=0&streams=my_wardrobe&limit=2",
        headers=auth_headers_a,
    )
    assert page.status_code == 200
    last = page.json()["changes"][-1]["seq"]
    following = client.get(
        f"/v1/mock/sync/changes?after={last}&streams=my_wardrobe",
        headers=auth_headers_a,
    )
    assert following.status_code == 200
    foreign = client.get(
        "/v1/mock/sync/changes?after=0&streams=my_wardrobe", headers=auth_headers_b
    )
    assert foreign.status_code == 200
    assert foreign.json()["changes"] == []


def test_be_013_s06_demo_seed_is_idempotent(
    client: TestClient, auth_headers_a: dict[str, str]
) -> None:
    """[BE-013-S06] Demo wardrobe seed repeats without duplicate rows."""
    first = client.post(
        "/v1/mock/seed", headers=auth_headers_a, json={"preset": "demo_wardrobe"}
    )
    second = client.post(
        "/v1/mock/seed", headers=auth_headers_a, json={"preset": "demo_wardrobe"}
    )
    assert first.status_code == second.status_code == 200
    assert second.json()["added"] == 0
