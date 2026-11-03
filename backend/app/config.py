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
    basic_auth_username: str = ""
    basic_auth_password: str = ""
    request_timeout_seconds: float = 5.0
    retry_attempts: int = 2
    cors_origins: tuple[str, ...] = ()
    mongodb_uri: str = ""
    mongodb_database: str = ""
    powersync_url: str = ""
    powersync_key_id: str = ""
    powersync_private_key: str = ""
    powersync_audience: str = ""
    rustfs_endpoint: str = ""
    rustfs_port: int = 443
    rustfs_use_ssl: bool = True
    rustfs_region: str = "us-east-1"
    rustfs_access_key: str = ""
    rustfs_secret_key: str = ""

    @classmethod
    def from_env(cls) -> Settings:
        origins = tuple(
            origin.strip()
            for origin in _env("GARBLO_CORS_ORIGINS").split(",")
            if origin.strip()
        )
        settings = cls(
            environment=_env("ENV", "development").lower(),
            basic_auth_username=_env("BASIC_AUTH_USERNAME", _env("GARBLO_BASIC_AUTH_USERNAME")),
            basic_auth_password=_env("BASIC_AUTH_PASSWORD", _env("GARBLO_BASIC_AUTH_PASSWORD")),
            request_timeout_seconds=float(_env("GARBLO_REQUEST_TIMEOUT_SECONDS", "5")),
            retry_attempts=int(_env("GARBLO_RETRY_ATTEMPTS", "2")),
            cors_origins=origins,
            mongodb_uri=_env("GARBLO_MONGODB_URI"),
            mongodb_database=_env("GARBLO_MONGODB_DATABASE"),
            powersync_url=_env("GARBLO_POWERSYNC_URL"),
            powersync_key_id=_env("GARBLO_POWERSYNC_KEY_ID"),
            powersync_private_key=_env("GARBLO_POWERSYNC_PRIVATE_KEY"),
            powersync_audience=_env("GARBLO_POWERSYNC_AUDIENCE"),
            rustfs_endpoint=_env("GARBLO_RUSTFS_ENDPOINT", _env("GARBLO_RUSTFS_URL")),
            rustfs_port=int(_env("GARBLO_RUSTFS_PORT", "443")),
            rustfs_use_ssl=_env("GARBLO_RUSTFS_USE_SSL", "true").lower() == "true",
            rustfs_region=_env("GARBLO_RUSTFS_REGION", "us-east-1"),
            rustfs_access_key=_env("GARBLO_RUSTFS_ACCESS_KEY"),
            rustfs_secret_key=_env("GARBLO_RUSTFS_SECRET_KEY"),
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
            if not self.basic_auth_username or not self.basic_auth_password:
                raise ConfigurationError(
                    "production requires BASIC_AUTH_USERNAME and BASIC_AUTH_PASSWORD"
                )
            if "*" in self.cors_origins:
                raise ConfigurationError("production CORS origins cannot be wildcard")
            required = {
                "MongoDB URI": self.mongodb_uri,
                "MongoDB database": self.mongodb_database,
                "PowerSync URL": self.powersync_url,
                "PowerSync key ID": self.powersync_key_id,
                "PowerSync private key": self.powersync_private_key,
                "PowerSync audience": self.powersync_audience,
                "RustFS endpoint": self.rustfs_endpoint,
                "RustFS access key": self.rustfs_access_key,
                "RustFS secret key": self.rustfs_secret_key,
            }
            missing = [name for name, value in required.items() if not value]
            if missing:
                raise ConfigurationError("production requires " + ", ".join(missing))


AppConfig = Settings
