# CHG-017: Direct PowerSync and RustFS credential boundaries

| Status | Source | Date |
|---|---|---|
| In progress | User architecture correction and BE-001 constraints | 2026-11-03 |

## Decision

The backend is a credential provider, not a data or media proxy:

- PowerSync access is a short-lived JWT signed with a backend-only RSA private
  key. The JWT contains `sub`, `kid`, `aud`, `iat`, and `exp`; the mobile client
  connects directly to PowerSync.
- RustFS access is granted through short-lived, owner-scoped presigned PUT/GET
  URLs generated from backend-only S3 credentials. The mobile client never
  receives access or secret keys.
- Local deterministic issuers and presigners provide contract tests without
  external services.

## Gate

Live PowerSync, RustFS, and platform-specific MongoDB wiring remain blocked by
BE-001. This change adds contracts, configuration names, and local test
implementations only.

## Outstanding verification

- PowerSync JWT issuance and local RS256 verification pass, but the configured
  Cloudflare endpoint currently returns HTTP 502 and an authenticated
  `/sync/stream` handshake has not passed.
- RustFS is reachable in some checks, but a real S3-compatible presigner and
  signed PUT/GET transfer verification are not yet wired into the runtime.
- The real platform track cannot be accepted until BE-001 is approved and the
  external integration tests pass.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-11-03 | CHG-017 | Corrected PowerSync and RustFS roles to direct-client infrastructure boundaries |
| 2026-11-03 | CHG-017 | Recorded remaining PowerSync, RustFS, and BE-001 acceptance blockers |
