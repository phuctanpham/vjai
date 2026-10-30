# BL-006 Test Plan

Standard: [tdd.md](../../../policies/engineering/tdd.md).

## Scenario tests
| Scenario | Level | Test file | Test name |
|---|---|---|---|
| BL-006-S01 | Repository unit | `apps/mobile/test/features/discovery/data/http_discovery_repository_test.dart` | [BL-006-S01] decodes discovery response into profiles |
| BL-006-S02 | Repository unit | same | [BL-006-S02] posts profileId and swipeType |
| BL-006-S03 | Repository unit | same | [BL-006-S03] HTTP 500 throws ServerFailure without fallback |
| BL-006-S04 | Repository unit | same | [BL-006-S04] network failure falls back to sample profiles |

## Required supporting tests
- `HttpApiClient` against a loopback `HttpServer`: GET path and query, POST JSON body and content type, non-2xx → `ServerFailure`, connection refused → `NetworkFailure`.
- Malformed JSON → `ServerFailure`.
- Backend: the existing `test_discovery.py` stays green (contract unchanged).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Created |
| 2026-10-30 | [CHG-010](../../../changes/CHG-010-monorepo-mobile-move.md) | Paths updated for the move of the Flutter app to `apps/mobile/` |
