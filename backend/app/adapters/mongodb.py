from __future__ import annotations

from collections.abc import Iterator
from contextlib import contextmanager
from copy import deepcopy
from typing import Any
from collections.abc import Callable

from app.store.base import Store


class ServiceUnavailable(RuntimeError):
    """A deterministic substitute for a configured third-party outage."""


class AdapterUnavailable(RuntimeError):
    """A production adapter cannot operate with its dependency or configuration."""


class MongoAtlasStore(Store):
    """MongoDB Atlas implementation of the store boundary.

    ``pymongo`` is deliberately imported only when this adapter is constructed.
    The optional factory makes contract tests independent of both pymongo and a
    live Atlas deployment.
    """

    def __init__(
        self,
        uri: str,
        database: str,
        *,
        timeout_seconds: float = 5.0,
        client_factory: Callable[..., Any] | None = None,
    ) -> None:
        if not uri or not database:
            raise AdapterUnavailable("MongoDB URI and database are required")
        if client_factory is None:
            try:
                from pymongo import MongoClient
            except ImportError as exc:
                raise AdapterUnavailable("pymongo is unavailable") from exc
            client_factory = MongoClient
        self._client = client_factory(
            uri, serverSelectionTimeoutMS=max(1, int(timeout_seconds * 1000))
        )
        self._database = self._client[database]
        self._session: Any = None

    def _collection(self, table: str) -> Any:
        return self._database[table]

    def _filter(self, owner: str, row_id: str) -> dict[str, str]:
        return {"_id": row_id, "user_id": owner}

    def get(self, owner: str, table: str, row_id: str) -> dict[str, Any] | None:
        row = self._collection(table).find_one(self._filter(owner, row_id), session=self._session)
        if row is None:
            return None
        row.pop("_id", None)
        return row

    def put(self, owner: str, table: str, row_id: str, row: dict[str, Any]) -> None:
        payload = dict(row)
        payload["user_id"] = owner
        self._collection(table).replace_one(
            self._filter(owner, row_id), {**payload, "_id": row_id}, upsert=True, session=self._session
        )

    def patch(self, owner: str, table: str, row_id: str, values: dict[str, Any]) -> None:
        values = dict(values)
        values.pop("user_id", None)
        self._collection(table).update_one(
            self._filter(owner, row_id), {"$set": values}, session=self._session
        )

    def delete(self, owner: str, table: str, row_id: str) -> None:
        self._collection(table).delete_one(self._filter(owner, row_id), session=self._session)

    def query(
        self, table: str, owner: str, where: dict[str, Any] | None = None
    ) -> list[dict[str, Any]]:
        query = {"user_id": owner, **(where or {})}
        rows = list(self._collection(table).find(query, session=self._session))
        for row in rows:
            row.pop("_id", None)
        return rows

    @contextmanager
    def transaction(self) -> Iterator[None]:
        session = self._client.start_session()
        self._session = session
        try:
            with session.start_transaction():
                yield
        finally:
            self._session = None
            session.end_session()


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
