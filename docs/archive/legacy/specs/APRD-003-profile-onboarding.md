# APRD-003: Profile Onboarding Wizard

> **Status:** Accepted for implementation  
> **Target bounded context:** `lib/features/onboarding/`

## 1. Goal

Guide an authenticated user through a validated, mock-persisted profile draft and route the completed profile into Discovery.

## 2. Scope

### In scope

- Four domain steps: basic information, interests, bio, and photos.
- Immutable `OnboardingDraft` and `OnboardingStep` models.
- Name, age, occupation, interest, bio, and preset-avatar inputs.
- Validation before advancing between steps.
- Mock repository persistence and completion state.
- Responsive centered desktop container with a `560px` maximum width.

### Anti-scope

- No camera or native file-picker access.
- No image processing, cropping, or compression.
- No cloud uploads.
- No changes to Discovery, Matching, or Chat implementation.

## 3. State and acceptance criteria

| State | Required condition |
|---|---|
| `editingStep1` | Name has at least two characters and age is at least 18 |
| `editingStep2` | At least two interests selected |
| `editingStep3` | Bio has at least ten characters and an avatar is selected |
| `submitting` | Repository save is in progress |
| `completed` | Profile saved and navigation targets `/discovery` |

The Next action is disabled until the current step is valid. Back preserves the draft. Submission failures remain explicit and retryable.

## 4. Verification

Run `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, and `flutter test test/features/onboarding/`.
