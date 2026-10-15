# TASK-012: Blocking & Content Reporting

> **Phase:** 5 — Safety and engagement  
> **Status:** Planned  
> **Target:** `lib/features/moderation/`, `backend/app/api/v1/endpoints/`  
> **Dependency:** TASK-007

## Objective

Allow a user to block a profile or submit a structured mock report from Discovery, Matching, or Chat entry points.

## Allowed files

- `lib/features/moderation/`
- Explicit integration files in feature presentation layers.
- `backend/app/api/v1/endpoints/moderation.py`
- `backend/tests/test_moderation.py`

## Locked files

Authentication, onboarding, networking contracts, and unrelated domain models.

## In scope

- Report reason enum and request model.
- Mock moderation repository.
- Confirmation dialog and validation.
- Blocked-profile filtering through a repository boundary.
- Success and error feedback.

## Anti-scope

No automated moderation, legal/compliance workflow, identity verification, appeals system, or permanent production enforcement.

## Acceptance criteria

- A report requires a valid reason.
- Confirmed blocks hide the profile from subsequent mock queries.
- Failed submission displays an error and allows retry.
- Destructive actions require confirmation.

## Verification

Run format, `flutter analyze`, focused Flutter moderation tests, and backend pytest.
