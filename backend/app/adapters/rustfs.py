from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
import json
from collections.abc import Callable
from typing import Protocol
from urllib.request import Request, urlopen

from app.adapters.mongodb import ServiceUnavailable
from app.adapters.mongodb import AdapterUnavailable
from app.sync.ids import deterministic_object_id


ObjectRequest = Callable[[str, str, dict[str, str], bytes | None], bytes]


class ObjectStorage(Protocol):
    def issue_upload_ticket(
        self, owner_id: str, object_key: str, mime_type: str, size: int
    ) -> UploadTicket: ...

    def put(self, ticket: UploadTicket, payload: bytes) -> None: ...
    def get(self, ticket_id: str) -> bytes: ...
    def verify(self, ticket_id: str, expected_sha256: str) -> bool: ...


def _object_request(method: str, url: str, headers: dict[str, str], body: bytes | None) -> bytes:
    try:
        with urlopen(Request(url, data=body, headers=headers, method=method), timeout=5) as response:
            return response.read()
    except OSError as exc:
        raise AdapterUnavailable(f"RustFS request unavailable: {exc}") from exc


@dataclass(frozen=True)
class UploadTicket:
    ticket_id: str
    owner_id: str
    object_key: str
    mime_type: str
    size: int
    url: str
    expires_at: str = "2026-10-30T09:15:00Z"


class RustFSHttpAdapter:
    """RustFS/S3-compatible HTTP adapter; all object I/O stays behind this port."""

    def __init__(
        self, base_url: str, token: str, *, request: ObjectRequest = _object_request
    ) -> None:
        if not base_url or not token:
            raise AdapterUnavailable("RustFS URL and token are required")
        self._base_url = base_url.rstrip("/")
        self._token = token
        self._request = request
    def _headers(self) -> dict[str, str]:
        return {"Authorization": "Bearer " + self._token}


    def issue_upload_ticket(
        self, owner_id: str, object_key: str, mime_type: str, size: int
    ) -> UploadTicket:
        if size < 0:
            raise ValueError("size must not be negative")
        body = json.dumps({
            "ownerId": owner_id, "objectKey": object_key, "mimeType": mime_type, "size": size
        }).encode()
        raw = self._request(
            "POST", f"{self._base_url}/v1/files/tickets",
            {**self._headers(), "Content-Type": "application/json"}, body
        )
        try:
            data = json.loads(raw)
            return UploadTicket(
                ticket_id=data["ticketId"], owner_id=owner_id, object_key=data["objectKey"],
                mime_type=data["mimeType"], size=data["size"], url=data["url"],
                expires_at=data["expiresAt"],
            )
        except (ValueError, KeyError, TypeError) as exc:
            raise AdapterUnavailable("RustFS returned an invalid upload ticket") from exc

    def put(self, ticket: UploadTicket, payload: bytes) -> None:
        if len(payload) != ticket.size:
            raise ValueError("size does not match ticket")
        self._request(
            "PUT", ticket.url,
            {"Content-Type": ticket.mime_type, "Content-Length": str(len(payload))}, payload
        )

    def get(self, ticket_id: str) -> bytes:
        return self._request(
            "GET", f"{self._base_url}/v1/files/{ticket_id}",
            self._headers(), None
        )

    def verify(self, ticket_id: str, expected_sha256: str) -> bool:
        body = json.dumps({"sha256": expected_sha256}).encode()
        raw = self._request(
            "POST", f"{self._base_url}/v1/files/{ticket_id}/verify",
            {**self._headers(), "Content-Type": "application/json"}, body
        )
        try:
            return bool(json.loads(raw)["verified"])
        except (ValueError, KeyError, TypeError) as exc:
            raise AdapterUnavailable("RustFS returned an invalid verification response") from exc


class RustFSMockAdapter:
    """RustFS/S3-shaped attachment ticket and byte verifier without object I/O."""

    def __init__(self, *, fail_operations: dict[str, int] | None = None) -> None:
        self._objects: dict[str, bytes] = {}
        self._tickets: dict[str, UploadTicket] = {}
        self._failures = dict(fail_operations or {})

    def _fail_if_configured(self, operation: str) -> None:
        remaining = self._failures.get(operation, 0)
        if remaining:
            self._failures[operation] = remaining - 1
            raise ServiceUnavailable(f"RustFS operation unavailable: {operation}")

    def issue_upload_ticket(
        self, owner_id: str, object_key: str, mime_type: str, size: int
    ) -> UploadTicket:
        self._fail_if_configured("issue_ticket")
        if size < 0:
            raise ValueError("size must not be negative")
        ticket_id = deterministic_object_id([owner_id, object_key, mime_type, str(size)])
        ticket = UploadTicket(ticket_id, owner_id, object_key, mime_type, size, f"/v1/mock/files/{ticket_id}")
        self._tickets[ticket_id] = ticket
        return ticket

    def put(self, ticket: UploadTicket, payload: bytes) -> None:
        self._fail_if_configured("put")
        if ticket.ticket_id not in self._tickets:
            raise ValueError("unknown upload ticket")
        if len(payload) != ticket.size:
            raise ValueError("size does not match ticket")
        self._objects[ticket.ticket_id] = bytes(payload)

    def get(self, ticket_id: str) -> bytes:
        self._fail_if_configured("get")
        try:
            return self._objects[ticket_id]
        except KeyError as exc:
            raise ValueError("object not found") from exc

    def verify(self, ticket_id: str, expected_sha256: str) -> bool:
        self._fail_if_configured("verify")
        actual = sha256(self.get(ticket_id)).hexdigest()
        if actual != expected_sha256:
            raise ValueError("sha256 does not match")
        return True


MockRustFS = RustFSMockAdapter
