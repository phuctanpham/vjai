# AI-004: On-device bystander blur and duplicate detection

> **Owner:** AI Engineer (+ Mobile for packaging)  
> **Status:** Blocked by spikes SP-1 (blur within 1.5 s/photo) and SP-4 (duplicate threshold)  
> **Spec phase:** P5 (P5-A07, P5-M01)  
> **Source:** UC-01 TAC-01.1, I3, I5 · Gap ② D · [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md)

## Why

Mobile Phase 2 (TASK-007) strips EXIF/GPS/XMP metadata on the phone before a
photo is stored, but does **not** blur bystanders or detect duplicates. The
spec requires both on the phone before anything is analysed or uploaded.

## Plug point fixed by Phase 2

`PhotoSanitizer` in `apps/mobile/lib/core/media/photo_sanitizer.dart` turns picked bytes
into a `SanitizedPhoto` (bytes, MIME type, orientation) and fails explicitly
with `SanitizationFailure`. Blur runs as an extra step **after** metadata
stripping and before `AttachmentStore.save`; it must:

- never write or keep the unblurred bytes (TASK-007-S03 stays green);
- set `media_assets.bystanders_blurred = 1` only when blur actually ran;
- fail explicitly (no "protected" claim) when the model cannot run.

Duplicate detection compares against the compact `item_embeddings`
(int8 × 128, spec R3) and shows a warning in review (S-17.4).

## Acceptance

- Blur ≤ 1.5 s per photo p95 on the mid-range Android reference phone, off the
  UI thread (TAC-01.1).
- No raw photo leaves the phone (traffic capture, TAC-01.2).
- Duplicate threshold tuned on real wardrobes.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | Created; Phase 2 strips metadata only. |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
