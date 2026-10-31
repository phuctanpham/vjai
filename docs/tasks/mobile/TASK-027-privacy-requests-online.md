# TASK-027: Privacy requests online (withdraw body consent, delete my data)

> **Phase:** P4 · P4-M07 (erasure part)  
> **Track:** M (BE-017 in-memory erasure and proof function) → R (BE-007 on MongoDB + RustFS)  
> **Status:** Draft · needs CHG-015 approval and an implementation plan. Export and Delete account are blocked by gap ④  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Dependencies:** [TASK-010](TASK-010-mock-backend-integration.md), [TASK-023](TASK-023-identity-dev-token-to-anonymous-account.md), [TASK-011](TASK-011-phone-schema-v2-alignment.md) (`privacy_requests`)  
> **Source:** Flow Spec v2.8 UC-09 · DB handbook §13 LC-01…LC-05, LC-11 · TASK-008 (local erasure, shipped)

## Why

TASK-008 wipes the phone directly. Once data is on the server, a phone-only wipe would leave
the server copy and re-sync it. Erasure becomes a `privacy_requests` row. The phone wipes itself
only after the write handler acknowledges the request, so an offline request is never lost
(handbook §13).

## Scope

- Withdraw body consent: PATCH `consents.revoked_at` (allowed, C04-08) and PUT
  `privacy_requests {scope: BODY}`. Body photos disappear when the server's deletes sync. No
  local DELETE on synced tables.
- Delete my data: PUT `privacy_requests {scope: ALL}`. Once the upload is acknowledged (2xx), the
  phone wipes the database, file cache and token within 5 s (LC-04), then restarts fresh
  (TASK-008-S05). While offline, the request waits in the queue and the page says so (copy per APM).
- Confirmation counts still come from local rows (LC-02, TASK-008-S02).
- With the flag off, TASK-008 behaviour is unchanged.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-027-S01 | Delete all online: the `privacy_requests` ALL PUT is sent first; the local wipe starts only after 200 and finishes ≤ 5 s | Integration (mock) |
| TASK-027-S02 | Delete all offline: the request is queued and survives a restart; nothing is wiped until it is acknowledged | Integration |
| TASK-027-S03 | Track M proof: after the wipe, BE-017's proof function returns zero rows and files for the owner | Integration, tagged `live_backend` |
| TASK-027-S04 | Withdraw body consent writes one PATCH and one PUT, no DELETE; Pieces and outfit photos stay | Repository (`RecordingConnection`) |
| TASK-027-S05 | A 4xx on the request is shown as a retryable error; the phone is not wiped | ViewModel |
| TASK-027-S06 | Flag off: every TASK-008 test passes unchanged | Regression |

## Anti-scope

No export ZIP, no Delete account with grace (gap ④). No status page in the account hub (gap ④).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
