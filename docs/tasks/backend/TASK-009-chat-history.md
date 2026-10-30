# TASK-009: Chat History & Thread UI

> **Phase:** 4 — Messaging  
> **Status:** Planned  
> **Target:** `apps/mobile/lib/features/chat/`  
> **Dependency:** TASK-008

## Objective

Add a read-only mock conversation list and conversation thread UI for an existing `Match`.

## Allowed files

- `apps/mobile/lib/features/chat/domain/`
- `apps/mobile/lib/features/chat/data/`
- `apps/mobile/lib/features/chat/presentation/`
- `apps/mobile/lib/app/router.dart`
- `apps/mobile/test/features/chat/`

## Locked files

`apps/mobile/lib/features/auth/*`, `apps/mobile/lib/features/onboarding/*`, `apps/mobile/lib/features/discovery/*`, and `apps/mobile/lib/features/matching/*`.

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

## Technical implementation contract

- **Boundary:** thread widgets dispatch message intent to a Chat ViewModel; only the repository owns conversation data.
- **Serialization:** use canonical `Conversation` and `Message` entities with stable IDs and timestamps.
- **Failure behavior:** loading, empty, and repository errors are distinct; failed sends do not append a success-shaped message.
- **Test matrix:** entity behavior, chronological ordering, repository states, local send success/failure, retry, and responsive thread rendering.

## Verification

Run format, `flutter analyze`, and `flutter test test/features/chat/`.
