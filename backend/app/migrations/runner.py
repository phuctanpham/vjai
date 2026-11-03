from __future__ import annotations

import argparse
from dataclasses import dataclass
from typing import Any

from app.store.memory import InMemoryStore
from app.sync.ids import deterministic_object_id, is_object_id

DEMO_OWNER = "65f0c1a2b3c4d5e6f7a8b9c0"
SYSTEM_OWNER = "__migration__"
CATALOG_OWNER = "__catalog__"
MIGRATION_TABLE = "schema_migrations"
DETERMINISTIC_CREATED_AT = "2026-01-01T00:00:00Z"

_CATALOG = (
    ("SHIRT", "TOPS", "Shirt"),
    ("WIDE_LEG_TROUSERS", "BOTTOMS", "Wide-leg trousers"),
    ("SNEAKERS", "SHOES", "Sneakers"),
    ("BELT", "ACCESSORIES", "Belt"),
)


@dataclass(frozen=True)
class MigrationResult:
    applied_versions: tuple[int, ...]
    added_rows: int
    dry_run: bool = False


@dataclass(frozen=True)
class VerificationResult:
    valid: bool
    errors: tuple[str, ...] = ()


def _validate_owner(owner: str) -> None:
    if not is_object_id(owner):
        raise ValueError("owner must be a 24-character hexadecimal ObjectId")


def _catalog_rows() -> list[tuple[str, dict[str, str]]]:
    return [
        (
            deterministic_object_id(["catalog", code]),
            {"type_code": code, "group_code": group, "label": label},
        )
        for code, group, label in _CATALOG
    ]


def _wardrobe_rows(owner: str) -> list[tuple[str, dict[str, str]]]:
    return [
        (
            deterministic_object_id(["demo-seed", f"seed_{index:02d}"]),
            {
                "user_id": owner,
                "name": f"Demo item {index}",
                "type_code": "TOP",
                "created_at": DETERMINISTIC_CREATED_AT,
            },
        )
        for index in range(1, 10)
    ]


def _migration_exists(store: InMemoryStore, version: int, owner: str) -> bool:
    marker = str(version) if version == 1 else f"{version}:{owner}"
    return store.get(SYSTEM_OWNER, MIGRATION_TABLE, marker) is not None


def _expected_rows(
    store: InMemoryStore, owner: str
) -> list[tuple[str, str, str, dict[str, str]]]:
    return [
        *[
            (CATALOG_OWNER, "item_types", row_id, row)
            for row_id, row in _catalog_rows()
        ],
        *[(owner, "wardrobe_items", row_id, row) for row_id, row in _wardrobe_rows(owner)],
    ]


def run_demo_migrations(
    store: InMemoryStore,
    *,
    owner: str,
    dry_run: bool = False,
) -> MigrationResult:
    """Apply the demo schema/data migrations to exactly one owner.

    The store is deliberately injected: this function opens no database,
    network connection, credential source, clock, or random source.
    """
    _validate_owner(owner)
    pending = tuple(
        version
        for version in (1, 2)
        if not _migration_exists(store, version, owner)
    )
    added = 0
    if dry_run:
        for _, table, row_id, row in _expected_rows(store, owner):
            target_owner = CATALOG_OWNER if table == "item_types" else owner
            if store.get(target_owner, table, row_id) is None:
                added += 1
        return MigrationResult(pending, added, dry_run=True)

    with store.transaction():
        for row_id, row in _catalog_rows():
            if store.get(CATALOG_OWNER, "item_types", row_id) is None:
                store.put(CATALOG_OWNER, "item_types", row_id, row)
                added += 1
        if 1 in pending:
            store.put(SYSTEM_OWNER, MIGRATION_TABLE, "1", {"version": 1})

        for row_id, row in _wardrobe_rows(owner):
            if store.get(owner, "wardrobe_items", row_id) is None:
                store.put(owner, "wardrobe_items", row_id, row)
                added += 1
        if 2 in pending:
            store.put(
                SYSTEM_OWNER,
                MIGRATION_TABLE,
                f"2:{owner}",
                {"version": 2, "owner": owner},
            )
    return MigrationResult(pending, added)


def verify_demo_migrations(
    store: InMemoryStore, *, owner: str
) -> VerificationResult:
    """Verify exact deterministic contents without modifying the store."""
    try:
        _validate_owner(owner)
    except ValueError as exc:
        return VerificationResult(False, (str(exc),))

    errors: list[str] = []
    for version in (1, 2):
        if not _migration_exists(store, version, owner):
            errors.append(f"missing migration version {version}")
    for row_owner, table, row_id, expected in _expected_rows(store, owner):
        actual = store.get(row_owner, table, row_id)
        if actual != expected:
            errors.append(f"{table} row {row_id} does not match expected data")
    if len(store.query("item_types", CATALOG_OWNER)) != len(_CATALOG):
        errors.append("item_types contains unexpected rows")
    if len(store.query("wardrobe_items", owner)) != 9:
        errors.append("wardrobe_items contains unexpected rows")
    return VerificationResult(not errors, tuple(errors))


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Run in-memory demo migrations")
    parser.add_argument("--owner", required=True, help="demo owner ObjectId")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--verify", action="store_true")
    args = parser.parse_args(argv)
    store = InMemoryStore()
    result = run_demo_migrations(store, owner=args.owner, dry_run=args.dry_run)
    if args.verify and not args.dry_run:
        verification = verify_demo_migrations(store, owner=args.owner)
        if not verification.valid:
            for error in verification.errors:
                print(error)
            return 1
    print(
        f"versions={result.applied_versions} added_rows={result.added_rows} "
        f"dry_run={result.dry_run}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
