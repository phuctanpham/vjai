# Coding Conventions

## 1. Dart / Flutter
- **Lints:** `flutter_lints` plus the rules in `analysis_options.yaml`. `flutter analyze` must report zero issues.
- **Formatting:** `dart format` defaults.
- **Files:** snake_case, one main public type per file. Tests mirror the `lib/` path with a `_test.dart` suffix.
- **Feature layout:** `domain/` holds entities and enums (pure Dart plus `package:flutter/foundation.dart`). `data/` holds the repository interface, its implementations and its provider. `presentation/` holds state, view model, view and `widgets/`.
- **Names:**

  | Kind | Pattern |
  |---|---|
  | State, status | `<Feature>State`, `<Feature>Status` |
  | ViewModel, provider | `<Feature>ViewModel`, `<feature>ViewModelProvider` |
  | Repository | `<Feature>Repository`, `Mock<Feature>Repository`, `Http<Feature>Repository` |
  | Repository provider | `<feature>RepositoryProvider` |

- **Immutability:** `@immutable`, `const` constructors, `copyWith`, value equality. `hashCode` must hash list contents: `Object.hash(a, b, Object.hashAll(list))`.
- **State management:** Riverpod `StateNotifier` with `StateNotifierProvider`, declared next to the class.
- **Errors:** repositories throw `Failure` subclasses. ViewModels turn them into an `error` status with a user-facing message. Never write an empty `catch`.
- **Widgets:** take colours from `colorScheme`, spacing from the design-system scale, and `const` wherever possible. Extract a widget class when a build helper is reused or grows beyond one screen of code.
- **Dependencies:** none beyond `pubspec.yaml` unless [decisions.md](decisions.md) records one.

## 2. Python / FastAPI
- Python ≥ 3.10, type hints on every function.
- One `APIRouter` per feature in `app/api/v1/endpoints/<feature>.py`, registered in `app/api/router.py`.
- Pydantic v2 style: `model_config = ConfigDict(populate_by_name=True)` with `Field(alias="camelCase")`. Do not write new `class Config:` blocks.
- Fixtures live in `app/data/`. No randomness or current-time logic unless it is injected.
- Errors use `HTTPException(status_code=..., detail=...)`.
- Tests live in `backend/tests/test_<feature>.py` and use `TestClient`.

## 3. Git
- Commit messages: `[BL-NNN] <type>: <summary>` or `[CHG-NNN] <type>: <summary>`. Types: `test`, `feat`, `fix`, `refactor`, `docs`, `chore`.
- TDD order is visible in history: a `test:` commit comes before its `feat:` or `fix:` commit.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Created from existing code patterns and lint config |
