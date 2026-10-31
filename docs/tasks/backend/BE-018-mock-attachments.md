# BE-018: Mock attachments — tickets, in-memory file store, upload verification

> **Owner:** Backend Developer  
> **Status:** Draft · needs [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) approval  
> **Track / priority:** M · **10**  
> **Blocked by:** [BE-012](BE-012-mock-write-handler.md), [BE-013](BE-013-mock-change-feed.md)  
> **Source:** Flow Spec v2.8 T4 › DB6, R9, Side effects (attachments) · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §6 FL-01…FL-05 · UC-01 TAC-01.3, I2, I3, I5 · mock of [BE-008](BE-008-rustfs-tickets-and-verify.md)

## Why

Photo bytes never go through sync. The phone inserts an `attachments` row, the
server answers with a short-lived PUT ticket, the phone uploads the bytes to that
URL, and the server checks the file. The mock replaces RustFS with process memory,
so the mobile attachment queue (P4-M03) and the server's EXIF re-check can be
tested without object storage.

## Behaviour

| Step | Mock |
|---|---|
| Phone PUTs `attachments` (`kind` PHOTO or BODY, `mime_type`, `bytes`, `sha256`, `state=PENDING_UPLOAD`) | Write an `attachment_tickets` row: `op=PUT`, `url=<base>/v1/mock/files/<ticket>`, `expires_at` = mock now + 15 min |
| `PUT /v1/mock/files/<ticket>` with the raw body (`Content-Type: image/jpeg` or `image/png`) | Store the bytes in memory under `users/<user_id>/<attachment_id>`. An expired, foreign or GET ticket → 403. No multipart and no `python-multipart`: the body is read as raw bytes |
| Phone PATCHes `attachments.state=UPLOADED` | Verify: size and SHA-256 match the row; magic bytes are JPEG or PNG (I2); for JPEG, no APP1 Exif or XMP segment; for PNG, no `eXIf` chunk (I3, TAC-01.3) → `VERIFIED`, else `REJECTED` and delete the bytes |
| A GET ticket is needed (e.g. a cutout) | `op=GET` ticket valid 1 h; `GET /v1/mock/files/<ticket>` returns the bytes |
| Fake extraction (BE-014) | Uses the verified bytes for `stable_hash(content)`, so the server picks the same sample set as the phone (CHG-014 Q3) |

Ticket IDs are `deterministic_object_id([attachment_id, op, expires_at])`; the mock
clock makes expiry testable without waiting.

## Scenarios

| ID | Scenario | Test file |
|---|---|---|
| BE-018-S01 | Attachment PUT → one PUT ticket in the owner's `my_files` feed, expiring in 15 min | `tests/test_attachments.py` |
| BE-018-S02 | Upload with the ticket, PATCH UPLOADED → `VERIFIED` for a stripped JPEG and a PNG fixture | `tests/test_attachments.py` |
| BE-018-S03 | A JPEG with EXIF/GPS, a HEIC file, or a hash mismatch → `REJECTED`, bytes deleted | `tests/test_attachments.py` |
| BE-018-S04 | An expired ticket (clock + 16 min) or another owner's ticket → 403 | `tests/test_attachments.py` |
| BE-018-S05 | The verified bytes drive the fake extractor: same sample set as the Dart `stableHash` for the golden image | `tests/test_attachments.py` |
| BE-018-S06 | Erasure ALL (BE-017) leaves no bytes under `users/<user_id>/` | `tests/test_attachments.py` |

Fixtures: reuse the phone's image fixtures (`apps/mobile/test/helpers/image_fixtures.dart`)
through [TASK-012](../mobile/TASK-012-shared-golden-fixtures.md), so both sides strip and verify the same bytes.

## Allowed files

`backend/app/files/` (store, verifier, tickets), `backend/app/api/v1/endpoints/mock_files.py`,
`backend/app/sync/effects.py` (registration), `backend/tests/test_attachments.py`,
`backend/tests/fixtures/images/`, report.

## Anti-scope

No real S3 or RustFS, no multipart or resumable uploads (P4-M03 on the real
store), no bystander blur (AI-004), no image decoding library.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created |
