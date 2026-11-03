from __future__ import annotations

from app.sync.ids import is_object_id


def issue_token(user_id: str) -> str:
    if not is_object_id(user_id):
        raise ValueError("user_id must be an ObjectId")
    return f"dev.{user_id}"


def parse_token(authorization: str) -> str:
    token = authorization.removeprefix("Bearer ").removeprefix("dev.")
    if not is_object_id(token):
        raise ValueError("invalid development token")
    return token
