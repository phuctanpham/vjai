# Garblo

> Cross-platform wardrobe and outfit application built with Flutter, with a
> phase-limited FastAPI mock backend for early integration work.

[![Flutter](https://img.shields.io/badge/Flutter-3.24.5-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.10+-3776AB?logo=python&logoColor=white)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![uv](https://img.shields.io/badge/uv-Package%20Manager-DE5FE9)](https://docs.astral.sh/uv/)

---

## Product Overview

**Garblo** is a wardrobe and outfit application. Flow A turns photos into
structured wardrobe Pieces; Flow B creates Gu Match outfits from the user's
own Pieces. Flow C (Impact) and Flow D (Community) are feature-flagged
nice-to-have flows.

The [Garblo Flow Spec](docs/tasks/mobile/Garblo%20Flow%20Spec.html) is the
product authority: T7 governs UI, T2 data names, T4 the data platform, and T6
the phase ladder. See [docs/README.md](docs/README.md) for documentation
authority and precedence.

- **Clean separation of concerns**: Feature-first MVVM architecture with clear dependency flow.
- **Adaptive UI**: Responsive layouts tailored to mobile touch screens and widescreen desktop environments without platform fragmentation.
- **Phase-based delivery**: P1/P2 use in-memory or local persistence and fake
  AI; the future backend platform is pending BE-001.

---

## Current Project Status

- **Status**: Phase 2 persistent offline wardrobe app; legacy discovery code
  remains unrouted.
- **Frontend**: Flutter application structure with Riverpod, Material 3 theming, responsive mobile/desktop layouts, and fully tested Discovery vertical slice with mock repository.
- **Backend**: FastAPI remains a legacy dating mock for fixture and integration
  tests only; its P3/P4 replacement is unresolved in
  [BE-001](docs/tasks/backend/BE-001-platform-decision.md).

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

This is a two-package monorepo. The annotated file tree lives in one place,
[`docs/policies/engineering/codebase-map.md`](docs/policies/engineering/codebase-map.md).

| Path | Contents |
|---|---|
| `lib/`, `test/`, `pubspec.yaml` | Flutter app (`garblo`): `app/` shell and routing, `core/` storage, media and layout, `features/` wardrobe slices |
| `backend/` | Legacy FastAPI mock API (`garblo-backend`, managed with `uv`) |
| `docs/` | Every document; start at [`docs/README.md`](docs/README.md) |
| `CLAUDE.md`, `.claude/` | Claude Code instructions, subagents and skills |
| `.github/` | Copilot instructions and the Android APK workflow |

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
   - **Mobile (< 800px)**: Full-width content and bottom pillar navigation.
   - **Desktop (>= 800px)**: Multi-column layouts defined by T7.
3. **No Platform Checks in Widgets**: Avoids scattering `Platform.isAndroid` or `Platform.isWindows` in presentation code; layout is strictly driven by constraints.

---

## Backend Architecture

The current FastAPI service is a phase-limited, deterministic mock. It exists
for health checks and legacy fixture/integration tests; it is not the target
P3/P4 wardrobe backend. MongoDB, PowerSync, identity and wire-contract
decisions remain pending in
[BE-001](docs/tasks/backend/BE-001-platform-decision.md).

---

## Setup & Running Instructions

### 1. Flutter Client Setup

#### Prerequisites
- Flutter SDK **3.24.5** (pinned in `.fvmrc` and CI; with [FVM](https://fvm.app) run `fvm use` in the repo root)
- Dart SDK 3.5.4 (bundled with Flutter 3.24.5)

#### Commands

```bash
# Get dependencies
flutter pub get

# Run on available device (Windows, Chrome, Android, etc.)
flutter run

# Run with custom backend host if needed
flutter run --dart-define=API_BASE_URL=http://localhost:8080
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
- Legacy discovery fixture: [http://localhost:8080/api/v1/discovery](http://localhost:8080/api/v1/discovery)

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
[`.github/workflows/android-apk.yml`](.github/workflows/android-apk.yml) builds the current Flutter app and publishes an artifact named
`garblo-android-apk`.

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

## Known Limitations and phase status

- P1/P2 use fake analysis and local repositories; production AI and backend
  services are later phases.
- The legacy dating feature tree and FastAPI endpoints remain for historical
  compatibility and are not routed by the wardrobe app.
- P3/P4 platform and synchronization decisions are blocked by
  [BE-001](docs/tasks/backend/BE-001-platform-decision.md).

For the active phase ladder, see
[Garblo Flow Spec T6](docs/tasks/mobile/Garblo%20Flow%20Spec.html#phases) and
[mobile task status](docs/tasks/mobile/README.md).
