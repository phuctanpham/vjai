# CHG-011: PowerSync security baseline for P3/P4

| Status | Source | Date |
|---|---|---|
| Draft | [TASK-002 securing PowerSync](../tasks/docs/TASK-002-securing-power-sync.md) · Flow Spec T4 | 2026-10-30 |

Status values: `Draft` → `Approved` (human) → `Done` (after merge).

## Problem

The PowerSync security note contains useful deployment techniques, but it
assumes a production backend, authentication service and Android project that
do not exist yet. It also treats certificate pinning as a universal control and
places example credentials and endpoints directly in client code. Agents need a
safe target contract without accidentally implementing the deferred platform.

## Decisions

| ID | Decision | Reason |
|---|---|---|
| PS-01 | P3/P4 target authentication is asymmetric JWT verification: the auth service signs with a protected RSA private key and PowerSync verifies a published JWKS using an explicit algorithm and `kid` allow-list. The private key never reaches PowerSync, the app or the repository | Prevents a shared HMAC secret from becoming a second server credential and supports key rotation |
| PS-02 | The connector obtains the current token from the authentication boundary and stores refresh credentials only through the existing secure-store abstraction. It must not use `SharedPreferences`, log tokens, or hard-code a sync endpoint | Keeps token lifecycle out of widgets and prevents secrets leaking into source, logs or ordinary preferences |
| PS-03 | Sync authorization is owner-scoped. Every stream query and write transaction derives the owner from the verified JWT `sub`; client-supplied `user_id` is checked against it and is never trusted for authorization | Prevents cross-owner reads and writes when a client changes payload fields |
| PS-04 | TLS is mandatory and cleartext sync is disabled. Certificate or public-key pinning is a deployment decision, not a P3 default: it requires backup pins, a rotation/runbook, platform coverage and recovery testing before enforcement | A single unplanned pin can brick all clients during certificate or proxy rotation |
| PS-05 | Public reverse proxies hide server version details and restrict `/probes/` to the monitoring network. Health endpoints expose only liveness/readiness status and no credentials, collection data or configuration | Reduces reconnaissance and information disclosure without making monitoring impossible |
| PS-06 | `powersync` remains unapproved until BE-001 resolves the backend platform and wire contract. `flutter_secure_storage` is already approved by D-006 and needs no new dependency decision | Keeps documentation from authorizing implementation before the platform gate |

## Engineering impact

| Affected | Change needed |
|---|---|
| [decisions.md](../policies/engineering/decisions.md) | Record the security baseline and the dependency boundary |
| [architecture.md](../policies/engineering/architecture.md) | Add client, sync and deployment security rules for P3/P4 |
| [data-schema.md](../policies/engineering/data-schema.md) | Add authorization and sync-stream invariants |
| [BE-001](../tasks/backend/BE-001-platform-decision.md) | Include JWKS, owner scoping, TLS, probe access and key rotation in the platform decision |
| [TASK-002](../tasks/docs/TASK-002-securing-power-sync.md) | Preserve the operational techniques while marking placeholders and deferred work |

## Anti-scope

No PowerSync service, authentication server, Nginx configuration, certificate
pin, production endpoint, JWT key, or new Flutter dependency is implemented by
this documentation change.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | — | Created from TASK-002 analysis; awaiting human approval. |
