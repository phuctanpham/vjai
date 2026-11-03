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
    mongodb_uri: str = ""
    mongodb_database: str = ""
    powersync_url: str = ""
    powersync_token: str = ""
    rustfs_url: str = ""
    rustfs_bucket: str = ""
    rustfs_token: str = ""

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
            mongodb_uri=_env("GARBLO_MONGODB_URI"),
            mongodb_database=_env("GARBLO_MONGODB_DATABASE"),
            powersync_url=_env("GARBLO_POWERSYNC_URL"),
            powersync_token=_env("GARBLO_POWERSYNC_TOKEN"),
            rustfs_url=_env("GARBLO_RUSTFS_URL"),
            rustfs_bucket=_env("GARBLO_RUSTFS_BUCKET"),
            rustfs_token=_env("GARBLO_RUSTFS_TOKEN"),
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
            required = {
                "MongoDB URI": self.mongodb_uri,
                "MongoDB database": self.mongodb_database,
                "PowerSync URL": self.powersync_url,
                "PowerSync token": self.powersync_token,
                "RustFS URL": self.rustfs_url,
                "RustFS bucket": self.rustfs_bucket,
                "RustFS token": self.rustfs_token,
            }
            missing = [name for name, value in required.items() if not value]
            if missing:
                raise ConfigurationError("production requires " + ", ".join(missing))


AppConfig = Settings
