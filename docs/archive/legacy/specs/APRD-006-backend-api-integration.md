# APRD-006: Backend Discovery API Integration

> **Status:** Accepted for implementation  
> **Target bounded context:** `lib/core/networking/` and `lib/features/discovery/data/`  
> **Companion API:** `backend/app/api/v1/endpoints/discovery.py`

## 1. Goal

Connect Discovery to the lightweight FastAPI mock server while preserving offline development through the existing in-memory repository.

## 2. Scope

### In scope

- Typed `ApiClient` HTTP implementation with `get` and `post`.
- `HttpDiscoveryRepository` for discovery and swipe endpoints.
- JSON-to-domain conversion using the existing `Profile` contract.
- Mapping HTTP failures to `ServerFailure` and connection failures to `NetworkFailure`.
- Configurable `API_BASE_URL` with the documented localhost default.
- Explicit offline fallback to sample data with observable warning behavior.
- Focused client and repository tests.

### Anti-scope

- No Dio, Retrofit, GraphQL, or gRPC.
- No certificate pinning.
- No production authentication, caching, or retry framework.
- No presentation-layer changes unless required to wire an existing provider.

## 3. Acceptance criteria

- `GET /api/v1/discovery` returns loaded profiles.
- `POST /api/v1/swipes` sends `profileId` and `swipeType`.
- HTTP errors are not silently converted into success.
- Connection failure falls back to mock data and keeps Discovery usable.

## 4. Verification

Run the focused Flutter format, analyze, and discovery/network tests, followed by `cd backend; uv run pytest`.
