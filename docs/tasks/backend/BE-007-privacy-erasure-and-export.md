# BE-007: Server-side erasure and data export (UC-09)

> **Owner:** Backend Developer  
> **Status:** Blocked by [BE-001](BE-001-platform-decision.md); export also waits for gap ④ (UC-19 "Needs spec")  
> **Spec phase:** P4 (P4-B09 privacy service, P4-M07)  
> **Source:** UC-09 AC-09.4–09.6 · TAC-09.2–09.6 · EN-09.2 · [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md)

## Why

Mobile Phase 2 (TASK-008) deletes the user's data **on the phone only**: it
closes the local database, deletes its files, the attachments folder and the
database key, and reopens a fresh database. Once data syncs (P3+), the same
request must also purge the server, object storage and CDN, and prove it.

## Contract fixed by Phase 2

| Phone behaviour | Server must |
|---|---|
| "Withdraw body-photo consent" sets `consents.revoked_at`; Pieces stay | Delete body-reference photos and try-on renders, cancel queued try-on jobs within 1 minute (TAC-08.4) |
| "Delete all my photos and wardrobe data" wipes the local store; the install owner ID is kept | Delete every collection row and object for that `user_id`; batches become `DELETED_BY_USER`; in-flight jobs are cancelled and their outputs discarded (AC-09.6) |
| Counts are shown before the second tap (AC-09.2) | Provide the same counts for synced data (photos, Pieces, try-on images) |

## Scope

- A `privacy_requests` command row (scope BODY, ALL or EXPORT) through
  `POST /v1/sync/tx`. Spec v2.8 removed `POST /v1/privacy/erasure-requests`.
  Idempotent and resumable (TAC-09.4). The behaviour, including the "phone wipes
  only after the request is acknowledged" ordering (DB handbook LC-04), is defined
  first in the mock, [BE-017](BE-017-fake-privacy-requests.md); this card runs it on
  MongoDB and RustFS (every prefix `users/{user_id}/`, LC-06).
- Hard delete ≤ 24 h (placeholder, legal ceiling 30 days) with an automated
  proof query returning zero rows and objects (TAC-09.2).
- Backups age out in the retention window; restores re-apply the erasure log
  (TAC-09.3).
- Events `erasure_requested{scope}`, `erasure_completed{duration}` with no
  personal data (TAC-09.6).
- Export generation (Download my data) after UC-19 is specified.

## Anti-scope

No account deletion with grace period (S-19.4, needs spec) in this card.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | Created from the Phase 2 local-erasure contract. |
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Erasure endpoint replaced by the `privacy_requests` command row (spec v2.8); mock predecessor BE-017. |
