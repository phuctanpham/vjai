from __future__ import annotations

from enum import Enum
from typing import Any

from pydantic import BaseModel, ConfigDict, create_model


class TableClass(str, Enum):
    READ_WRITE = "read_write"
    INSERT_ONLY = "insert_only"
    PATCH_ONLY = "patch_only"
    COMMAND = "command"
    READ_ONLY = "read_only"


def _model(name: str, fields: dict[str, tuple[Any, Any]]) -> type[BaseModel]:
    return create_model(name, __config__=ConfigDict(extra="forbid"), **fields)


_ANY = (Any, None)
TABLE_MODELS: dict[str, type[BaseModel]] = {
    "wardrobe_items": _model("WardrobeItem", {"user_id": _ANY, "type_code": _ANY, "name": _ANY, "created_at": _ANY, "archived": _ANY, "source_asset_id": _ANY}),
    "wear_events": _model("WearEvent", {"user_id": _ANY, "worn_date": _ANY, "items": _ANY}),
    "upload_batches": _model("UploadBatch", {"user_id": _ANY, "status": _ANY, "created_at": _ANY}),
    "media_assets": _model("MediaAsset", {"user_id": _ANY, "batch_id": _ANY, "mime_type": _ANY, "removed": _ANY}),
    "ai_processing_jobs": _model("AIJob", {"user_id": _ANY, "status": _ANY}),
    "extracted_items": _model("ExtractedItem", {"user_id": _ANY, "value": _ANY, "last_worn_input": _ANY}),
    "consents": _model("Consent", {"user_id": _ANY, "revoked_at": _ANY}),
    "interactions": _model("Interaction", {"user_id": _ANY, "action": _ANY}),
    "gu_match_sessions": _model("GuMatchSession", {"user_id": _ANY, "path": _ANY, "occasions": _ANY, "raw_prompt": _ANY}),
    "outfit_candidates": _model("OutfitCandidate", {"user_id": _ANY, "items": _ANY, "swipe_status": _ANY}),
    "item_types": _model("ItemType", {"type_code": _ANY, "group_code": _ANY, "label": _ANY}),
    "attachments": _model("Attachment", {"user_id": _ANY, "kind": _ANY, "owner_table": _ANY, "owner_id": _ANY, "mime_type": _ANY, "bytes": _ANY, "sha256": _ANY, "state": _ANY}),
    "attachment_tickets": _model("AttachmentTicket", {"user_id": _ANY, "op": _ANY, "url": _ANY, "expires_at": _ANY}),
    "privacy_requests": _model("PrivacyRequest", {"user_id": _ANY, "scope": _ANY, "status": _ANY}),
}

TABLE_CLASSES = {
    "profiles": TableClass.READ_WRITE, "wardrobe_items": TableClass.READ_WRITE,
    "upload_batches": TableClass.READ_WRITE, "media_assets": TableClass.READ_WRITE,
    "interactions": TableClass.READ_WRITE, "attachments": TableClass.READ_WRITE,
    "wear_events": TableClass.INSERT_ONLY, "consents": TableClass.INSERT_ONLY,
    "extracted_items": TableClass.PATCH_ONLY, "gu_match_sessions": TableClass.COMMAND,
    "privacy_requests": TableClass.COMMAND, "item_types": TableClass.READ_ONLY,
    "ai_processing_jobs": TableClass.READ_ONLY, "outfit_candidates": TableClass.READ_ONLY,
    "attachment_tickets": TableClass.READ_ONLY,
}
