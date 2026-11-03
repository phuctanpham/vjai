from __future__ import annotations

import dataclasses

import pytest


def test_mock_provider_is_deterministic_and_service_free() -> None:
    from app.ai.ports import ExtractionInput, OutfitItem
    from app.ai.providers import DeterministicAIProvider

    provider = DeterministicAIProvider(model_version="mock-v1")
    request = ExtractionInput("asset-1", content=b"shirt")
    items = [
        OutfitItem("bottom-1", "BOTTOM", days_unworn=12),
        OutfitItem("top-1", "TOP", days_unworn=20),
        OutfitItem("shoe-1", "SHOES", days_unworn=3),
    ]

    assert provider.extract(request) == provider.extract(request)
    assert provider.suggestions(items, ("casual",)) == provider.suggestions(
        items, ("casual",)
    )
    assert provider.suggestions(items, ("casual",))[0].model_version == "mock-v1"


def test_mock_provider_applies_wear_rule_and_never_uses_user_id() -> None:
    from app.ai.ports import OutfitItem
    from app.ai.providers import DeterministicAIProvider

    result = DeterministicAIProvider().wear_rules(
        [OutfitItem("top-1", "TOP", days_unworn=31)]
    )
    assert result[0].item_id == "top-1"
    assert result[0].rule == "dormant"
    assert all(
        "user_id" not in {field.name for field in dataclasses.fields(value)}
        for value in result
    )


def test_real_provider_requires_configuration_without_network(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    from app.ai.providers import MissingProviderConfiguration, OpenAIProvider

    monkeypatch.delenv("GARBLO_OPENAI_API_KEY", raising=False)
    with pytest.raises(MissingProviderConfiguration):
        OpenAIProvider().name_look(("TOP", "BOTTOM"), ("casual",))


def test_real_provider_reports_invalid_response_and_network_errors(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    from app.ai.providers import (
        InvalidProviderResponse,
        OpenAIProvider,
        ProviderNetworkError,
    )

    monkeypatch.setenv("GARBLO_OPENAI_API_KEY", "test-key")
    invalid = OpenAIProvider(transport=lambda **_: {"choices": []})
    with pytest.raises(InvalidProviderResponse):
        invalid.name_look(("TOP",), ())

    def broken(**_: object) -> object:
        raise OSError("offline")

    with pytest.raises(ProviderNetworkError):
        OpenAIProvider(transport=broken).name_look(("TOP",), ())
