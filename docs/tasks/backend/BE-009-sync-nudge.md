# BE-009: Sync nudge — data-free push when results are ready

> **Owner:** Backend Developer  
> **Status:** Blocked by [BE-001](BE-001-platform-decision.md); needs APNs/FCM credentials (never committed)  
> **Track:** R (real) · spec T3 › Sync model, T4 › Side effects ("sync nudge")  
> **Source:** [DB handbook](<../../specs/Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md>) §11 NT-01…NT-03, §2 C05-07 (the handbook already cites this ID)

## Why

When a worker writes a result row (drafts ready, deck ready, erasure done) while
the app is in the background, a push asks the app to sync. The push carries no data.

## Scope

- Device-token rows per install (`notifications` / device registry, per the handbook
  §11 DDS), removed on erasure (NT-03).
- A nudge carries only a type such as `results_ready` or `deletion_complete` (NT-01);
  at most one per user per minute, duplicates collapsed (NT-02).
- Called from the side-effect registry after BE-014, BE-015 and BE-017 write results.
- Mock: an in-memory `NudgeSender` that records the calls, so the mock track can
  assert "one nudge, no payload" without APNs/FCM.

## Anti-scope

No marketing notifications, no in-app inbox (gap ⑤), no message text with personal data.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created for the ID the DB handbook already cites |
