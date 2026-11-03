from __future__ import annotations

import hashlib
import json
import os
from copy import deepcopy
from datetime import datetime, timedelta, timezone
from typing import Any

from fastapi import FastAPI, Header, HTTPException, Query
from pydantic import BaseModel, ConfigDict

from app.ai.ports import ContextRequest, DeterministicContext
from app.core.clock import FixedClock, iso_now
from app.store.memory import InMemoryStore
from app.sync.ids import deterministic_object_id, is_object_id
from app.sync.schema import TABLE_CLASSES, TABLE_MODELS, TableClass

OWNER_A = "65f0c1a2b3c4d5e6f7a8b9c0"


class MockState:
    def __init__(self) -> None:
        self.store = InMemoryStore()
        self.clock = FixedClock()
        self.changes: list[dict[str, Any]] = []
        self.transactions: dict[tuple[str, int], str] = {}
        self.scenarios: dict[str, str] = {}
        self._seed_catalog()

    def _seed_catalog(self) -> None:
        for code, group, label in (
            ("SHIRT", "TOPS", "Shirt"), ("WIDE_LEG_TROUSERS", "BOTTOMS", "Wide-leg trousers"),
            ("SNEAKERS", "SHOES", "Sneakers"), ("BELT", "ACCESSORIES", "Belt"),
        ):
            row_id = deterministic_object_id(["catalog", code])
            row = {"type_code": code, "group_code": group, "label": label}
            self.store.put("__catalog__", "item_types", row_id, row)
            self.append("__catalog__", "item_types", row_id, "PUT", row)

    def reset(self) -> None:
        self.store = InMemoryStore()
        self.changes.clear()
        self.transactions.clear()
        self.scenarios.clear()
        self._seed_catalog()

    def append(self, owner: str, table: str, row_id: str, op: str, data: dict[str, Any] | None) -> None:
        seq = len(self.changes) + 1
        stream = "catalog" if table == "item_types" else "my_files" if table in {"attachments", "attachment_tickets"} else "my_studio_jobs" if table == "ai_processing_jobs" else "my_decks" if table == "outfit_candidates" else "my_wardrobe"
        self.changes.append({"seq": seq, "stream": stream, "op": op, "type": table, "id": row_id, "data": deepcopy(data), "_owner": owner})


def _error(code: str, message: str, status: int, op_index: int | None = None) -> HTTPException:
    body: dict[str, Any] = {"code": code, "message": message}
    if op_index is not None:
        body["op_index"] = op_index
    return HTTPException(status_code=status, detail={"error": body})


def _owner(authorization: str | None) -> str:
    if not authorization:
        raise _error("UNAUTHENTICATED", "Authorization is required", 401)
    token = authorization.removeprefix("Bearer ").removeprefix("dev.")
    if token == "******":
        return OWNER_A
    if is_object_id(token):
        return token
    raise _error("UNAUTHENTICATED", "Invalid development token", 401)


def create_app(adapter: str = "mock") -> FastAPI:
    state = MockState()
    app = FastAPI(title="Garblo mock backend")
    app.state.mock = state
    app.state.adapter = adapter

    def unavailable() -> None:
        if os.getenv("ENV", "development") == "production":
            raise HTTPException(status_code=404, detail="Not found")

    @app.exception_handler(HTTPException)
    async def http_error(_, exc: HTTPException) -> Any:
        from fastapi.responses import JSONResponse
        if isinstance(exc.detail, dict) and "error" in exc.detail:
            return JSONResponse(content=exc.detail, status_code=exc.status_code)
        return JSONResponse(content={"detail": exc.detail}, status_code=exc.status_code)

    @app.post("/v1/auth/dev-token")
    def dev_token(payload: dict[str, str]) -> dict[str, str]:
        unavailable()
        user_id = payload.get("user_id", "")
        if not is_object_id(user_id):
            raise HTTPException(status_code=422, detail="user_id must be an ObjectId")
        return {"token": f"dev.{user_id}", "user_id": user_id}

    @app.put("/v1/mock/clock")
    def set_clock(payload: dict[str, str]) -> dict[str, str]:
        unavailable()
        try:
            value = datetime.fromisoformat(payload["now"].replace("Z", "+00:00")).astimezone(timezone.utc)
        except (KeyError, ValueError) as exc:
            raise HTTPException(status_code=422, detail="invalid clock") from exc
        state.clock.set(value)
        return {"now": iso_now(state.clock)}

    @app.post("/v1/mock/reset")
    def reset(authorization: str | None = Header(default=None)) -> dict[str, bool]:
        unavailable()
        _owner(authorization)
        state.reset()
        return {"reset": True}

    @app.put("/v1/mock/scenarios")
    @app.post("/v1/mock/scenarios")
    def scenarios(payload: dict[str, str], authorization: str | None = Header(default=None)) -> dict[str, bool]:
        unavailable()
        owner = _owner(authorization)
        state.scenarios[owner] = json.dumps(payload, sort_keys=True)
        return {"ok": True}

    @app.post("/v1/mock/seed")
    def seed(payload: dict[str, str], authorization: str | None = Header(default=None)) -> dict[str, int]:
        unavailable()
        owner = _owner(authorization)
        preset = payload.get("preset")
        added = 0
        if preset == "catalog":
            catalog = [("SHIRT", "TOPS", "Shirt"), ("WIDE_LEG_TROUSERS", "BOTTOMS", "Wide-leg trousers"),
                       ("SNEAKERS", "SHOES", "Sneakers"), ("BELT", "ACCESSORIES", "Belt")]
            for code, group, label in catalog:
                row_id = deterministic_object_id(["catalog", code])
                if state.store.get("__catalog__", "item_types", row_id) is None and state.store.get(owner, "item_types", row_id) is None:
                    state.store.put(owner, "item_types", row_id, {"type_code": code, "group_code": group, "label": label})
                    state.append(owner, "item_types", row_id, "PUT", state.store.get(owner, "item_types", row_id))
                    added += 1
        elif preset == "demo_wardrobe":
            for index in range(1, 10):
                row_id = deterministic_object_id(["demo-seed", f"seed_{index:02d}"])
                if state.store.get(owner, "wardrobe_items", row_id) is None:
                    row = {"user_id": owner, "name": f"Demo item {index}", "type_code": "TOP", "created_at": iso_now(state.clock)}
                    state.store.put(owner, "wardrobe_items", row_id, row)
                    state.append(owner, "wardrobe_items", row_id, "PUT", row)
                    added += 1
        else:
            raise HTTPException(status_code=422, detail="unknown preset")
        return {"added": added}

    @app.post("/v1/sync/tx")
    def sync_tx(payload: dict[str, Any], authorization: str | None = Header(default=None)) -> dict[str, Any]:
        owner = _owner(authorization)
        if state.scenarios.get(owner, "").find("FAIL_5XX_ONCE") >= 0:
            state.scenarios[owner] = ""
            raise _error("RETRY_LATER", "temporary mock failure", 503)
        tx_id = payload.get("tx_id")
        ops = payload.get("ops")
        if not isinstance(tx_id, int) or not isinstance(ops, list):
            raise HTTPException(status_code=422, detail="invalid transaction")
        digest = hashlib.sha256(json.dumps(ops, sort_keys=True, separators=(",", ":")).encode()).hexdigest()
        key = (owner, tx_id)
        if key in state.transactions:
            if state.transactions[key] != digest:
                raise _error("TX_ID_REUSED", "transaction id has different operations", 409)
            return {"applied": True, "replayed": True, "tx_id": tx_id, "checkpoint": len(state.changes)}
        staged: list[tuple[str, str, str, dict[str, Any], str]] = []
        for index, operation in enumerate(ops):
            table, action, row_id, data = operation.get("type"), operation.get("op"), operation.get("id"), operation.get("data", {})
            if table not in TABLE_CLASSES:
                raise _error("SCHEMA_VIOLATION", "unknown table", 422, index)
            if not is_object_id(row_id or ""):
                raise _error("INVALID_ID", "id must be an ObjectId", 422, index)
            klass = TABLE_CLASSES[table]
            if klass == TableClass.READ_ONLY:
                raise _error("TABLE_NOT_WRITABLE", "table is read-only", 403, index)
            if klass == TableClass.INSERT_ONLY and action != "PUT":
                raise _error("APPEND_ONLY", "table is append-only", 422, index)
            if klass == TableClass.PATCH_ONLY and action != "PATCH":
                raise _error("FIELD_NOT_WRITABLE", "only PATCH is allowed", 422, index)
            if action == "PATCH" and table == "wear_events":
                raise _error("APPEND_ONLY", "table is append-only", 422, index)
            if not isinstance(data, dict):
                raise _error("SCHEMA_VIOLATION", "data must be an object", 422, index)
            if data.get("user_id", owner) != owner:
                raise _error("OWNER_MISMATCH", "row belongs to another owner", 403, index)
            for other_owner, tables in state.store.rows.items():
                if other_owner != owner and row_id in tables.get(table, {}):
                    raise _error("OWNER_MISMATCH", "row belongs to another owner", 403, index)
            if action == "PATCH" and table == "profiles" and set(data) - {"display_name"}:
                raise _error("FIELD_NOT_WRITABLE", "field is server-owned", 422, index)
            existing = state.store.get(owner, table, row_id)
            if existing is None and action == "PATCH":
                raise _error("SCHEMA_VIOLATION", "row does not exist", 422, index)
            if table in TABLE_MODELS:
                try:
                    TABLE_MODELS[table](**data)
                except Exception as exc:
                    raise _error("SCHEMA_VIOLATION", str(exc), 422, index) from exc
            staged.append((table, action, row_id, data, owner))
        with state.store.transaction():
            for table, action, row_id, data, row_owner in staged:
                row = deepcopy(data)
                row.setdefault("user_id", row_owner)
                if action == "PUT":
                    if state.store.get(row_owner, table, row_id) is None:
                        row.setdefault("created_at", iso_now(state.clock))
                        state.store.put(row_owner, table, row_id, row)
                        state.append(row_owner, table, row_id, "PUT", row)
                        if table == "attachments":
                            ticket_id = deterministic_object_id([row_id, "PUT", iso_now(state.clock)])
                            ticket = {"user_id": row_owner, "op": "PUT", "url": f"/v1/mock/files/{ticket_id}", "expires_at": iso_now(state.clock)}
                            state.store.put(row_owner, "attachment_tickets", ticket_id, ticket)
                            state.append(row_owner, "attachment_tickets", ticket_id, "PUT", ticket)
                elif action == "PATCH":
                    state.store.patch(row_owner, table, row_id, row)
                    state.append(row_owner, table, row_id, "PUT", state.store.get(row_owner, table, row_id))
        state.transactions[key] = digest
        return {"applied": True, "replayed": False, "tx_id": tx_id, "checkpoint": len(state.changes)}

    @app.get("/v1/mock/sync/changes")
    def changes(after: int = Query(0), streams: str = Query(...), limit: int = Query(500), authorization: str | None = Header(default=None)) -> dict[str, Any]:
        unavailable()
        owner = _owner(authorization)
        requested = set(streams.split(","))
        valid = {"catalog", "my_wardrobe", "my_studio", "my_studio_jobs", "my_decks", "my_files"}
        if not requested <= valid:
            raise HTTPException(status_code=422, detail="unknown stream")
        rows = [change for change in state.changes if change["seq"] > after and (change["_owner"] == owner or change["stream"] == "catalog") and change["stream"] in requested]
        selected = rows[:limit]
        result = [{key: value for key, value in row.items() if key != "_owner"} for row in selected]
        return {"checkpoint": len(state.changes), "has_more": len(rows) > limit, "changes": result}

    return app


app = create_app()
