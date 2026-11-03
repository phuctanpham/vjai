from __future__ import annotations

from dataclasses import dataclass
from typing import Protocol


@dataclass(frozen=True)
class ExtractionInput:
    asset_id: str
    content: bytes | None = None
    content_hash: int | None = None


@dataclass(frozen=True)
class ExtractedPiece:
    name: str
    type_code: str
    color: str
    material: str
    style_tag: str
    confidence: float
    model_version: str


@dataclass(frozen=True)
class OutfitItem:
    item_id: str
    type_code: str
    days_unworn: int
    archived: bool = False


@dataclass(frozen=True)
class OutfitSuggestion:
    slot_role: str
    item_id: str
    match_pct: int
    highlight_reason: str | None
    title: str
    model_version: str


@dataclass(frozen=True)
class WearRule:
    item_id: str
    rule: str
    model_version: str


class AIProvider(Protocol):
    def extract(self, request: ExtractionInput) -> list[ExtractedPiece]: ...
    def suggestions(
        self, items: list[OutfitItem], occasions: tuple[str, ...] = ()
    ) -> list[OutfitSuggestion]: ...
    def name_look(self, item_types: tuple[str, ...], occasions: tuple[str, ...]) -> str: ...
    def wear_rules(self, items: list[OutfitItem]) -> list[WearRule]: ...


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
