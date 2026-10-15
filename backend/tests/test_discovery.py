from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


def test_get_discovery_profiles():
    response = client.get("/api/v1/discovery")
    assert response.status_code == 200
    profiles = response.json()
    assert isinstance(profiles, list)
    assert len(profiles) >= 1

    first = profiles[0]
    assert "id" in first
    assert "name" in first
    assert "age" in first
    assert "bio" in first
    assert "occupation" in first
    assert "distanceKm" in first
    assert "interests" in first


def test_get_profile_by_id():
    response = client.get("/api/v1/profiles/usr_01")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == "usr_01"
    assert data["name"] == "Alex Chen"


def test_get_profile_not_found():
    response = client.get("/api/v1/profiles/non_existent")
    assert response.status_code == 404


def test_record_swipe_like():
    response = client.post(
        "/api/v1/swipes",
        json={"profileId": "usr_01", "swipeType": "like"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["profileId"] == "usr_01"
    assert data["swipeType"] == "like"
    assert data["matched"] is True


def test_record_swipe_pass():
    response = client.post(
        "/api/v1/swipes",
        json={"profileId": "usr_02", "swipeType": "pass"},
    )
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert data["profileId"] == "usr_02"
    assert data["swipeType"] == "pass"
    assert data["matched"] is False

