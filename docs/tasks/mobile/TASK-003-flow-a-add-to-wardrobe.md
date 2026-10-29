# TASK-003: Flow A — Add photos to wardrobe

> **Phase:** 1 · MVP  
> **Status:** Tests written (red); pending CHG-003 approval for implementation  
> **Dependencies:** [TASK-002](TASK-002-mobile-foundation.md) · [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md)  
> **Source use cases:** UC-01, UC-02, UC-03, UC-04 · spec T2 (enums, state machine, invariants I1, I2, I4, I8, I9) · T6 P1-05, P1-07, P1-08

## Objective

Deliver the wardrobe MVP path from adding photos through human review and
saving structured wardrobe items, ending on the Wardrobe catalog screen, with
fixture data and a deterministic fake analysis.

## Scope

UI strings and sizes follow spec T7 › G3/G4 and G1/G2 (CHG-003 W-11); strings
derived from G4 are listed in CHG-003.

- **1a/2a Index Pieces** (`studio`): "STUDIO / 01", "Index Pieces", dropzone
  "Tap to add photos" · "JPG, PNG · UP TO 10 PER BATCH", staged tray in pick
  order ("3 PHOTOS SELECTED"), × removes one photo, consent card "Private by
  default" with "Process my photos, including body photos if any", gated
  **Analyze with Garblo** (I1, 48 high). Picking goes through `PhotoPicker`
  (`lib/core/media/`), backed in Phase 1 by preset fixture photos. Only
  JPG/PNG, at most 10 per batch (I2), with notices for skipped and
  over-limit files. The EXIF/blur line is CHG-003 Q-01.
- **Consent** recorded with version `v1.0_studio_body_ai` and time from `Clock`;
  reused by later batches (D3).
- **3a "What should Garblo read?"**: read-only photo strip, "Pieces" on by
  default, "Pose"/"Background" off with "ONLY WHEN A PERSON IS IN THE PHOTO",
  **Read photos** disabled when nothing is checked (I4), **Reselect photos** /
  scrim tap rolls back to DRAFT with consent kept.
- **Fake analysis** (`MockStudioRepository`): deterministic fixture items per
  preset photo; 0..n items per photo (C2); outcomes success, partial ("1 photo
  couldn't be read"), all failed, zero items. No automatic retries (A-02).
- **4a Review Pieces**: banner "FROM 3 PHOTOS · 3 PIECES" · "Check before
  indexing", "PIECE 1/3" · "94% CONFIDENCE", fields Type/Colour/Material/
  Style/Last worn, collapsed queue. Type picker grouped by item group; the
  group follows the type (TAC-03.6). `userModified` is true only when a value
  differs from the AI's (TAC-03.5). Last worn per A-01 (no future dates).
- **Save** "Index N Pieces": all N or none (TAC-03.2); failure keeps edits and
  shows Try again; duplicate taps are ignored while saving. Success switches
  to the Archive pillar.
- **5a Archive** (`wardrobe`): "YOUR ARCHIVE", "Archive", "{N} PIECES", chips
  All/Tops/Bottoms/Shoes/Bags/Hats/Accessories (single select), flush grid of
  2 columns below 800 and 3 at or above (T7 › G1), newest first,
  "{Group} · {Style}", "▲ BENCHED · {d} DAYS" at ≥ 30 days (I8), empty and
  empty-group states, **Draft a Fit** FAB → Gu Match pillar. Pages of 20
  (AC-04.7).
- **Rescue rule** (N6, I12) in the shared rules library: a wear is a rescue
  only when the 30+ day gap is measured from a logged wear or the save date,
  never from the estimate. Used by Flow C later; no rewards UI here.
- Seed: 9 fixture wardrobe items including a White T-shirt unworn for 41 days,
  so the demo reaches 12 after saving 3.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-003-S01 | Analyze is enabled only with 1–10 photos and consent; consent stays checked when photos drop to 0 (I1, AC-01.6/01.7) | ViewModel/widget |
| TASK-003-S02 | Removing a photo keeps the order; removing the last one returns to the empty state (AC-01.4/01.5) | Domain/ViewModel |
| TASK-003-S03 | Reselect photos (or dismissing the sheet) returns to DRAFT with tray editable and consent kept (AC-02.5) | ViewModel/widget |
| TASK-003-S04 | Review allows correction before save; type change moves the group; `userModified` only when changed; edits survive switching items (AC-03.4–03.6) | Domain/ViewModel/widget |
| TASK-003-S05 | Save writes zero-to-many wardrobe items atomically and lands on Wardrobe with new items first (AC-03.8, TAC-03.2) | Repository/journey |
| TASK-003-S06 | Save failure preserves the review draft and exposes retry; duplicate saves are blocked (AC-03.9) | ViewModel/widget |
| TASK-003-S07 | Wardrobe shows saved items, total, group chips and filtering without changing the total; empty states (AC-04.1–04.4) | Repository/ViewModel/widget |
| TASK-003-S08 | Studio and Wardrobe import no networking; analysis receives only staged assets (I3/I5 stand-in) | Boundary |
| TASK-003-S09 | Only JPG/PNG are staged, at most 10, with notices for skipped and over-limit files (I2) | Domain/ViewModel |
| TASK-003-S10 | "Pieces" is checked by default; Read photos is disabled when no task is checked (I4, AC-02.3/02.4) | Domain/widget |
| TASK-003-S11 | Analysis outcomes: success → review; partial → the successful Pieces with a note; all failed → Try again/Reselect keeping photos and consent; zero items → message (A-02) | Domain/ViewModel/widget |
| TASK-003-S12 | The batch state machine rejects skipped transitions (TAC-02.5, A-02) | Domain |
| TASK-003-S13 | BENCHED status shows at ≥ 30 days from wear, Last-worn estimate or save date; no future Last-worn dates (I8, AC-03.11, AC-04.5/04.6, A-01) | Domain/ViewModel/widget |
| TASK-003-S14 | An estimated Last worn never earns a rescue: the gap counts from a logged wear or the save date (N6, I12, A-01) | Domain |

## Test plan

| Scenario | Level | Test file | Test name prefix |
|---|---|---|---|
| S01 | ViewModel | test/features/studio/presentation/studio_view_model_test.dart | [TASK-003-S01] |
| S01 | Widget | test/features/studio/presentation/studio_view_test.dart | [TASK-003-S01] |
| S02 | Domain | test/features/studio/domain/photo_tray_test.dart | [TASK-003-S02] |
| S02 | ViewModel | test/features/studio/presentation/studio_view_model_test.dart | [TASK-003-S02] |
| S03 | ViewModel | test/features/studio/presentation/studio_view_model_test.dart | [TASK-003-S03] |
| S03 | Widget | test/features/studio/presentation/studio_view_test.dart | [TASK-003-S03] |
| S04 | Domain | test/features/studio/domain/extracted_item_test.dart | [TASK-003-S04] |
| S04 | ViewModel | test/features/studio/presentation/studio_view_model_test.dart | [TASK-003-S04] |
| S04 | Widget | test/features/studio/presentation/studio_view_test.dart | [TASK-003-S04] |
| S05 | Repository | test/features/wardrobe/data/wardrobe_repository_test.dart | [TASK-003-S05] |
| S05 | ViewModel | test/features/studio/presentation/studio_view_model_test.dart | [TASK-003-S05] |
| S05 | Journey | test/app/flow_a_journey_test.dart | [TASK-003-S05] |
| S06 | ViewModel | test/features/studio/presentation/studio_view_model_test.dart | [TASK-003-S06] |
| S06 | Widget | test/features/studio/presentation/studio_view_test.dart | [TASK-003-S06] |
| S07 | Repository | test/features/wardrobe/data/wardrobe_repository_test.dart | [TASK-003-S07] |
| S07 | ViewModel | test/features/wardrobe/presentation/wardrobe_view_model_test.dart | [TASK-003-S07] |
| S07 | Widget | test/features/wardrobe/presentation/wardrobe_view_test.dart | [TASK-003-S07] |
| S08 | Boundary | test/features/studio/studio_boundary_test.dart | [TASK-003-S08] |
| S08 | Repository | test/features/studio/data/studio_repository_test.dart | [TASK-003-S08] |
| S09 | Domain | test/features/studio/domain/photo_tray_test.dart | [TASK-003-S09] |
| S09 | ViewModel | test/features/studio/presentation/studio_view_model_test.dart | [TASK-003-S09] |
| S10 | Domain | test/features/studio/domain/analysis_selection_test.dart | [TASK-003-S10] |
| S10 | Widget | test/features/studio/presentation/studio_view_test.dart | [TASK-003-S10] |
| S11 | Domain | test/features/studio/domain/review_draft_test.dart | [TASK-003-S11] |
| S11 | Widget | test/features/studio/presentation/studio_view_test.dart | [TASK-003-S11] |
| S11 | Repository | test/features/studio/data/studio_repository_test.dart | [TASK-003-S11] |
| S11 | ViewModel | test/features/studio/presentation/studio_view_model_test.dart | [TASK-003-S11] |
| S12 | Domain | test/features/studio/domain/batch_status_test.dart | [TASK-003-S12] |
| S13 | Domain | test/features/studio/domain/last_worn_test.dart | [TASK-003-S13] |
| S13 | Domain | test/features/wardrobe/domain/dormancy_test.dart | [TASK-003-S13] |
| S13 | ViewModel | test/features/wardrobe/presentation/wardrobe_view_model_test.dart | [TASK-003-S13] |
| S13 | Widget | test/features/wardrobe/presentation/wardrobe_view_test.dart | [TASK-003-S13] |
| S14 | Domain | test/features/wardrobe/domain/dormancy_test.dart | [TASK-003-S14] |

Required non-scenario tests: `WardrobeItem`, `ExtractedItem`, `PhotoTray`
value equality and list-content `hashCode`; `ItemTypeCatalog` covers all six
groups and every type has exactly one group; repository load failure → error
state with retry; both layouts for every widget test file.

## File confinement

**App Developer may create or modify:**

- `lib/core/media/photo_picker.dart`
- `lib/features/studio/{domain,data,presentation}/**`
- `lib/features/wardrobe/{domain,data,presentation}/**`
- `lib/app/shell/app_shell.dart` (plug Studio and Wardrobe pages in)
- `test/features/studio/**`, `test/features/wardrobe/**`,
  `test/app/flow_a_journey_test.dart`, `test/helpers/**`

**Locked:** dating features, `backend/**`, `pubspec.yaml` dependencies.

Photo access must use the `PhotoPicker` abstraction. Native camera, picker,
and cloud upload integrations are not part of this task.

## Anti-scope

- No production AI, cloud object storage, or remote image upload.
- No EXIF/GPS stripping or bystander blur (spec P2/P5). The SANITIZING status
  exists in the state machine but completes instantly.
- No camera hardware, body-photo try-on, calendar, rewards, or community work.
- No item detail, Archive/Delete, Add without photo, or duplicate detection
  (Gap ②, "Needs spec").
- No resumable-review banner, upload progress, or "Connect to analyze"
  offline copy (P1 is offline by design).
- No changes to dating features.

## Acceptance criteria

- Every scenario has a failing test before implementation.
- Domain entities use the [TASK-001 canonical terms](TASK-001-product-domain-alignment.md#canonical-terms) and value equality.
- Repository returns typed domain entities, never raw JSON to widgets.
- All key states are tested on mobile and desktop constraints.
- Flutter formatting, analysis, and targeted tests pass.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | — | Created Flow A task from the must-have mobile specification. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Split into `studio` + `wardrobe`; "category" → item group; added S09–S13 (picker limits, scope defaults, outcomes, state machine, dormancy); test plan and file list added. |
| 2026-10-29 | [CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md) | Review: T7 G3/G4 copy, Archive grid 2/3 columns (G1), A-01 conditions, partial-batch widget test, S14 (N6/I12). |
