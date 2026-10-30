# Domain Glossary & Ubiquitous Language

To prevent semantic drift, hallucinations, and naming inconsistencies across agent sessions, all code, comments, and prompts must adhere strictly to these canonical definitions.

---

## 1. Domain Entities & Value Objects

| Term | Canonical Code Symbol | Definition | Prohibited Synonyms |
|---|---|---|---|
| **Candidate / Profile** | `Profile` | A discoverable user entity shown in the discovery feed containing bio, age, location, and photos. | `User`, `Account`, `TargetUser`, `CardData`, `Item` |
| **Swipe Interaction** | `SwipeType` | The user's decision on a profile: `like`, `pass`, or `superlike`. | `Action`, `Vote`, `Choice`, `Direction` |
| **Discovery Feed** | `DiscoveryState` | The finite state representing candidate browsing, remaining count, and status. | `CardStack`, `TinderFeed`, `SwipeDeck` |
| **Mutual Match** | `Match` | An event/entity formed when two users reciprocate likes. | `Pair`, `Connection`, `Link`, `Friend` |
| **Conversation** | `Conversation` | A 1-to-1 messaging thread established between matched users. | `ChatRoom`, `Channel`, `DirectMessage` |
| **Message** | `Message` | A single textual or media transmission inside a conversation. | `ChatEntry`, `Comment`, `Post` |
| **Session** | `AuthSession` | The authentication credential state holding JWT tokens and user ID. | `LoginState`, `Credentials` |

---

## 2. Technical & Architecture Terms

| Term | Context | Definition |
|---|---|---|
| **ViewModel** | Presentation | A Riverpod `StateNotifier` or `Notifier` holding state and handling user actions. Never imports UI widgets. |
| **Repository** | Data / Domain | An abstract Dart class defining the contract for data operations. Implementation can be mock or remote. |
| **Adaptive Layout** | Presentation | Layout that dynamically shifts structure based on available constraint width via `LayoutBuilder`, not OS checks. |
| **Bounded Vertical Slice**| Workflow | An end-to-end user slice spanning UI, ViewModel, Repository, Mock/API, and Tests delivered as a unit. |
| **Anti-Scope** | Specification | Explicit list of forbidden implementations to prevent agent over-engineering. |
| **Definition of Done (DoD)**| Verification | Automated checklist of tests, formatting, and analysis required before merging. |

