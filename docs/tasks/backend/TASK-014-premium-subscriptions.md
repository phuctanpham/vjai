# TASK-014: Premium Subscriptions & Paywall

> **Phase:** 6 — Commercialization  
> **Status:** Planned  
> **Target:** `lib/features/profile/`  
> **Dependency:** TASK-008

## Objective

Model subscription status and display a mock premium feature explanation without processing payments.

## Allowed files

- `lib/features/profile/`
- `lib/features/subscriptions/`
- `test/features/profile/`
- `test/features/subscriptions/`

## Locked files

Discovery, authentication, onboarding, chat, and backend payment infrastructure.

## In scope

- Subscription plan/status domain types.
- Mock repository and explicit loading/error states.
- Read-only paywall and upgrade explanation.
- Accessible feature comparison and dismissal behavior.

## Anti-scope

No payment SDK, billing account, transaction handling, receipt validation, or production entitlement enforcement.

## Acceptance criteria

- Current plan is displayed from the mock repository.
- Locked feature interaction opens a clear paywall.
- Errors are explicit and retryable.
- No payment credentials or secrets are introduced.

## Technical implementation contract

- **Boundary:** the paywall is a presentation of repository-provided entitlement state; it must not call a billing SDK.
- **Serialization:** subscription status uses typed plan and entitlement values, not arbitrary booleans scattered through widgets.
- **Failure behavior:** plan-loading failures are explicit; upgrade actions remain mock-only and never imply a completed payment.
- **Test matrix:** plan decoding, loading/error states, locked-feature interaction, dismissal, semantics, and responsive layout.

## Verification

Run format, `flutter analyze`, and focused profile/subscription tests.
