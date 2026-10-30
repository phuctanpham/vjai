# TASK-007: Private photo storage and metadata stripping

> **Phase:** 2 · P2 Persistent offline app  
> **Status:** Green on `phase-2/persistence-tdd`, merged with PR 4 ([report](../../reports/TASK-005-008-app-developer.md))  
> **Dependencies:** [TASK-005](TASK-005-local-persistence-foundation.md) · [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md)  
> **Source tasks:** P2-04 · spec UC-01 AC-01.9, I3, I5, TAC-01.2 · R9

## Objective

Real photos from the device reach storage only after their metadata is
stripped on the phone; the original bytes are never written; files live in
app-private storage and are referenced by attachment IDs.

## Scope

- `image_picker` behind `PhotoPicker` (P2-D4); `PickedPhoto` carries the photo
  bytes. The file type is sniffed from the bytes: JPG and PNG are accepted;
  HEIC and anything else show the existing rejected-file notice.
- In-house, lossless metadata stripping (P2-D10), with the orientation read
  first and stored on `media_assets.orientation`:
  - JPEG: remove every APP1 segment (EXIF **and** XMP) and APP13; keep APP0
    and APP2 (ICC).
  - PNG: remove `tEXt`, `zTXt`, `iTXt` and `eXIf`; keep `iCCP`.
  - Reject malformed files, unsupported types and files over 25 MB with a
    `SanitizationFailure`.
- `AttachmentStore` under the app support directory: opaque ObjectId
  attachment IDs, no public paths or URLs.
- Studio storage: staged photos are sanitized, stored and recorded on
  `media_assets`; a photo that fails is not added, and the notice says so.
  Discarding a batch deletes its files and rows.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-007-S01 | A JPG loses every APP1 (EXIF with GPS, and XMP) and APP13, keeps APP0, APP2 (ICC) and the image data, and its orientation is read | Unit |
| TASK-007-S02 | A PNG loses `tEXt`, `zTXt`, `iTXt` and `eXIf`, keeps `iCCP` and the image data | Unit |
| TASK-007-S03 | The original bytes are never written to the attachment store | Boundary |
| TASK-007-S04 | Malformed, unsupported (HEIC) or oversized input fails explicitly | Unit |
| TASK-007-S05 | A photo that fails sanitizing leaves no file and no `media_assets` row | Integration |
| TASK-007-S06 | Attachments are referenced by opaque IDs under app-private storage; IDs cannot escape the store | Boundary |
| TASK-007-S07 | Discarding a batch removes its files and database rows | Integration |

## Test plan

| Scenario | Level | Test file | Test name prefix |
|---|---|---|---|
| S01, S02, S04 | Unit | apps/mobile/test/core/media/photo_sanitizer_test.dart | [TASK-007-S0x] |
| S04 | Unit | apps/mobile/test/core/media/image_mime_test.dart | [TASK-007-S04] |
| S03, S06 | Boundary | apps/mobile/test/core/storage/attachment_store_test.dart | [TASK-007-S03] / [TASK-007-S06] |
| S03, S05, S07 | Integration | apps/mobile/test/features/studio/data/photo_storage_test.dart | [TASK-007-S0x] |

Fixtures are built byte by byte in `apps/mobile/test/helpers/image_fixtures.dart`, with
one fixture per stripping rule.

Device checks: picking from the gallery on Android, iOS, Windows and macOS;
HEIC from an iPhone shows the rejected notice.

## File confinement

- `apps/mobile/lib/core/media/**` (`PickedPhoto` bytes, MIME sniffing, sanitizer,
  `ImagePickerPhotoPicker`)
- `apps/mobile/lib/core/storage/attachment_store.dart`
- `apps/mobile/lib/features/studio/data/**`, `apps/mobile/lib/features/studio/domain/media_asset.dart`,
  `apps/mobile/lib/features/studio/domain/photo_storage.dart`
- `apps/mobile/lib/features/studio/presentation/studio_view_model.dart` (store staged
  photos; failure notice)
- `apps/mobile/test/core/media/**`, `apps/mobile/test/core/storage/**`, `apps/mobile/test/features/studio/data/**`,
  `apps/mobile/test/helpers/image_fixtures.dart`

## Anti-scope

- No bystander blur, pose estimation, duplicate detection, ML or cloud upload
  (AI-004, P5).
- No camera capture and no HEIC conversion.
- No local file paths in logs or analytics.

## Acceptance criteria

- Each stripping rule has its own fixture test.
- Failure paths clean up both files and rows.
- The pipeline stays replaceable by the P3/P4 attachment upload path.
- Flutter verification gates pass.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | — | Created from T6 P2-04 and privacy invariant R9. |
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | image_picker behind PhotoPicker; HEIC rejected; exact JPEG/PNG stripping rules incl. XMP and kept ICC; orientation stored; test plan. |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
