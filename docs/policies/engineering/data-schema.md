# Data Schema

The active wardrobe data contract is defined by the Flow Spec and the
phase-specific records below. This policy points to those sources instead of
maintaining a second dating API contract.

## 1. Authority by phase

| Concern | Source |
|---|---|
| Logical entities and names | Flow Spec T2 |
| Phone tables and column types | Flow Spec T4 and [CHG-005 phone schema v1](../../changes/CHG-005-phase-2-local-persistence.md) |
| AI processing jobs | [CHG-006 G-03](../../changes/CHG-006-phase-2-green-decisions.md) |
| UI-facing repository behavior | Flow Spec T6 and the applicable mobile task card |
| Backend platform and wire contracts | BE-001, pending before P3 |

## 2. Phone schema v1

The declarative implementation is
`apps/mobile/lib/core/storage/phone_schema.dart`. Every synced table has an
`id TEXT PRIMARY KEY`; other columns use only `TEXT`, `INTEGER` or `REAL`.
Dates are ISO-8601 text, booleans are integer `0`/`1`, and structured values
are JSON stored as text.

The current tables are:

- `wardrobe_items`
- `wear_events`
- `upload_batches`
- `media_assets`
- `ai_processing_jobs`
- `extracted_items`
- `consents`
- `interactions`
- `gu_match_sessions`
- `outfit_candidates`
- `item_types`
- local-only `session_draft`

Use CHG-005 for the authoritative columns and indexes. Use CHG-006 for the
one-job-per-photo-and-task rule and deterministic job IDs.

## 3. Persistence and idempotency rules

- Synced tables have no foreign keys or `UNIQUE` constraints on the phone.
- Idempotency comes from deterministic IDs and an existence check in the same
  write transaction.
- `wear_events` and `consents` are append-only.
- Derived values such as last worn, wear count and dormancy come from
  `wear_events`; do not add editable counters to the phone schema.
- The owner ID is generated once per install and stored securely.

## 4. Phase boundaries

- **P1:** in-memory repositories and fake analysis; no SQLite, PowerSync,
  backend API or ML.
- **P2:** local SQLite/SQLCipher using the phone schema v1; fake analysis and
  rule-based Gu Match remain local.
- **P3:** PowerSync replaces the SQLite database behind repository interfaces;
  final read/write ownership is governed by T4 and the resolved backend
  decision.
- **P4/P5:** backend services and real AI are introduced according to T4/T6.

## 5. Backend contract status

The old `/api/v1/discovery`, dating profile schema and dating storage keys are
legacy contracts only. Do not extend them for wardrobe work. The wardrobe
REST, sync and authentication contracts remain blocked on
[BE-001](../../tasks/backend/BE-001-platform-decision.md).

## 6. Sync security invariants

When P3/P4 is approved, these invariants apply to every synced table and
attachment path:

- The verified JWT `sub` is the owner identity. Sync queries filter by that
  identity, and the write handler rejects a payload whose `user_id` does not
  match it.
- Client-writable fields are allow-listed per collection. Server-owned fields,
  catalogs and derived values cannot be changed through the upload queue.
- JWT verification uses the configured asymmetric algorithm and `kid` from the
  auth service's JWKS. Key material and refresh credentials are never schema
  columns, synced values or logs.
- Sync and attachment URLs use TLS. Signed attachment URLs are short-lived and
  scoped to the owning object; public community data remains REST-only.
- Health probes are operational endpoints, not data APIs: they are network
  restricted and return no configuration, tokens or row contents.

This section is a security contract for the future platform, not an approval to
build it. See [CHG-011](../../changes/CHG-011-power-sync-security-baseline.md)
and [BE-001](../../tasks/backend/BE-001-platform-decision.md).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Created from the previous implementation contract |
| 2026-10-30 | [CHG-007](../../changes/CHG-007-documentation-authority-migration.md) | Replaced the dating API contract with the Flow Spec and Phase 2 phone schema authorities |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
| 2026-10-30 | [CHG-011](../../changes/CHG-011-power-sync-security-baseline.md) | Added deferred sync authorization and transport-security invariants |
