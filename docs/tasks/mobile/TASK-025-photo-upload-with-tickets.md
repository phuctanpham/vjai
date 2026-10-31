# TASK-025: Photo upload with tickets; Analyze queued offline

> **Phase:** P4 · P4-M03  
> **Track:** M (BE-018 in-memory files, mock PUT tickets, EXIF verify) → R (RustFS presigned PUT, multipart, BE-008 verify worker)  
> **Status:** Draft · needs CHG-015 approval, the ST-06 offline copy confirmed (DOC-004 Q8) and an implementation plan  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Dependencies:** [TASK-021](TASK-021-attachment-downloads.md) (`attachments` rows, cache), [TASK-024](TASK-024-rejections-and-retries.md), [TASK-018](TASK-018-flows-on-server-fakes.md)  
> **Source:** Flow Spec v2.8 UC-01 TAC-01.3…01.6, UC-02 TAC-02.6 · DB handbook §5 ST-02, ST-03, ST-06, §6 FL-01…FL-06

## Why

Analysis waits until every photo is VERIFIED (ST-03), and the server only sees sanitized bytes
(I3, I5). The phone already strips metadata (TASK-007). It now has to upload those exact bytes
with a ticket from sync, survive network drops, and let Analyze be tapped offline.

## Scope

- Upload worker in `core/storage/`. When a PUT ticket arrives for a PENDING_UPLOAD attachment,
  upload the bytes, then PATCH `attachments.state = UPLOADED` (with `bytes`, `sha256`). The
  server sets VERIFIED or REJECTED. Expired tickets wait for a renewed one. Backoff: 5 tries
  (FL-04). Multipart above 5 MB is Track R only.
- Analyze offline. The batch PATCH to QUEUED_FOR_AI is queued, and the Studio shows the ST-06
  line "OFFLINE · ANALYSIS STARTS WHEN ONLINE" (copy owned by the APM).
- A REJECTED attachment (EXIF found by the server) marks that photo failed in the tray, with the
  existing "couldn't be protected" copy. It is never retried with the same bytes.
- The raw original is never read again after sanitizing; only stored bytes are uploaded.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-025-S01 | A PUT ticket from the feed uploads the stored bytes exactly (hash equal), then queues PATCH UPLOADED | Unit (`MockClient`) |
| TASK-025-S02 | Network drop mid-upload: retried with backoff; after a restart the upload resumes from the queue | Integration |
| TASK-025-S03 | Server REJECTED (fixture with EXIF): the tray marks the photo failed; Analyze stays enabled for the rest if 1–10 remain (I1) | Widget + integration |
| TASK-025-S04 | Analyze offline shows the offline status line; going online runs analysis with no second tap | Journey (both layouts) |
| TASK-025-S05 | No upload body ever contains GPS, XMP or PNG text chunks (checks the bytes sent, using TASK-007 fixtures) | Integration |
| TASK-025-S06 | Track R: multipart upload of a > 5 MB fixture to RustFS dev, tagged `live_backend` | Integration |

## Anti-scope

No body photos (TASK-030). No on-device blur (TASK-029). No push "results ready" (BE-009).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
