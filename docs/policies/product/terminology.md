# Terminology

Canonical domain terms. Use the **code symbol** in code, tests, Gherkin steps and documents. Prohibited synonyms must not appear anywhere.

| Term | Code symbol | Definition | Prohibited synonyms |
|---|---|---|---|
| Profile | `Profile` | A discoverable person shown in the discovery feed: name, age, bio, occupation, distance, interests, photos | User, Account, TargetUser, CardData, Item |
| Candidate | `Profile` | A `Profile` while it is shown in the discovery feed | — |
| Swipe | `SwipeType` | The user's decision on a candidate: `like`, `pass` or `superlike` | Action, Vote, Choice, Direction |
| Discovery feed | `DiscoveryState` | The queue of candidates being browsed, with its status and remaining count | CardStack, TinderFeed, SwipeDeck |
| Match | `Match` | Formed when two people like each other | Pair, Connection, Link, Friend |
| Conversation | `Conversation` | A 1-to-1 message thread between matched people | ChatRoom, Channel, DirectMessage |
| Message | `Message` | One transmission inside a conversation | ChatEntry, Comment, Post |
| Session | `AuthSession` | The signed-in state: user ID, token, expiry | LoginState, Credentials |
| Onboarding draft | `OnboardingDraft` | An unfinished profile being built during onboarding | ProfileForm, SignupData |
| Report | `Report` | A user's complaint about a profile, with a reason | Flag, Complaint |
| Block | `Block` | A user's decision to hide a profile permanently | Ban, Mute |

## UI states
Every screen that loads data uses these state names: `initial`, `loading`, `loaded`, `empty`, `error`.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Moved from `docs/architecture/GLOSSARY.md` (domain terms only; technical terms moved to architecture.md); added Onboarding draft, Report, Block |
