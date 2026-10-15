# BL-006: Backend discovery API integration

| Status | Depends on | Feature area |
|---|---|---|
| Ready to code | BL-005 | `lib/core/networking/`, `lib/features/discovery/data/` |

## Goal
The discovery feed comes from the FastAPI mock server, and the app stays usable when the server is offline.

## Scope
- Load candidates from the backend and send swipes to it.
- Server errors are shown as errors. When the server cannot be reached, the app falls back to sample profiles, and the fallback is observable.
- The server address is configurable, defaulting to localhost.

## Anti-scope
- Dio, Retrofit, GraphQL, gRPC.
- Certificate pinning; production authentication, caching or retry frameworks.
- Changes to discovery presentation code.

## Documents
- Behaviour: [product/uat.feature](product/uat.feature)
- Plan: [engineering/implementation-plan.md](engineering/implementation-plan.md) · [engineering/test-plan.md](engineering/test-plan.md) · [engineering/dataflow.md](engineering/dataflow.md)

## Product acceptance
Pending.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Migrated from APRD-006 + TASK-006 |
