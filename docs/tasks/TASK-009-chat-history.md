# TASK-009: Chat History & Thread UI

> **Phase:** 4 — Messaging  
> **Status:** Planned  
> **Target:** `lib/features/chat/`  
> **Dependency:** TASK-008

## Objective

Add a read-only mock conversation list and conversation thread UI for an existing `Match`.

## Allowed files

- `lib/features/chat/domain/`
- `lib/features/chat/data/`
- `lib/features/chat/presentation/`
- `lib/app/router.dart`
- `test/features/chat/`

## Locked files

`lib/features/auth/*`, `lib/features/onboarding/*`, `lib/features/discovery/*`, and `lib/features/matching/*`.

## In scope

- `Conversation` and `Message` domain models.
- Mock repository with loading, loaded, empty, and error paths.
- Conversation list and message bubble layout.
- Empty conversation state and retry.
- Responsive mobile thread and desktop centered thread.

## Anti-scope

No WebSockets, push notifications, read receipts, attachments, voice/video calls, or message delivery guarantees.

## Acceptance criteria

- Selecting a match opens its conversation placeholder.
- Existing messages render in chronological order.
- Empty and error states are explicit and retryable.
- Sending a message updates only the in-memory mock list.

## Verification

Run format, `flutter analyze`, and `flutter test test/features/chat/`.
