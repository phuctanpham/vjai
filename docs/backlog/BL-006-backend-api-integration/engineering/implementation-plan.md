# BL-006 Implementation Plan

## Generated files
| Role | Path | Change |
|---|---|---|
| App Developer | `lib/core/networking/http_api_client.dart` | New `HttpApiClient implements ApiClient`, built on `dart:io` `HttpClient` (no new package) |
| App Developer | `lib/app/providers.dart` | `apiClientProvider` → `HttpApiClient(baseUrl: String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080'))` |
| App Developer | `lib/features/discovery/data/http_discovery_repository.dart` | New `HttpDiscoveryRepository` |
| App Developer | `lib/features/discovery/data/discovery_repository.dart` | Provider returns `HttpDiscoveryRepository`, which falls back to `MockDiscoveryRepository` |
| App Developer | `test/core/networking/http_api_client_test.dart`, `test/features/discovery/data/http_discovery_repository_test.dart` | New tests |
| Backend Developer | — | No change; the existing endpoints and `backend/tests/test_discovery.py` are the contract |

**Locked:** `lib/features/discovery/presentation/**` and everything else not listed.

## Contracts
- **Boundary:** `HttpDiscoveryRepository` is the only discovery code that turns `ApiClient` responses into `Profile`.
- **Data:** `GET /api/v1/discovery`, `POST /api/v1/swipes` exactly as in [data-schema.md](../../../policies/engineering/data-schema.md).
- **Failure behaviour:** HTTP status ≥ 400 → `ServerFailure` (no fallback). Socket or timeout errors → `NetworkFailure` → fallback to `MockDiscoveryRepository` and a `dart:developer` `log()` warning. No other errors are swallowed.
- **Swipe persistence:** keeps BL-005's local swipe history and also posts the swipe to the server.

## Sequence
1. `HttpApiClient` (tested against a loopback `HttpServer` in the test).
2. `HttpDiscoveryRepository` (tested with a fake `ApiClient`).
3. Provider wiring.

## Verification
`dart format --output=none --set-exit-if-changed .` · `flutter analyze` · `flutter test test/core/ test/features/discovery/` · `cd backend && uv run pytest`

## Engineering acceptance
Pending.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Migrated from TASK-006; chose `dart:io` over the `http` package to avoid a new dependency; env name fixed to `API_BASE_URL` |
