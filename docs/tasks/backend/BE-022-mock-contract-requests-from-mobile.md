# BE-022: Mock contract requests from the mobile analysis

> **Owner:** Backend Developer (checks and test changes) · Engineering Manager (where a policy changes)  
> **Status:** Draft · needs [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) approval; items marked DOC-004 wait for that decision  
> **Track:** M (applies to the Draft cards BE-011…BE-018 before they are coded)  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31

## Why

The mobile analysis found phone-side mismatches with the v2.8 contract (CHG-015 F-01…F-14).
The phone fixes its side in TASK-013, TASK-014 and TASK-011. These requests keep the mock from
building in the opposite assumptions, so phone and server meet on the same contract the first
time.

## Requests

| # | Card | Request | Why | Verify with |
|---|---|---|---|---|
| 1 | BE-011 | Validate enum fields **strictly** as T2 UPPER_SNAKE (`PROMPT_LED`, `WORK`, `DISMISS_PASS`, `TOP`). Do **not** add tolerance for the phone's v1 camelCase values; the phone migrates them (TASK-013) | One encoding; no compatibility path that outlives P3 | `contracts/fixtures/enums.json` (TASK-012) |
| 2 | BE-011 | Timestamps: accept only ISO-8601 with `Z` or an offset; date fields (`worn_date`, `last_worn_estimate`) only `YYYY-MM-DD`. The phone's v1 `last_worn_estimate` has a time part (F-03) | D01 | Schema tests |
| 3 | BE-011, BE-012 | Read the table classes and allow-lists from `contracts/fixtures/table_classes.json` (TASK-012), not a hand copy | One source for the phone write guard (TASK-014) and the handler | Parity test |
| 4 | BE-012 | `upload_batches.status`: allow phone PATCH only to DRAFT, SANITIZING, QUEUED_FOR_AI, COMPLETED; the mock writes the rest (DOC-004 Q2) | F-09 | BE-012-S11 extended |
| 5 | BE-012 | Reject a PUT to `extracted_items` from the phone (PATCH of `value`, `last_worn_input` only), and record the code. The phone v1 re-inserts drafts on every save (F-06; fixed by TASK-014) | ST-07 | New negative scenario |
| 6 | BE-015 | Set `swipe_status` only from `interactions`; implement the save-for-later action decided in DOC-004 Q3; use the action names decided in Q4 | F-10, F-11 | BE-015 scenarios |
| 7 | BE-015 | Fit `items` shape per DOC-004 Q5 | F-12 | BE-015-S02 |
| 8 | BE-016 | Compute calendar days in the user's time zone per DOC-004 Q1; add the UTC+7 early-morning cases from `dormancy_cases.json` | F-05 | BE-016 golden tests |
| 9 | BE-012…BE-018 | Export each contract scenario's request and response to `contracts/fixtures/sync/<card>-<scenario>.json`, so the Flutter suite replays them (TASK-010, TASK-018, TASK-024…027) | Mobile tests need no running server | File list in each report |
| 10 | BE-012 | Rejection fixture set covering every 4xx code, for TASK-024-S01 | Rejection UX | `sync/be012-rejections.json` |
| 11 | BE-014, AI-005 | Outcome and latency scenarios: one photo FAILED then retried, SKIPPED_NO_PERSON, `SLOW_8S` per photo | TASK-028 | Scenario names in the report |

## Acceptance criteria

- [ ] Each request is either applied in its card (with a Change history row naming CHG-015) or answered with a reason.
- [ ] Requests 4, 6, 7 and 8 follow the DOC-004 decision; no default is chosen silently.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer for the Backend Developer and the ASEM |
