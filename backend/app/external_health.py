from __future__ import annotations

import argparse
import os
from dataclasses import dataclass
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


@dataclass(frozen=True)
class HealthResult:
    service: str
    status: str
    detail: str


def _http_probe(name: str, url: str, token: str = "", path: str = "/health") -> HealthResult:
    if not url:
        return HealthResult(name, "not_configured", "URL is missing")
    headers = {"Authorization": f"Bearer {token}"} if token else {}
    try:
        with urlopen(Request(url.rstrip("/") + path, headers=headers), timeout=5) as response:
            return HealthResult(name, "connected", f"HTTP {response.status}")
    except HTTPError as exc:
        if exc.code in {401, 403, 404, 405}:
            return HealthResult(name, "reachable", f"HTTP {exc.code}")
        return HealthResult(name, "failed", f"HTTP {exc.code}")
    except (TimeoutError, URLError, OSError) as exc:
        return HealthResult(name, "failed", type(exc).__name__)


def check_external_services() -> tuple[HealthResult, ...]:
    results = [
        _http_probe(
            "PowerSync",
            os.getenv("GARBLO_POWERSYNC_URL", "").strip(),
            path="/probes/liveness",
        ),
        _http_probe(
            "RustFS",
            os.getenv("GARBLO_RUSTFS_URL", "").strip(),
            os.getenv("GARBLO_RUSTFS_TOKEN", "").strip(),
        ),
        _http_probe(
            "OpenAI",
            "https://api.openai.com/v1",
            os.getenv("GARBLO_OPENAI_API_KEY", "").strip(),
        )
        if os.getenv("GARBLO_OPENAI_API_KEY", "").strip()
        else HealthResult("OpenAI", "not_configured", "API key is missing"),
    ]

    uri = os.getenv("GARBLO_MONGODB_URI", "").strip()
    database = os.getenv("GARBLO_MONGODB_DATABASE", "").strip()
    if not uri or not database:
        results.insert(0, HealthResult("MongoDB Atlas", "not_configured", "URI or database is missing"))
    else:
        try:
            from pymongo import MongoClient
            from pymongo.errors import PyMongoError

            client = MongoClient(uri, serverSelectionTimeoutMS=5000)
            client.admin.command("ping")
            client.close()
            results.insert(0, HealthResult("MongoDB Atlas", "connected", "ping succeeded"))
        except ImportError:
            results.insert(0, HealthResult("MongoDB Atlas", "failed", "pymongo is not installed"))
        except (OSError, PyMongoError) as exc:
            results.insert(0, HealthResult("MongoDB Atlas", "failed", type(exc).__name__))
    return tuple(results)


def main() -> int:
    parser = argparse.ArgumentParser(description="Check configured external backend services")
    parser.parse_args()
    results = check_external_services()
    for result in results:
        print(f"{result.service}: {result.status} ({result.detail})")
    return 0 if all(result.status in {"connected", "reachable", "not_configured"} for result in results) else 1


if __name__ == "__main__":
    raise SystemExit(main())
