# BE-019: Auth service — anonymous JWT, JWKS, refresh rotation, Google link

> **Owner:** Backend Developer  
> **Status:** Blocked by [BE-001](BE-001-platform-decision.md) (questions 4–7) and spike SP-6  
> **Track:** R (real) · spec P4-B01 · mock predecessor: dev token in [BE-011](BE-011-mock-platform-core.md)  
> **Source:** Flow Spec v2.8 T4 › Account lifecycle, DB2, R6 · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §4 ID-01…ID-08 · [CHG-011](../../changes/CHG-011-power-sync-security-baseline.md), D-009 security baseline · [data-schema.md](../../policies/engineering/data-schema.md) §6

## Why

PowerSync needs a JWT from first launch, and the install owner ID the phone has
been using since Phase 2 must become the `sub` with no re-keying (BE-006). No card
covered spec P4-B01 until now.

## Scope

- `POST /v1/auth/anonymous {user_id}` creates the account with `sub = user_id`
  (accepting the phone-generated ObjectId once) and returns an access JWT and a
  refresh token (ID-02).
- Asymmetric signing with an explicit `alg` and `kid`; JWKS published for PowerSync;
  key rotation documented (CHG-011).
- Refresh-token rotation with reuse detection; only hashes stored.
- `linked` claim; Google link keeps `sub`; merge flow when the Google identity
  already has an account (ID-05, ID-06).
- The write handler's `current_owner` dependency switches from the dev token to
  JWT verification; every BE-012 owner test still passes.

## Anti-scope

No email or password login. No Community gating beyond the `linked` claim.
The private key never enters the app, PowerSync or the repo.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created; spec P4-B01 had no card |
