# ADR 002: State Management and Dependency Injection with Riverpod

## Context
Flutter provides several state management alternatives (Provider, Riverpod, Bloc, MobX). We need compile-time safety, easy testing, minimal boilerplate, and built-in dependency injection across mobile and desktop.

## Decision
We select **Riverpod** (`flutter_riverpod`) with the ViewModel pattern (`StateNotifier` / `Notifier`).

Key principles:
1. Every view is paired with an immutable state class (`DiscoveryState`) defining explicit status flags (`initial`, `loading`, `loaded`, `empty`, `error`).
2. ViewModels (`DiscoveryViewModel`) manipulate state and expose action methods (`loadProfiles`, `swipe`, `retry`).
3. Repositories and external services are injected via top-level Riverpod providers.
4. Testing overrides providers with `ProviderScope(overrides: [...])` without needing mockito codegen.

## Consequences
### Positive
- Compile-time dependency safety without `BuildContext` requirements.
- Declarative and predictable state transitions.
- High testability for unit and widget testing.

### Negative
- Requires learning Riverpod provider paradigms.

