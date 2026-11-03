from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Callable


@dataclass(frozen=True)
class EffectContext:
    owner_id: str
    table: str
    operation: str
    row_id: str
    row: dict[str, Any]

    @property
    def status(self) -> str | None:
        value = self.row.get("status")
        return value if isinstance(value, str) else None


EffectHandler = Callable[[EffectContext], Any]
Worker = EffectHandler


class EffectRegistry:
    """In-process effect boundary; it never creates workers or network clients."""

    def __init__(self) -> None:
        self._handlers: dict[tuple[str, str, str | None], EffectHandler] = {}

    def register(
        self,
        table: str,
        operation: str,
        handler: EffectHandler,
        *,
        status: str | None = None,
    ) -> None:
        key = (table, operation, status)
        if key in self._handlers:
            raise ValueError(f"effect handler already registered for {key}")
        self._handlers[key] = handler

    def dispatch(self, context: EffectContext) -> Any:
        handler = self._handlers.get(
            (context.table, context.operation, context.status)
        ) or self._handlers.get((context.table, context.operation, None))
        return handler(context) if handler is not None else None

    def registered(self) -> tuple[tuple[str, str, str | None], ...]:
        return tuple(self._handlers)


WorkerRegistry = EffectRegistry
