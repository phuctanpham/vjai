# BL-005: Local swipe persistence and feed filtering

| Status | Depends on | Feature area |
|---|---|---|
| Ready to code | BL-004, CHG-002 | `lib/features/discovery/`, `lib/core/storage/` |

## Goal
Profiles the user has already swiped do not reappear after a reload. A reset action restores the full feed for testing.

## Scope
- Persist each swiped profile ID locally.
- Exclude persisted IDs when the feed loads; show the empty state when none remain.
- A "Reset Feed History" action in the discovery app bar that clears the history and reloads.

## Anti-scope
- SQLite, Drift or any database package.
- Remote sync of swipes.
- Undo or rewind.
- Changes to authentication, matching or chat.

## Documents
- Behaviour: [product/uat.feature](product/uat.feature)
- Plan: [engineering/implementation-plan.md](engineering/implementation-plan.md) · [engineering/test-plan.md](engineering/test-plan.md)

## Product acceptance
Pending.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Migrated from APRD-005 + TASK-005 |
