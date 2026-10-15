# Architecture

Why each rule exists is recorded in [decisions.md](decisions.md).

## 1. System
| Part | Role | Stack |
|---|---|---|
| `lib/` | **Primary product.** One Flutter app for Android, iOS, Windows, macOS | Flutter, Dart 3, Riverpod |
| `backend/` | **Secondary.** Deterministic mock API for fixtures and HTTP integration | Python 3.10+, FastAPI, Pydantic v2, uv |

## 2. Flutter layering

```text
View (ConsumerWidget)            observes state, dispatches user intent
  ↓
ViewModel (Riverpod notifier)    owns state transitions and business flow
  ↓
Repository (abstract class)      the only data boundary; returns domain entities
  ↓
ApiClient / LocalStorage / mock  data sources in lib/core/
```

- **Feature-first:** `lib/features/<feature>/{domain,data,presentation}`. Shared infrastructure in `lib/core/`; app shell, routing, theme and global providers in `lib/app/`.
- **Widgets** never call repositories, parse JSON, touch storage or hold business rules.
- **ViewModels** expose an immutable state with an explicit status enum, block duplicate actions while busy, and never import `dart:io`, `dart:html` or widgets.
- **Repositories** return domain entities, never raw JSON. Errors are `Failure` subclasses from `lib/core/errors/`.
- **No extra layers.** Add a use case only when a flow coordinates several repositories or has non-trivial domain computation. No mappers or DTOs that duplicate entities.
- **Cross-feature use** goes through another feature's `domain/` types or repository interface, never its presentation code.

## 3. Adaptive UI
- One widget tree per screen; `LayoutBuilder` picks the mobile (`< 800`) or desktop (`≥ 800`) structure (see [design-system.md](../product/design-system.md)).
- No `Platform.isX` checks in widgets. Native capabilities (notifications, window control, storage) sit behind interfaces in `lib/core/`.

## 4. Backend mock
- Routers per feature in `backend/app/api/v1/endpoints/`, aggregated in `backend/app/api/router.py`.
- Pydantic models in `backend/app/models/` define the contract described in [data-schema.md](data-schema.md).
- Fixtures in `backend/app/data/`. Responses are deterministic.
- Out of bounds: databases, real authentication, microservices, message brokers, cloud deployment.

## 5. Technical terms
| Term | Meaning |
|---|---|
| Bounded vertical slice | One backlog item delivered end to end: UI, ViewModel, repository, mock/API, tests |
| Anti-scope | Explicit list of what an item must not build |
| Contract code | Merged code another item depends on; read-only unless an implementation plan lists it |

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Merged from `docs/architecture/README.md`, ADR 001–003 and glossary technical terms |
