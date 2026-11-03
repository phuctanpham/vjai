from __future__ import annotations

import re
from collections.abc import Iterable

_ID = re.compile(r"^[0-9a-f]{24}$")


def is_object_id(value: str) -> bool:
    return bool(_ID.fullmatch(value))


def _fnv64(data: bytes, offset: int) -> int:
    value = offset
    for byte in data:
        value = ((value ^ byte) * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF
    return value


def deterministic_object_id(parts: Iterable[str]) -> str:
    data = "|".join(f"{len(part)}:{part}" for part in parts).encode()
    high = _fnv64(data, 0xCBF29CE484222325)
    low = _fnv64(data, 0x84222325CBF29CE4)
    return f"{high:016x}{low:016x}"[:24]


def stable_hash(data: bytes) -> int:
    value = 0x811C9DC5
    for byte in data:
        value = ((value ^ byte) * 0x01000193) & 0xFFFFFFFF
    return value
