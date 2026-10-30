# TASK-008: Local data erasure (UC-09 "Delete my data")

> **Phase:** 2 · P2 Persistent offline app  
> **Status:** Tests written (red) on `phase-2/persistence-tdd`  
> **Dependencies:** [TASK-005](TASK-005-local-persistence-foundation.md), [TASK-007](TASK-007-photo-privacy-pipeline.md) · [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md)  
> **Source:** UC-09 AC-09.1–09.4, AC-09.6 · TAC-09.1 · T7 › G3 1a ("Avatar › Privacy & data") · spec P2-07 (wipe part)

The file keeps its original name for link stability; its scope is now UC-09
local erasure only (CHG-005 P2-D2).

## Objective

Give the user a "Privacy & data" page, reached from the header avatar, that
withdraws body-photo consent or deletes all their photos and wardrobe data on
this phone, after an on-page confirmation with counts.

## Scope

- Header avatar (person icon until first-launch provides the initial,
  P2-D3) with the tooltip "Privacy & data" opens the Privacy & data page.
- Two actions, each saying what it removes:
  - "Withdraw body-photo consent": sets `revoked_at` on the active consent and
    deletes body-reference photos and try-on images (none exist in P2); the
    Pieces stay; the next analysis asks for consent again.
  - "Delete all my photos and wardrobe data": removes photos, Pieces, wear
    events, Gu Match history, batches and consents.
- Confirmation is a step on the page (no system dialog) that lists the counts,
  e.g. "3 photos, 12 Pieces, 0 try-on images", and needs a second explicit tap
  (AC-09.2).
- Delete all (P2-D12): close the database → delete the database files and
  the attachments folder → delete the database key → reopen fresh; the app
  restarts on Add with an empty Archive. The owner ID is kept.
- Work in flight is discarded: an analysis that finishes after the wipe
  writes nothing (AC-09.6).

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-008-S01 | The Privacy & data page lists both actions, each with what it removes | Widget |
| TASK-008-S02 | Choosing an action shows a confirmation step on the page with the counts; nothing happens without the second tap | ViewModel/widget |
| TASK-008-S03 | Withdrawing body-photo consent sets `revoked_at`, keeps the Pieces, and the Studio asks for consent again | Repository |
| TASK-008-S04 | Delete all removes the database files, every attachment and the database key | Integration |
| TASK-008-S05 | After delete all, the reopened database is empty and the app is told to restart fresh | Integration/ViewModel |
| TASK-008-S06 | The wipe is verified complete (no rows, no files) and takes ≤ 5 s on the host (TAC-09.1) | Integration |
| TASK-008-S07 | An analysis that completes after the wipe writes nothing and does not throw | ViewModel |
| TASK-008-S08 | The header avatar opens Privacy & data on both layouts | Widget |

## Test plan

| Scenario | Level | Test file | Test name prefix |
|---|---|---|---|
| S04, S05, S06 | Integration | test/core/storage/local_data_store_test.dart | [TASK-008-S0x] |
| S02, S03 | Repository | test/features/privacy/data/privacy_repository_test.dart | [TASK-008-S0x] |
| S02, S05 | ViewModel | test/features/privacy/presentation/privacy_view_model_test.dart | [TASK-008-S0x] |
| S01, S02 | Widget | test/features/privacy/presentation/privacy_view_test.dart | [TASK-008-S0x] |
| S07 | ViewModel | test/features/studio/presentation/studio_erasure_test.dart | [TASK-008-S07] |
| S08 | Widget | test/app/privacy_entry_test.dart | [TASK-008-S08] |

Device check: the wipe of the encrypted database and attachments on Android
and iOS within 5 s (TAC-09.1).

## File confinement

- `lib/core/storage/local_data_store.dart`
- `lib/features/privacy/{domain,data,presentation}/**` (new feature)
- `lib/features/studio/presentation/studio_view_model.dart` (ignore results
  after dispose)
- `lib/app/shell/app_shell.dart` (avatar), `lib/app/router.dart`
  (`/privacy`), `lib/app/bootstrap.dart` (restart after delete all)
- `test/core/storage/**`, `test/features/privacy/**`,
  `test/features/studio/presentation/studio_erasure_test.dart`,
  `test/app/privacy_entry_test.dart`

## Deferred (not Phase 2)

| Item | Why | Becomes |
|---|---|---|
| Save to calendar (4b) | Nice-to-have, UC-15 | Flow C/D release |
| Evening reminder, "results ready" notification | Gap ③ / ⑤ "Needs spec" | After UC-18 / UC-20 |
| Download my data (ZIP) | Gap ④ C "Needs spec" (manifest, contents) | After UC-19 |
| Poster save | Flow D, UC-12 | Flow D release |
| Server purge, export generation | Backend | [BE-007](../backend/BE-007-privacy-erasure-and-export.md) |

## Anti-scope

- No account deletion, server erasure request, sync or cloud backup.
- No account hub or notification inbox beyond the avatar → Privacy & data
  entry.
- Do not report deletion as complete until the files and rows are verified
  absent.

## Acceptance criteria

- Both actions need the on-page second tap; counts are shown first.
- The wipe is verified with real temporary storage.
- Flutter verification gates pass.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-29 | — | Created from T6 P2-06, P2-07, and P2-08; gated on unresolved product gaps. |
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | Re-scoped to UC-09 local erasure; Avatar › Privacy & data entry; wipe by deleting files; calendar, reminders, export and poster deferred; test plan. |
