# BL-002 Implementation Plan

## Generated files
| Role | Path | Change |
|---|---|---|
| Backend Developer | `backend/app/models/auth.py` | `LoginRequest`, `AuthSession` per [data-schema.md](../../../policies/engineering/data-schema.md) |
| Backend Developer | `backend/app/api/v1/endpoints/auth.py` | `POST /login`, `POST /logout` (keep `GET /status`) |
| Backend Developer | `backend/tests/test_auth.py` | New tests |
| App Developer | `apps/mobile/lib/features/auth/domain/{auth_session,auth_failure}.dart` | `AuthSession { userId, token, expiresAt }` + JSON; `InvalidCredentialsFailure` |
| App Developer | `apps/mobile/lib/features/auth/data/auth_repository.dart` | `AuthRepository { login, register, logout, getCurrentSession }`, `MockAuthRepository` using `LocalStorage`, provider |
| App Developer | `apps/mobile/lib/features/auth/presentation/{auth_state,auth_view_model,auth_view}.dart`, `widgets/auth_text_field.dart` | Form, validation, states |
| App Developer | `apps/mobile/lib/app/router.dart` | `/login` route; redirect to `/login` without a session |
| App Developer | `apps/mobile/test/features/auth/**` | New tests |
| App Developer | `apps/mobile/lib/features/auth/auth_placeholder.dart` | Delete |

**Order:** backend first (contract is already in data-schema). The app uses `MockAuthRepository`; calling the HTTP endpoints is out of scope until BL-006 provides `HttpApiClient`. **Locked:** discovery, matching, chat.

## State model
| `AuthStatus` | Trigger | UI | Actions |
|---|---|---|---|
| `unauthenticated` | Start without session / sign-out | Form | submit, toggle sign-up, social |
| `authenticating` | Submit | Form disabled, spinner in button | none (duplicate submits ignored) |
| `authenticated` | Repository success | Navigate to `/discovery` | sign out |
| `error` | `InvalidCredentialsFailure` or other `Failure` | Form enabled + error banner | edit, retry |

## Contracts
- **Boundary:** only the repository reads or writes the session (`auth_token` key, JSON `AuthSession`).
- **Failure behaviour:** typed failures, visible and retryable. Sign-out must not report success if clearing storage fails.
- **Mock rule:** `MockAuthRepository` rejects the password `wrong-password`, matching the backend.

## Verification
`dart format --output=none --set-exit-if-changed .` · `flutter analyze` · `flutter test test/features/auth/` · `cd backend && uv run pytest`

## Engineering acceptance
Pending.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Migrated from TASK-002; backend contract defined; verification runs the full pytest suite (TASK-002 ran only test_health) |
| 2026-10-30 | [CHG-010](../../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
