# TASK-016: Retire the legacy dating code in the mobile app

> **Phase:** P3 preparation · cleanup  
> **Track:** M  
> **Status:** Draft · needs a removal decision from the Product Manager (README: "the dating feature tree stays … until a removal CHG") and an implementation plan  
> **Owner:** App Developer  
> **Raised by:** App Developer, mobile + database analysis, 2026-10-31 ([CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) F-16)  
> **Mobile counterpart of:** [BE-005](../backend/BE-005-retire-dating-mock-api.md)

## Why

The app still compiles and tests the retired dating product. That code costs build and test
time, and agents read it. It also uses vocabulary CLAUDE.md forbids reusing. TASK-010 adds the
real sync transport, and the legacy `ApiClient` beside it would be an obvious wrong turn.

## Inventory

| Path | What it is | Used by routed code? |
|---|---|---|
| `lib/features/discovery/` (+ `test/features/discovery/`) | BL-004 dating slice | No (unrouted) |
| `lib/features/{auth,onboarding,matching,chat,profile,notifications,moderation}/*_placeholder.dart` | Empty placeholders | No |
| `lib/core/networking/api_client.dart` (`ApiClient`, `MockApiClient`) | Placeholder HTTP client | Only `app/providers.dart` |
| `lib/core/storage/local_storage.dart` (`LocalStorage`, `InMemoryLocalStorage`) | Legacy key-value store | Only `app/providers.dart` and discovery |
| `lib/app/providers.dart` (`apiClientProvider`, `localStorageProvider`) | Legacy providers | No |
| `core/errors/failures.dart` `ServerFailure`, `NetworkFailure` | Still used by Studio fakes | **Keep** |

The implementation plan confirms each "No" with Grep before deleting.

## Scope

Delete the files above and their tests. Keep `failures.dart`. Record the deleted test count in
the report (they are deletions, not changes: CHG note). The ASEM updates the codebase map, and
the architecture layering diagram drops `ApiClient / LocalStorage`.

## TDD scenarios

| ID | Scenario | Level |
|---|---|---|
| TASK-016-S01 | An architecture test fails if `lib/` contains `discovery`, `swipe`, `match` or `profile_card` paths, or imports `core/networking/api_client.dart` | Architecture |
| TASK-016-S02 | `flutter analyze` is clean and every remaining test passes; the report lists removed tests by file | Regression |

## Anti-scope

No wardrobe behaviour change. `features/notifications/` returns later as a new feature from its
own spec (gap ⑤), not by reviving the placeholder.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-31 | [CHG-015](../../changes/CHG-015-mobile-contract-alignment-and-p3-p5-plan.md) | Created (Draft) by the App Developer |
