# Lessons Learned

Recurring agent failure modes and the rule each produced. Owner: ASEM. Add an entry only when a failure has happened, or is likely to happen again, and a rule prevents it.

| # | Failure mode | Rule it produced |
|---|---|---|
| 1 | Agents proposed a compiled Go backend for what is only a mock | Backend is a mock ([decisions.md](../policies/engineering/decisions.md) D-004) |
| 2 | Agents add `Platform.isX` checks in widgets | Layout by width only ([architecture.md](../policies/engineering/architecture.md) §3) |
| 3 | Agents generate empty use cases, mappers and DTOs | No extra layers ([architecture.md](../policies/engineering/architecture.md) §2) |
| 4 | Agents build features that a placeholder folder hints at (SQLite, WebSockets, auth) | Anti-scope in every item card; only `Ready to code` items ([docs/README.md](../README.md) §5) |
| 5 | Process docs repeated the same rules in 4–5 files and drifted apart | One fact, one place ([docs/README.md](../README.md) §3) |
| 6 | A widget test at the default 800 × 600 surface silently tests the desktop layout | Set the surface size explicitly ([tdd.md](../policies/engineering/tdd.md) §3) |
| 7 | A bulk link rewrite through Windows PowerShell re-encoded 12 UTF-8 docs as Windows-1252 (`—` became `â€”`, tree lines became `â”œâ”€â”€`) | Write docs as UTF-8 with the Edit/Write tools; never round-trip them through `Get-Content`/`Set-Content` ([CLAUDE.md](../../CLAUDE.md) › Guardrails) |

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../changes/CHG-001-agentic-documentation-system.md) | Moved from `docs/agent/`; incidents condensed to one line each; added #5, #6 |
| 2026-10-30 | [CHG-008](../changes/CHG-008-claude-code-adapter.md) | Added #7 (encoding corruption during the CHG-007 link rewrite) |
