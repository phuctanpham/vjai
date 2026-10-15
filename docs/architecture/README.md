# Garblo Architecture Documentation

This document describes the architectural principles, layers, responsibilities, and design decisions for the Garblo cross-platform application and mock backend.

---

## 1. Chosen Architecture

Garblo follows a **Feature-First lightweight MVVM (Model-View-ViewModel)** architecture on the Flutter client, paired with a modular mock API backend in Python/FastAPI.

### Dependency Direction

```text
View (Presentation)
  ↓
ViewModel / Notifier (State Management)
  ↓
Repository Interface (Domain boundary)
  ↓
Data Source / API Client / Local Storage (Data access)
```

1. **Views** observe ViewModel state and dispatch user interactions.
2. **ViewModels** execute business logic, manage UI state, and communicate with Repositories.
3. **Repositories** abstract where data originates (remote network, local cache, or in-memory mock).
4. **Data Sources** interact with network sockets, HTTP clients, or file systems.

Widgets never reference repositories, API clients, or disk storage directly.

---

## 2. Feature-First Organization

The client codebase is structured around business capabilities rather than technical layers:

```text
lib/
├── app/                      # Application shell, router, themes, top-level providers
├── core/                     # Cross-cutting concerns (errors, shared widgets, contracts)
└── features/                 # Vertical business slices
    ├── discovery/            # Candidate discovery feed & swiping
    │   ├── data/             # Repositories and data providers
    │   ├── domain/           # Models, entities, and value objects
    │   └── presentation/     # Views, ViewModels, and UI widgets
    ├── auth/                 # Future slice: Authentication & account recovery
    ├── onboarding/           # Future slice: Profile creation wizard
    ├── matching/             # Future slice: Mutual match dialog & lists
    ├── chat/                 # Future slice: Realtime chat & messaging
    ├── profile/              # Future slice: Profile edit & settings
    ├── notifications/        # Future slice: Push & in-app alerts
    └── moderation/           # Future slice: Reporting & blocking
```

Each feature is self-contained. Adding, modifying, or refactoring a feature has minimal impact on other features.

---

## 3. ViewModel Responsibilities

A ViewModel (implemented via Riverpod `StateNotifier` / `Notifier`):

- Holds and emits the immutable state for the associated view.
- Expresses explicit states: `initial`, `loading`, `loaded`, `empty`, `error`.
- Handles side effects (e.g., initiating API calls, handling retries, mutating card queues).
- Emits presentation-friendly error messages.
- Does **not** import `dart:io`, `dart:html`, or build UI widgets.

---

## 4. Repository Responsibilities

A Repository:

- Acts as a mediator between domain logic and data sources.
- Defines an abstract Dart interface in the domain/data layer.
- Returns clean domain entities (`Profile`), preventing raw JSON or network objects from leaking into the presentation layer.
- Enables effortless unit and widget testing via mock implementations without running network servers.

---

## 5. Adaptive UI Strategy

Garblo targets Android, iOS, Windows, and macOS. Rather than writing separate platform applications, the UI adapts based on **available window width**:

- Breakpoint: `>= 800px` activates desktop layout; `< 800px` uses mobile layout.
- Implementation: Driven by `LayoutBuilder` and `MediaQuery`.
- **Platform Agnosticism**: No scattered `Platform.isAndroid` or `Platform.isIOS` checks in UI widgets. Platform-specific capabilities (e.g. native notifications or haptics) are encapsulated behind interfaces.

### Mobile vs. Desktop Responsibilities

| Responsibility | Mobile (< 800px) | Desktop (>= 800px) |
|---|---|---|
| **Navigation** | App bar / Bottom nav bar | Persistent sidebar navigation |
| **Feed Presentation** | Full-screen touch cards | Centered card with fixed max width |
| **Profile Details** | Bottom-sheet / overlay sheet | Dedicated side information panel |
| **Controls** | Large touch targets at bottom | Mouse-friendly buttons with tooltips |

Both form factors share the exact same `Profile` domain entity, `DiscoveryRepository`, and `DiscoveryViewModel`.

---

## 6. Backend Strategy

The backend provides a mock API built with **FastAPI** and managed via **`uv`**:

- Mimics the schema expected by the mobile and desktop client.
- Provides immediate local endpoints for development and integration testing.
- Features are grouped under `app/api/v1/endpoints/`.
- Enables rapid UI prototyping without heavy infrastructure (Docker, external databases).

---

## 7. When to Introduce Use Cases

Do **not** introduce use-case or interactor classes prematurely for simple CRUD operations that merely pass data from repository to ViewModel.

Introduce dedicated use case classes only when:
1. Business logic involves coordinating multiple repositories (e.g., matching + push notification + analytics dispatch).
2. Complex validation or computation is reused across multiple ViewModels.
3. Transactional workflows require strict step sequencing.

---

## 8. When Not to Introduce Additional Abstractions

- Do not create abstract classes when there is only ever one implementation and no testing need.
- Do not add boilerplate mapper classes when `Profile.fromJson` or clean factory constructors are sufficient.
- Do not create microservices for early-stage features.

