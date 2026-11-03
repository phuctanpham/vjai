from __future__ import annotations

import hashlib
import hmac
from dataclasses import dataclass
from datetime import datetime, timezone
from urllib.parse import urlencode
from collections.abc import Callable
from typing import Protocol


class PresigningError(RuntimeError):
    """Raised when an object URL cannot be safely generated."""


@dataclass(frozen=True)
class PresignedObjectUrl:
    owner_id: str
    object_key: str
    method: str
    url: str
    expires_at: str


class ObjectUrlPresigner(Protocol):
    def put_url(self, owner_id: str, object_key: str) -> PresignedObjectUrl: ...
    def get_url(self, owner_id: str, object_key: str) -> PresignedObjectUrl: ...


S3Presign = Callable[[str, str, str, int], str]


class RustFSS3Presigner:
    """Production boundary for an injected S3-compatible presign implementation.

    The SDK/client is intentionally injected until BE-001 approves the live
    RustFS platform and dependency. No network call occurs in this boundary.
    """

    def __init__(
        self,
        endpoint: str,
        bucket: str,
        *,
        expires_seconds: int = 300,
        presign: S3Presign | None = None,
    ) -> None:
        if not endpoint or not bucket:
            raise PresigningError("RustFS endpoint and bucket are required")
        if expires_seconds <= 0:
            raise PresigningError("presigned URL lifetime must be positive")
        if presign is None:
            raise PresigningError("RustFS S3 presign implementation is unavailable")
        self.endpoint = endpoint.rstrip("/")
        self.bucket = bucket
        self.expires_seconds = expires_seconds
        self._presign = presign

    def _issue(self, owner_id: str, object_key: str, method: str) -> PresignedObjectUrl:
        if not owner_id or not object_key.startswith(f"{owner_id}/"):
            raise PresigningError("object key must be scoped to the owner")
        url = self._presign(self.bucket, object_key, method, self.expires_seconds)
        return PresignedObjectUrl(owner_id, object_key, method, url, "")

    def put_url(self, owner_id: str, object_key: str) -> PresignedObjectUrl:
        return self._issue(owner_id, object_key, "PUT")

    def get_url(self, owner_id: str, object_key: str) -> PresignedObjectUrl:
        return self._issue(owner_id, object_key, "GET")


class DeterministicRustFSPresigner:
    """Local presigner for contract tests; it performs no object I/O."""

    def __init__(self, endpoint: str, secret_key: str, *, expires_seconds: int = 300) -> None:
        if not endpoint or not secret_key:
            raise PresigningError("RustFS endpoint and secret key are required")
        if expires_seconds <= 0:
            raise PresigningError("presigned URL lifetime must be positive")
        self.endpoint = endpoint.rstrip("/")
        self.secret_key = secret_key
        self.expires_seconds = expires_seconds

    def _issue(self, owner_id: str, object_key: str, method: str) -> PresignedObjectUrl:
        if not owner_id or not object_key or not object_key.startswith(f"{owner_id}/"):
            raise PresigningError("object key must be scoped to the owner")
        if method not in {"GET", "PUT"}:
            raise PresigningError("unsupported object method")
        expires = int(datetime.now(timezone.utc).timestamp()) + self.expires_seconds
        canonical = f"{method}\n{owner_id}\n{object_key}\n{expires}"
        signature = hmac.new(
            self.secret_key.encode(), canonical.encode(), hashlib.sha256
        ).hexdigest()
        query = urlencode({"expires": expires, "signature": signature})
        return PresignedObjectUrl(
            owner_id,
            object_key,
            method,
            f"{self.endpoint}/{object_key}?{query}",
            datetime.fromtimestamp(expires, timezone.utc).isoformat(),
        )

    def put_url(self, owner_id: str, object_key: str) -> PresignedObjectUrl:
        return self._issue(owner_id, object_key, "PUT")

    def get_url(self, owner_id: str, object_key: str) -> PresignedObjectUrl:
        return self._issue(owner_id, object_key, "GET")
