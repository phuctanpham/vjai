from __future__ import annotations

from hashlib import sha256

import pytest


def test_mongo_adapter_crud_query_and_owner_isolation() -> None:
    from app.adapters.mongodb import MongoMockStore

    store = MongoMockStore()
    store.put("owner-a", "wardrobe_items", "one", {"user_id": "owner-a", "type_code": "SHIRT"})
    store.put("owner-b", "wardrobe_items", "one", {"user_id": "owner-b", "type_code": "SHIRT"})

    assert store.get("owner-a", "wardrobe_items", "one")["user_id"] == "owner-a"
    assert store.query("wardrobe_items", "owner-a", {"type_code": "SHIRT"}) == [
        {"user_id": "owner-a", "type_code": "SHIRT"}
    ]
    store.patch("owner-a", "wardrobe_items", "one", {"name": "Blue"})
    store.delete("owner-a", "wardrobe_items", "one")
    assert store.get("owner-b", "wardrobe_items", "one") is not None
    assert store.get("owner-a", "wardrobe_items", "one") is None


def test_mongo_adapter_transaction_rolls_back_and_can_fail_deterministically() -> None:
    from app.adapters.mongodb import MongoMockStore, ServiceUnavailable

    store = MongoMockStore(fail_operations={"put": 1})
    with pytest.raises(ServiceUnavailable):
        store.put("owner", "items", "one", {})
    assert store.get("owner", "items", "one") is None

    store = MongoMockStore()
    with pytest.raises(RuntimeError):
        with store.transaction():
            store.put("owner", "items", "one", {})
            raise RuntimeError("abort")
    assert store.get("owner", "items", "one") is None


def test_powersync_adapter_syncs_changes_with_cursor_and_owner_filter() -> None:
    from app.adapters.powersync import PowerSyncMockAdapter

    sync = PowerSyncMockAdapter()
    sync.put("owner-a", "items", "one", {"user_id": "owner-a"})
    sync.put("owner-b", "items", "two", {"user_id": "owner-b"})

    changes, checkpoint = sync.changes("owner-a", after=0)
    assert checkpoint == 2
    assert [(change.operation, change.row_id) for change in changes] == [("PUT", "one")]
    assert sync.changes("owner-a", after=checkpoint)[0] == ()


def test_rustfs_adapter_issues_deterministic_ticket_and_verifies_bytes() -> None:
    from app.adapters.rustfs import RustFSMockAdapter

    payload = b"image"
    storage = RustFSMockAdapter()
    ticket = storage.issue_upload_ticket("owner", "attachments/a", "image/png", len(payload))
    assert ticket.url == "/v1/mock/files/" + ticket.ticket_id
    storage.put(ticket, payload)
    assert storage.get(ticket.ticket_id) == payload
    assert storage.verify(ticket.ticket_id, sha256(payload).hexdigest())
    with pytest.raises(ValueError, match="sha256"):
        storage.verify(ticket.ticket_id, "0" * 64)


def test_rustfs_adapter_configuration_failures_are_deterministic() -> None:
    from app.adapters.rustfs import RustFSMockAdapter, ServiceUnavailable

    storage = RustFSMockAdapter(fail_operations={"issue_ticket": 1})
    with pytest.raises(ServiceUnavailable):
        storage.issue_upload_ticket("owner", "key", "image/png", 1)
