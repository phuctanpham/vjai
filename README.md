# Garblo

> Cross-platform discovery and social connection application built with Flutter and Python/FastAPI.

[![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![uv](https://img.shields.io/badge/uv-Package%20Manager-DE5FE9)](https://docs.astral.sh/uv/)

---

## Product Overview

**Garblo** is a modern cross-platform application designed for discovering people, shared interests, and social connections. Designed for a solo developer utilizing agentic coding workflows, Garblo emphasizes:

- **Clean separation of concerns**: Feature-first MVVM architecture with clear dependency flow.
- **Adaptive UI**: Responsive layouts tailored to mobile touch screens and widescreen desktop environments without platform fragmentation.
- **Mock-driven velocity**: A lightweight Python / FastAPI mock server managed with `uv` for immediate prototyping and rapid integration.

---

## Current Project Status

- **Status**: Foundation & Discovery Scaffold (Initial Architecture Complete).
- **Frontend**: Flutter application structure with Riverpod, Material 3 theming, responsive mobile/desktop layouts, and fully tested Discovery vertical slice with mock repository.
- **Backend**: FastAPI mock API managed with `uv`, exposing health checks (`/health`, `/api/v1/health`), sample discovery candidates (`/api/v1/discovery`), and swipe submission (`/api/v1/swipes`).

---

## Supported Platforms

| Platform | Support Tier | Primary Interaction Model |
|---|---|---|
| **Android** | Tier 1 (Mobile) | Touch gestures, vertical card stack, mobile app bar |
| **iOS** | Tier 1 (Mobile) | Touch gestures, swipe cards, iOS safe areas |
| **Windows** | Tier 1 (Desktop) | Mouse & keyboard, sidebar navigation, profile info panel |
| **macOS** | Tier 1 (Desktop) | Mouse & keyboard, sidebar navigation, profile info panel |

---

## Repository Structure

```text
.
├── .github/
│   └── copilot-instructions.md       # AI agent development rules & guidelines
├── docs/
│   ├── architecture/
│   │   ├── README.md                 # Complete architecture guide
│   │   ├── MAP.md                    # Codebase topology & agent context map
│   │   ├── GLOSSARY.md               # Domain vocabulary & ubiquitous language
│   │   ├── 001-feature-first-architecture.md
│   │   ├── 002-state-management.md
│   │   ├── 003-adaptive-mobile-desktop-ui.md
│   │   ├── 004-agentic-development-workflow.md
│   │   └── 005-agentic-product-management.md
│   ├── specs/
│   │   ├── APRD-001-discovery.md
│   │   ├── APRD-002-authentication.md
│   │   ├── APRD-003-profile-onboarding.md
│   │   ├── APRD-005-swipe-persistence.md
│   │   ├── APRD-006-backend-api-integration.md
│   │   ├── APRD-007-mutual-matching.md
│   │   └── APRD-008-matches-list.md
│   ├── quality/
│   │   └── DOD.md                    # Definition of Done & automated gates
│   ├── agent/
│   │   └── LESSONS_LEARNED.md        # Living memory of agent guardrails
│   └── tasks/
│       └── README.md                 # Vertical slice task backlog (Phases 1-6)
├── backend/                          # Secondary Mock backend API (Python / FastAPI / uv)
│   ├── pyproject.toml                # Dependencies & uv project configuration
│   ├── README.md                     # Backend documentation & endpoints
│   ├── app/
│   │   ├── main.py                   # FastAPI server entrypoint & CORS
│   │   ├── config.py                 # Environment settings
│   │   ├── api/                      # Aggregated API routes & v1 endpoints
│   │   ├── models/                   # Pydantic schemas (Profile, Swipe, Health)
│   │   └── data/                     # Sample mock discovery profiles
│   └── tests/                        # Backend test suite (pytest)
├── lib/                              # Flutter client application
│   ├── main.dart                     # Flutter application entrypoint
│   ├── app/                          # App shell, routing, theme, providers
│   ├── core/                         # Core abstractions (errors, widgets, storage)
│   └── features/                     # Feature-first domain modules
│       ├── discovery/                # Implemented: Discovery feature slice
│       │   ├── data/                 # DiscoveryRepository & MockDiscoveryRepository
│       │   ├── domain/               # Profile entity & SwipeType enum
│       │   └── presentation/         # Views, ViewModels, and adaptive layouts
│       ├── auth/                     # Placeholder: Authentication boundary
│       ├── onboarding/               # Placeholder: Onboarding wizard
│       ├── matching/                 # Placeholder: Match list & celebration
│       ├── chat/                     # Placeholder: Realtime messaging
│       ├── profile/                  # Placeholder: Self profile & settings
│       ├── notifications/            # Placeholder: Push & alerts
│       └── moderation/               # Placeholder: Block & report
├── test/                             # Flutter test suites
│   └── features/discovery/
│       ├── data/discovery_repository_test.dart
│       ├── domain/profile_test.dart
│       └── presentation/
│           ├── discovery_view_model_test.dart
│           └── discovery_view_test.dart
├── pubspec.yaml                      # Flutter dependencies & metadata
├── analysis_options.yaml             # Dart static analysis configuration
└── README.md                         # Project documentation
```

---

## Frontend Architecture

The Flutter client employs a lightweight **Feature-First MVVM** architecture powered by **Riverpod**:

```text
View (ConsumerWidget)
  ↓ watches state & invokes actions
ViewModel / Notifier (DiscoveryViewModel)
  ↓ queries / mutates
Repository (DiscoveryRepository)
  ↓ fetches / persists
Data Source (Mock / FastAPI Backend / Local Storage)
```

### Key Frontend Decisions

1. **Explicit States**: State is modeled with explicit status flags (`initial`, `loading`, `loaded`, `empty`, `error`) and immutable state classes.
2. **Adaptive Responsive Layouts**: Uses `LayoutBuilder` with an `800px` breakpoint:
   - **Mobile (< 800px)**: Focuses on touch cards and bottom action buttons (Pass, Superlike, Like).
   - **Desktop (>= 800px)**: Multi-column view providing sidebar navigation, centered card preview, and a detailed profile metadata sidebar.
3. **No Platform Checks in Widgets**: Avoids scattering `Platform.isAndroid` or `Platform.isWindows` in presentation code; layout is strictly driven by constraints.

---

## Backend Architecture

The backend is built with **FastAPI** and packaged using **`uv`**:

- **Fast & Lightweight**: Zero heavy infrastructure required for local development.
- **Realistic Mock Data**: Returns complete `Profile` models with realistic names, bios, interest tags, and photos.
- **CORS Configured**: Ready for Flutter Web and desktop clients out of the box.

---

## Setup & Running Instructions

### 1. Flutter Client Setup

#### Prerequisites
- Flutter SDK `>= 3.10.0`
- Dart SDK `>= 3.0.0`

#### Commands

```bash
# Get dependencies
flutter pub get

# Run on available device (Windows, Chrome, Android, etc.)
flutter run

# Run with custom backend host if needed
flutter run --dart-define=API_URL=http://localhost:8080
```

### 2. Backend Setup (with `uv`)

#### Prerequisites
- Python `>= 3.10`
- [`uv`](https://docs.astral.sh/uv/)

#### Commands

```bash
cd backend

# Install dependencies into virtual environment
uv sync --extra dev

# Start development server with live reload
uv run uvicorn app.main:app --reload --port 8080 --host 0.0.0.0
```

Once running:
- API Root: [http://localhost:8080/](http://localhost:8080/)
- Health Check: [http://localhost:8080/health](http://localhost:8080/health)
- Swagger Documentation: [http://localhost:8080/docs](http://localhost:8080/docs)
- Discovery Feed: [http://localhost:8080/api/v1/discovery](http://localhost:8080/api/v1/discovery)

---

## Testing & Static Analysis

### Flutter Tests & Quality Checks

```bash
# Format code
dart format .

# Static analysis
flutter analyze

# Run unit and widget tests
flutter test
```

### Download a sample Android APK

Every push to `main` and every manually dispatched run of
[`.github/workflows/android-apk.yml`](.github/workflows/android-apk.yml) builds the
sample Discovery app and publishes an artifact named `garblo-android-apk`.

To download it:

1. Open the repository's **Actions** tab.
2. Select the **Android APK** workflow and a successful run.
3. Download **garblo-android-apk** from the **Artifacts** section.
4. Extract the archive and install `app-release.apk` on an Android device or
   emulator.

The workflow generates the Android host project during the build so the
repository can keep the Flutter feature code focused on the shared application
surface. This is an unsigned sample APK for development and evaluation, not a
production Play Store release.

### Backend Tests & Quality Checks

```bash
cd backend

# Run pytest suite
uv run pytest
```

---

## Known Limitations

- **Mock Discovery Data**: Discovery profiles are currently generated from mock sample data; production database persistence is scheduled for Phase 3.
- **Swipes**: Swipes are recorded in-memory without persistent user session tracking.
- **Placeholders**: Feature modules for Auth, Matching, Chat, Notifications, and Moderation have established directory structures and interfaces, but business logic is deferred to upcoming vertical slices.

---

## Future Implementation Phases

1. **Phase 2**: Authentication (Email/OAuth) & Multi-Step Profile Onboarding.
2. **Phase 3**: Mutual Match Formation, Match Celebrations & Swipe Persistence.
3. **Phase 4**: Realtime Chat via WebSockets & Message History.
4. **Phase 5**: User Safety (Block/Report) & Push Notifications.
5. **Phase 6**: Premium Subscriptions & Performance Optimizations.

For full details, see [`docs/tasks/README.md`](file:///f:/github/vjai/docs/tasks/README.md).
