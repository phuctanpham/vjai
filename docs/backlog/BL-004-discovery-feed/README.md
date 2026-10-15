# BL-004: Discovery feed and adaptive layout

| Status | Depends on | Feature area |
|---|---|---|
| Done | BL-001 (app shell) | `lib/features/discovery/` |

## Goal
On mobile and desktop, users browse candidate profiles and record a swipe (`like`, `pass`, `superlike`) with immediate feedback.

## Scope
- `Profile` and `SwipeType` domain types; `DiscoveryRepository` with a configurable mock (delay, failure, empty).
- `DiscoveryViewModel` with `initial`, `loading`, `loaded`, `empty`, `error`; retry on error and refresh on empty.
- Mobile layout: full-bleed card, bottom actions. Desktop layout: sidebar, centred card, profile detail panel.

## Anti-scope
- Real database, WebSockets, push notifications, authentication gates, geolocation, paywalls.

## Documents
- Behaviour: [product/uat.feature](product/uat.feature)
- Plan: [engineering/implementation-plan.md](engineering/implementation-plan.md) · [engineering/test-plan.md](engineering/test-plan.md)

## Product acceptance
Accepted before this system existed. Re-check after [CHG-002](../../changes/CHG-002-restore-green-build.md) adds scenario IDs to the tests.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Migrated from APRD-001 |
