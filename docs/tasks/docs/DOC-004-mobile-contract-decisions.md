# DOC-004: Contract decisions needed before the mobile P3–P5 cards are Ready to code

> **Type:** Documentation and decision follow-up  
> **Status:** Open · needs the Product Manager, the Engineering Manager and, for spec changes, the human  
> **Owner:** Product Manager + Engineering Manager  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Related:** [DOC-002](DOC-002-flow-spec-v2-8-relocation.md) (spec relocation and ripple; rows 7–8 overlap Q2 and Q4), [DOC-001](DOC-001-phase-history-reconciliation.md) item 3 (deck ownership)

## Why

Checking the P1–P2 code against Flow Spec v2.8 and the DB handbook turned up places where the
documents disagree with each other, or say nothing the phone can build on. Under docs/README.md
§5 rule 6 the App Developer records each one and stops instead of choosing. Every question
below names the cards it blocks.

## Decisions

| # | Question | What the sources say | Proposal (App Developer) | Owner | Blocks |
|---|---|---|---|---|---|
| Q1 | Whose calendar day counts for dormancy, `gap_days` and rescue eligibility once timestamps are UTC? | D01: timestamps in UTC; WD-08: server dormancy matches the phone; no user time zone anywhere | Days are the user's local calendar days. Add `profiles.time_zone` (IANA, phone-written) so the server (BE-016) can do the same. `worn_date` stays a local date | ASEM, APM | TASK-013, TASK-011, BE-016 |
| Q2 | Who writes `upload_batches.status`? | C01-03: one writer per collection; the state machine has phone and server transitions | Per transition: the phone writes DRAFT, SANITIZING, QUEUED_FOR_AI, COMPLETED; the server writes AI_PROCESSING, AWAITING_REVIEW, FAILED, DELETED_BY_USER. Note the exception in C01-03 | ASEM | TASK-011, TASK-014, BE-012 |
| Q3 | How does the phone ask for `SAVED_TO_LOOKBOOK` ("save for later")? | `swipe_status` has it; `card_action` has no matching action; the phone may not PATCH `outfit_candidates` (BE-012-S06) | Add `SAVE_LATER` to `card_action`, or define LIKE_SAVE + a second LIKE_SAVE as "save". Prefer an explicit action | APM | TASK-026, TASK-018, BE-015 |
| Q4 | Interaction action names: `CUSTOMIZE_EDIT` / `TRIGGER_VTON` (T2) or `ADJUST` (T4 side effects, GM-05)? | Both in v2.8 | Keep T2 `card_action` as the stored values; T4 and the handbook say `CUSTOMIZE_EDIT` | APM | TASK-013, TASK-026, BE-015 |
| Q5 | Shape of `outfit_candidates.items` | T4: `{slot_role, item_id}`; handbook §8: `{slot_role, item_id, name, days_unworn}` | `{slot_role, item_id}` plus the server-computed `days_unworn` at draft time if the highlight needs it; the phone shows names and current days from local Pieces | ASEM | TASK-026, BE-015 |
| Q6 | UI for an upload rejection ("Couldn't save … · Fix") before `my_progress` ships | Handbook §12 open: "a small stream or a local banner" | Local banner from `sync_rejections` until Flow C; copy and placement from the APM | APM | TASK-024 |
| Q7 | Which DELETE ops may the phone send on synced tables? | D05: DELETE allowed except append-only; items "archived or deleted per gap ②"; erasure through `privacy_requests` | None in the P3–P4 must-have flows: tray removal is the PATCH `removed = 1`, and Pieces cannot be deleted until gap ② is specified. Any later exception is listed here by table | ASEM, APM (gap ②) | TASK-014 |
| Q8 | Offline copy: Analyze offline (ST-06 "OFFLINE · ANALYSIS STARTS WHEN ONLINE") and Draft Fits offline (GM-06 needs a connection) | ST-06 gives the Analyze line; no line for Draft Fits | Confirm the Analyze line; write the Draft Fits line in T7 › G4 voice | APM | TASK-018, TASK-025 |
| Q9 | Sync status, pending count and Sync now: screen and copy | P3-05 "Needs spec"; DB2 keeps "Sync now" | Place in the account hub (gap ④) or Privacy & data until the hub exists | APM | TASK-022 |
| Q10 | May the phone cache try-on renders beyond the 10-minute GET ticket? | FL-03: render tickets 10 min; C06-03: delete on withdrawal | Cache in memory only for the session; never on disk | APM, ASEM | TASK-030 |
| Q11 | Wire values of `extracted_items.last_worn_input.option` | Not in T2 › Enums | `DONT_REMEMBER`, `THIS_WEEK`, `THIS_MONTH`, `ONE_TO_THREE_MONTHS`, `OVER_THREE_MONTHS`, `EXACT_DATE`; add to T2 | APM | TASK-013, TASK-012 |
| Q12 | New mobile dependencies | decisions.md approves none of these | `http` (TASK-010); `powersync` + `powersync_sqlcipher` (TASK-020, after BE-001); an on-device ML runtime (TASK-029, after SP-1/SP-4). Use numbers that do not collide with the handbook's D-010…D-013 (DOC-002 #4) | ASEM | TASK-010, TASK-020, TASK-029 |

## Acceptance criteria

- [ ] Each question has a decision, an owner and a date, recorded in the owning document (Flow Spec, data-schema.md, decisions.md or a CHG) with its Change history row.
- [ ] Each blocked card names the decision it now follows.
- [ ] No code changes in this item.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created by the App Developer for the APM, ASEM and human |
