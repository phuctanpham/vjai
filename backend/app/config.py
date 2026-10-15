import os
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    port: int = int(os.getenv("PORT", "8080"))
    host: str = os.getenv("HOST", "0.0.0.0")
    environment: str = os.getenv("ENV", "development")
    service_name: str = os.getenv("SERVICE_NAME", "garblo-api")
    cors_origins: list[str] = ("*",)


settings = Settings()

