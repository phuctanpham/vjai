# APRD-007: Mutual Match Formation & Celebration

> **Status:** Accepted for implementation  
> **Target bounded context:** `lib/features/matching/` and the Discovery swipe integration

## 1. Goal

Represent a mutual `Match` and show a celebratory modal when a qualifying mock swipe produces one.

## 2. Scope

### In scope

- `Match` entity with identity, matched profile, and creation time.
- Matching repository contract and deterministic mock match behavior.
- Discovery swipe outcome carrying an explicit match event.
- Responsive `MatchCelebrationDialog`.
- Keep Swiping dismissal and Send a Message navigation callback.

### Anti-scope

- No confetti package.
- No audio.
- No push notifications.
- No production matching algorithm or remote match service.

## 3. Acceptance criteria

- Like or superlike on `usr_01` emits one match event.
- The dialog displays “It's a Match!” and the matched profile name.
- Keep Swiping closes the dialog.
- Send a Message invokes the chat placeholder route.
- Non-match profiles never open the dialog.

## 4. Verification

Run `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, and matching plus Discovery match tests.
