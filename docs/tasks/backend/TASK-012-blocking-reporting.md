# TASK-012: Blocking & Content Reporting

> **Phase:** 5 — Safety and engagement  
> **Status:** Planned  
> **Target:** `apps/mobile/lib/features/moderation/`, `backend/app/api/v1/endpoints/`  
> **Dependency:** TASK-007

## Objective

Allow a user to block a profile or submit a structured mock report from Discovery, Matching, or Chat entry points.

## Allowed files

- `apps/mobile/lib/features/moderation/`
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

## Technical implementation contract

- **Boundary:** moderation owns report/block contracts; feature widgets use callbacks or ViewModel actions rather than repository calls.
- **Serialization:** report requests carry a canonical reason enum, target profile ID, and optional detail with bounded length.
- **Failure behavior:** failed block/report submissions preserve the user’s context and show retryable feedback.
- **Test matrix:** request validation, confirmation flow, repository success/failure, blocked filtering, and endpoint responses.

## Verification

Run format, `flutter analyze`, focused Flutter moderation tests, and backend pytest.
