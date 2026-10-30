# BL-007 Implementation Plan

## Generated files
| Role | Path | Change |
|---|---|---|
| App Developer | `apps/mobile/lib/features/matching/domain/match.dart` | `Match { id, profile: Profile, createdAt }`, value equality, JSON |
| App Developer | `apps/mobile/lib/features/matching/data/matching_repository.dart` | `MatchingRepository { recordMatch(Profile), getMatches() }`, mock in-memory store, provider |
| App Developer | `apps/mobile/lib/features/matching/presentation/match_celebration_dialog.dart` | Presentation-only dialog with `onSendMessage` and `onKeepSwiping` callbacks |
| App Developer | `apps/mobile/lib/features/discovery/presentation/discovery_view_model.dart` | Swipe outcome carries a match event |
| App Developer | `apps/mobile/lib/features/discovery/presentation/discovery_view.dart` | Listens to the match event and shows the dialog |
| App Developer | `apps/mobile/lib/features/discovery/data/discovery_repository.dart` | `recordSwipe` returns `SwipeOutcome { matched }` using the mock rule |
| App Developer | `apps/mobile/lib/app/router.dart`, `apps/mobile/lib/features/chat/chat_placeholder.dart` | `/chat` route to a placeholder screen that shows the matched name |
| App Developer | `apps/mobile/test/features/matching/**`, `apps/mobile/test/features/discovery/presentation/discovery_view_model_match_test.dart` | New tests |
| App Developer | `apps/mobile/lib/features/matching/matching_placeholder.dart` | Delete |

**Locked:** auth, onboarding, backend (the `matched` field already exists in `SwipeResponse`).

## Contracts
- **Boundary:** the ViewModel exposes match events (see [event-stream.md](event-stream.md)). The dialog never queries a repository.
- **Data:** `Match` holds the canonical `Profile`; no duplicate profile shape.
- **Failure behaviour:** if `recordMatch` fails, no celebration is shown and the error is visible in discovery state.
- **Deterministic time:** `createdAt` comes from an injectable clock provider so tests can fix it.

## Verification
`dart format --output=none --set-exit-if-changed .` · `flutter analyze` · `flutter test test/features/matching/ test/features/discovery/`

## Engineering acceptance
Pending.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Migrated from TASK-007; added `getMatches()` (needed by BL-008), `/chat` placeholder route, injectable clock |
| 2026-10-30 | [CHG-010](../../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
