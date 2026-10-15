# TASK-005: Local Swipe Persistence & Feed Filtering (Vertical Slice)

> **Sprint**: Phase 3 (Core Social Mechanics)  
> **Status**: Ready for Agent Execution  
> **Target Bounded Context**: `lib/features/discovery/` & `lib/core/storage/`  
> **Dependencies**: TASK-004 (Discovery Feed Scaffold)  
> **Estimated Agent Prompts**: 1 bounded session  

---

## 1. Context & Objective
Currently, `DiscoveryViewModel` advances cards in memory, but reloading the feed or restarting the application returns the original candidate stack. This slice implements persistent local storage of swipe decisions (`like`, `pass`, `superlike`) using `LocalStorage`, filtering already-swiped candidate IDs out of subsequent feed queries, and providing a "Reset Demo Feed" option in settings/app bar for solo developer testing.

---

## 2. File Confinement

### Files to CREATE or MODIFY
- `lib/features/discovery/data/discovery_repository.dart` (Add `getSwipedProfileIds()`, `clearSwipeHistory()`, inject `LocalStorage`)
- `lib/features/discovery/presentation/discovery_view_model.dart` (Persist swipe immediately on action; provide `resetFeed()` method)
- `lib/features/discovery/presentation/discovery_view.dart` (Add "Reset Swipes" action menu item)
- `test/features/discovery/data/discovery_repository_test.dart` (Test persistence & filtering)
- `test/features/discovery/presentation/discovery_view_model_test.dart` (Test feed without already swiped profiles)

### LOCKED Files (Strict Anti-Touch)
- `lib/features/auth/*`
- `lib/features/chat/*`
- `lib/features/matching/*`

---

## 3. In-Scope vs. Explicit Anti-Scope

### In-Scope (Strict Requirements)
- Store a JSON string or comma-separated list of swiped profile IDs in `LocalStorage` under key `garblo_swiped_profile_ids`.
- `DiscoveryRepository.getProfiles()` must load swiped IDs and exclude them from returned candidates.
- If all available profiles have been swiped, the feed must transition directly to `DiscoveryStatus.empty`.
- Add an action button/popup menu in `DiscoveryView` app bar: "Reset Feed History" which clears stored swipes and reloads the full sample stack.
- Unit and widget tests proving persistence and filtering.

### Anti-Scope (Strictly Forbidden)
- **NO SQLite (sqflite) or Drift native database dependencies** (use existing `LocalStorage` interface).
- **NO remote cloud sync of offline swipes**.
- **NO undo/rewind animation mechanics** (keep implementation minimal).

---

## 4. Finite State Machine (FSM) Matrix

| Condition | In-Memory Profiles | Stored Swiped IDs | Resulting `DiscoveryStatus` |
|---|---|---|---|
| Fresh Install | 5 profiles | `[]` | `DiscoveryStatus.loaded` (Candidate 1 shown) |
| 3 Swipes Persisted | 5 profiles | `['usr_01', 'usr_02', 'usr_03']` | `DiscoveryStatus.loaded` (Candidate 4 shown) |
| All Swiped | 5 profiles | `['usr_01'...'usr_05']` | `DiscoveryStatus.empty` ("You're all caught up!") |
| "Reset Feed" Tapped | 5 profiles | Cleared to `[]` | `DiscoveryStatus.loaded` (Candidate 1 shown) |

---

## 5. Acceptance Criteria (Gherkin Format)

### Scenario 1: Swiping Persists Profile ID
```gherkin
Given the user is viewing candidate "usr_01"
When the user taps "Like"
Then LocalStorage must contain "usr_01" in "garblo_swiped_profile_ids"
And state.currentIndex must increment
```

### Scenario 2: Swiped Profiles Filtered On Reload
```gherkin
Given LocalStorage already contains swiped IDs ["usr_01", "usr_02"]
When DiscoveryViewModel.loadProfiles() executes
Then the returned profiles list must NOT contain "usr_01" or "usr_02"
And the first profile rendered must be "usr_03"
```

### Scenario 3: Resetting Swipes Restores Full Feed
```gherkin
Given all profiles have been swiped and state is DiscoveryStatus.empty
When the user taps "Reset Feed History"
Then LocalStorage key "garblo_swiped_profile_ids" must be removed
And state.status must transition to DiscoveryStatus.loaded
And candidate "usr_01" must be visible again
```

---

## 6. Verification Commands

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test test/features/discovery/
```

