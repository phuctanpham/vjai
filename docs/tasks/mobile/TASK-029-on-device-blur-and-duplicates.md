# TASK-029: On-device bystander blur and duplicate check behind ports

> **Phase:** P5 · P5-M01  
> **Track:** M (deterministic fakes on the phone) → R (P5-A07 models packaged for Flutter)  
> **Status:** Draft · Track M needs CHG-015 approval and a plan. Track R is blocked by SP-1, SP-4 and [AI-004](../backend/AI-004-on-device-blur-and-duplicates.md), plus a decisions.md entry for the ML runtime. The duplicate UI is blocked by gap ② D  
> **Owner:** App Developer · AI Engineer (models)  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Dependencies:** [TASK-011](TASK-011-phone-schema-v2-alignment.md) (`item_embeddings`), TASK-007 sanitizer (shipped)  
> **Source:** Flow Spec v2.8 UC-01 TAC-01.1 · T6 › P5-M01 ("no raw photo leaves the phone"), P5 exit (sanitizing ≤ 1.5 s/photo) · DB handbook C05-04, WD-07

## Why

I3 says no AI job reads a photo with unblurred bystanders, and blurring happens on the phone.
Today `media_assets.bystanders_blurred` is always 0. The pipeline order (strip → blur → store →
upload) has to exist, and be tested, before a model can be dropped in. Duplicate checks compare
against the synced int8 × 128 `item_embeddings`.

## Scope

- `BystanderBlur` port in `core/media/`: `blur(bytes) → BlurResult(bytes, facesFound, blurred)`.
  `NoOpBlur` is today's behaviour; `FixtureBlur` is a test fake that "finds" faces in marked
  fixtures. Runs after metadata stripping, before the bytes are stored. Sets
  `bystanders_blurred` and `contains_person`.
- `DuplicateDetector` port in `features/studio/domain/`: compares a draft's embedding with
  `item_embeddings`. `FakeDuplicateDetector` uses a fixture embedding table. Result shape only;
  the review UI waits for gap ② D.
- Budgets: a `benchmark` test records the blur time per photo on the host. Device numbers go in
  the report.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-029-S01 | Order: strip, then blur, then store; a blur failure stores nothing (same rule as TASK-007-S05) | Unit |
| TASK-029-S02 | A fixture with two faces stores blurred bytes and sets `bystanders_blurred = 1`, `contains_person = 1` | Repository |
| TASK-029-S03 | Withdrawing body consent does **not** delete a photo just because `contains_person = 1` (TASK-011-S05 still holds) | Repository |
| TASK-029-S04 | `FakeDuplicateDetector` flags a draft whose embedding is within the fixture threshold of an owned item, and never one of another owner | Unit |
| TASK-029-S05 | Blur of a 12 MP fixture completes ≤ 1.5 s on the host, tagged `benchmark` | Benchmark |

## Anti-scope

No model files in this card (Track R). No duplicate UI (gap ② D). No server-side blur.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
