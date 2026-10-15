```markdown
# Initialize Garblo cross-platform application architecture

You are working in the existing GitHub repository:

- Repository: `phuctanpham/vjai`
- Product/app name: `Garblo`
- Target platforms: Android, iOS, Windows, and macOS
- Development style: solo developer using agentic coding
- Architecture: Flutter frontend with a Go backend skeleton

Create a pull request containing the initial project foundation. Inspect the existing repository before changing anything and preserve useful existing files.

## Main goals

1. Initialize a maintainable Flutter application structure.
2. Add agentic coding and architecture documentation.
3. Add a minimal runnable Flutter app named `Garblo`.
4. Add a minimal Go backend skeleton.
5. Demonstrate the recommended architecture with a working discovery feature.
6. Add tests and verification instructions.
7. Keep the implementation intentionally minimal. Do not implement the complete product yet.

---

## Frontend architecture

Use Flutter and Dart with the following rules:

- Feature-first organization.
- Lightweight MVVM or ViewModel-style presentation.
- Riverpod for state management and dependency injection, unless an existing project decision requires another approach.
- Repository interfaces between presentation and data access.
- Adaptive mobile and desktop UI based on available window size.
- Use `LayoutBuilder`, `MediaQuery`, or equivalent responsive mechanisms.
- Do not scatter `Platform.isAndroid`, `Platform.isIOS`, or desktop checks throughout widgets.
- Keep platform-specific behavior behind interfaces or services.
- Use this dependency direction:

```text
View
  ↓
ViewModel / Notifier
  ↓
Repository
  ↓
Service / API / Local storage
```

Avoid strict Clean Architecture boilerplate unless it is clearly useful.

---

## Flutter project structure

Create or organize the Flutter code approximately like this:

```text
lib/
├── main.dart
├── app/
│ ├── app.dart
│ ├── router.dart
│ ├── theme/
│ └── providers.dart
├── core/
│ ├── errors/
│ ├── networking/
│ ├── storage/
│ └── widgets/
└── features/
    ├── auth/
    ├── onboarding/
    ├── discovery/
    ├── matching/
    ├── chat/
    ├── profile/
    ├── notifications/
    └── moderation/
```

The feature directories may contain placeholder documentation or minimal placeholder files, but do not create fake production functionality.

---

## Required discovery feature

Implement a small, working discovery feature to demonstrate the architecture.

Create:

```text
features/discovery/
├── data/
│ └── discovery_repository.dart
├── domain/
│ ├── profile.dart
│ └── swipe_type.dart
└── presentation/
    ├── discovery_state.dart
    ├── discovery_view_model.dart
    ├── discovery_view.dart
    └── widgets/
        ├── profile_card.dart
        └── discovery_layout.dart
```

The discovery feature must include:

- A `Profile` model.
- A repository interface.
- A mock repository implementation.
- A ViewModel or Riverpod Notifier.
- Explicit states:
  - initial
  - loading
  - loaded
  - empty
  - error
- Mock profile data.
- A retry action for errors.
- A simple profile card.
- A mobile layout.
- A desktop layout.
- Responsive behavior based on available width.
- No direct repository or API calls from widgets.

The mobile layout should be touch-friendly and card-oriented.

The desktop layout should provide:

- Navigation area or sidebar.
- Centered profile card.
- Visible action buttons.
- Profile information panel where appropriate.
- Mouse-friendly controls.

The same domain model, repository, and ViewModel should be reused across mobile and desktop layouts.

Do not implement real swipe persistence, matching, chat, authentication, or networking yet.

---

## Backend skeleton

Create a separate Go backend under:

```text
backend/
```

Use a modular monolith structure:

```text
backend/
├── cmd/
│ └── server/
│ └── main.go
├── internal/
│ ├── config/
│ ├── httpserver/
│ ├── auth/
│ ├── profiles/
│ ├── discovery/
│ ├── swipes/
│ ├── matches/
│ ├── chat/
│ ├── notifications/
│ └── moderation/
├── go.mod
└── README.md
```

Implement only a minimal server skeleton:

- Start an HTTP server.
- Load configuration from environment variables.
- Provide:

```text
GET /health
GET /api/v1/health
```

- Return JSON responses.
- Use clear package boundaries.
- Add a basic server test, including the health endpoint.
- Do not implement real authentication, databases, matching, chat, or notifications.
- Do not add microservices.
- Do not add external infrastructure unless absolutely necessary.

Example health response:

```json
{
  "status": "ok",
  "service": "garblo-api"
}
```

Use idiomatic Go and standard library packages where practical.

---

## Documentation requirements

Add or update the root `README.md` with:

- Garblo product overview.
- Current project status.
- Supported platforms.
- Repository structure.
- Flutter setup instructions.
- Backend setup instructions.
- Commands to run tests and static analysis.
- Explanation of the frontend architecture.
- Explanation of the backend modular monolith.
- Known limitations.
- Future implementation phases.

# Historical Bootstrap Guide

> **Historical document:** This file records the original repository bootstrap prompt. It is retained for project history and must not be treated as the current implementation specification.
>
> The current sources of truth are [`.github/copilot-instructions.md`](.github/copilot-instructions.md), [`docs/architecture/MAP.md`](docs/architecture/MAP.md), the relevant APRD and task card, and [`docs/quality/DOD.md`](docs/quality/DOD.md). The backend has since moved from the originally proposed Go skeleton to the lightweight Python/FastAPI mock backend documented in [`backend/README.md`](backend/README.md).

Add agent instructions at:

```text
.github/copilot-instructions.md
```

Include these rules:

- Inspect the repository before editing.
- Work on one bounded vertical slice at a time.
- Do not modify unrelated features.
- Do not add dependencies without explaining why.
- Follow feature-first organization.
- Keep widgets free of API and business logic.
- Keep platform-specific behavior behind interfaces.
- Use adaptive layouts for mobile and desktop.
- Add tests for new business logic and important UI states.
- Run formatting, analysis, and tests before completing work.
- Never add credentials, secrets, or private user data.
- Prefer the simplest design that satisfies the requirement.

Add:

```text
docs/architecture/README.md
```

Document:

- Chosen architecture.
- Dependency direction.
- Feature-first organization.
- ViewModel responsibilities.
- Repository responsibilities.
- Adaptive UI strategy.
- Mobile versus desktop responsibilities.
- Backend modular monolith strategy.
- When to introduce use cases.
- When not to introduce additional abstractions.

Add ADR files:

```text
docs/architecture/001-feature-first-architecture.md
docs/architecture/002-state-management.md
docs/architecture/003-adaptive-mobile-desktop-ui.md
docs/architecture/004-agentic-development-workflow.md
```

Add an initial task backlog:

```text
docs/tasks/README.md
```

The task backlog should describe future vertical slices, including:

1. App shell and routing
2. Authentication
3. Profile onboarding
4. Discovery with mock data
5. Swipe persistence
6. Backend discovery API
7. Matching
8. Match list
9. Chat history
10. Realtime chat
11. Notifications
12. Blocking and reporting
13. Moderation
14. Subscriptions
15. Performance and accessibility

---

## Testing requirements

Flutter tests should cover:

- Profile model behavior where applicable.
- Mock repository success.
- Mock repository empty result.
- Mock repository error.
- ViewModel loading state.
- ViewModel loaded state.
- ViewModel empty state.
- ViewModel error state.
- Main discovery screen rendering.
- Mobile and desktop layout behavior where practical.

Go tests should cover:

- Health endpoint.
- Basic server response behavior.

Use appropriate test directories, for example:

```text
test/features/discovery/
backend/internal/httpserver/
```

---

## Verification requirements

Run the following where the required toolchains are available:

```bash
dart format .
flutter analyze
flutter test
```

For the backend:

```bash
gofmt -w .
go test ./...
go vet ./...
```

If a command cannot run because the environment lacks Flutter, Dart, Go, or another dependency, clearly report that limitation. Do not hide failed or skipped verification.

---

## Scope restrictions

Do not:

- Implement a complete Tinder clone.
- Add real authentication.
- Add real user accounts.
- Add real matching logic.
- Add a production database.
- Add payment processing.
- Add real-time chat.
- Add recommendation algorithms.
- Add cloud deployment configuration.
- Add secrets or credentials.
- Introduce microservices.
- Rewrite unrelated existing code.
- Add large generated files unnecessarily.
- Add dependencies without documenting the reason.

---

## Definition of done

The pull request is complete when:

- The repository contains the documented Flutter architecture.
- The Flutter app has a minimal Garblo app shell.
- The discovery feature runs with mock data.
- Mobile and desktop layouts are both represented.
- Loading, loaded, empty, and error states exist.
- The backend starts and exposes a health endpoint.
- Flutter and Go tests are included.
- Documentation and agent instructions are present.
- Formatting and static analysis have been run where possible.
- The pull request description lists:
  - Changed files
  - Architecture decisions
  - Commands run
  - Test results
  - Known limitations
  - Recommended next tasks
```

After the agent finishes, review the pull request and verify that it did not implement too much at once. The most important files to inspect first are:

```text
.github/copilot-instructions.md
README.md
docs/architecture/README.md
lib/features/discovery/
backend/cmd/server/main.go
```

If the agent produces an overly large or confusing pull request, ask it to split the work into two follow-up pull requests:

1. Flutter architecture and discovery scaffold  
2. Go backend skeleton and documentation updatesCopy and paste this into **GitHub Copilot coding agent** for the `phuctanpham/vjai` repository:

```markdown
# Initialize Garblo cross-platform application architecture

You are working in the existing GitHub repository:

- Repository: `phuctanpham/vjai`
- Product/app name: `Garblo`
- Target platforms: Android, iOS, Windows, and macOS
- Development style: solo developer using agentic coding
- Architecture: Flutter frontend with a Go backend skeleton

Create a pull request containing the initial project foundation. Inspect the existing repository before changing anything and preserve useful existing files.

## Main goals

1. Initialize a maintainable Flutter application structure.
2. Add agentic coding and architecture documentation.
3. Add a minimal runnable Flutter app named `Garblo`.
4. Add a minimal Go backend skeleton.
5. Demonstrate the recommended architecture with a working discovery feature.
6. Add tests and verification instructions.
7. Keep the implementation intentionally minimal. Do not implement the complete product yet.

---

## Frontend architecture

Use Flutter and Dart with the following rules:

- Feature-first organization.
- Lightweight MVVM or ViewModel-style presentation.
- Riverpod for state management and dependency injection, unless an existing project decision requires another approach.
- Repository interfaces between presentation and data access.
- Adaptive mobile and desktop UI based on available window size.
- Use `LayoutBuilder`, `MediaQuery`, or equivalent responsive mechanisms.
- Do not scatter `Platform.isAndroid`, `Platform.isIOS`, or desktop checks throughout widgets.
- Keep platform-specific behavior behind interfaces or services.
- Use this dependency direction:

```text
View
  ↓
ViewModel / Notifier
  ↓
Repository
  ↓
Service / API / Local storage
```

Avoid strict Clean Architecture boilerplate unless it is clearly useful.

---

## Flutter project structure

Create or organize the Flutter code approximately like this:

```text
lib/
├── main.dart
├── app/
│ ├── app.dart
│ ├── router.dart
│ ├── theme/
│ └── providers.dart
├── core/
│ ├── errors/
│ ├── networking/
│ ├── storage/
│ └── widgets/
└── features/
    ├── auth/
    ├── onboarding/
    ├── discovery/
    ├── matching/
    ├── chat/
    ├── profile/
    ├── notifications/
    └── moderation/
```

The feature directories may contain placeholder documentation or minimal placeholder files, but do not create fake production functionality.

---

## Required discovery feature

Implement a small, working discovery feature to demonstrate the architecture.

Create:

```text
features/discovery/
├── data/
│ └── discovery_repository.dart
├── domain/
│ ├── profile.dart
│ └── swipe_type.dart
└── presentation/
    ├── discovery_state.dart
    ├── discovery_view_model.dart
    ├── discovery_view.dart
    └── widgets/
        ├── profile_card.dart
        └── discovery_layout.dart
```

The discovery feature must include:

- A `Profile` model.
- A repository interface.
- A mock repository implementation.
- A ViewModel or Riverpod Notifier.
- Explicit states:
  - initial
  - loading
  - loaded
  - empty
  - error
- Mock profile data.
- A retry action for errors.
- A simple profile card.
- A mobile layout.
- A desktop layout.
- Responsive behavior based on available width.
- No direct repository or API calls from widgets.

The mobile layout should be touch-friendly and card-oriented.

The desktop layout should provide:

- Navigation area or sidebar.
- Centered profile card.
- Visible action buttons.
- Profile information panel where appropriate.
- Mouse-friendly controls.

The same domain model, repository, and ViewModel should be reused across mobile and desktop layouts.

Do not implement real swipe persistence, matching, chat, authentication, or networking yet.

---

## Backend skeleton

Create a separate Go backend under:

```text
backend/
```

Use a modular monolith structure:

```text
backend/
├── cmd/
│ └── server/
│ └── main.go
├── internal/
│ ├── config/
│ ├── httpserver/
│ ├── auth/
│ ├── profiles/
│ ├── discovery/
│ ├── swipes/
│ ├── matches/
│ ├── chat/
│ ├── notifications/
│ └── moderation/
├── go.mod
└── README.md
```

Implement only a minimal server skeleton:

- Start an HTTP server.
- Load configuration from environment variables.
- Provide:

```text
GET /health
GET /api/v1/health
```

- Return JSON responses.
- Use clear package boundaries.
- Add a basic server test, including the health endpoint.
- Do not implement real authentication, databases, matching, chat, or notifications.
- Do not add microservices.
- Do not add external infrastructure unless absolutely necessary.

Example health response:

```json
{
  "status": "ok",
  "service": "garblo-api"
}
```

Use idiomatic Go and standard library packages where practical.

---

## Documentation requirements

Add or update the root `README.md` with:

- Garblo product overview.
- Current project status.
- Supported platforms.
- Repository structure.
- Flutter setup instructions.
- Backend setup instructions.
- Commands to run tests and static analysis.
- Explanation of the frontend architecture.
- Explanation of the backend modular monolith.
- Known limitations.
- Future implementation phases.

Add agent instructions at:

```text
.github/copilot-instructions.md
```

Include these rules:

- Inspect the repository before editing.
- Work on one bounded vertical slice at a time.
- Do not modify unrelated features.
- Do not add dependencies without explaining why.
- Follow feature-first organization.
- Keep widgets free of API and business logic.
- Keep platform-specific behavior behind interfaces.
- Use adaptive layouts for mobile and desktop.
- Add tests for new business logic and important UI states.
- Run formatting, analysis, and tests before completing work.
- Never add credentials, secrets, or private user data.
- Prefer the simplest design that satisfies the requirement.

Add:

```text
docs/architecture/README.md
```

Document:

- Chosen architecture.
- Dependency direction.
- Feature-first organization.
- ViewModel responsibilities.
- Repository responsibilities.
- Adaptive UI strategy.
- Mobile versus desktop responsibilities.
- Backend modular monolith strategy.
- When to introduce use cases.
- When not to introduce additional abstractions.

Add ADR files:

```text
docs/architecture/001-feature-first-architecture.md
docs/architecture/002-state-management.md
docs/architecture/003-adaptive-mobile-desktop-ui.md
docs/architecture/004-agentic-development-workflow.md
```

Add an initial task backlog:

```text
docs/tasks/README.md
```

The task backlog should describe future vertical slices, including:

1. App shell and routing
2. Authentication
3. Profile onboarding
4. Discovery with mock data
5. Swipe persistence
6. Backend discovery API
7. Matching
8. Match list
9. Chat history
10. Realtime chat
11. Notifications
12. Blocking and reporting
13. Moderation
14. Subscriptions
15. Performance and accessibility

---

## Testing requirements

Flutter tests should cover:

- Profile model behavior where applicable.
- Mock repository success.
- Mock repository empty result.
- Mock repository error.
- ViewModel loading state.
- ViewModel loaded state.
- ViewModel empty state.
- ViewModel error state.
- Main discovery screen rendering.
- Mobile and desktop layout behavior where practical.

Go tests should cover:

- Health endpoint.
- Basic server response behavior.

Use appropriate test directories, for example:

```text
test/features/discovery/
backend/internal/httpserver/
```

---

## Verification requirements

Run the following where the required toolchains are available:

```bash
dart format .
flutter analyze
flutter test
```

For the backend:

```bash
gofmt -w .
go test ./...
go vet ./...
```

If a command cannot run because the environment lacks Flutter, Dart, Go, or another dependency, clearly report that limitation. Do not hide failed or skipped verification.

---

## Scope restrictions

Do not:

- Implement a complete Tinder clone.
- Add real authentication.
- Add real user accounts.
- Add real matching logic.
- Add a production database.
- Add payment processing.
- Add real-time chat.
- Add recommendation algorithms.
- Add cloud deployment configuration.
- Add secrets or credentials.
- Introduce microservices.
- Rewrite unrelated existing code.
- Add large generated files unnecessarily.
- Add dependencies without documenting the reason.

---

## Definition of done

The pull request is complete when:

- The repository contains the documented Flutter architecture.
- The Flutter app has a minimal Garblo app shell.
- The discovery feature runs with mock data.
- Mobile and desktop layouts are both represented.
- Loading, loaded, empty, and error states exist.
- The backend starts and exposes a health endpoint.
- Flutter and Go tests are included.
- Documentation and agent instructions are present.
- Formatting and static analysis have been run where possible.
- The pull request description lists:
  - Changed files
  - Architecture decisions
  - Commands run
  - Test results
  - Known limitations
  - Recommended next tasks
```

After the agent finishes, review the pull request and verify that it did not implement too much at once. The most important files to inspect first are:

```text
.github/copilot-instructions.md
README.md
docs/architecture/README.md
lib/features/discovery/
backend/cmd/server/main.go
```

If the agent produces an overly large or confusing pull request, ask it to split the work into two follow-up pull requests:

1. Flutter architecture and discovery scaffold  
2. Go backend skeleton and documentation updates
