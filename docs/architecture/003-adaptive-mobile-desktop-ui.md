# ADR 003: Adaptive Mobile and Desktop UI

## Context
Garblo targets mobile (Android, iOS) and desktop (Windows, macOS) operating systems. Forking codebases or scattering `Platform.isAndroid` or `Platform.isWindows` checks across widgets leads to unmaintainable and fragile UI.

## Decision
We adopt **responsive layout switching** driven by available width constraints rather than OS queries:

1. A clear breakpoint (`800px`) demarcates mobile and desktop presentations.
2. `LayoutBuilder` dynamically chooses between touch-oriented card layouts and multi-column desktop layouts.
3. Both layouts share the identical domain model (`Profile`), repository (`DiscoveryRepository`), and state notifier (`DiscoveryViewModel`).
4. Platform-specific capabilities (e.g. native window resizing, notifications) are hidden behind abstract service interfaces.

## Consequences
### Positive
- Single unified codebase runs smoothly across phones, tablets, foldables, and desktop windows.
- Resizing a desktop window smoothly refits between layouts.
- Zero platform leakage in presentation widgets.

### Negative
- UI widgets must be tested under both constraint sizes.

