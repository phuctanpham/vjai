from __future__ import annotations

from dataclasses import dataclass, field
from typing import Any, Protocol


@dataclass(frozen=True)
class Principal:
    """The authenticated identity passed across application boundaries."""

    owner_id: str
    claims: dict[str, Any] = field(default_factory=dict)


class TokenVerifier(Protocol):
    """Verifies an already extracted bearer token without owning HTTP concerns."""

    def verify(self, token: str) -> Principal: ...


class TokenIssuer(Protocol):
    def issue(self, principal: Principal) -> str: ...


class AuthenticationService(Protocol):
    def authenticate(self, authorization: str) -> Principal: ...


AuthService = AuthenticationService
