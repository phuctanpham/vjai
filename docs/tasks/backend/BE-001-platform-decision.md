# BE-001: Backend platform decision

> **Owner:** Backend Developer + Engineering Manager  
> **Status:** Acknowledged · on the product owner's agenda, to be decided before spec phase P3 starts. Does not block P1 or P2.  
> **Raised by:** Mobile Phase 1 analysis ([CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md))

**Review note (2026-10-29):** the spec chose a MongoDB replica set + PowerSync
(T4), so the FastAPI mock decision (D-004) has to change. The questions below
remain for the decision record.

## Conflict

| Source | Says |
|---|---|
| [decisions.md](../../policies/engineering/decisions.md) D-004, [architecture.md](../../policies/engineering/architecture.md) §4 | Backend is a deterministic **FastAPI mock**. Databases, real auth and cloud deployment are out of bounds |
| Spec T3/T4 (DB1–DB4) | MongoDB replica set, PowerSync Service with Sync Streams, anonymous JWT + Google link, object storage, write handler `POST /v1/sync/tx` |
| Spec T6 | P3 needs MongoDB + PowerSync (download-only); P4 needs the full write path and services |

Both cannot be true. Mobile Phase 1 does not depend on the answer; P3 does.

## Decision required

1. Does the FastAPI mock remain the backend, and if so, does it grow into the
   spec's write handler and services (P4), or is it replaced?
2. Is PowerSync approved as a Flutter dependency (`powersync` Dart package,
   spec DB3)? It needs a `decisions.md` entry.
3. Which wire format do the mobile repositories target: the spec's REST + SSE
   contracts (T2 › API surface) or PowerSync tables (T4 › Phone schema)?

## Deliverable

A `decisions.md` entry (D-006 or later) and an updated
[architecture.md](../../policies/engineering/architecture.md) §4. Then
BE-002…BE-004 can move to `Ready`.

## Anti-scope

No infrastructure, database or service is built under this card.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created from the Phase 1 conflict analysis. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Acknowledged in review: D-004 must change; decide before P3. |
