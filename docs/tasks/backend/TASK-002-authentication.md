# TASK-002: Authentication & Session Management (Vertical Slice)

> **Sprint**: Phase 2 (Identity & Onboarding)  
> **Status**: Ready for Agent Execution  
> **Target Bounded Context**: `apps/mobile/lib/features/auth/`  
> **Companion Mock API**: `backend/app/api/v1/endpoints/auth.py`  
> **Estimated Agent Prompts**: 1 bounded session  

---

## 1. Context & Objective
Implement a lightweight, self-contained authentication slice in Flutter using Riverpod. The user must be able to view login and registration forms, submit credentials to a mock `AuthRepository`, persist the mock session token via `LocalStorage`, and toggle between authenticated and unauthenticated states with route guarding.

---

## 2. File Confinement

### Files to CREATE or MODIFY
- `apps/mobile/lib/features/auth/domain/auth_session.dart` (Session model with userId, token, expiry)
- `apps/mobile/lib/features/auth/domain/auth_failure.dart` (InvalidCredentialsFailure, NetworkFailure)
- `apps/mobile/lib/features/auth/data/auth_repository.dart` (Abstract contract & MockAuthRepository)
- `apps/mobile/lib/features/auth/presentation/auth_state.dart` (AuthStatus: unauthenticated, authenticating, authenticated, error)
- `apps/mobile/lib/features/auth/presentation/auth_view_model.dart` (StateNotifier managing login/logout)
- `apps/mobile/lib/features/auth/presentation/auth_view.dart` (Responsive login/signup screen with form validation)
- `apps/mobile/lib/features/auth/presentation/widgets/auth_text_field.dart` (Reusable styled input)
- `apps/mobile/lib/app/router.dart` (Add `/login` route and auth check)
- `apps/mobile/test/features/auth/domain/auth_session_test.dart`
- `apps/mobile/test/features/auth/data/auth_repository_test.dart`
- `apps/mobile/test/features/auth/presentation/auth_view_model_test.dart`
- `apps/mobile/test/features/auth/presentation/auth_view_test.dart`
- `backend/app/api/v1/endpoints/auth.py` (Mock login/logout FastAPI endpoints)

### LOCKED Files (Strict Anti-Touch)
- `apps/mobile/lib/features/discovery/*` (Do NOT touch discovery logic)
- `apps/mobile/lib/features/matching/*`
- `apps/mobile/lib/features/chat/*`

---

## 3. In-Scope vs. Explicit Anti-Scope

### In-Scope (Strict Requirements)
- Email & password text fields with basic email format and password length validation ($\ge 6$ chars).
- Mock Google & Apple social sign-in button placeholders (trigger mock login).
- Password visibility toggle (eye icon).
- Loading spinner on submit button during `authenticating` state.
- Error message banner when credentials fail (e.g. invalid password simulation).
- Session token saved to `LocalStorage` on login, cleared on logout.
- Responsive layout: Centered card with max width `420px` on desktop, full width on mobile.

### Anti-Scope (Strictly Forbidden)
- **NO real Firebase Auth / Supabase Auth SDK integration**.
- **NO real OAuth redirect flows or browser callbacks**.
- **NO phone SMS OTP verification**.
- **NO biometric (FaceID/Fingerprint) hardware access**.

---

## 4. Finite State Machine (FSM) Matrix

| State (`AuthStatus`) | Trigger | UI Representation | Actions Available |
|---|---|---|---|
| `unauthenticated` | Default / Logged out | Clean login/signup form | Fill inputs, submit login, toggle sign up |
| `authenticating` | Submit tapped | Disabled form + spinner on button | Cancel / wait |
| `authenticated` | Success returned | Redirect to `/discovery` or home | Logout |
| `error` | Repo throws failure | Form re-enabled + red error banner | Edit inputs, retry submit |

---

## 5. Acceptance Criteria (Gherkin Format)

### Scenario 1: Successful Login
```gherkin
Given the user is on the AuthView
When the user enters email "alex@example.com" and password "password123"
And the user taps "Sign In"
Then state.status must transition to AuthStatus.authenticating
And upon mock repo success, state.status must be AuthStatus.authenticated
And state.session must contain a non-empty token and userId
And localStorage must contain key "auth_token"
```

### Scenario 2: Validation Failure
```gherkin
Given the user enters an invalid email "not-an-email"
When the user taps "Sign In"
Then form validation must fail without calling AuthRepository.login
And error text "Please enter a valid email address" must be displayed
```

### Scenario 3: Login Error Handling
```gherkin
Given the AuthRepository is configured to reject credentials
When the user submits validly formatted credentials
Then state.status must transition to AuthStatus.error
And an error message "Invalid email or password" must be displayed
And the submit button must be re-enabled
```

---

## 6. Step-by-Step Implementation Sequence

1. **Domain**: Create `AuthSession` entity (`userId`, `token`, `expiresAt`) with equality and `fromJson`/`toJson`.
2. **Data**: Create `AuthRepository` abstract class (`login`, `register`, `logout`, `getCurrentSession`) and `MockAuthRepository`.
3. **State & VM**: Create `AuthState` with explicit `AuthStatus` enum and `AuthViewModel` (`StateNotifier<AuthState>`).
4. **Presentation**: Build `AuthView` with responsive form (mobile full width, desktop centered box `420px`).
5. **Backend Companion**: Add mock `POST /api/v1/auth/login` and `POST /api/v1/auth/logout` in `backend/app/api/v1/endpoints/auth.py`.
6. **Tests**: Implement unit tests for session, repository, and view model, plus widget test for form rendering.

---

## 7. Technical Implementation Contract

- **Boundary:** `AuthView` dispatches to `AuthViewModel`; only the repository handles session persistence.
- **Serialization:** `AuthSession` owns `userId`, `token`, and `expiresAt` conversion; the storage key is `auth_token`.
- **Failure behavior:** invalid credentials and network failures remain typed, visible, and retryable; logout must not claim success if storage cleanup fails.
- **Test matrix:** session equality/JSON, repository success/failure, ViewModel transitions, validation, route behavior, and responsive form rendering.

## 8. Verification Commands

```bash
# Frontend checks
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test test/features/auth/

# Backend checks
cd backend
uv run pytest tests/test_health.py
```
