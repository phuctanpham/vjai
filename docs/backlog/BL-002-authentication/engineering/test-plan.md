# BL-002 Test Plan

Standard: [tdd.md](../../../policies/engineering/tdd.md).

## Scenario tests
| Scenario | Level | Test file | Test name |
|---|---|---|---|
| BL-002-S01 | ViewModel unit + widget | `test/features/auth/presentation/auth_view_model_test.dart`, `auth_view_test.dart` | [BL-002-S01] valid sign-in authenticates and stores session |
| BL-002-S02 | Widget | `auth_view_test.dart` | [BL-002-S02] invalid email blocks submit |
| BL-002-S03 | Widget | same | [BL-002-S03] short password blocks submit |
| BL-002-S04 | ViewModel unit + widget | both | [BL-002-S04] wrong password shows error and re-enables submit |
| BL-002-S05 | Widget (app + router) | `test/features/auth/presentation/auth_routing_test.dart` | [BL-002-S05] stored session starts on discovery |
| BL-002-S06 | Widget (app + router) | same | [BL-002-S06] no session starts on sign-in |
| BL-002-S07 | ViewModel unit | `auth_view_model_test.dart` | [BL-002-S07] sign out clears session |
| BL-002-S08 | Widget | `auth_view_test.dart` | [BL-002-S08] google button signs in through mock |
| BL-002-S09 | Widget, 400 × 800 and 1280 × 800 | `auth_view_test.dart` | [BL-002-S09] form layout per width |
| BL-002-S01, S04 | Endpoint | `backend/tests/test_auth.py` | `test_BL_002_S01_login_returns_session`, `test_BL_002_S04_wrong_password_returns_401` |

## Required supporting tests
- `AuthSession`: equality, JSON round trip.
- Repository: login, register, logout, `getCurrentSession`; storage failure on logout throws.
- ViewModel ignores a second submit while `authenticating`.
- Backend: logout returns `{success: true}`; malformed body → 422.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Created |
