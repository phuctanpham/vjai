from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True)
class RetryPolicy:
    attempts: int = 2

    def __post_init__(self) -> None:
        if self.attempts < 0:
            raise ValueError("retry attempts cannot be negative")


@dataclass(frozen=True)
class TimeoutPolicy:
    seconds: float = 5.0

    def __post_init__(self) -> None:
        if self.seconds <= 0:
            raise ValueError("timeout must be positive")


class Logger(Protocol):
    def debug(self, message: str, **fields: object) -> None: ...
    def info(self, message: str, **fields: object) -> None: ...
    def warning(self, message: str, **fields: object) -> None: ...
    def error(self, message: str, **fields: object) -> None: ...
