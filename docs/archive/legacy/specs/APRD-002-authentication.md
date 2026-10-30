# APRD-002: Authentication & Session Management

> **Status:** Accepted for implementation  
> **Target bounded context:** `apps/mobile/lib/features/auth/`  
> **Companion API:** `backend/app/api/v1/endpoints/auth.py`

## 1. Goal

Provide a lightweight mock authentication flow with login, registration, session persistence, logout, and route protection without introducing a production identity provider.

## 2. Scope

### In scope

- `AuthSession` domain entity and authentication failure types.
- Riverpod state with `unauthenticated`, `authenticating`, `authenticated`, and `error`.
- Mock repository for login, registration, logout, and current-session lookup.
- Local token persistence through `LocalStorage`.
- Responsive login and registration forms.
- Mock social sign-in buttons.
- Mock FastAPI login/logout endpoints.

### Anti-scope

- No Firebase, Supabase, or production identity provider.
- No OAuth redirects or browser callbacks.
- No SMS, biometric, or device authentication.
- No real user database or password storage.

## 3. State and acceptance criteria

| State | Trigger | Required UI |
|---|---|---|
| `unauthenticated` | Initial state or logout | Login/registration form |
| `authenticating` | Submit credentials | Disabled form and progress indicator |
| `authenticated` | Repository succeeds | Navigate to `/discovery` |
| `error` | Repository rejects request | Error banner and retryable form |

- Valid credentials produce a non-empty `AuthSession` and persist `auth_token`.
- Invalid email or short password fails client validation without calling the repository.
- Repository failure produces an explicit error state.
- Logout clears the persisted session.

## 4. Verification

Run `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, `flutter test test/features/auth/`, and `cd backend; uv run pytest`.
