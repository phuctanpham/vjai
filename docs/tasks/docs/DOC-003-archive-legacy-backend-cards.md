# DOC-003: Archive the retired dating cards still in `tasks/backend/`, and fix ID collisions

> **Type:** Documentation follow-up  
> **Status:** Open  
> **Owner:** Product Manager (task folders, status) + Engineering Manager (codebase map)  
> **Raised by:** Backend Developer, backend + AI codebase analysis, 2026-10-30 ([CHG-014](../../changes/CHG-014-mock-first-backend-track.md))  
> **Related:** [CHG-013](../../changes/CHG-013-final-documentation-cleanup.md) (moved the dating backlog to `archive/legacy/`, but not these files)

## What was found

1. `docs/tasks/backend/` still holds 14 retired **dating** cards:
   `TASK-002-authentication.md`, `TASK-003-profile-onboarding.md`,
   `TASK-005-swipe-persistence.md` … `TASK-015-performance-accessibility.md`. The
   backend `README.md` still carries the dating backlog (§1–4, "READY TO CODE"
   statuses, the protocol citing `.github/copilot-instructions.md`).
2. **ID collisions.** These cards reuse IDs of the active mobile tasks
   (`TASK-002`…`TASK-009`) and the new ones (`TASK-010`…`TASK-012`). The Grep that
   CLAUDE.md recommends, `\[TASK-005-S`, cannot tell "Local swipe persistence (dating)"
   from "Local persistence foundation (wardrobe)". An agent that reads the folder
   sees `TASK-013 … Target: backend/app/api/v1/` as a backend card.
3. `docs/tasks/docs/TASK-001-doc-conficts.md` and `TASK-002-securing-power-sync.md`
   break the `DOC-NNN` naming that CHG-013 set for this folder. "conficts" is also
   misspelled.

## Proposed fix

- Move the 14 dating cards to `docs/archive/legacy/tasks-backend/`, unchanged, and
  move the backend README's "Retired dating backlog (history)" section with them.
- Rename `tasks/docs/TASK-001-doc-conficts.md` → `DOC-004-doc-conflicts.md` and
  `TASK-002-securing-power-sync.md` → `DOC-005-securing-power-sync.md`; update the links.
- Update `codebase-map.md` › Docs and the archive index.

## Acceptance criteria

- [ ] `docs/tasks/backend/` holds only BE-NNN and AI-NNN cards and the README.
- [ ] Grep `TASK-0(0[2-9]|1[0-5])` under `docs/tasks/` matches only mobile cards and their links.
- [ ] No history is deleted (CHG-013 rule).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created by the Backend Developer for the APM and ASEM |
