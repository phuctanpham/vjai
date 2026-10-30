# BL-007 Event Stream

| Event | Emitter | Consumer | Payload | Lifetime |
|---|---|---|---|---|
| `MatchFormed` | `DiscoveryViewModel` after a swipe whose outcome is `matched: true` and `recordMatch` succeeded | `DiscoveryView` (shows the dialog once) | `Match` | One-shot. Cleared from state as soon as the view consumes it, so a rebuild never shows the dialog twice |

```mermaid
sequenceDiagram
    actor User
    participant View as DiscoveryView
    participant VM as DiscoveryViewModel
    participant DRepo as DiscoveryRepository
    participant MRepo as MatchingRepository
    participant Dialog as MatchCelebrationDialog

    User->>View: tap Like on Alex Chen
    View->>VM: swipe(like)
    VM->>DRepo: recordSwipe(usr_01, like)
    DRepo-->>VM: SwipeOutcome(matched: true)
    VM->>MRepo: recordMatch(profile)
    MRepo-->>VM: Match
    VM-->>View: state.pendingMatch = Match   (MatchFormed)
    View->>VM: consumeMatch()
    View->>Dialog: showDialog
    alt Keep Swiping
        Dialog-->>View: pop → next candidate visible
    else Send a Message
        Dialog-->>View: pop + pushNamed('/chat', arguments: Match)
    end
```

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Migrated from the TASK-007 sequence diagram; one-shot consumption made explicit |
