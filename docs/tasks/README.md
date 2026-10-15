# Garblo Master Product Backlog for Coding Agents

This backlog is the single source of truth for AI coding agents and the solo fullstack engineer. Tasks are structured as **bounded vertical slices** with explicit in-scope criteria, negative boundaries (anti-scope), locked files, finite state machine matrices, and automated verification commands.

---

## 1. Vertical Slice Dependency Graph

```mermaid
graph TD
    T001["TASK-001: App Shell & Foundation<br/>[COMPLETE]"]
    T004["TASK-004: Discovery Feed Scaffold<br/>[COMPLETE]"]
    
    T002["TASK-002: Authentication Slice<br/>[READY TO CODE]"]
    T003["TASK-003: Profile Onboarding Wizard<br/>[READY TO CODE]"]
    
    T005["TASK-005: Local Swipe Persistence<br/>[READY TO CODE]"]
    T006["TASK-006: Backend API Integration<br/>[READY TO CODE]"]
    
    T007["TASK-007: Mutual Match Formation<br/>[READY TO CODE]"]
    T008["TASK-008: Matches & Connections Tab<br/>[READY TO CODE]"]
    
    T009["TASK-009: Chat History & Thread UI<br/>[PLANNED]"]
    T010["TASK-010: Realtime Chat WebSockets<br/>[PLANNED]"]
    
    T011["TASK-011: Push Notifications<br/>[PLANNED]"]
    T012["TASK-012: Blocking & Reporting<br/>[PLANNED]"]
    
    T001 --> T004
    T001 --> T002
    T002 --> T003
    T004 --> T005
    T005 --> T006
    T005 --> T007
    T007 --> T008
    T008 --> T009
    T009 --> T010
    T008 --> T011
    T007 --> T012
    T012 --> T013
    T008 --> T014
    T009 --> T015
    T011 --> T015
```

---

## 2. Master Sprint & Task Status Matrix

| Task ID | Phase | Feature Title | Target Directory | Status | Specification Card |
|---|---|---|---|---|---|
| **TASK-001** | Phase 1 | App Shell & Multi-Platform Scaffold | `lib/app/` | `COMPLETED` | Architecture baseline |
| **TASK-004** | Phase 1 | Discovery Feed & Adaptive Layout | `lib/features/discovery/` | `COMPLETED` | [APRD-001](../specs/APRD-001-discovery.md) |
| **TASK-002** | Phase 2 | Authentication & Mock Session | `lib/features/auth/` | `READY TO CODE` | [Task](TASK-002-authentication.md) · [APRD](../specs/APRD-002-authentication.md) |
| **TASK-003** | Phase 2 | Multi-Step Profile Onboarding Wizard | `lib/features/onboarding/` | `READY TO CODE` | [Task](TASK-003-profile-onboarding.md) · [APRD](../specs/APRD-003-profile-onboarding.md) |
| **TASK-005** | Phase 3 | Local Swipe Persistence & Filtering | `lib/features/discovery/` | `READY TO CODE` | [Task](TASK-005-swipe-persistence.md) · [APRD](../specs/APRD-005-swipe-persistence.md) |
| **TASK-006** | Phase 3 | Backend FastAPI API Integration | `lib/core/networking/` | `READY TO CODE` | [Task](TASK-006-backend-api-integration.md) · [APRD](../specs/APRD-006-backend-api-integration.md) |
| **TASK-007** | Phase 3 | Mutual Match Formation & Celebration | `lib/features/matching/` | `READY TO CODE` | [Task](TASK-007-mutual-matching.md) · [APRD](../specs/APRD-007-mutual-matching.md) |
| **TASK-008** | Phase 3 | Matches Carousel & Connections View | `lib/features/matching/` | `READY TO CODE` | [Task](TASK-008-matches-list.md) · [APRD](../specs/APRD-008-matches-list.md) |
| **TASK-009** | Phase 4 | Chat History & Message Bubbles | `lib/features/chat/` | `PLANNED` | [Task](TASK-009-chat-history.md) |
| **TASK-010** | Phase 4 | Realtime Chat via WebSockets | `lib/features/chat/` | `PLANNED` | [Task](TASK-010-realtime-chat.md) |
| **TASK-011** | Phase 5 | Push & In-App Notifications | `lib/features/notifications/` | `PLANNED` | [Task](TASK-011-push-notifications.md) |
| **TASK-012** | Phase 5 | User Blocking & Content Reporting | `lib/features/moderation/` | `PLANNED` | [Task](TASK-012-blocking-reporting.md) |
| **TASK-013** | Phase 5 | Automated Content Moderation | `backend/app/api/v1/` | `PLANNED` | [Task](TASK-013-automated-moderation.md) |
| **TASK-014** | Phase 6 | Premium Subscriptions & Paywall | `lib/features/profile/` | `PLANNED` | [Task](TASK-014-premium-subscriptions.md) |
| **TASK-015** | Phase 6 | Performance & Accessibility Polish | `lib/` | `PLANNED` | [Task](TASK-015-performance-accessibility.md) |

---

## 3. Technical Delivery View

This table is the manager's implementation handoff. A task is not ready for coding unless its contract, state behavior, test surface, and file boundary are clear.

| Task | Primary contract | State/behavior to verify | Required test surface | Boundary |
|---|---|---|---|---|
| TASK-001 / TASK-004 | App shell, `Profile`, `DiscoveryRepository` | `initial`, `loading`, `loaded`, `empty`, `error` | Domain, repository, ViewModel, widget, mobile/desktop | `lib/app/`, `lib/features/discovery/` |
| TASK-002 | `AuthSession`, auth repository, `LocalStorage` token key | `unauthenticated`, `authenticating`, `authenticated`, `error` | Session, repository, ViewModel, form | `lib/features/auth/`, auth endpoints |
| TASK-003 | `OnboardingDraft`, step validation, profile conversion | Editing steps, `submitting`, `completed` | Draft/validation, ViewModel, wizard widgets | `lib/features/onboarding/` |
| TASK-005 | `LocalStorage` swipe-ID contract | Filtered loaded feed, empty after exhaustion, reset | Storage/repository filtering, ViewModel, reset action | Discovery and core storage only |
| TASK-006 | `ApiClient`, HTTP repository, Pydantic JSON shape | Remote success, server error, network fallback | Client, repository mapping, backend endpoint | Networking and discovery data |
| TASK-007 | `Match`, matching repository, swipe outcome event | Match event versus ordinary swipe | Entity, repository, ViewModel event, dialog | Matching plus declared Discovery integration |
| TASK-008 | Match list repository and `/matches` route | `loading`, `loaded`, `empty`, `error`, search | ViewModel filtering and responsive widgets | Matching presentation and router |
| TASK-009 | `Conversation` and `Message` contracts | Loading, loaded, empty, error, send-local-message | Models, repository, ViewModel, thread widgets | Chat feature only |
| TASK-010 | WebSocket transport lifecycle | Connected, reconnecting, disconnected, error | Transport, lifecycle cleanup, backend endpoint | Chat/networking integration |
| TASK-011 | Notification entity and unread repository | Loading, loaded, empty, error, read mutation | Repository, ViewModel, badge/list widgets | Notifications only |
| TASK-012 | Report reason/request and block repository | Confirmation, submitting, success, error | Validation, repository, confirmation UI, endpoint | Moderation and explicit integration points |
| TASK-013 | Pydantic moderation request/decision | Safe, review, rejected, validation error | Schema and endpoint tests | Backend moderation endpoint only |
| TASK-014 | Subscription plan/status contract | Loading, loaded, error, dismissed paywall | Repository, state, paywall widgets | Profile/subscription feature |
| TASK-015 | Recorded performance/accessibility baseline | Measured before/after behavior | Semantics, keyboard, constraint, performance tests | Only affected files |

### Technical readiness gate

Before changing code, the manager or coding agent must confirm:

- The task dependencies are complete or explicitly stubbed by an existing contract.
- The APRD and task card agree on scope, anti-scope, state behavior, and acceptance criteria.
- Allowed and locked files are explicit.
- Domain/API serialization names are documented where data crosses a boundary.
- Failure behavior is defined; no silent fallback is implied.
- Tests identify the measurable behavior rather than only checking widget existence.
- The verification command is runnable in the repository's actual toolchain.

If any gate is missing, update the documentation before implementation.

## 4. Protocol for Coding Agents Picking Up a Task

When starting any task card from this backlog, the coding agent MUST execute the following 5-step loop:

1. **Ingest Directives & Task Card**:
   - Read [`.github/copilot-instructions.md`](../../.github/copilot-instructions.md).
   - Read the specific task card (e.g. [`TASK-002-authentication.md`](TASK-002-authentication.md)).
   - Check the **Locked Files** list: do NOT modify any file listed under Locked Files.
2. **Review Anti-Scope**:
   - Explicitly confirm what is NOT being built in this prompt session.
3. **Inspect Target Bounded Context**:
   - Inspect files in the target directory using `view_file` or directory tools.
4. **Implement Vertical Slice**:
   - Follow the unidirectional flow: Domain $\rightarrow$ Data Repository $\rightarrow$ ViewModel/State $\rightarrow$ Presentation/Widgets.
5. **Verify Against Definition of Done**:
   - Run the specified verification commands:
     ```bash
     dart format --output=none --set-exit-if-changed .
     flutter analyze
     flutter test test/features/<feature>/
     ```
   - Only declare completion once all tests pass with zero warnings.
