# APRD-008: Matches & Connections View

> **Status:** Accepted for implementation  
> **Target bounded context:** `apps/mobile/lib/features/matching/`

## 1. Goal

Give users a responsive view of mutual matches and placeholder conversation connections.

## 2. Scope

### In scope

- Explicit loading, loaded, empty, and error state.
- New Matches horizontal carousel.
- Connections list with profile, timestamp teaser, and unread indicator.
- Case-insensitive real-time name filtering.
- `/matches` route.
- Mobile full-width layout and desktop `720px` maximum content width.
- Focused ViewModel and widget tests.

### Anti-scope

- No real-time messaging.
- No voice or video calling.
- No blocking or reporting flow.
- No production pagination or remote search.

## 3. Acceptance criteria

- Zero matches render the canonical empty message and Discovery action.
- Two matches render in both carousel and list.
- Searching “Alex” hides non-matching names.
- Repository failures render ErrorView with retry.

## 4. Verification

Run `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, and `flutter test test/features/matching/`.
