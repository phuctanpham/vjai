# Garblo Legacy Mock API Backend

This FastAPI service is a deterministic, phase-limited mock managed with
[`uv`](https://docs.astral.sh/uv/). It currently serves legacy dating fixtures
for health and integration tests. It is not the target wardrobe backend for
P3/P4; that platform decision is pending
[BE-001](../docs/tasks/backend/BE-001-platform-decision.md).

## Architecture

```text
backend/
├── pyproject.toml              # Dependencies & uv configuration
├── README.md                   # Backend documentation
├── app/
│   ├── main.py                 # FastAPI application & CORS
│   ├── config.py               # Environment & settings
│   ├── api/
│   │   ├── router.py           # API router aggregator
│   │   └── v1/
│   │       └── endpoints/
│   │           ├── health.py   # Liveness & health check
│   │           ├── discovery.py# Discovery candidates & swipe mock
│   │           ├── auth.py     # Auth boundary placeholder
│   │           ├── matches.py  # Matches boundary placeholder
│   │           └── chat.py     # Chat boundary placeholder
│   ├── models/
│   │   ├── health.py           # Health response Pydantic model
│   │   └── profile.py          # Profile, SwipeRequest, SwipeResponse models
│   └── data/
│       └── sample_data.py      # Sample mock profile data
└── tests/
    ├── test_health.py          # Health check endpoint tests
    └── test_discovery.py       # Discovery & swipe API tests
```

## Requirements

- Python >= 3.10
- [`uv`](https://docs.astral.sh/uv/) package manager

## Quickstart with `uv`

### 1. Install dependencies

```bash
cd backend
uv sync --extra dev
```

### 2. Run the development server

```bash
uv run uvicorn app.main:app --reload --port 8080 --host 0.0.0.0
```

The interactive OpenAPI documentation will be accessible at:
- Swagger UI: [http://localhost:8080/docs](http://localhost:8080/docs)
- ReDoc: [http://localhost:8080/redoc](http://localhost:8080/redoc)

### 3. Run tests

```bash
uv run pytest
```

## Endpoints

| Method | Path | Description | Response Status |
|---|---|---|---|
| `GET` | `/health` | Server liveness check | `200 OK` |
| `GET` | `/api/v1/health` | API version 1 health check | `200 OK` |
| `GET` | `/api/v1/discovery` | Retrieve candidate discovery feed | `200 OK` |
| `GET` | `/api/v1/profiles/{id}` | Retrieve profile details by ID | `200 OK` / `404` |
| `POST` | `/api/v1/swipes` | Record a like/pass/superlike swipe | `200 OK` |
| `GET` | `/api/v1/auth/status` | Placeholder auth status | `200 OK` |
| `GET` | `/api/v1/matches` | Placeholder matches list | `200 OK` |
| `GET` | `/api/v1/chat/conversations` | Placeholder conversations list | `200 OK` |

### Legacy sample profile JSON

```json
{
  "id": "usr_01",
  "name": "Alex Chen",
  "age": 27,
  "bio": "Software engineer & amateur photographer. Passionate about mountain biking and artisanal coffee roasts.",
  "occupation": "Mobile Architect",
  "distanceKm": 4,
  "interests": ["Coding", "Photography", "Cycling", "Coffee"],
  "imageUrls": [
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800"
  ]
}
```
