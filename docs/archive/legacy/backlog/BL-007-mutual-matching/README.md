# BL-007: Mutual match and celebration

| Status | Depends on | Feature area |
|---|---|---|
| Ready to code | BL-005 | `apps/mobile/lib/features/matching/`, discovery swipe integration |

## Goal
When a like or superlike creates a mutual match, the user sees an "It's a Match!" celebration and can either keep swiping or start a conversation.

## Scope
- `Match` entity (identity, matched profile, creation time) and a matching repository with a deterministic mock rule ([data-schema.md §4](../../policies/engineering/data-schema.md)).
- The discovery swipe outcome carries an explicit match event.
- A responsive celebration dialog with "Send a Message" and "Keep Swiping".
- "Send a Message" opens a conversation placeholder screen.

## Anti-scope
- Confetti or particle packages, audio, push notifications.
- A production matching algorithm or remote match service.
- Real chat (BL-009).

## Documents
- Behaviour: [product/uat.feature](product/uat.feature) · [product/ui-ux.md](product/ui-ux.md)
- Plan: [engineering/implementation-plan.md](engineering/implementation-plan.md) · [engineering/test-plan.md](engineering/test-plan.md) · [engineering/event-stream.md](engineering/event-stream.md)

## Product acceptance
Pending.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Migrated from APRD-007 + TASK-007 |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
