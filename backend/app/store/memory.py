from __future__ import annotations

from copy import deepcopy
from contextlib import contextmanager
from typing import Any, Iterator


class InMemoryStore:
    def __init__(self) -> None:
        self.rows: dict[str, dict[str, dict[str, dict[str, Any]]]] = {}

    def _table(self, owner: str, table: str) -> dict[str, dict[str, Any]]:
        return self.rows.setdefault(owner, {}).setdefault(table, {})

    def get(self, owner: str, table: str, row_id: str) -> dict[str, Any] | None:
        row = self._table(owner, table).get(row_id)
        return deepcopy(row) if row is not None else None

    def put(self, owner: str, table: str, row_id: str, row: dict[str, Any]) -> None:
        self._table(owner, table)[row_id] = deepcopy(row)

    def patch(self, owner: str, table: str, row_id: str, values: dict[str, Any]) -> None:
        self._table(owner, table).setdefault(row_id, {}).update(deepcopy(values))

    def delete(self, owner: str, table: str, row_id: str) -> None:
        self._table(owner, table).pop(row_id, None)

    def query(
        self, table: str, owner: str, where: dict[str, Any] | None = None
    ) -> list[dict[str, Any]]:
        return [
            deepcopy(row)
            for row in self._table(owner, table).values()
            if where is None or all(row.get(key) == value for key, value in where.items())
        ]

    @contextmanager
    def transaction(self) -> Iterator[None]:
        snapshot = deepcopy(self.rows)
        try:
            yield
        except Exception:
            self.rows = snapshot
            raise
