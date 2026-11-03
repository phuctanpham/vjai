from __future__ import annotations

import argparse

from fastapi.testclient import TestClient

from app.main import create_app
from app.migrations.runner import (
    DEMO_OWNER,
    run_demo_migrations,
    verify_demo_migrations,
)
from app.store.memory import InMemoryStore


def run() -> tuple[bool, str]:
    """Run deterministic localhost checks without configured services."""
    store = InMemoryStore()
    first = run_demo_migrations(store, owner=DEMO_OWNER)
    second = run_demo_migrations(store, owner=DEMO_OWNER)
    verification = verify_demo_migrations(store, owner=DEMO_OWNER)
    if first.applied_versions != (1, 2) or second.added_rows != 0:
        return False, "migration idempotency check failed"
    if not verification.valid:
        return False, "migration verification failed: " + "; ".join(verification.errors)

    application = create_app(adapter="mock")
    if application.state.adapter != "mock":
        return False, "self-test must use the explicit mock adapter"
    with TestClient(application) as client:
        response = client.get("/health")
    if response.status_code != 200 or response.json() != {
        "status": "ok",
        "service": "garblo-backend",
    }:
        return False, "health check failed"
    return True, "health=ok migrations=ok adapter=mock external_services=skipped"


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="Run local, no-service backend checks")
    parser.parse_args(argv)
    passed, message = run()
    print(message)
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main())
