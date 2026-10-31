# TASK-015: Result engine seams for analysis, context and decks

> **Phase:** P3 preparation · refactor of P1–P2 code  
> **Track:** M (no backend needed)  
> **Status:** Draft · needs CHG-015 approval and an implementation plan from the Engineering Manager  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) F-15)  
> **Dependencies:** TASK-013 · **Blocks:** TASK-018, TASK-026, TASK-028  
> **Source:** Flow Spec v2.8 T6 (fakes until the phase that makes them real; P4-B05 "swapping in P5 models changes only the worker") · T4 › Side effects (DB5)

## Why

From P3 the results the user waits for are written by the server and arrive as synced rows:
analysis jobs and drafts, context cards, decks and swap results. Today these fakes are wired
inside the repositories:

- `LocalStudioRepository.analyze` picks fixture items and writes jobs itself.
- `LocalGuMatchRepository` creates a `MockGuMatchRepository` inside its constructor, so the
  Local implementation depends on the Mock one, and context, generation, swaps and wear logging
  all go through it.

To switch to server results without touching ViewModels or tests, each result type needs its
own seam.

## Scope

| Seam (in `features/<f>/domain/`) | `Local*` (today's behaviour, moved) | `Synced*` (TASK-018) |
|---|---|---|
| `AnalysisEngine.request(batch, selection)` + `watch(batchId) → Stream<AnalysisProgress>` | Fixture or hash-chosen sample sets; finishes immediately | Patches the batch to QUEUED_FOR_AI; reads jobs and drafts from synced rows |
| `ContextSource.gather(session) → Stream<ContextCard>` | Fixture cards (`MockGuMatchRepository` copy) | Reads `gu_match_sessions.context` as it is patched |
| `DeckEngine.draft(session) → Stream<DeckProgress>`, `swap(…)` | `FakeCandidateGenerator` | Reads `outfit_candidates`; swap is an ADJUST interaction |

- Repositories take the engines as constructor arguments, picked by providers.
  `LocalGuMatchRepository` no longer creates a `MockGuMatchRepository`.
- Wear logging stays in `WearRepository`: it is phone-owned (`wear_events`).
- `analyze` becomes request-and-watch: the ViewModel shows "Reading photos" until progress says
  done. The Local engine finishes at once, so screens and tests behave as before.
- Engine contract suites in `test/helpers/contracts/` run against every implementation, as the
  repository suites do.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-015-S01 | `LocalAnalysisEngine` returns the same review as Phase 2 for preset URIs, hash-chosen samples and failing photos (CHG-006 G-01 fixtures) | Contract |
| TASK-015-S02 | `LocalContextSource` emits the fixture cards in order; a missing kind is omitted (AC-06.9) | Contract |
| TASK-015-S03 | `LocalDeckEngine` gives the `[fake-generator]` decks unchanged; swap keeps I6 and TAC-08.6 | Contract |
| TASK-015-S04 | No file under `features/*/data/local_*` imports a `Mock*` class (architecture test) | Architecture |
| TASK-015-S05 | Studio and Gu Match ViewModel tests and both journeys pass without a change | Regression |

## File confinement

- `apps/mobile/lib/features/studio/{domain,data}/`, `apps/mobile/lib/features/gu_match/{domain,data}/`
- `apps/mobile/lib/app/bootstrap.dart` (provider wiring)
- `apps/mobile/test/helpers/contracts/` (engine suites), `apps/mobile/test/architecture/`, mirrored tests

## Anti-scope

No synced engines (TASK-018). No change to the fake rules, copy or deck order. No new dependency.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
