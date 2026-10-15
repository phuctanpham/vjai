# Garblo Vertical Slice Backlog

This backlog outlines the planned vertical slices for Garblo. Each task represents an end-to-end slice spanning presentation, state management, repository, backend API/mock, and tests.

---

### Phase 1: Foundation & Discovery (Current)
- [x] **Task 1: App Shell and Architecture Foundation**
  - Setup Flutter project structure, Riverpod state management, Material 3 theming, and routing.
  - Setup Python/FastAPI mock backend with `uv`.
- [x] **Task 4: Discovery with Mock Data**
  - Implement discovery feed, Profile domain entity, `DiscoveryViewModel`, adaptive layout (mobile touch cards and desktop multi-column view), explicit status handling (`initial`, `loading`, `loaded`, `empty`, `error`), and unit/widget test suites.

---

### Phase 2: Identity & Onboarding
- [ ] **Task 2: Authentication**
  - Login / Signup UI with email and OAuth providers.
  - Session token storage in `core/storage`.
  - Auth state notifier and route guarding.
- [ ] **Task 3: Profile Onboarding**
  - Multi-step profile setup wizard (name, birthdate, photos, bio, interests).
  - Client-side image cropping and validation.
  - Backend profile creation endpoint.

---

### Phase 3: Core Social Mechanics
- [ ] **Task 5: Swipe Persistence & Local Caching**
  - Local SQLite / Hive persistence for swipe history to prevent duplicate profiles offline.
  - Batching offline swipes for synchronization.
- [ ] **Task 6: Backend Discovery API Integration**
  - Connect Flutter `DiscoveryRepository` to FastAPI backend `/api/v1/discovery` and `/api/v1/swipes`.
  - Geo-distance filtering and pagination cursor.
- [ ] **Task 7: Mutual Match Formation**
  - Match detection algorithm on swipe.
  - "It's a Match!" celebration modal overlay on client.
  - Direct deep link to message thread.
- [ ] **Task 8: Match List & Connections Tab**
  - Grid/list view of active matches with unread indicators.
  - Search and filter matches by name or recent activity.

---

### Phase 4: Communication
- [ ] **Task 9: Chat History & Thread UI**
  - Message bubble presentation with timestamp and delivery receipts.
  - Pagination for historical chat messages.
- [ ] **Task 10: Realtime Chat with WebSockets**
  - WebSocket connection for instant duplex messaging.
  - Typing indicators and active presence status.

---

### Phase 5: Trust, Safety & Operations
- [ ] **Task 11: Push & In-App Notifications**
  - Firebase Cloud Messaging (FCM) integration for mobile and desktop notification center.
  - Notification preference settings.
- [ ] **Task 12: Blocking and Reporting**
  - User safety actions: block profile, report for inappropriate content.
  - Instant removal of blocked profiles from discovery and match lists.
- [ ] **Task 13: Content Moderation**
  - Automated keyword and image safety filtering.
  - Admin moderation review endpoints.

---

### Phase 6: Monetization & Polish
- [ ] **Task 14: Subscriptions & Premium Features**
  - In-app purchases for Garblo Gold/Plus (unlimited likes, rewind swipe, passport location).
  - Premium paywall UI.
- [ ] **Task 15: Performance, Offline Resilience & Accessibility**
  - Semantics annotations for screen readers.
  - Image caching and prefetching optimization.
  - Desktop keyboard shortcuts (Arrow keys for swipe).

