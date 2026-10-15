# Copilot & AI Agent Coding Instructions for Garblo

Welcome to the **Garblo** codebase (`phuctanpham/vjai`). Follow these core principles and development guidelines when planning, modifying, or extending the application.

## Core Directives

1. **Inspect Before Editing**: Always inspect the repository and surrounding files before proposing or writing code. Respect and preserve existing working architecture.
2. **Bounded Vertical Slices**: Work on one bounded vertical slice at a time (e.g. from presentation down to data source). Do not mix unrelated domains.
3. **Do Not Modify Unrelated Features**: Restrict code edits strictly to the scope of the assigned task or issue.
4. **Justify New Dependencies**: Do not introduce new third-party libraries or dependencies without explicit architectural justification.
5. **Feature-First Organization**: Group code by business capability under `lib/features/<feature_name>/` containing `domain/`, `data/`, and `presentation/` subdirectories.
6. **Clean Separation of Concerns**: Keep widgets completely free of direct API, database, or domain business logic. Widgets communicate exclusively via ViewModels / Notifiers.
7. **Platform Agnosticism**: Keep platform-specific behavior behind abstract interfaces or services. Do NOT scatter `Platform.isAndroid`, `Platform.isIOS`, or desktop checks inside UI widgets.
8. **Adaptive Layouts**: Design UI to adapt fluidly across mobile and desktop form factors based on available layout width using `LayoutBuilder` and `MediaQuery`.
9. **Rigorous Testing**: Every new business logic path, state transition, and key UI state (loading, loaded, empty, error) must include corresponding unit and widget tests.
10. **Quality Checks**: Run formatting, static analysis (`flutter analyze` / `dart format`, `uv run pytest`), and automated tests before marking tasks as complete.
11. **Zero Secret Leakage**: Never commit credentials, API keys, tokens, or private user data. Use environment variables and configuration files.
12. **Simplicity First**: Prefer the simplest, most maintainable design that satisfies requirements. Avoid premature abstraction layers (such as boilerplate Clean Architecture use cases) unless truly justified.

## Frontend Architecture Rules

```text
View (StatelessWidget / ConsumerWidget)
  ↓
ViewModel / Notifier (StateNotifier / Riverpod)
  ↓
Repository Interface (Abstract domain contract)
  ↓
Data Source / API Client / Storage (Concrete implementation)
```

- **State Management**: Use **Riverpod** for state management and dependency injection.
- **Explicit States**: View states must explicitly represent `initial`, `loading`, `loaded`, `empty`, and `error`.
- **Responsive Layout**: Breakpoints define desktop vs mobile presentation (e.g., width >= 800px activates desktop layout with sidebar and detail panel).

## Backend Guidelines

- The backend is a lightweight mock API written in **Python / FastAPI** managed with **`uv`**.
- Encapsulate routes under `backend/app/api/v1/endpoints/`.
- Provide typed request and response schemas via Pydantic models.
- Support CORS for local web and desktop Flutter development.

