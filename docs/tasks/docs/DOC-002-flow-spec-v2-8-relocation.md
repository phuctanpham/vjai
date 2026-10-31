# DOC-002: Flow Spec v2.8 relocation and contract ripple

> **Type:** Documentation follow-up  
> **Status:** Open · needs the human (Type 1 files) plus the Product Manager and Engineering Manager  
> **Owner:** Product Manager + Engineering Manager; the human for Type 1 files  
> **Raised by:** Backend Developer, backend + AI codebase analysis, 2026-10-30 ([CHG-014](../../changes/CHG-014-mock-first-backend-track.md))  
> **Related:** [DOC-001](DOC-001-phase-history-reconciliation.md) item 4 (authoritative spec version)

## What was found

The working tree on 2026-10-30 (uncommitted) **deletes** `docs/tasks/mobile/Garblo Flow Spec.html`
(v2.7) and `docs/policies/product/Garblo UI UX Design System Handbook.md`, and **adds**
`docs/specs/` with three Markdown files:

- `Garblo Flow Spec.md`, v2.8, 30 Oct 2026;
- `Garblo UI UX Design System Handbook.md`;
- `Garblo — Đặc tả cơ sở dữ liệu (DRS + DDS).md` (the "DB handbook", English text with a Vietnamese file name).

## Conflicts to resolve

| # | Where | Problem | Proposed fix | Owner |
|---|---|---|---|---|
| 1 | `.claude/skills/flow-spec/` (`SKILL.md`, `section.sh`), `.agents/skills/flow-spec/` (`SKILL.md`, `section.sh`, `section.ps1`), `GEMINI.md`; `CLAUDE.md` "Never read the 490 KB HTML" | Point to the deleted HTML; anchors (`#platform`) do not exist in the Markdown | Re-point the skill to `docs/specs/Garblo Flow Spec.md` and map anchors to headings, or keep an HTML copy | Human (Type 1) |
| 2 | `codebase-map.md` › Docs, `tasks/mobile/README.md` › Source (v2.7), CHG-013 › Flow Spec basis, DOC-001, every `Garblo%20Flow%20Spec.html#…` link | Dead links after the delete | Replace the links; record the version change | ASEM, APM |
| 3 | Spec v2.8 T2 › Sync contract, T4 › DB5 | REST + SSE surface removed; the app reads and writes only its local DB; one write endpoint | Backend cards updated under CHG-014. Still open: [data-schema.md](../../policies/engineering/data-schema.md) §1 ("Backend platform and wire contracts: BE-001") and §5; [architecture.md](../../policies/engineering/architecture.md) §4 | ASEM |
| 4 | DB handbook › §1 | Cites **D-009** for the one-piece data flow, but repo D-009 is the PowerSync security baseline; cites **D-010, D-011, D-013**, which do not exist in `decisions.md` | Add the missing decisions with numbers that do not collide, and fix the handbook's references | ASEM |
| 5 | DB handbook › §1 note | Cites `CHG-007-one-piece-data-flow-and-rustfs.md`, which is not in the repo; repo CHG-007 is the documentation authority migration (two CHG-007s) | Import that CHG under a new number and re-point the references | ASEM, APM |
| 6 | DB handbook › decision 10 | "One Claude Doc … diagrams drawn in the doc (a deliberate deviation from the repo's Mermaid rule)", while README §3 rule 6 says diagrams are Mermaid in the owning document | Decide whether the handbook is a followed (Type 2) file; if so, give it an owner and a Change history table (README §3 rule 7) | Human, ASEM |
| 7 | README §5 rule 7 precedence | Lists "Flow Spec (T7/T2/T4/T6)" but not the DB handbook; the handbook and CHG-005 both define columns (see [TASK-011](../mobile/TASK-011-phone-schema-v2-alignment.md)) | Place the handbook in the precedence list (proposed: with T4, below the Flow Spec) | Human |
| 8 | DB handbook › GM-02 session statuses; §13 `privacy_requests` statuses | Values not in Flow Spec T2 › Enums | Add them to T2 or mark them as the handbook's proposal | APM |
| 9 | [coding-conventions.md](../../policies/engineering/coding-conventions.md) §2 | "`Field(alias="camelCase")`" contradicts the snake_case column names of the sync contract | Sync models use column names, no alias (CHG-014) | ASEM |
| 10 | [tdd.md](../../policies/engineering/tdd.md) §3 | Scenario-ID test names (`'[BE-012-S01] …'`) are impossible as pytest function names | `test_be012_s01_<slug>` + docstring `[BE-012-S01] …`; select with `-k` (CHG-014) | ASEM |
| 11 | [ci-cd.md](../../policies/engineering/ci-cd.md) §2 | Says `uv.lock` is committed; it is not, and the backend gate fails to build | Fixed by [BE-010](../backend/BE-010-restore-backend-gate.md); update the text after it merges | ASEM |
| 12 | Design System Handbook moved from `policies/product/` to `specs/` | `design-system.md` and T7 references may point to the old path | Check and re-point | APM |

## Acceptance criteria

- [ ] The spec files are committed (or the delete is reverted) in one reviewed change.
- [ ] `flow-spec` lookups work on the new file.
- [ ] No link in `docs/` (outside `archive/`) points to the deleted paths.
- [ ] Each row above has a decision, owner and date; policy edits name their CHG.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-014](../../changes/CHG-014-mock-first-backend-track.md) | Created by the Backend Developer for the APM, ASEM and human |
