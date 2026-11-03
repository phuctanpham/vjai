from __future__ import annotations

import hashlib
import json
import os
from collections.abc import Callable
from typing import Any

from .ports import (
    AIProvider,
    ExtractedPiece,
    ExtractionInput,
    OutfitItem,
    OutfitSuggestion,
    WearRule,
)


class AIProviderError(RuntimeError):
    """Base error for a provider failure that callers must surface."""


class MissingProviderConfiguration(AIProviderError):
    pass


class ProviderDependencyError(AIProviderError):
    pass


class ProviderNetworkError(AIProviderError):
    pass


class InvalidProviderResponse(AIProviderError):
    pass


class DeterministicAIProvider:
    """A local provider with stable outputs and no service boundary."""

    def __init__(self, model_version: str = "mock-v1") -> None:
        self.model_version = model_version

    def extract(self, request: ExtractionInput) -> list[ExtractedPiece]:
        value = request.content if request.content is not None else request.asset_id.encode()
        sample = hashlib.sha256(value).digest()[0] % 3
        samples = (
            ("Violet shirt", "TOP", "violet"),
            ("Cream trousers", "BOTTOM", "cream"),
            ("Cream sneakers", "SHOES", "cream"),
        )
        name, type_code, color = samples[sample]
        return [
            ExtractedPiece(
                name, type_code, color, "cotton", "casual", 0.90, self.model_version
            )
        ]

    def suggestions(
        self, items: list[OutfitItem], occasions: tuple[str, ...] = ()
    ) -> list[OutfitSuggestion]:
        usable = sorted(
            (item for item in items if not item.archived),
            key=lambda item: (-item.days_unworn, item.item_id),
        )
        selected: list[OutfitItem] = []
        for type_code in ("TOP", "BOTTOM", "SHOES"):
            selected_item = next(
                (item for item in usable if item.type_code == type_code), None
            )
            if selected_item is not None:
                selected.append(selected_item)
        if not selected:
            return []
        least_worn = min(item.days_unworn for item in selected)
        match = min(95, 70 + round(0.3 * least_worn))
        title = self.name_look(tuple(item.type_code for item in selected), occasions)
        return [
            OutfitSuggestion(
                item.type_code.lower(),
                item.item_id,
                match,
                "dormant item" if item.days_unworn >= 30 else None,
                title,
                self.model_version,
            )
            for item in selected
        ]

    def name_look(self, item_types: tuple[str, ...], occasions: tuple[str, ...]) -> str:
        occasion = occasions[0].title() if occasions else "Everyday"
        return f"{occasion} Edit"

    def wear_rules(self, items: list[OutfitItem]) -> list[WearRule]:
        return [
            WearRule(item.item_id, "dormant" if item.days_unworn >= 30 else "wear", self.model_version)
            for item in items
            if not item.archived
        ]


Transport = Callable[..., object]


class OpenAIProvider:
    """Production-shaped OpenAI boundary; it performs no work until an operation."""

    def __init__(
        self,
        *,
        api_key: str | None = None,
        model: str | None = None,
        timeout_seconds: float = 5.0,
        retries: int = 2,
        transport: Transport | None = None,
    ) -> None:
        self._api_key = api_key
        self._model = model or os.getenv("GARBLO_OPENAI_MODEL", "gpt-4o-mini")
        self._timeout = timeout_seconds
        self._retries = retries
        self._transport = transport

    def _request(self, operation: str, payload: dict[str, Any]) -> Any:
        key = self._api_key or os.getenv("GARBLO_OPENAI_API_KEY", "").strip()
        if not key:
            raise MissingProviderConfiguration("GARBLO_OPENAI_API_KEY is required")
        body = {"model": self._model, "operation": operation, "input": payload}
        for attempt in range(self._retries + 1):
            try:
                if self._transport is not None:
                    response = self._transport(
                        operation=operation, payload=body, timeout=self._timeout
                    )
                else:
                    try:
                        import urllib.error
                        import urllib.request
                    except ImportError as exc:
                        raise ProviderDependencyError(
                            "the standard HTTP client is unavailable"
                        ) from exc
                    request = urllib.request.Request(
                        "https://api.openai.com/v1/responses",
                        data=json.dumps(body).encode(),
                        headers={
                            "Authorization": "Bearer " + key,
                            "Content-Type": "application/json",
                        },
                        method="POST",
                    )
                    with urllib.request.urlopen(request, timeout=self._timeout) as result:
                        response = json.loads(result.read())
                return self._decode(response)
            except ProviderDependencyError:
                raise
            except (TimeoutError, OSError) as exc:
                if attempt == self._retries:
                    raise ProviderNetworkError("OpenAI request failed") from exc
        raise ProviderNetworkError("OpenAI request failed")

    @staticmethod
    def _decode(response: object) -> Any:
        if not isinstance(response, dict):
            raise InvalidProviderResponse("OpenAI response must be an object")
        if "output" in response:
            return response["output"]
        choices = response.get("choices")
        if isinstance(choices, list) and choices and isinstance(choices[0], dict):
            message = choices[0].get("message", {})
            if isinstance(message, dict) and "content" in message:
                content = message["content"]
                if isinstance(content, str):
                    try:
                        return json.loads(content)
                    except json.JSONDecodeError as exc:
                        raise InvalidProviderResponse("response content is not JSON") from exc
        raise InvalidProviderResponse("OpenAI response has no structured output")

    def name_look(self, item_types: tuple[str, ...], occasions: tuple[str, ...]) -> str:
        result = self._request("name_look", {"item_types": item_types, "occasions": occasions})
        if isinstance(result, dict) and isinstance(result.get("title"), str):
            return result["title"]
        raise InvalidProviderResponse("name_look requires a title")

    def extract(self, request: ExtractionInput) -> list[ExtractedPiece]:
        result = self._request("extract", {"asset_id": request.asset_id})
        if not isinstance(result, list):
            raise InvalidProviderResponse("extract requires a list")
        try:
            return [ExtractedPiece(**piece) for piece in result if isinstance(piece, dict)]
        except (TypeError, KeyError) as exc:
            raise InvalidProviderResponse("extract contains an invalid piece") from exc

    def suggestions(
        self, items: list[OutfitItem], occasions: tuple[str, ...] = ()
    ) -> list[OutfitSuggestion]:
        result = self._request("suggestions", {"items": [item.__dict__ for item in items], "occasions": occasions})
        if not isinstance(result, list):
            raise InvalidProviderResponse("suggestions requires a list")
        try:
            return [OutfitSuggestion(**suggestion) for suggestion in result if isinstance(suggestion, dict)]
        except (TypeError, KeyError) as exc:
            raise InvalidProviderResponse("suggestions contains an invalid look") from exc

    def wear_rules(self, items: list[OutfitItem]) -> list[WearRule]:
        result = self._request("wear_rules", {"items": [item.__dict__ for item in items]})
        if not isinstance(result, list):
            raise InvalidProviderResponse("wear_rules requires a list")
        try:
            return [WearRule(**rule) for rule in result if isinstance(rule, dict)]
        except (TypeError, KeyError) as exc:
            raise InvalidProviderResponse("wear_rules contains an invalid rule") from exc


def provider_from_environment() -> AIProvider:
    """Build the configured real provider without contacting OpenAI."""
    return OpenAIProvider()
