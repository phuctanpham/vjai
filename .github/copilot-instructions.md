# Copilot & AI Agent Coding Instructions for Garblo

Welcome to the **Garblo** codebase (`phuctanpham/vjai`). This project is designed for a **solo fullstack developer** orchestrating **AI coding agents** to deliver multi-native applications.

---

## 1. Fundamental Architectural Mandate

- **PRIMARY FOCUS — Flutter Multi-Native Framework (`apps/mobile/lib/`)**:
  - The core of this codebase is a maintainable, reactive Flutter framework targeting **Android, iOS, Windows, and macOS**.
  - All feature logic, state management, adaptive presentation, and domain modeling live here.
- **SECONDARY UTILITY — Python Mock Backend (`backend/`)**:
  - The current Python/FastAPI service managed via `uv` is a **phase-limited
    legacy mock** for fixtures, health checks and integration tests.
  - Do not treat its dating endpoints as the active product contract.
  - Do not implement the future MongoDB/PowerSync platform until
    [BE-001](../docs/tasks/backend/BE-001-platform-decision.md) is resolved.

---

## 2. Core Agentic Directives (Non-Negotiable)

1. **Inspect Before Editing**: Always inspect the repository and surrounding files before proposing or writing code. Respect and preserve existing working architecture.
2. **Consult the active documentation authority**: Read
   [`docs/README.md`](../docs/README.md), the relevant policy, and the
   [Flow Spec](../docs/tasks/mobile/Garblo%20Flow%20Spec.html) section before
   consulting retained legacy documents.
3. **Respect Anti-Scope**: Every task or APRD defines an **Anti-Scope** (what is strictly prohibited). Never implement features listed under Anti-Scope.
4. **Bounded Vertical Slices**: Work on one bounded vertical slice at a time (e.g. from presentation down to data source). Do not mix unrelated domains.
5. **Locked Files (Do NOT Touch)**: Do not modify files outside the assigned feature slice. Never touch unrelated features.
6. **Justify New Dependencies**: Do not introduce new third-party packages or libraries without explicit architectural justification.
7. **Feature-First Organization**: Group code by business capability under `apps/mobile/lib/features/<feature_name>/` containing `domain/`, `data/`, and `presentation/` subdirectories.
8. **Clean Separation of Concerns**: Keep widgets completely free of direct API, database, or domain business logic. Widgets communicate exclusively via ViewModels / Notifiers.
9. **Platform Agnosticism**: Keep platform-specific behavior behind abstract interfaces or services. **Do NOT** scatter `Platform.isAndroid`, `Platform.isIOS`, or desktop checks inside UI widgets.
10. **Adaptive Layouts**: Design UI to adapt fluidly across mobile (< 800px touch cards) and desktop ($\ge$ 800px multi-column layout) based on available layout width using `LayoutBuilder` and `MediaQuery`.
11. **Rigorous Testing**: Every new business logic path, state transition, and key UI state (`initial`, `loading`, `loaded`, `empty`, `error`) must include corresponding unit and widget tests.
12. **Verification Gates (Definition of Done)**: Always execute verification commands before marking work complete (see [`docs/policies/engineering/definition-of-done.md`](../docs/policies/engineering/definition-of-done.md)).
13. **Zero Secret Leakage**: Never commit credentials, API keys, tokens, or private user data. Use environment variables and configuration files.
14. **Ubiquitous Language**: Use the active canonical symbols in
   [`docs/policies/product/terminology.md`](../docs/policies/product/terminology.md).
   The retained dating glossary is legacy-only.

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
- Keep the legacy mock typed and deterministic. Do not present its dating
  schemas as the wardrobe contract.
- Support CORS for local web and desktop Flutter development.

---

## 5. Verification Commands

Before completing any task, run the appropriate verification suite:

```bash
# Flutter (from apps/mobile/)
cd apps/mobile
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test

# Backend (uv, from the repository root)
cd ../../backend
uv run pytest
```
