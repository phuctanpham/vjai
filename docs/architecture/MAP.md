# Codebase Topology & Agent Context Map

Use this map to navigate the repository efficiently. Do not crawl directories outside the target slice.

---

## 1. High-Level System Partitioning

| Partition | Role | Priority | Tech Stack | Root Directory |
|---|---|---|---|---|
| **Client Frontend** | Primary multi-native application (Android, iOS, Windows, macOS) | **Primary** | Flutter 3.10+, Dart, Riverpod | [`lib/`](../../lib/) |
| **Mock Backend** | Lightweight mock API & fixture generator | **Secondary** | Python 3.10+, FastAPI, uv | [`backend/`](../../backend/) |
| **Test Suites** | Automated verification gates | **Critical** | flutter_test, pytest | [`test/`](../../test/), [`backend/tests/`](../../backend/tests/) |
| **Documentation & Control**| System governance, ADRs, APRDs, DoD | **Control Plane**| Markdown | [`docs/`](../), [`.github/`](../../.github/) |

---

## 2. Flutter Client Directory Map (`lib/`)

```text
lib/
├── main.dart                      # Bootstrap & ProviderScope wrapper
├── app/                           # App-wide shell
│   ├── app.dart                   # Root MaterialApp with theme config
│   ├── router.dart                # Named route generator
│   ├── providers.dart             # Global DI providers (apiClient, localStorage)
│   └── theme/
│       └── app_theme.dart         # Material 3 light & dark color schemes
├── core/                          # Cross-cutting foundational layer
│   ├── errors/
│   │   └── failures.dart          # Domain failure hierarchy (ServerFailure, NetworkFailure)
│   ├── networking/
│   │   └── api_client.dart        # Abstract HTTP contract & mock implementation
│   ├── storage/
│   │   └── local_storage.dart     # Abstract Key-Value contract & memory store
│   └── widgets/
│       ├── error_view.dart        # Reusable failure UI with retry callback
│       └── empty_view.dart        # Reusable empty queue / completion UI
└── features/                      # Feature-first domain vertical slices
    ├── discovery/                 # [COMPLETE] Discovery feed & swipe interactions
    │   ├── domain/                # Profile entity, SwipeType enum
    │   ├── data/                  # DiscoveryRepository contract & MockDiscoveryRepository
    │   └── presentation/          # DiscoveryView, ViewModel, State, ProfileCard, DiscoveryLayout
    ├── auth/                      # [PLACEHOLDER] Authentication & session
    ├── onboarding/                # [PLACEHOLDER] Profile creation wizard
    ├── matching/                  # [PLACEHOLDER] Mutual match modal & list
    ├── chat/                      # [PLACEHOLDER] Messaging & chat history
    ├── profile/                   # [PLACEHOLDER] Self profile view & editor
    ├── notifications/             # [PLACEHOLDER] Push notifications & badges
    └── moderation/                # [PLACEHOLDER] Reporting & safety blocking
```

---

## 3. Mock Backend Directory Map (`backend/`)

```text
backend/
├── pyproject.toml                 # uv configuration & dependencies (FastAPI, Uvicorn, Pytest)
├── README.md                      # Backend run commands & endpoint documentation
├── app/
│   ├── main.py                    # FastAPI server entrypoint & CORS middleware
│   ├── config.py                  # Environment settings (PORT, HOST, SERVICE_NAME)
│   ├── api/
│   │   ├── router.py              # Aggregates feature routers
│   │   └── v1/endpoints/
│   │       ├── health.py          # /health & /api/v1/health
│   │       ├── discovery.py       # /api/v1/discovery & /api/v1/swipes
│   │       ├── auth.py            # /api/v1/auth placeholder
│   │       ├── matches.py         # /api/v1/matches placeholder
│   │       └── chat.py            # /api/v1/chat placeholder
│   ├── models/
│   │   ├── health.py              # Health check Pydantic model
│   │   └── profile.py             # Profile, SwipeRequest, SwipeResponse Pydantic models
│   └── data/
│       └── sample_data.py         # Mock candidate profile database
└── tests/
    ├── test_health.py             # Health endpoint tests
    └── test_discovery.py          # Discovery feed & swipe tests
```

---

## 4. Test Directory Map (`test/`)

```text
test/
└── features/
    └── discovery/
        ├── domain/
        │   └── profile_test.dart               # Equality, copyWith, serialization
        ├── data/
        │   └── discovery_repository_test.dart  # Success, empty, error, swipe recording
        └── presentation/
            ├── discovery_view_model_test.dart  # State transitions, queue advancement
            └── discovery_view_test.dart        # Widget rendering, mobile & desktop layouts
```

---

## 5. Control Plane Documents (`docs/` & `.github/`)

- `.github/copilot-instructions.md`: Non-negotiable agent directives.
- `docs/architecture/00X-*.md`: Architectural Decision Records (ADRs).
- `docs/architecture/GLOSSARY.md`: Domain glossary & ubiquitous language.
- `docs/specs/`: Agentic Product Requirements Documents (APRDs).
- `docs/tasks/README.md`: Phased vertical slice backlog.
- `docs/quality/DOD.md`: Executable Definition of Done.
- `docs/agent/LESSONS_LEARNED.md`: Living memory of agent guardrails.

