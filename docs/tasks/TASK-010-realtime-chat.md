# TASK-010: Realtime Chat via WebSockets

> **Phase:** 4 — Messaging  
> **Status:** Planned  
> **Target:** `lib/features/chat/`, `backend/app/api/v1/endpoints/chat.py`  
> **Dependency:** TASK-009

## Objective

Add a minimal mock WebSocket transport for live message updates while keeping conversation state behind the repository boundary.

## Allowed files

- `lib/features/chat/data/`
- `lib/features/chat/presentation/`
- `lib/core/networking/`
- `backend/app/api/v1/endpoints/chat.py`
- `test/features/chat/`
- `backend/tests/test_chat.py`

## Locked files

All auth, onboarding, discovery, matching, notification, and moderation feature files.

## In scope

- WebSocket connection lifecycle abstraction.
- Connected, reconnecting, disconnected, and error states.
- Mock server echo/broadcast behavior.
- Explicit cleanup when leaving a conversation.

## Anti-scope

No production broker, message durability, encryption protocol, presence system, typing indicators, or push notifications.

## Acceptance criteria

- A conversation can connect and receive a mock message.
- Disconnects are visible and retryable.
- Leaving the view closes the socket.
- Existing repository contracts remain testable without a server.

## Verification

Run format, `flutter analyze`, focused Flutter chat tests, and `cd backend; uv run pytest`.
