I found 16 conflicts between the repo's docs and the Flow Spec. The cause is mostly one thing: the repo's policy files still describe the old dating app, while the task cards and change records follow the spec.

**🔴 High: these will mislead developers now**

| # | Repo doc › position | Spec › position | Conflict | Simplest fix |
|---|---|---|---|---|
| 1 | `policies/product/design-system.md` › §1–4 | T7 › G0–G4 | Still the dating theme: coral seed `#FF4B6E`, Material type, 48 px targets, radius 12/16/20, fire-icon brand, "You're all caught up!" | Replace it with a pointer to T7 (CHG-003 already asks for this) |
| 2 | `policies/product/terminology.md` › whole table | T7 › G4 copy, T2 data names | Only dating terms (Profile, Swipe, Match). Agents are told to use this file | Swap in the wardrobe terms from TASK-001; mark the dating terms as retired |
| 3 | `policies/engineering/data-schema.md` › §1–5 | T2 API (`/v1/studio`…), T4 schema | camelCase JSON, `usr_NN` IDs, `/api/v1/discovery` routes, dating storage keys | Point it to CHG-005's phone schema v1 and the T2 API |
| 4 | `policies/engineering/architecture.md` › §1, §4; `decisions.md` › D-004 | T4 › DB1–DB3 (MongoDB + PowerSync + auth) | Backend is "mock only: no databases, no real auth" | Decide BE-001 before P3 and replace D-004 |
| 5 | `docs/README.md` › §5 rule 7 (precedence) | — | The Flow Spec isn't in the precedence list, so policies can outrank it; CHG-003 W-11 says T7 wins | Add "Flow Spec (T7 for UI)" above policies |
| 6 | CHG-005 › schema (`gu_match_sessions`, `outfit_candidates` "written on the phone in P2–P3") | T4 › phone schema: server-only, client writes rejected | In P3, the phone's writes to these tables would be queued and later rejected. My earlier reply ("BE-004 timing") caused this | From P3, fake decks go to a local-only table until P4 |

**🟡 Medium: scope and version drift**

| # | Repo doc › position | Spec › position | Conflict | Simplest fix |
|---|---|---|---|---|
| 7 | `tasks/mobile/README.md` › Explicitly deferred | T6 › P1-04, P1-08, P1-10, P1-11, P1-12 | First launch, item detail, manual wear logging, Flows C/D and the account hub are deferred; the spec puts them in P1 | Update the spec's T6 to match what was decided |
| 8 | CHG-005 › P2-D2 | T6 › P2-03 (partly), P2-05 to P2-08 | Impact metrics, rewards, check-ins, notifications, calendar, data export and poster are deferred | Same: update T6 |
| 9 | `tasks/mobile/README.md` › phase rules | T6 › "each phase starts at the first-launch screen" | No first-launch screen exists (gap ①) | Spec gap ① first, or change the T6 wording |
| 10 | `tasks/mobile/Garblo Flow Spec.html` | Published spec is v2.7.1 | The repo copy is v2.7 and lacks the P1-02 colour fix | Replace the repo copy |
| 11 | CHG-003 › Q-01 | T7 › G3 1a consent card | Still "open: hide the line". You decided: show only what's true in each phase | Close Q-01 with that decision |
| 12 | CHG-005 › P2-D3 | UC-09 › AC-09.1 "bell › gear" | The repo follows Avatar › Privacy & data; the spec's UC-09 still says bell › gear | Fix the spec (still pending on my side) |

**🟢 Low: tidy-up**

| # | Repo doc › position | Spec › position | Conflict | Simplest fix |
|---|---|---|---|---|
| 13 | `decisions.md` › D-003; CHG-003 › Q-02 | T7 › G1: 600 / 840 / 1024 | The repo uses 800 (accepted for the pilot); the Archive switches to 3 columns at 800, the spec at 600 | Record it as an accepted deviation |
| 14 | BE-006 › Scope (4 streams) | T4 › Sync Streams (5) | `my_progress` is missing | Note it as deferred with Flow C |
| 15 | BE-006 › "No DB-enforced uniqueness" | T4 › MongoDB unique index on `{user_id, worn_date, signature}` | That rule is for the phone, but it reads as if it covers MongoDB too | Add: "phone only; MongoDB keeps the unique index" |
| 16 | `docs/specs`, `docs/architecture`, `docs/quality`, `backlog/BL-00x` (dating) | — | `docs/README.md` says these were replaced, but they still exist without a "superseded" mark | Mark them superseded, or delete them in one change record |

## Refactoring plan and execution status

The refactor is split by decision dependency so an unresolved backend choice
does not get encoded into an active policy:

| Batch | Sections/documents | Status |
|---|---|---|
| 1 · authority migration | `docs/README.md` precedence; root [README.md](../../../README.md); [GUIDE.md](../../archive/legacy/GUIDE.md); `.github/copilot-instructions.md`; `backend/README.md`; product and engineering policies; [CHG-007](../../changes/CHG-007-documentation-authority-migration.md) | **Applied** |
| 2 · backend decision | `policies/engineering/architecture.md` §4 and `policies/engineering/decisions.md` D-004, after [BE-001](../backend/BE-001-platform-decision.md) | **Blocked** |
| 3 · Flow Spec reconciliation | T4 phone write ownership, T6 phase scope/entry point, T7 consent truth, UC-09 navigation, and the v2.7.1 source version | **Pending v2.8** |
| 4 · accepted deviations | CHG-003 Q-01/Q-02, CHG-005 schema wording, BE-006 sync streams and uniqueness wording | **Pending** |
| 5 · legacy cleanup | Mark `docs/archive/legacy/specs/`, `docs/archive/legacy/architecture/`, `docs/archive/legacy/quality/` and dating backlog items as superseded, or remove them under a separate change | **Applied for legacy directories; dating backlog review pending** |

Batch 1 is complete in CHG-007. The checked-in Flow Spec already contains the
v2.7.1 P1-02 correction; its existing working-tree change is preserved and is
not part of the policy migration. Do not update the backend architecture or
decision record until BE-001 is resolved, and do not delete legacy documents
under this task.

The former `docs/architecture/`, `docs/specs/` and `docs/quality/` directories
are preserved under [`docs/archive/legacy/`](../../archive/legacy/), alongside
the retired dating backlog. Active documents remain centralized in
`policies/`, `changes/`, `tasks/`, `memory/` and `reports`. The duplicate
`docs/docs/` snapshot was removed under CHG-013, and the Type 1 root README and
adapter references were updated in the integration pass.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-013](../../changes/CHG-013-final-documentation-cleanup.md) | Recorded final archive relocation and completed the Type 1 integration pass. |