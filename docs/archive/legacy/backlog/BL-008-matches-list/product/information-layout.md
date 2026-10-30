# BL-008 Information Layout

Content in order of priority, top to bottom:

| # | Block | Content | Mobile (< 800) | Desktop (≥ 800) |
|---|---|---|---|---|
| 1 | Search | Text field, placeholder "Search matches" | Full width, below app bar | Inside content column |
| 2 | New Matches | Horizontal carousel: avatar bubble + first name | Scrolls horizontally | Scrolls horizontally |
| 3 | Connections | List tile: avatar · name · "Matched {relative time}" · unread dot | Full width | Content column centred, max width 720, sidebar on the left |

- Search filters blocks 2 and 3 together.
- When search matches nothing, show "No matches for "{query}"" in place of blocks 2 and 3. This is not the empty state.
- Relative time uses the injectable clock (BL-007) so results are deterministic.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Created from TASK-008 scope; no-search-result message added |
