from __future__ import annotations

import os
from dataclasses import dataclass


class ConfigurationError(ValueError):
    """Raised when an application configuration cannot safely start."""


def _env(name: str, default: str = "") -> str:
    return os.getenv(name, default).strip()


@dataclass(frozen=True)
class Settings:
    environment: str = "development"
    auth_issuer: str = ""
    auth_audience: str = ""
    jwt_algorithm: str = "RS256"
    request_timeout_seconds: float = 5.0
    retry_attempts: int = 2
    cors_origins: tuple[str, ...] = ()

    @classmethod
    def from_env(cls) -> Settings:
        origins = tuple(
            origin.strip()
            for origin in _env("GARBLO_CORS_ORIGINS").split(",")
            if origin.strip()
        )
        settings = cls(
            environment=_env("ENV", "development").lower(),
            auth_issuer=_env("GARBLO_AUTH_ISSUER"),
            auth_audience=_env("GARBLO_AUTH_AUDIENCE"),
            jwt_algorithm=_env("GARBLO_JWT_ALGORITHM", "RS256"),
            request_timeout_seconds=float(_env("GARBLO_REQUEST_TIMEOUT_SECONDS", "5")),
            retry_attempts=int(_env("GARBLO_RETRY_ATTEMPTS", "2")),
            cors_origins=origins,
        )
        settings.validate()
        return settings

    def validate(self) -> None:
        if self.environment not in {"development", "test", "production"}:
            raise ConfigurationError("ENV must be development, test, or production")
        if self.request_timeout_seconds <= 0:
            raise ConfigurationError("request timeout must be positive")
        if self.retry_attempts < 0:
            raise ConfigurationError("retry attempts cannot be negative")
        if self.environment == "production":
            if not self.auth_issuer or not self.auth_audience:
                raise ConfigurationError(
                    "production requires GARBLO_AUTH_ISSUER and GARBLO_AUTH_AUDIENCE"
                )
            if self.jwt_algorithm not in {"RS256", "RS384", "RS512", "ES256", "ES384", "ES512"}:
                raise ConfigurationError("production requires an asymmetric JWT algorithm")
            if "*" in self.cors_origins:
                raise ConfigurationError("production CORS origins cannot be wildcard")


AppConfig = Settings
