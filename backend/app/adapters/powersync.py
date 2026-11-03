from __future__ import annotations

from copy import deepcopy
from collections.abc import Iterator
from typing import Any

from app.adapters.mongodb import MongoMockStore
from app.sync.ports import Change


class PowerSyncMockAdapter:
    """Local PowerSync-shaped write/checkpoint/change-feed adapter."""

    def __init__(self, store: MongoMockStore | None = None) -> None:
        self.store = store or MongoMockStore()
        self._changes: list[Change] = []
        self._owners: dict[int, str] = {}

    def _append(
        self, owner: str, table: str, operation: str, row_id: str, data: dict[str, Any] | None
    ) -> None:
        stream = "catalog" if table == "item_types" else "my_files" if table == "attachments" else "my_wardrobe"
        self._changes.append(
            Change(len(self._changes) + 1, stream, operation, table, row_id, deepcopy(data))
        )
        self._owners[len(self._changes)] = owner

    def get(self, owner: str, table: str, row_id: str) -> dict[str, Any] | None:
        return self.store.get(owner, table, row_id)

    def query(
        self, table: str, owner: str, where: dict[str, Any] | None = None
    ) -> list[dict[str, Any]]:
        return self.store.query(table, owner, where)

    def transaction(self) -> Iterator[None]:
        return self.store.transaction()

    def put(self, owner: str, table: str, row_id: str, row: dict[str, Any]) -> None:
        self.store.put(owner, table, row_id, row)
        self._append(owner, table, "PUT", row_id, row)

    def patch(self, owner: str, table: str, row_id: str, values: dict[str, Any]) -> None:
        self.store.patch(owner, table, row_id, values)
        self._append(owner, table, "PUT", row_id, self.store.get(owner, table, row_id))

    def delete(self, owner: str, table: str, row_id: str) -> None:
        self.store.delete(owner, table, row_id)
        self._append(owner, table, "DELETE", row_id, None)

    def changes(
        self, owner: str, *, after: int = 0, streams: tuple[str, ...] | None = None,
        limit: int = 500,
    ) -> tuple[tuple[Change, ...], int]:
        allowed = set(streams) if streams is not None else None
        selected = tuple(
            change for change in self._changes
            if change.sequence > after
            and (change.stream == "catalog" or self._owners[change.sequence] == owner)
            and (allowed is None or change.stream in allowed)
        )
        return selected[:limit], len(self._changes)

    def read(
        self, owner_id: str, after: int, streams: tuple[str, ...], limit: int = 500
    ) -> tuple[Change, ...]:
        return self.changes(owner_id, after=after, streams=streams, limit=limit)[0]

    def checkpoint(self) -> int:
        return len(self._changes)


MockPowerSyncAdapter = PowerSyncMockAdapter
