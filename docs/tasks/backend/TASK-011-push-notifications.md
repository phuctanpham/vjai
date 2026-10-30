# TASK-011: Push & In-App Notifications

> **Phase:** 5 — Safety and engagement  
> **Status:** Planned  
> **Target:** `lib/features/notifications/`  
> **Dependencies:** TASK-008 and TASK-010

## Objective

Represent notification items and provide an in-app notification center with unread counts.

## Allowed files

- `lib/features/notifications/`
- `lib/app/router.dart`
- `test/features/notifications/`

## Locked files

All existing feature directories except notification integration points explicitly identified during implementation.

## In scope

- Notification entity and repository contract.
- Mock notification store.
- Loading, loaded, empty, and error states.
- Unread badge and mark-as-read action.
- Responsive notification list.

## Anti-scope

No Firebase/APNs/FCM integration, native permission prompts, background services, or notification delivery backend.

## Acceptance criteria

- Unread notifications show a badge.
- Opening an item marks it read in the mock store.
- Empty and error states have clear UI.
- Notifications do not directly access platform APIs.

## Technical implementation contract

- **Boundary:** notification services and storage are hidden behind a repository; widgets consume ViewModel state.
- **Serialization:** notification records require stable IDs, read status, timestamp, and typed category.
- **Failure behavior:** failed read mutations remain visible and do not remove unread state optimistically without confirmation.
- **Test matrix:** repository states, unread count, mark-read success/failure, badge semantics, and responsive list rendering.

## Verification

Run format, `flutter analyze`, and `flutter test test/features/notifications/`.
