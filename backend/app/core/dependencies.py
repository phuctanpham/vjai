from __future__ import annotations

from dataclasses import dataclass

from app.auth.ports import TokenVerifier
from app.config import Settings
from app.store.base import Store
from app.sync.effects import EffectRegistry
from app.sync.ports import ChangeFeedService, SyncTransactionService


@dataclass(frozen=True)
class Dependencies:
    """Explicit application collaborators; construction performs no I/O."""

    settings: Settings
    store: Store
    token_verifier: TokenVerifier
    transactions: SyncTransactionService
    changes: ChangeFeedService
    effects: EffectRegistry

    def validate(self) -> None:
        self.settings.validate()


def build_dependencies(
    *,
    settings: Settings,
    store: Store,
    token_verifier: TokenVerifier,
    transactions: SyncTransactionService,
    changes: ChangeFeedService,
    effects: EffectRegistry | None = None,
) -> Dependencies:
    """Compose injected adapters without selecting a database or network client."""

    dependencies = Dependencies(
        settings=settings,
        store=store,
        token_verifier=token_verifier,
        transactions=transactions,
        changes=changes,
        effects=effects or EffectRegistry(),
    )
    dependencies.validate()
    return dependencies


DependencyContainer = Dependencies
