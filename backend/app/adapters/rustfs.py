from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256

from app.adapters.mongodb import ServiceUnavailable
from app.sync.ids import deterministic_object_id


@dataclass(frozen=True)
class UploadTicket:
    ticket_id: str
    owner_id: str
    object_key: str
    mime_type: str
    size: int
    url: str
    expires_at: str = "2026-10-30T09:15:00Z"


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
