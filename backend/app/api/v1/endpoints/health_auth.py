import base64
import secrets
from typing import Any

from fastapi import Request


def _environment_value(request: Request, name: str) -> str | None:
    environment: Any = request.scope.get("env")
    if environment is None:
        return None
    if isinstance(environment, dict):
        value = environment.get(name)
    else:
        value = getattr(environment, name, None)
    return value if isinstance(value, str) else None


def has_valid_basic_auth(request: Request) -> bool:
    username = _environment_value(request, "BASIC_AUTH_USERNAME")
    password = _environment_value(request, "BASIC_AUTH_PASSWORD")
    authorization = request.headers.get("Authorization", "")
    if not username or not password or not authorization.startswith("Basic "):
        return False

    try:
        encoded = authorization.removeprefix("Basic ").strip()
        decoded = base64.b64decode(encoded, validate=True).decode("utf-8")
        supplied_username, separator, supplied_password = decoded.partition(":")
    except (UnicodeDecodeError, ValueError):
        return False

    return (
        bool(separator)
        and secrets.compare_digest(supplied_username, username)
        and secrets.compare_digest(supplied_password, password)
    )
