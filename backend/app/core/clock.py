from __future__ import annotations

from datetime import datetime, timezone
from typing import Protocol


class Clock(Protocol):
    def now(self) -> datetime: ...


class FixedClock:
    def __init__(self, value: datetime | None = None) -> None:
        self._value = value or datetime(2026, 10, 30, 9, tzinfo=timezone.utc)

    def now(self) -> datetime:
        return self._value

    def set(self, value: datetime) -> None:
        self._value = value


def iso_now(clock: Clock) -> str:
    return clock.now().astimezone(timezone.utc).isoformat(timespec="seconds").replace("+00:00", "Z")
