"""Shared contract-test fixtures.

The application is intentionally imported inside fixtures: Phase 4 Step 1 is a
red test scaffold and the backend package does not exist until the green steps.
"""

from __future__ import annotations

from collections.abc import Iterator
from importlib import import_module
from typing import Any

import pytest
from fastapi.testclient import TestClient

OWNER_A = "65f0c1a2b3c4d5e6f7a8b9c0"
OWNER_B = "65f0c1a2b3c4d5e6f7a8b9c1"


@pytest.fixture(params=("mock", "real"), ids=("mock-api", "real-api"))
def client(request: pytest.FixtureRequest) -> Iterator[TestClient]:
    """Build either planned adapter through the common application factory."""
    try:
        module = import_module("app.main")
        factory = getattr(module, "create_app")
        application: Any = factory(adapter=request.param)
    except (ImportError, AttributeError) as exc:
        pytest.fail(
            f"Phase 4 {request.param} contract has no planned app factory "
            f"(app.main.create_app(adapter=...)): {exc}"
        )
    with TestClient(application) as test_client:
        yield test_client


@pytest.fixture
def auth_headers_a() -> dict[str, str]:
    return {"Authorization": f"Bearer dev.{OWNER_A}"}


@pytest.fixture
def auth_headers_b() -> dict[str, str]:
    return {"Authorization": f"Bearer dev.{OWNER_B}"}


@pytest.fixture
def owner_a() -> str:
    return OWNER_A
