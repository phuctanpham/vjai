from __future__ import annotations

from app.migrations.runner import (
    DEMO_OWNER,
    MigrationResult,
    run_demo_migrations,
    verify_demo_migrations,
)
from app.store.memory import InMemoryStore
from app.sync.ids import deterministic_object_id


def test_demo_migrations_are_versioned_and_idempotent() -> None:
    store = InMemoryStore()

    first = run_demo_migrations(store, owner=DEMO_OWNER)
    second = run_demo_migrations(store, owner=DEMO_OWNER)

    assert isinstance(first, MigrationResult)
    assert first.applied_versions == (1, 2)
    assert second.applied_versions == ()
    assert second.added_rows == 0
    assert len(store.query("wardrobe_items", DEMO_OWNER)) == 9
    assert len(store.query("item_types", "__catalog__")) == 4
    assert verify_demo_migrations(store, owner=DEMO_OWNER).valid


def test_dry_run_and_verify_never_write_or_cross_owner() -> None:
    store = InMemoryStore()

    preview = run_demo_migrations(store, owner=DEMO_OWNER, dry_run=True)
    assert preview.applied_versions == (1, 2)
    assert preview.added_rows == 13
    assert store.query("wardrobe_items", DEMO_OWNER) == []

    other_owner = "65f0c1a2b3c4d5e6f7a8b9c1"
    run_demo_migrations(store, owner=other_owner)
    assert store.query("wardrobe_items", DEMO_OWNER) == []
    assert not verify_demo_migrations(store, owner=DEMO_OWNER).valid


def test_verification_detects_tampering() -> None:
    store = InMemoryStore()
    run_demo_migrations(store, owner=DEMO_OWNER)
    row_id = deterministic_object_id(["demo-seed", "seed_01"])
    store.patch(DEMO_OWNER, "wardrobe_items", row_id, {"name": "changed"})

    result = verify_demo_migrations(store, owner=DEMO_OWNER)
    assert not result.valid
    assert "wardrobe_items" in result.errors[0]
