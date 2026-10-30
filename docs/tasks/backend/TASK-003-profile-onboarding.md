# TASK-003: Profile Onboarding Wizard (Vertical Slice)

> **Sprint**: Phase 2 (Identity & Onboarding)  
> **Status**: Ready for Agent Execution  
> **Target Bounded Context**: `apps/mobile/lib/features/onboarding/`  
> **Dependencies**: TASK-002 (Auth Session)  
> **Estimated Agent Prompts**: 1 bounded session  

---

## 1. Context & Objective
Build an interactive multi-step profile onboarding wizard that guides the user through setting up their initial profile: basic information (name, age, occupation), bio, interest tags selection, and photo selection preview. The finished profile is persisted to mock storage and redirected into the Discovery feed.

---

## 2. File Confinement

### Files to CREATE or MODIFY
- `apps/mobile/lib/features/onboarding/domain/onboarding_step.dart` (Step enum: basicInfo, interests, bio, photos)
- `apps/mobile/lib/features/onboarding/domain/onboarding_draft.dart` (Draft model holding incomplete fields)
- `apps/mobile/lib/features/onboarding/data/onboarding_repository.dart` (Submit draft profile contract & mock)
- `apps/mobile/lib/features/onboarding/presentation/onboarding_state.dart` (Step tracker, draft, validation status)
- `apps/mobile/lib/features/onboarding/presentation/onboarding_view_model.dart` (Step navigation & draft field setters)
- `apps/mobile/lib/features/onboarding/presentation/onboarding_view.dart` (Progress indicator + multi-step page container)
- `apps/mobile/lib/features/onboarding/presentation/steps/basic_info_step.dart`
- `apps/mobile/lib/features/onboarding/presentation/steps/interests_step.dart` (Selectable interest chips)
- `apps/mobile/lib/features/onboarding/presentation/steps/bio_photo_step.dart`
- `apps/mobile/test/features/onboarding/presentation/onboarding_view_model_test.dart`
- `apps/mobile/test/features/onboarding/presentation/onboarding_view_test.dart`

### LOCKED Files (Strict Anti-Touch)
- `apps/mobile/lib/features/discovery/*` (Do NOT touch discovery feed)
- `apps/mobile/lib/features/matching/*`
- `apps/mobile/lib/features/chat/*`

---

## 3. In-Scope vs. Explicit Anti-Scope

### In-Scope (Strict Requirements)
- Linear multi-step flow with top linear progress indicator (Step 1/3, 2/3, 3/3).
- Step 1 (Basic Info): Name, Age (must be $\ge 18$), Occupation inputs.
- Step 2 (Interests): Grid/wrap of selectable chips (e.g. Coding, Photography, Hiking, Coffee, Music, Art, Travel, Fitness); user must select at least 2.
- Step 3 (Bio & Photo Preview): Bio text area (up to 300 characters with character counter) and preset avatar / placeholder image selector.
- Back and Next navigation buttons with validation disabling "Next" until step criteria are met.
- Final step completes by converting `OnboardingDraft` to a `Profile` entity and saving.
- Responsive container: Max width `560px` centered on desktop screens, full screen on mobile devices.

### Anti-Scope (Strictly Forbidden)
- **NO native camera hardware access or file picker plugins** (use preset sample avatar URLs or icon placeholders).
- **NO image compression or cropping libraries**.
- **NO cloud file upload to AWS S3 or Cloudinary**.

---

## 4. Finite State Machine (FSM) Matrix

| State | Current Step | Condition | Next Action |
|---|---|---|---|
| `editingStep1` | Basic Info | Inputs valid (name $\ge 2$ chars, age $\ge 18$) | Enable "Continue" $\rightarrow$ step 2 |
| `editingStep2` | Interests | $\ge 2$ chips selected | Enable "Continue" $\rightarrow$ step 3 |
| `editingStep3` | Bio & Avatar | Bio $\ge 10$ chars | Enable "Finish Profile" |
| `submitting` | Finalizing | Async repo call executing | Show loading overlay |
| `completed` | Done | Success | Route to `/discovery` |

---

## 5. Acceptance Criteria (Gherkin Format)

### Scenario 1: Step 1 Validation Gate
```gherkin
Given the user is on Step 1 of onboarding
When the user enters age "16"
Then the "Continue" button must be disabled
And a warning "Must be at least 18 years old" must appear
When the user changes age to "24" and enters name "Jordan"
Then the "Continue" button must become enabled
```

### Scenario 2: Selecting Interests
```gherkin
Given the user is on Step 2 (Interests)
When the user taps chips "Coding" and "Photography"
Then selectedInterests count must equal 2
And the "Continue" button must become active
```

### Scenario 3: Onboarding Completion
```gherkin
Given the user has completed all 3 steps
When the user taps "Finish Profile"
Then state.isSubmitting must be true
And upon repository completion, navigator must route to "/discovery"
```

---

## 6. Technical Implementation Contract

- **Boundary:** step widgets emit field intent; `OnboardingViewModel` owns validation and draft transitions; the repository owns persistence.
- **Serialization:** the final draft converts to the canonical `Profile` entity without introducing a duplicate profile model.
- **Failure behavior:** submission errors remain in an explicit error state and preserve the draft for retry.
- **Test matrix:** draft validation, step transitions, completion conversion, repository failure, widget button enablement, and desktop/mobile constraints.

## 7. Verification Commands

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test test/features/onboarding/
```
