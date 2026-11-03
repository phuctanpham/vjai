from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Protocol


@dataclass(frozen=True)
class SyncTransaction:
    owner_id: str
    transaction_id: int
    operations: tuple[dict[str, Any], ...]


@dataclass(frozen=True)
class SyncTransactionResult:
    applied: bool
    replayed: bool
    transaction_id: int
    checkpoint: int


@dataclass(frozen=True)
class Change:
    sequence: int
    stream: str
    operation: str
    table: str
    row_id: str
    data: dict[str, Any] | None


class SyncTransactionService(Protocol):
    def apply(self, transaction: SyncTransaction) -> SyncTransactionResult: ...


class ChangeFeedService(Protocol):
    def read(
        self,
        owner_id: str,
        after: int,
        streams: tuple[str, ...],
        limit: int = 500,
    ) -> tuple[Change, ...]: ...

    def checkpoint(self) -> int: ...


TransactionService = SyncTransactionService
ChangeFeed = ChangeFeedService
