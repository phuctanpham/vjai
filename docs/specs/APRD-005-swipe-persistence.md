# APRD-005: Local Swipe Persistence & Feed Filtering

> **Status:** Accepted for implementation  
> **Target bounded context:** `lib/features/discovery/` and `lib/core/storage/`

## 1. Goal

Persist demo swipe decisions locally so already-swiped profiles do not reappear after reload, while retaining a reset action for development.

## 2. Scope

### In scope

- Store profile IDs under `garblo_swiped_profile_ids`.
- Filter persisted IDs in `DiscoveryRepository.getProfiles()`.
- Persist a swipe before or during the repository operation using existing storage abstractions.
- Expose `resetFeed()` and a visible Reset Feed History action.
- Transition directly to `DiscoveryStatus.empty` when all profiles are filtered.

### Anti-scope

- No SQLite, Drift, or database package.
- No remote synchronization.
- No rewind or undo behavior.
- No changes to authentication, matching, or chat.

## 3. Acceptance criteria

- Swiping `usr_01` stores that ID.
- Reloading excludes stored IDs and begins at the first remaining profile.
- Exhausting the filtered list renders the existing empty state.
- Reset removes the storage key and restores the full mock feed.

## 4. Verification

Run `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, and `flutter test test/features/discovery/`.
