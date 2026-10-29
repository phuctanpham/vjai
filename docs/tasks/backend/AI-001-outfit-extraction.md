# AI-001: Outfit extraction models

> **Owner:** AI Engineer (+ Backend for the worker)  
> **Status:** Blocked by [BE-002](BE-002-studio-pipeline.md) and spike SP-2  
> **Spec phase:** P5 (P5-A01, P5-A02, P5-B01)  
> **Source:** UC-02 · UC-03 · TAC-02.1, 02.2, 02.4, 02.7 · T4 (item_embeddings, item_vectors)

## Why

Phase 1 returns fixture items per preset photo. P4 replaces that with a stub
worker behind the real job pipeline (BE-002). This card replaces the stub with
real models while keeping the `ExtractedItem` contract unchanged.

## Must produce (per photo)

0..n `ExtractedItem`s (C2) with `name`, `typeCode` from the item-type catalog
(BE-003), `color`, `material`, `styleTag`, calibrated `confidence` in 0..1, a
background-removed cutout, and a 512-d embedding plus a compact int8 × 128
copy. Pose and scene models run only when checked and end as
`SKIPPED_NO_PERSON` when no person is found (AC-02.7).

Found while building Phase 1 (TASK-003):

- **Piece names** ("Violet shirt", "Cream sneakers") come from fixtures in
  Phase 1. The real pipeline must produce `name`, from the extractor
  (colour + type label) or from LLM naming (AI-003).
- **Type codes** must be one of the Phase 1 catalog codes
  (`ItemTypeCatalog` in `lib/features/wardrobe/domain/item_type.dart`) or a
  code added to the catalog first (BE-003). An unknown code is rejected on
  the phone.
- **Low confidence.** The review shows every Piece's confidence. The
  "▲ CHECK · 72% CONFIDENCE" pill below the review threshold (T7 › G3 4a) is
  not built in Phase 1; it needs the calibrated threshold from this card.
- **Pose and Background** produce no output in Phase 1. The checkboxes exist
  (default off), but no job runs.

## Acceptance

- ≤ 8 s per photo p95; ≤ 30 s for 10 photos (TAC-02.1).
- Pose/scene never called when unchecked (TAC-02.2).
- Workers read only the sanitized store; model calls carry no user ID (TAC-02.7).
- Confidence is calibrated on an agreed evaluation set; the review threshold
  (placeholder 0.80) is confirmed.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Created; Phase 1 uses fixture extraction. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | From TASK-003 green: Piece names, catalog type codes, low-confidence pill, Pose/Background in Phase 1. |
