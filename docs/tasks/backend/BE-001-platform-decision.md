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

Whatever is decided, the current FastAPI code is the **retired dating mock**
(`/api/v1/discovery`, `/api/v1/swipes`, `/api/v1/matches`, `/api/v1/chat`,
`Profile` models). It is not a starting point for the wardrobe API; retiring
it is [BE-005](BE-005-retire-dating-mock-api.md).

## Decision required

1. Does the FastAPI mock remain the backend, and if so, does it grow into the
   spec's write handler and services (P4), or is it replaced?
2. Is PowerSync approved as a Flutter dependency (`powersync` Dart package,
   spec DB3)? It needs a `decisions.md` entry.
3. Which wire format do the mobile repositories target: the spec's REST + SSE
   contracts (T2 › API surface) or PowerSync tables (T4 › Phone schema)?

The decision must also approve the minimum security contract from
[CHG-011](../../changes/CHG-011-power-sync-security-baseline.md):

4. Will the auth service issue asymmetric JWTs and publish a JWKS with an
   explicit algorithm and `kid` rotation policy?
5. How do PowerSync streams and `POST /v1/sync/tx` enforce
   `JWT.sub == user_id`, client-field allow-lists, replay protection and
   append-only rules?
6. Which TLS termination, probe network allow-list, secret storage and
   attachment URL expiry/ownership controls are part of the deployment?
7. If certificate pinning is selected, where are backup pins, rotation,
   emergency recovery and Android/iOS/Windows/macOS coverage documented?

Raised by the mock track ([CHG-014](../../changes/CHG-014-mock-first-backend-track.md)):

8. **Idempotency key of `POST /v1/sync/tx`.** T4 keys `applied_tx` by `tx_id`, but
   the PowerSync SDK's transaction ID is believed to be a local counter per
   database, so two installs or a reinstall can repeat it (to confirm in the spike).
   The mock keys on `(sub, tx_id)` plus an ops hash and returns 409 `TX_ID_REUSED`
   on a mismatch ([BE-012](BE-012-mock-write-handler.md)). Pick the real key.
9. Do side-effect workers run in-process behind the effects registry
   ([BE-020](BE-020-write-handler-on-mongodb.md)) or behind a queue? A queue is a new
   dependency and needs its own entry.
10. Does the in-memory `Store` stay as the contract-test double for the real store
    (proposed: yes, as Mock/Local do on the phone)?

## Deliverable

A `decisions.md` entry (number assigned by the ASEM; the DB handbook already cites
D-010, D-011 and D-013, so check they are free) and an updated
[architecture.md](../../policies/engineering/architecture.md) §4. Then the Track R
cards (BE-002…BE-004, BE-006…BE-009, BE-019, BE-020) can move to `Ready`.

**No longer blocks mobile integration.** The mock track (BE-010…BE-018, AI-005,
AI-006) mocks the v2.8 contract inside D-004's rules and can start once CHG-014 is
approved. This decision now gates only the real platform.

## Anti-scope

No infrastructure, database or service is built under this card.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created from the Phase 1 conflict analysis. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Acknowledged in review: D-004 must change; decide before P3. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | The current FastAPI code is the retired dating mock; retirement is BE-005. |
| 2026-10-30 | [CHG-011](../../changes/CHG-011-power-sync-security-baseline.md) | Added security acceptance questions for the P3/P4 platform decision. |
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Questions 8–10 from the mock track; D-number collision note; no longer blocks mobile integration. |
