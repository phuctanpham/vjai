# TASK-023: Identity: dev token, then the anonymous account

> **Phase:** P3 (dev token) → P4 · P4-M01 (anonymous account; Google link later)  
> **Track:** M (BE-011 `POST /v1/auth/dev-token`) → R (BE-019 auth service)  
> **Status:** Draft · Track M needs CHG-015 approval and a plan. Track R is blocked by [BE-019](../backend/BE-019-auth-service.md). The first-launch and Google-link UI are blocked by gap ① ("Needs spec")  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md))  
> **Dependencies:** [TASK-010](TASK-010-mock-backend-integration.md) (`CredentialsSource`)  
> **Source:** Flow Spec v2.8 T4 › DB2, Account lifecycle · DB handbook §4 ID-01…ID-07 · decisions.md D-009, architecture.md §5

## Why

The install owner ID (CHG-005 P2-D9) must become the JWT `sub` without re-keying a row (ID-02).
Tokens must never reach widgets (architecture.md §5). The mock gives a token for any ObjectId.
The real service issues an anonymous JWT and a refresh token that must survive a reinstall
(Keychain / Block Store).

## Scope

- `AuthSession` in `core/auth/`: `currentToken()`, `refresh()`, `signOut()`, a `ownerId`
  getter. It implements TASK-010's `CredentialsSource`. Tokens are held in memory. The refresh
  token is kept in `SecureStore` under its own key, separate from the database key.
- `DevAuthSession` (Track M): `POST /v1/auth/dev-token {user_id: ownerId}`. Built only with
  `GARBLO_BACKEND=mock`.
- `AnonymousAuthSession` (Track R): create the account on first launch, refresh with rotation,
  map 401 to one refresh and retry.
- "Delete all" keeps the owner ID (TASK-008). The token is cleared only by erasure (LC-04,
  TASK-027) and Delete account (later).

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-023-S01 | The dev token is requested with the install owner ID; every upload carries `Bearer dev.<ownerId>`; `user_id` in rows equals it | Unit (`MockClient`) |
| TASK-023-S02 | A 401 triggers one refresh and one retry; a second 401 surfaces "Sign-in expired" (copy per APM) and keeps the queue | Unit |
| TASK-023-S03 | No widget or ViewModel imports `core/auth/` token types (architecture test) | Architecture |
| TASK-023-S04 | Track R: a reinstall (new database, same secure store) restores the same `sub` and re-syncs | Integration, tagged `live_backend` |
| TASK-023-S05 | Tokens never appear in logs or in any table (grep over the test database and captured logs) | Integration |

## Anti-scope

No Google sign-in, merge choice or first-launch screen (gap ①, P4-M01 UI part). No Community
`linked` claim checks on the phone.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
