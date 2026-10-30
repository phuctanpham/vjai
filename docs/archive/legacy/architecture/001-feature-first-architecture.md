# ADR 001: Feature-First Organization

## Context
When organizing a Flutter codebase, developers typically choose between layer-first (all models together, all views together) or feature-first (grouping by domain/business function). As applications scale with multiple bounded contexts (discovery, chat, matching, auth), layer-first architectures result in high file distance and merge conflicts.

## Decision
We adopt a **feature-first** organization:
- `apps/mobile/lib/features/<feature>/` holds `data/`, `domain/`, and `presentation/` for that vertical slice.
- `apps/mobile/lib/core/` houses common infrastructure, shared error types, and reusable UI components.
- `apps/mobile/lib/app/` manages app bootstrap, global theming, and routing.

## Consequences
### Positive
- High cohesion: all files related to discovery live together.
- Low coupling: changes to one feature do not affect other features.
- Enables agentic coding where an AI agent works on a single bounded context without touching unrelated code.

### Negative
- Shared models must be intentionally elevated to `core/` or defined via shared interfaces.

