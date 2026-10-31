# BE-020: Write handler on MongoDB

> **Owner:** Backend Developer  
> **Status:** Blocked by [BE-001](BE-001-platform-decision.md) and [BE-006](BE-006-phone-schema-sync-parity.md)  
> **Track:** R (real) · spec P4-B02, P4-B03 · mock predecessor [BE-012](BE-012-mock-write-handler.md)  
> **Source:** Flow Spec v2.8 T4 › Write path · [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §2 C04, §3 D05

## Why

BE-012 defines every rule of `POST /v1/sync/tx` against the `Store` protocol, with an
in-memory store. This card adds a MongoDB store, so the endpoint, the rules and the
tests stay the same, and only storage changes.

## Scope

- `MongoStore` implementing `Store`: one multi-document transaction per CRUD
  transaction, write concern `majority`; `applied_tx` record inside it (TTL 7 days),
  keyed as BE-001 decides (CHG-014 Q1).
- Duplicate-key from the same owner = already applied; from another owner = 403.
- Rejections logged to `sync_rejections`, plus a user notification once the
  notifications table exists.
- **Contract:** the BE-012 and BE-013 test suites are parametrised over
  `InMemoryStore` and `MongoStore` (the latter in an integration job with a
  disposable replica set), the same pattern as the mobile Mock/Local contract suites.
- Side-effect workers (BE-014…BE-017) move from in-process calls to a queue only
  if BE-001 approves one. Otherwise they stay in-process, behind the same registry.

## Anti-scope

No new rule (any rule change goes to BE-012 first). No PowerSync configuration (BE-006).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created; spec P4-B02/B03 had no card |
