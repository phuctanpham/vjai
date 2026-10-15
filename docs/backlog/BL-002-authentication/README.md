# BL-002: Authentication and session

| Status | Depends on | Feature area |
|---|---|---|
| Ready to code | BL-001, CHG-002 | `lib/features/auth/`, `backend/app/api/v1/endpoints/auth.py` |

## Goal
A user can sign in, register, stay signed in across restarts, and sign out, all against a mock. Only signed-in users reach discovery.

## Scope
- Email and password sign-in and registration forms, with validation (valid email format, password ≥ 6 characters) and a password visibility toggle.
- Mock "Continue with Google" and "Continue with Apple" buttons, which sign in through the mock.
- Progress on submit, an error banner on failure, the form re-enabled for retry.
- The session is kept locally and cleared on sign-out. Signed-out users are sent to `/login`.
- Mock backend login and logout endpoints.

## Anti-scope
- Firebase, Supabase or any production identity provider.
- OAuth redirects or browser callbacks.
- SMS/OTP, biometrics, device authentication.
- A real user database or password storage.

## Documents
- Behaviour: [product/uat.feature](product/uat.feature)
- Plan: [engineering/implementation-plan.md](engineering/implementation-plan.md) · [engineering/test-plan.md](engineering/test-plan.md)

## Product acceptance
Pending.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Migrated from APRD-002 + TASK-002 |
