# TASK-028: Real-pipeline states on the phone (job progress, partial failure, provenance)

> **Phase:** P5 readiness (the P4 stub worker and P5 models produce the same rows)  
> **Track:** M (AI-005 fakes with latency and outcome scenarios through BE-014) → R (P5-A01, A02 real models)  
> **Status:** Draft · needs CHG-015 approval and an implementation plan; Track R waits for AI-001  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Dependencies:** [TASK-018](TASK-018-flows-on-server-fakes.md); backend [AI-005](../backend/AI-005-model-ports-and-fakes.md), [BE-014](../backend/BE-014-fake-studio-side-effects.md)  
> **Source:** Flow Spec v2.8 UC-02 AC-02.6…02.8, TAC-02.4 · T6 › P5 exit (extraction ≤ 8 s/photo) · DB handbook C11-01…C11-04, ST-05

## Why

Fakes finish at once and always succeed per photo. Real models take seconds per photo, retry,
skip photos with no person, and differ in confidence. The phone must show this honestly from
synced job rows **before** the models exist. Then P5 swaps only the worker (P4-B05), and the
mobile release does not wait for AI.

## Scope

- Per-photo progress from `ai_processing_jobs` (PENDING → PROCESSING → COMPLETED / FAILED /
  SKIPPED_NO_PERSON; FAILED → PENDING retry, max 2).
- Partial results: review opens when the batch is AWAITING_REVIEW. Skipped pose or background
  jobs never block review and are labelled per spec.
- Confidence as the server sends it (calibrated in P5). Low-confidence attributes keep today's
  review highlight.
- Provenance: `ai` vs `value` stays separate (C11-01). The card label shows WARDROBE PHOTO or
  the server's value. The model version is stored, not shown (C11-04).
- Slow-path UX with injected latency (BE-014/AI-005 scenario `SLOW_8S`): a long-running state
  per spec. A "results ready" push is out of scope (BE-009).

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-028-S01 | A 3-photo batch shows each photo's job state as rows sync, in slot order | Widget (recorded feed) |
| TASK-028-S02 | A job that fails once and succeeds on retry ends COMPLETED without an error flash | ViewModel |
| TASK-028-S03 | Pose and background on a photo with no person end SKIPPED_NO_PERSON; review still opens | Journey |
| TASK-028-S04 | Editing an attribute changes `value` only; `ai` is unchanged in the stored row | Repository |
| TASK-028-S05 | With 8 s per photo injected, the screen stays responsive and shows the long-running state | Widget (fake clock) |

## Anti-scope

No model code on the phone. No confidence calibration logic (server). No push.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
