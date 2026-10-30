# Garblo Architecture Rules

## 1. Monorepo Organization

- **Mobile App:** `apps/mobile/` is the single Flutter codebase targeting Android, iOS, Windows, and macOS. All Flutter commands execute from `apps/mobile/`.
- **Backend:** `backend/` is a legacy mock API. It does not dictate wardrobe data contracts.
- **Documentation:** `docs/` is the single source of truth following the "one fact, one place" principle.

## 2. Layering & Imports

Garblo enforces strict Clean Architecture:

```text
View (UI Widgets / Pages)
  ↓ (reads/watches)
ViewModel (Riverpod StateNotifier / Notifier)
  ↓ (calls)
Repository Interface (lib/core/ or feature domain)
  ↓ (implements)
Data Implementation (Local via SQLCipher or Mock)
```

- **Forbidden Imports:** Views and widgets MUST NOT import `data/` implementations.
- **Enforcement:** Enforced via `apps/mobile/test/architecture/` test suite.

## 3. Responsive & Adaptive UI

- Breakpoints defined in `lib/core/layout/breakpoints.dart`.
- Desktop layout is active when width $\ge 800$ (`Breakpoints.desktop = 800`).
- No `Platform.isAndroid`, `Platform.isIOS`, or `Platform.isWindows` branching within widget layouts. Layout must strictly adapt based on available constraints/width.
- Widget tests must verify both mobile ($< 800$) and desktop ($\ge 800$) surface sizes using test helpers in `apps/mobile/test/helpers/layout.dart`.

## 4. State Management (Riverpod)

- ViewModels extend `StateNotifier<T>` or equivalent Riverpod state holders.
- Database and store providers (`localDatabaseProvider`, `ownerIdProvider`, `attachmentStoreProvider`) throw exceptions by default and are overridden during `bootstrap.dart` (or via `ProviderScope` in tests).

