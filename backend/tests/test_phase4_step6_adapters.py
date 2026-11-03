from __future__ import annotations

import builtins
import json

import pytest


def test_production_settings_require_all_service_endpoints(monkeypatch: pytest.MonkeyPatch) -> None:
    from app.config import ConfigurationError, Settings

    monkeypatch.setenv("ENV", "production")
    monkeypatch.setenv("BASIC_AUTH_USERNAME", "service-user")
    monkeypatch.setenv("BASIC_AUTH_PASSWORD", "service-password")
    with pytest.raises(ConfigurationError, match="MongoDB"):
        Settings.from_env()


def test_mongodb_dependency_is_lazy_and_unavailable_is_explicit(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    from app.adapters.mongodb import AdapterUnavailable, MongoAtlasStore

    real_import = builtins.__import__

    def blocked(name: str, *args: object, **kwargs: object) -> object:
        if name == "pymongo":
            raise ModuleNotFoundError("pymongo")
        return real_import(name, *args, **kwargs)

    monkeypatch.setattr(builtins, "__import__", blocked)
    with pytest.raises(AdapterUnavailable, match="pymongo"):
        MongoAtlasStore("mongodb://example", "garblo")


def test_powersync_maps_change_response_and_uses_owner_boundary() -> None:
    from app.adapters.powersync import PowerSyncHttpAdapter

    requests: list[tuple[str, dict[str, object]]] = []

    def request(method: str, url: str, headers: dict[str, str], body: bytes | None) -> bytes:
        requests.append((url, json.loads(body or b"{}")))
        return json.dumps(
            {"changes": [{"sequence": 4, "stream": "my_wardrobe", "operation": "PUT",
                          "table": "wardrobe_items", "row_id": "item-1",
                          "data": {"user_id": "owner"}}]}
        ).encode()

    changes = PowerSyncHttpAdapter("https://sync.example", "token", request=request).read(
        "owner", 3, ("my_wardrobe",)
    )
    assert changes[0].row_id == "item-1"
    assert "owner=owner" in requests[0][0]
    assert "streams=my_wardrobe" in requests[0][0]


def test_rustfs_maps_ticket_response_without_object_storage_dependency() -> None:
    from app.adapters.rustfs import RustFSHttpAdapter

    def request(method: str, url: str, headers: dict[str, str], body: bytes | None) -> bytes:
        return b'{"ticketId":"ticket-1","objectKey":"owner/item","mimeType":"image/png",' \
               b'"size":4,"url":"https://storage/upload","expiresAt":"2030-01-01T00:00:00Z"}'

    ticket = RustFSHttpAdapter("https://files.example", "token", request=request).issue_upload_ticket(
        "owner", "owner/item", "image/png", 4
    )
    assert ticket.ticket_id == "ticket-1"
    assert ticket.owner_id == "owner"
    assert ticket.url == "https://storage/upload"
