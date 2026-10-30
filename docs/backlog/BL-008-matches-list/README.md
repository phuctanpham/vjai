# BL-008: Matches and connections view

| Status | Depends on | Feature area |
|---|---|---|
| Ready to code | BL-007 | `apps/mobile/lib/features/matching/presentation/` |

## Goal
Users see their matches in one screen: a "New Matches" carousel, a list of connections, and a name search.

## Scope
- A `/matches` screen with `loading`, `loaded`, `empty` and `error` states.
- A "New Matches" horizontal carousel of avatar bubbles.
- A list of matches showing avatar, name, "Matched … ago" and an unread dot.
- Case-insensitive search by name that filters as the user types.
- The desktop sidebar's "Matches" item and a mobile entry point open the screen.

## Anti-scope
- Real-time messaging (tapping a match opens the BL-007 conversation placeholder).
- Voice or video calls, blocking or reporting (BL-012), pagination, remote search.

## Documents
- Behaviour: [product/uat.feature](product/uat.feature) · [product/information-layout.md](product/information-layout.md)
- Plan: [engineering/implementation-plan.md](engineering/implementation-plan.md) · [engineering/test-plan.md](engineering/test-plan.md)

## Product acceptance
Pending.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Migrated from APRD-008 + TASK-008; loading uses the standard progress indicator (TASK-008 also mentioned shimmer) |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
