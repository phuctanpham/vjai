from __future__ import annotations

import base64
import json
import os
import shutil
import subprocess
import tempfile
from collections.abc import Callable
from dataclasses import dataclass
from time import time

from app.auth.ports import Principal, TokenIssuer


class PowerSyncTokenError(RuntimeError):
    """Raised when a PowerSync token cannot be issued safely."""


def _b64(value: bytes) -> str:
    return base64.urlsafe_b64encode(value).rstrip(b"=").decode("ascii")


@dataclass(frozen=True)
class PowerSyncTokenSettings:
    url: str
    key_id: str
    private_key: str
    audience: str
    lifetime_seconds: int = 300


Signer = Callable[[bytes, str], bytes]


class OpenSSLRS256Signer:
    """Signs JWT input with an RSA private key through the system OpenSSL binary."""

    def __init__(self, executable: str | None = None) -> None:
        self._executable = executable or shutil.which("openssl")
        if self._executable is None:
            raise PowerSyncTokenError("openssl is required for RS256 signing")

    def __call__(self, payload: bytes, private_key: str) -> bytes:
        key_path: str | None = None
        try:
            with tempfile.NamedTemporaryFile(
                mode="w", encoding="utf-8", prefix="garblo-key-", suffix=".pem", delete=False
            ) as key_file:
                key_file.write(private_key.replace("\\n", "\n"))
                key_path = key_file.name
            os.chmod(key_path, 0o600)
            result = subprocess.run(
                [self._executable, "dgst", "-sha256", "-sign", key_path],
                input=payload,
                capture_output=True,
                check=False,
            )
            if result.returncode != 0:
                raise PowerSyncTokenError("OpenSSL failed to sign the PowerSync token")
            return result.stdout
        except OSError as exc:
            raise PowerSyncTokenError("OpenSSL could not sign the PowerSync token") from exc
        finally:
            if key_path is not None:
                try:
                    os.unlink(key_path)
                except OSError:
                    pass


class PowerSyncJwtIssuer(TokenIssuer):
    """Issues short-lived JWTs for direct mobile-to-PowerSync connections.

    RSA signing is injected so contract tests remain dependency-free. Production
    wiring must provide an RSA-SHA256 signer backed by secret storage.
    """

    def __init__(self, settings: PowerSyncTokenSettings, signer: Signer) -> None:
        if not settings.url or not settings.key_id or not settings.private_key:
            raise PowerSyncTokenError("PowerSync URL, key ID, and private key are required")
        if not settings.audience:
            raise PowerSyncTokenError("PowerSync audience is required")
        if settings.lifetime_seconds <= 0:
            raise PowerSyncTokenError("PowerSync token lifetime must be positive")
        self.settings = settings
        self._signer = signer

    def issue(self, principal: Principal) -> str:
        if not principal.owner_id:
            raise PowerSyncTokenError("PowerSync subject is required")
        now = int(time())
        header = {"alg": "RS256", "kid": self.settings.key_id, "typ": "JWT"}
        claims = {
            "sub": principal.owner_id,
            "aud": self.settings.audience,
            "iat": now,
            "exp": now + self.settings.lifetime_seconds,
        }
        encoded = ".".join(
            _b64(json.dumps(part, separators=(",", ":"), sort_keys=True).encode())
            for part in (header, claims)
        )
        signature = self._signer(encoded.encode("ascii"), self.settings.private_key)
        return f"{encoded}.{_b64(signature)}"


class DeterministicPowerSyncJwtIssuer(PowerSyncJwtIssuer):
    """Local fake issuer; never use its deterministic signature in production."""

    def __init__(self, settings: PowerSyncTokenSettings) -> None:
        import hashlib

        def sign(payload: bytes, private_key: str) -> bytes:
            return hashlib.sha256(payload + private_key.encode()).digest()

        super().__init__(settings, sign)


def settings_from_env() -> PowerSyncTokenSettings:
    return PowerSyncTokenSettings(
        url=os.getenv("GARBLO_POWERSYNC_URL", "").strip(),
        key_id=os.getenv("GARBLO_POWERSYNC_KEY_ID", "").strip(),
        private_key=os.getenv("GARBLO_POWERSYNC_PRIVATE_KEY", "").strip(),
        audience=os.getenv("GARBLO_POWERSYNC_AUDIENCE", "").strip()
        or os.getenv("GARBLO_POWERSYNC_URL", "").strip(),
        lifetime_seconds=int(os.getenv("GARBLO_POWERSYNC_TOKEN_LIFETIME_SECONDS", "300")),
    )
