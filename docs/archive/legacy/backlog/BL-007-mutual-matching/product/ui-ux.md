# BL-007 UI/UX: Match celebration dialog

| Element | Spec |
|---|---|
| Title | "It's a Match!", `headlineMedium`, bold, primary-to-tertiary gradient text |
| Subtitle | "You and {name} liked each other." |
| Visual | Two overlapping circular avatars (the user's own avatar falls back to the brand icon until BL-003 exists) with a heart badge between them |
| Primary action | Filled button "Send a Message" |
| Secondary action | Outlined button "Keep Swiping" |
| Entry animation | Scale 0.8 → 1.0 with `Curves.easeOutBack`, 300 ms; Flutter built-ins only |
| Mobile (< 800) | Full-width dialog with 16 px side margins |
| Desktop (≥ 800) | Centred card, max width 400 |
| Dismiss | Keep Swiping, or the system back gesture/Escape (same as Keep Swiping) |

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Migrated from TASK-007 scope; animation and dismiss behaviour made explicit |
