# Copilot & AI Agent Coding Instructions for Garblo

Welcome to the **Garblo** codebase (`phuctanpham/vjai`). This project is designed for a **solo fullstack developer** orchestrating **AI coding agents** to deliver multi-native applications.

---

## 1. Fundamental Architectural Mandate

- **PRIMARY FOCUS — Flutter Multi-Native Framework (`lib/`)**:
  - The core of this codebase is a maintainable, reactive Flutter framework targeting **Android, iOS, Windows, and macOS**.
  - All feature logic, state management, adaptive presentation, and domain modeling live here.
- **SECONDARY UTILITY — Python Mock Backend (`backend/`)**:
  - The Python/FastAPI mock server managed via `uv` is **strictly secondary**.
  - Its sole purpose is to serve mock data, simulate swipe endpoints, and validate client HTTP integrations.
  - **Do NOT** over-engineer the backend with real databases, authentication microservices, or complex infrastructure.

---

## 2. Core Agentic Directives (Non-Negotiable)

1. **Inspect Before Editing**: Always inspect the repository and surrounding files before proposing or writing code. Respect and preserve existing working architecture.
2. **Consult the Topology Map**: Reference [`docs/architecture/MAP.md`](../docs/architecture/MAP.md) to locate bounded contexts rather than crawling the entire repository.
3. **Respect Anti-Scope**: Every task or APRD defines an **Anti-Scope** (what is strictly prohibited). Never implement features listed under Anti-Scope.
4. **Bounded Vertical Slices**: Work on one bounded vertical slice at a time (e.g. from presentation down to data source). Do not mix unrelated domains.
5. **Locked Files (Do NOT Touch)**: Do not modify files outside the assigned feature slice. Never touch unrelated features.
6. **Justify New Dependencies**: Do not introduce new third-party packages or libraries without explicit architectural justification.
7. **Feature-First Organization**: Group code by business capability under `lib/features/<feature_name>/` containing `domain/`, `data/`, and `presentation/` subdirectories.
8. **Clean Separation of Concerns**: Keep widgets completely free of direct API, database, or domain business logic. Widgets communicate exclusively via ViewModels / Notifiers.
9. **Platform Agnosticism**: Keep platform-specific behavior behind abstract interfaces or services. **Do NOT** scatter `Platform.isAndroid`, `Platform.isIOS`, or desktop checks inside UI widgets.
10. **Adaptive Layouts**: Design UI to adapt fluidly across mobile (< 800px touch cards) and desktop ($\ge$ 800px multi-column layout) based on available layout width using `LayoutBuilder` and `MediaQuery`.
11. **Rigorous Testing**: Every new business logic path, state transition, and key UI state (`initial`, `loading`, `loaded`, `empty`, `error`) must include corresponding unit and widget tests.
12. **Verification Gates (Definition of Done)**: Always execute verification commands before marking work complete (see [`docs/quality/DOD.md`](../docs/quality/DOD.md)).
13. **Zero Secret Leakage**: Never commit credentials, API keys, tokens, or private user data. Use environment variables and configuration files.
14. **Ubiquitous Language**: Use the canonical symbols defined in [`docs/architecture/GLOSSARY.md`](../docs/architecture/GLOSSARY.md). Do not invent synonym types.

---

## 3. Frontend Architecture Rules

```text
View (StatelessWidget / ConsumerWidget)
  ↓ watches state & dispatches actions
ViewModel / Notifier (StateNotifier / Riverpod)
  ↓ queries & mutates
Repository Interface (Abstract domain contract)
  ↓ fetches / persists
Data Source / API Client / Storage (Concrete implementation)
```

- **State Management**: Use **Riverpod** for state management and dependency injection.
- **Explicit States**: View states must explicitly represent `initial`, `loading`, `loaded`, `empty`, and `error`.
- **Responsive Layout**: Breakpoints define desktop vs mobile presentation (breakpoint: `800px`).

---

## 4. Backend Mock Guidelines

- Lightweight mock API written in **Python / FastAPI** managed with **`uv`**.
- Encapsulate routes under `backend/app/api/v1/endpoints/`.
- Provide typed request and response schemas via Pydantic models matching Flutter's domain entities.
- Support CORS for local web and desktop Flutter development.

---

## 5. Verification Commands

Before completing any task, run the appropriate verification suite:

```bash
# Flutter
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

# Backend (uv)
cd backend
uv run pytest
```
