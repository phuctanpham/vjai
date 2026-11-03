from __future__ import annotations

from app.external_health import HealthResult, _http_probe


def test_http_probe_reports_missing_configuration() -> None:
    assert _http_probe("PowerSync", "").status == "not_configured"


def test_http_probe_maps_auth_failure_to_reachable(monkeypatch) -> None:
    from urllib.error import HTTPError

    def fail(*args, **kwargs):
        raise HTTPError("https://example", 401, "unauthorized", {}, None)

    monkeypatch.setattr("app.external_health.urlopen", fail)
    result = _http_probe("RustFS", "https://example", "token")
    assert result == HealthResult("RustFS", "reachable", "HTTP 401")


def test_http_probe_uses_configured_path(monkeypatch) -> None:
    seen = []

    def succeed(request, **kwargs):
        seen.append(request.full_url)

        class Response:
            status = 200

            def __enter__(self):
                return self

            def __exit__(self, *args):
                return False

        return Response()

    monkeypatch.setattr("app.external_health.urlopen", succeed)
    assert _http_probe("PowerSync", "https://example", path="/probes/liveness").status == "connected"
    assert seen == ["https://example/probes/liveness"]
