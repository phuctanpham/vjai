from __future__ import annotations

import dataclasses
import importlib

import pytest


def test_be_011_s01_s02_planned_id_port_has_lowercase_object_ids() -> None:
    """[BE-011-S01, S02] Planned IDs preserve Dart vectors and strict format."""
    try:
        ids = importlib.import_module("app.sync.ids")
    except ImportError as exc:
        pytest.fail(f"planned app.sync.ids contract is missing: {exc}")
    value = ids.deterministic_object_id(["demo-seed", "seed_01"])
    assert value == "679dd79ffc8dcfcf27566db7"
    assert ids.is_object_id(value)
    assert not ids.is_object_id(value.upper())


def test_be_011_s03_schema_and_be_022_enums_are_strict() -> None:
    """[BE-011-S03, BE-022] Models expose all tables and reject extra fields."""
    try:
        schema = importlib.import_module("app.sync.schema")
    except ImportError as exc:
        pytest.fail(f"planned app.sync.schema contract is missing: {exc}")
    expected = {"wardrobe_items", "wear_events", "upload_batches", "media_assets",
                "ai_processing_jobs", "extracted_items", "consents", "interactions",
                "gu_match_sessions", "outfit_candidates", "item_types", "attachments",
                "attachment_tickets", "privacy_requests"}
    assert expected <= set(schema.TABLE_MODELS)
    with pytest.raises(Exception):
        schema.TABLE_MODELS["gu_match_sessions"](
            path="promptLed", occasions="[]", unknown_wire_field="reject"
        )


def test_ai_005_s06_s07_ports_are_deterministic_and_contain_no_user_id() -> None:
    """[AI-005-S06, S07] AI ports are pure data contracts without owner identity."""
    try:
        ports = importlib.import_module("app.ai.ports")
    except ImportError as exc:
        pytest.fail(f"planned app.ai.ports contract is missing: {exc}")
    for type_name in ("ExtractionInput", "ContextRequest"):
        fields = {field.name for field in dataclasses.fields(getattr(ports, type_name))}
        assert "user_id" not in fields


def test_be_016_s01_s05_wear_rules_take_time_as_an_argument() -> None:
    """[BE-016-S01, S05] Wear rules are pure and do not read wall-clock time."""
    try:
        wear = importlib.import_module("app.rules.wear")
    except ImportError as exc:
        pytest.fail(f"planned app.rules.wear contract is missing: {exc}")
    assert "today" in wear.days_unworn.__annotations__
    assert wear.is_dormant(30) is True
