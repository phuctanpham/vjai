# TASK-021: Attachment records, GET tickets and the offline file cache

> **Phase:** P3 · P3-06  
> **Track:** M (BE-018 in-memory files and mock tickets) → R (RustFS presigned GET, BE-008)  
> **Status:** Draft · needs CHG-015 approval and an implementation plan from the Engineering Manager  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Dependencies:** [TASK-011](TASK-011-phone-schema-v2-alignment.md) (`attachments`, `attachment_tickets`), [TASK-010](TASK-010-mock-backend-integration.md); backend [BE-018](../backend/BE-018-mock-attachments.md) → [BE-008](../backend/BE-008-rustfs-tickets-and-verify.md)  
> **Source:** Flow Spec v2.8 T4 › R9, DB6 · DB handbook §6 FL-01…FL-04 · T6 › P3-06 ("images cache offline; queued uploads are visible in the pending count")

## Why

Today photos live only in `FileAttachmentStore`, keyed by a local ID, and `media_assets`
references them directly. In P3 the phone also shows files it did not make: seeded cutouts,
editorial images, and the user's own photos from another phone. Bytes never travel in a row. The
phone finds a short-lived GET URL in a synced `attachment_tickets` row and caches the file.

## Scope

- `attachments` rows for every phone photo (kind PHOTO, state PENDING_UPLOAD). The existing
  attachment ID becomes `attachments.id`, so `media_assets.attachment_id` keeps its meaning.
- `AttachmentCache` in `core/storage/`: `bytes(attachmentId)` reads the local file first.
  Otherwise it waits for a GET ticket, downloads through `SyncTransport` (no auth header on
  presigned URLs), verifies `sha256`, and stores the file. A missing or expired ticket shows the
  placeholder (no error, R2), and a renewed ticket retries.
- Uploads stay queued in P3: the PENDING_UPLOAD count joins the pending count (TASK-022).
- The orphan sweep (CHG-009 V-02) also treats `attachments` rows as references.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-021-S01 | A photo picked and sanitized creates one `attachments` row (PHOTO, PENDING_UPLOAD, sha256 of the stored bytes) in the same transaction as its `media_assets` row | Repository |
| TASK-021-S02 | A feed-delivered GET ticket downloads the file once; a second read is served from the cache offline | Unit (`MockClient`) |
| TASK-021-S03 | A sha256 mismatch discards the file and keeps the placeholder | Unit |
| TASK-021-S04 | An expired ticket shows the placeholder; a renewed ticket from the feed loads the image | Unit + widget |
| TASK-021-S05 | Delete all removes cached files and attachment rows | Integration |
| TASK-021-S06 | Track R: the same tests against a RustFS dev bucket with SigV4 presigned GET (SP-R1), tagged `live_backend` | Integration |

## Anti-scope

No PUT upload (TASK-025). No body or render files (TASK-030). No CDN, no public URL (FL-09).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
