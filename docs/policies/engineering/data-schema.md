# Data Schema

The contract shared by Dart domain entities, Pydantic models, local storage and fixtures.

## 1. Wire rules
- JSON with **camelCase** keys. Pydantic fields are snake_case with a camelCase `alias`; Dart fields are camelCase.
- Enums are lowercase strings (`"like"`, `"pass"`, `"superlike"`).
- IDs are strings. Profiles use `usr_NN`.
- Timestamps are ISO-8601 UTC strings (`2026-10-16T08:30:00Z`).
- Errors are HTTP status codes with FastAPI's `{"detail": "..."}` body.
- All routes are under `/api/v1/`, except `GET /health`.

## 2. Entities

### Profile
| Field | Type | Required | Notes |
|---|---|---|---|
| `id` | string | yes | `usr_NN` |
| `name` | string | yes | |
| `age` | int | yes | ≥ 18 |
| `bio` | string | yes | may be empty |
| `occupation` | string | yes | may be empty |
| `distanceKm` | int | yes | fixture value; no geolocation |
| `interests` | string[] | no | default `[]` |
| `imageUrls` | string[] | no | default `[]` |

### SwipeRequest → SwipeResponse
| Request field | Type | | Response field | Type |
|---|---|---|---|---|
| `profileId` | string | | `success` | bool |
| `swipeType` | `like`·`pass`·`superlike` | | `profileId` | string |
| | | | `swipeType` | enum |
| | | | `matched` | bool, default `false` |

### HealthResponse
`{ "status": "ok", "service": "garblo-api" }`

### LoginRequest → AuthSession (BL-002)
| Request field | Type | | Response field | Type |
|---|---|---|---|---|
| `email` | string | | `userId` | string |
| `password` | string | | `token` | string, non-empty |
| | | | `expiresAt` | ISO-8601 UTC |

Mock rule: password `wrong-password` → `401 {"detail": "Invalid email or password"}`; any other well-formed request → `200` with `userId: "me_01"`, `token: "mock-token-me_01"`, `expiresAt: "2099-01-01T00:00:00Z"`.

## 3. Endpoints

| Method | Path | Request | Response | Owner item |
|---|---|---|---|---|
| GET | `/health`, `/api/v1/health` | — | HealthResponse | BL-001 |
| GET | `/api/v1/discovery` | — | Profile[] | BL-004 |
| GET | `/api/v1/profiles/{id}` | — | Profile or 404 | BL-004 |
| POST | `/api/v1/swipes` | SwipeRequest | SwipeResponse | BL-004 |
| GET | `/api/v1/auth/status` | — | `{authenticated, provider}` placeholder | BL-002 |
| POST | `/api/v1/auth/login` | LoginRequest | AuthSession or 401 | BL-002 |
| POST | `/api/v1/auth/logout` | — | `{success: true}` | BL-002 |
| GET | `/api/v1/matches` | — | `{matches: []}` placeholder | BL-008 |
| GET | `/api/v1/chat/conversations` | — | `{conversations: []}` placeholder | BL-009 |

## 4. Fixtures
- `backend/app/data/sample_data.py` is the source of truth for sample profiles `usr_01`–`usr_05`. `MockDiscoveryRepository` in Dart mirrors it.
- Deterministic mock rule: a `like` or `superlike` on `usr_01` (Alex Chen) returns `matched: true`; everything else returns `false`.
- Known drift: `usr_01` has 2 `imageUrls` in Python but 1 in Dart ([CHG-002](../../changes/CHG-002-restore-green-build.md)).

## 5. Local storage keys

| Key | Value | Owner item |
|---|---|---|
| `garblo_swiped_profile_ids` | JSON array of profile IDs | BL-005 |
| `auth_token` | AuthSession as JSON | BL-002 |

New keys must be added here before use.

## 6. Configuration

| Name | Where | Default |
|---|---|---|
| `API_BASE_URL` | Flutter `--dart-define` | `http://localhost:8080` (BL-006) |
| `PORT`, `HOST`, `ENV`, `SERVICE_NAME` | backend env | `8080`, `0.0.0.0`, `development`, `garblo-api` |

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Created from the code, backend README and backlog items; `API_BASE_URL` chosen over README's `API_URL` |
