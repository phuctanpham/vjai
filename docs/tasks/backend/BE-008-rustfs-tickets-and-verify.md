# BE-008: RustFS buckets, ticket issuer and verify worker

> **Owner:** Backend Developer + DevOps  
> **Status:** Blocked by [BE-001](BE-001-platform-decision.md) and spike SP-R1  
> **Track:** R (real) · spec P4-B04, P4-B06 · mock predecessor [BE-018](BE-018-mock-attachments.md)  
> **Source:** Flow Spec v2.8 T4 › DB6, R9 · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §3 D07, §6 FL-01…FL-10 (the handbook already cites this ID for FL-03, FL-06, FL-08, FL-09 and C05-03)

## Why

BE-018 fixes the ticket and verification behaviour in memory. This card moves it to
RustFS without changing what the phone sees: the same `attachments` states, the
same `attachment_tickets` rows, the same rejection rules.

## Scope

- Buckets `sanitized`, `body` (own encryption key, readable only by the try-on
  worker role), `renders`, `posters`, `exports` (7-day lifecycle), `editorial`;
  keys `users/{user_id}/…`; versioning off for personal buckets (FL-07, FL-08).
- Ticket issuer: presigned SigV4 PUT (15 min) and GET (1 h; body renders 10 min),
  renewed before expiry (FL-02, FL-03).
- Verify worker: size, SHA-256, no EXIF/GPS/maker notes; VERIFIED or REJECTED and
  delete (FL-05, TAC-01.3). Reuses BE-018's verifier unchanged.
- Orphan sweep: objects with no VERIFIED attachment removed after 24 h (FL-06).
- Contract: BE-018's tests run against a RustFS-backed `FileStore` in an
  integration job.

## Anti-scope

No CDN, no public personal file (FL-09). No multipart client logic on the phone (P4-M03).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created for the ID the DB handbook already cites; real counterpart of BE-018 |
