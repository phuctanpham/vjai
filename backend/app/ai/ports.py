from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True)
class ExtractionInput:
    asset_id: str
    content_hash: int


@dataclass(frozen=True)
class ContextRequest:
    path: str
    occasions: tuple[str, ...] = ()


class DeterministicExtractor:
    def extract(self, request: ExtractionInput) -> dict[str, str]:
        return {"type_code": "TOP", "color": "white", "source": str(request.content_hash)}


class DeterministicContext:
    def cards(self, request: ContextRequest) -> list[dict[str, str]]:
        return [{"source": source, "is_missing": False} for source in ("occasion", "weather", "rain", "commute")]
