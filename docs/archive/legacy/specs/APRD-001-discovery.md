# APRD-001: Discovery Feed & Swiping Feature

> **Status**: Accepted & Implemented  
> **Target Bounded Context**: `apps/mobile/lib/features/discovery/`  
> **Companion Mock API**: `backend/app/api/v1/endpoints/discovery.py`

---

## 1. Feature Identity & Goal
Enable users on mobile and desktop to discover candidate profiles, browse detailed bios, and register their swipe intent (`like`, `pass`, `superlike`) with immediate UI feedback and responsive adaptations.

---

## 2. In-Scope vs. Explicit Anti-Scope

### In-Scope (Strict Requirements)
- Domain `Profile` entity and `SwipeType` enum.
- Abstract `DiscoveryRepository` contract with `MockDiscoveryRepository` supporting customizable delay, error injection, and empty queue simulation.
- `DiscoveryViewModel` (Riverpod `StateNotifier`) driving `DiscoveryState`.
- Explicit state handling: `initial`, `loading`, `loaded`, `empty`, `error`.
- Error state with retry action.
- Empty state with feed refresh action.
- Adaptive `DiscoveryLayout`:
  - Mobile (< 800px): Full-bleed touch card, bottom controls.
  - Desktop ($\ge$ 800px): Left sidebar nav, centered card preview, right-side profile metadata panel.
- Widget and unit test coverage.

### Anti-Scope (Strictly Forbidden for this Slice)
- **NO real database connection** (use in-memory mock data).
- **NO real-time WebSockets** or push notifications on match.
- **NO authentication gates** (discovery is accessible directly in the scaffold).
- **NO geolocation distance calculations** (distances are mock fixture values).
- **NO payment paywalls** (e.g. unlimited likes or rewind features).

---

## 3. Finite State Machine (FSM) Matrix

| State (`DiscoveryStatus`) | Trigger | UI Representation | Actions Available |
|---|---|---|---|
| `initial` | DiscoveryView mounted | Centered `CircularProgressIndicator` | Auto-invokes `loadProfiles()` |
| `loading` | Async request initiated | Centered `CircularProgressIndicator` | None (UI blocked from double-swiping) |
| `loaded` | Profiles returned ($> 0$) | `DiscoveryLayout` with `ProfileCard` | `swipe(SwipeType.like)`, `pass`, `superlike`, reload |
| `empty` | Profiles returned ($== 0$) or queue exhausted | `EmptyView` ("You're all caught up!") | `retry()` / Refresh Feed |
| `error` | Repository throws exception | `ErrorView` with error message | `retry()` / Try Again |

---

## 4. Deterministic Acceptance Criteria (Gherkin Format)

### Scenario 1: Initial feed load success
```gherkin
Given the DiscoveryView is rendered
When the view model completes loading profiles from DiscoveryRepository
Then the state.status must be DiscoveryStatus.loaded
And state.currentProfile must display the first candidate in the list
And the profile card must render candidate name, age, and occupation
```

### Scenario 2: Swiping advances candidate queue
```gherkin
Given the user is viewing candidate 1 of 5
When the user taps the 'Like' button
Then state.currentIndex must increment from 0 to 1
And state.currentProfile must be candidate 2
And DiscoveryRepository.recordSwipe must be called with swipeType=like
```

### Scenario 3: Candidate queue exhaustion transitions to empty
```gherkin
Given the user is viewing the final candidate in the list
When the user records a swipe (pass or like)
Then state.status must transition to DiscoveryStatus.empty
And the view must render EmptyView with title "You're all caught up!"
And a "Refresh Feed" button must be visible
```

### Scenario 4: Error recovery via retry
```gherkin
Given the repository throws an error on initial load
Then state.status must transition to DiscoveryStatus.error
And the view must render ErrorView with a "Try Again" button
When the user taps "Try Again"
Then the state.status must temporarily become loading
And upon success transition to loaded
```

### Scenario 5: Responsive desktop layout
```gherkin
Given the screen constraints have width >= 800px
When the DiscoveryLayout renders
Then the desktop sidebar with "Discover" and "Matches" must be visible
And the right-side profile inspection panel must be visible
```

---

## 5. Verification Commands

```bash
flutter analyze
flutter test test/features/discovery/
```

