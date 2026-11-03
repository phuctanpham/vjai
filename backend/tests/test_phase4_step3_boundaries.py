from __future__ import annotations

import pytest


def test_production_boundaries_are_importable_and_structural() -> None:
    from app.auth.ports import Principal, TokenVerifier
    from app.core.dependencies import Dependencies
    from app.sync.effects import EffectRegistry
    from app.sync.ports import ChangeFeedService, SyncTransactionService

    assert Principal("owner").owner_id == "owner"
    assert TokenVerifier
    assert SyncTransactionService
    assert ChangeFeedService
    assert isinstance(EffectRegistry(), EffectRegistry)
    assert Dependencies


def test_configuration_rejects_unsafe_production_defaults(monkeypatch: pytest.MonkeyPatch) -> None:
    from app.config import ConfigurationError, Settings

    monkeypatch.setenv("ENV", "production")
    monkeypatch.delenv("BASIC_AUTH_USERNAME", raising=False)
    monkeypatch.delenv("BASIC_AUTH_PASSWORD", raising=False)
    with pytest.raises(ConfigurationError, match="BASIC_AUTH"):
        Settings.from_env()


def test_effect_registry_dispatches_a_registered_handler() -> None:
    from app.sync.effects import EffectContext, EffectRegistry

    seen: list[str] = []
    registry = EffectRegistry()
    registry.register("wardrobe_items", "PUT", lambda context: seen.append(context.row_id))

    registry.dispatch(
        EffectContext(
            owner_id="owner",
            table="wardrobe_items",
            operation="PUT",
            row_id="row",
            row={"user_id": "owner"},
        )
    )
    assert seen == ["row"]
