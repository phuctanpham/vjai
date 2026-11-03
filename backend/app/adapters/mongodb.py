from __future__ import annotations

from collections.abc import Iterator
from contextlib import contextmanager
from copy import deepcopy
from typing import Any


class ServiceUnavailable(RuntimeError):
    """A deterministic substitute for a configured third-party outage."""


class MongoMockStore:
    """MongoDB-shaped store with owner-isolated, process-local collections.

    It intentionally has no MongoDB client or connection string.  The shape is
    kept behind ``Store`` so the real adapter can replace it later.
    """

    def __init__(self, *, fail_operations: dict[str, int] | None = None) -> None:
        self._collections: dict[str, dict[str, dict[str, dict[str, Any]]]] = {}
        self._failures = dict(fail_operations or {})

    def _fail_if_configured(self, operation: str) -> None:
        remaining = self._failures.get(operation, 0)
        if remaining:
            self._failures[operation] = remaining - 1
            raise ServiceUnavailable(f"MongoDB operation unavailable: {operation}")

    def _table(self, owner: str, table: str) -> dict[str, dict[str, Any]]:
        return self._collections.setdefault(owner, {}).setdefault(table, {})

    def get(self, owner: str, table: str, row_id: str) -> dict[str, Any] | None:
        self._fail_if_configured("get")
        row = self._table(owner, table).get(row_id)
        return deepcopy(row) if row is not None else None

    def put(self, owner: str, table: str, row_id: str, row: dict[str, Any]) -> None:
        self._fail_if_configured("put")
        self._table(owner, table)[row_id] = deepcopy(row)

    def patch(self, owner: str, table: str, row_id: str, values: dict[str, Any]) -> None:
        self._fail_if_configured("patch")
        self._table(owner, table).setdefault(row_id, {}).update(deepcopy(values))

    def delete(self, owner: str, table: str, row_id: str) -> None:
        self._fail_if_configured("delete")
        self._table(owner, table).pop(row_id, None)

    def query(
        self, table: str, owner: str, where: dict[str, Any] | None = None
    ) -> list[dict[str, Any]]:
        self._fail_if_configured("query")
        rows = self._table(owner, table).values()
        return [
            deepcopy(row)
            for row in rows
            if where is None or all(row.get(key) == value for key, value in where.items())
        ]

    @contextmanager
    def transaction(self) -> Iterator[None]:
        self._fail_if_configured("transaction")
        snapshot = deepcopy(self._collections)
        try:
            yield
        except Exception:
            self._collections = snapshot
            raise


MockMongoStore = MongoMockStore
