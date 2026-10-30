# Decisions

One entry per architecture, dependency or workflow decision. Newest last. Agents do not read this file by default; it explains *why* the policies say what they say.

| ID | Date | Decision | Reason | Consequence |
|---|---|---|---|---|
| D-001 | 2026-10-15 | Feature-first folders (`apps/mobile/lib/features/<f>/{domain,data,presentation}`) | Keeps a backlog item's files together; lets an agent work on one slice | Shared types must be moved deliberately into `apps/mobile/lib/core/` |
| D-002 | 2026-10-15 | Riverpod with the ViewModel pattern | Compile-time-safe dependency injection; providers can be overridden in tests without code generation | Team must know Riverpod |
| D-003 | 2026-10-15 | Adaptive UI by width (800 px), not by operating system | One codebase for four platforms; resizing a window switches layout | Widgets are tested in both layouts |
| D-004 | 2026-10-15 | Python/FastAPI mock backend managed with uv, replacing the planned Go skeleton | Flutter is the product; the backend only serves fixtures, and compiled infrastructure added cost without value | Backend stays mock-only; no databases or real auth |
| D-005 | 2026-10-16 | Agentic documentation system: four agents in two tiers, three document types, BDD + TDD | Previous docs repeated rules 4–5 times and split each feature across two files | See [docs/README.md](../../README.md) |

| D-006 | 2026-10-30 | Local storage on `sqlite_async` + `sqlite3`, encrypted with `sqlcipher_flutter_libs`; key and install owner ID in `flutter_secure_storage`; files under `path_provider` app support | PowerSync's Dart SDK is built on `sqlite_async`, so P3 swaps the database object, not the repositories ([CHG-005](../../changes/CHG-005-phase-2-local-persistence.md)) | Synced tables follow PowerSync rules: `id TEXT PRIMARY KEY`, no FK, no UNIQUE |
| D-007 | 2026-10-30 | Real photos through `image_picker` behind `PhotoPicker`; JPG/PNG only | Phase 2 must sanitize real photos (spec P2-04) | HEIC is rejected, not converted |
| D-008 | 2026-10-30 | ObjectIds and image-metadata stripping written in-house | Avoids a dependency; stripping is lossless (no re-encode) | Fixtures pin each stripping rule |
| D-009 | 2026-10-30 | P3/P4 PowerSync security baseline: asymmetric JWT/JWKS verification, secure token access, owner-scoped streams and writes, TLS-only transport, restricted probes, and planned key rotation | Separates signing authority from sync verification and makes the authorization boundary explicit before the backend platform is built ([CHG-011](../../changes/CHG-011-power-sync-security-baseline.md)) | No PowerSync or real-auth implementation is approved until BE-001 resolves the platform; certificate pinning requires an operational rotation plan |

**Dependencies approved:** `flutter_riverpod`, `flutter_lints`, `sqlite_async`, `sqlite3`, `sqlcipher_flutter_libs`, `flutter_secure_storage`, `path_provider`, `image_picker`; `fastapi`, `uvicorn`, `pydantic`, `pytest`, `httpx`.
**Proposed in backlog, not yet approved:** `http` (BL-006).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Replaces ADR 001–005 and lesson #001 |
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | D-006 storage, D-007 photo picker, D-008 in-house ObjectId and metadata stripping |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
| 2026-10-30 | [CHG-011](../../changes/CHG-011-power-sync-security-baseline.md) | Added the deferred P3/P4 PowerSync security baseline |
