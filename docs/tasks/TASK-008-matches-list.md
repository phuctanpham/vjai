# TASK-008: Match List & Connections View (Vertical Slice)

> **Sprint**: Phase 3 (Core Social Mechanics)  
> **Status**: Ready for Agent Execution  
> **Target Bounded Context**: `lib/features/matching/`  
> **Dependencies**: TASK-007 (Mutual Match Formation)  
> **Estimated Agent Prompts**: 1 bounded session  

---

## 1. Context & Objective
Build the dedicated **Matches & Connections** tab in the application. Users can view their active mutual matches, browse a horizontal carousel of "New Matches", and view a list of existing connection threads. The view adapts across mobile (tabs) and desktop (sidebar item) and connects directly to the shared `MatchingRepository`.

---

## 2. File Confinement

### Files to CREATE or MODIFY
- `lib/features/matching/presentation/matches_state.dart` (MatchesState with explicit loading/loaded/empty/error status)
- `lib/features/matching/presentation/matches_view_model.dart` (StateNotifier fetching matches list)
- `lib/features/matching/presentation/matches_view.dart` (Primary screen displaying matches)
- `lib/features/matching/presentation/widgets/new_matches_carousel.dart` (Horizontal avatar story bubbles)
- `lib/features/matching/presentation/widgets/match_list_item.dart` (Tile with avatar, name, last interaction, unread dot)
- `lib/app/router.dart` (Add `/matches` route)
- `test/features/matching/presentation/matches_view_model_test.dart`
- `test/features/matching/presentation/matches_view_test.dart`

### LOCKED Files (Strict Anti-Touch)
- `lib/features/auth/*`
- `lib/features/onboarding/*`

---

## 3. In-Scope vs. Explicit Anti-Scope

### In-Scope (Strict Requirements)
- Top section: "New Matches" horizontal carousel displaying rounded avatar bubbles with user names.
- Bottom section: "Messages / Connections" vertical list showing matched profiles with timestamp teaser (e.g. "Matched 2 hours ago").
- Explicit states:
  - `loading`: Shimmer / skeleton indicator.
  - `empty`: Friendly EmptyView ("No matches yet! Keep swiping in Discovery to find new connections").
  - `loaded`: Populated carousel and list.
- Search input at the top to filter matches by name in real-time.
- Responsive layout:
  - Mobile: Full width scrollable column.
  - Desktop: Integrated inside main scaffold, centered with max width `720px`.
- Unit tests for filtering & status transitions; widget tests for empty and loaded states.

### Anti-Scope (Strictly Forbidden)
- **NO full realtime messaging protocol** (clicking a match opens a placeholder conversation screen).
- **NO voice/video calling buttons**.
- **NO profile blocking flow in this task** (handled in TASK-012).

---

## 4. Finite State Machine (FSM) Matrix

| State | Condition | UI Representation | Actions Available |
|---|---|---|---|
| `loading` | Fetching from repo | Center progress indicator | None |
| `empty` | Zero matches in store | EmptyView with "Start Swiping" button | Tap to route to `/discovery` |
| `loaded` | Matches $> 0$ | New matches carousel + connection list | Search filter, tap match |
| `error` | Repo failure | ErrorView with retry button | Tap retry |

---

## 5. Acceptance Criteria (Gherkin Format)

### Scenario 1: Empty Matches Screen
```gherkin
Given the user has 0 mutual matches
When the MatchesView is rendered
Then the EmptyView must be visible
And the text "No matches yet!" must appear
And tapping the action button must navigate to the Discovery feed
```

### Scenario 2: Populated Matches List
```gherkin
Given the user has 2 matches (Alex Chen and David Kim)
When the MatchesView loads successfully
Then the "New Matches" carousel must display 2 avatars
And the list below must render 2 match list tiles with names and photos
```

### Scenario 3: Real-Time Search Filtering
```gherkin
Given the matches list contains "Alex Chen" and "David Kim"
When the user types "Alex" into the search bar
Then only "Alex Chen" must be displayed in the list
And "David Kim" must be filtered out
```

---

## 6. Verification Commands

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test test/features/matching/
```

