# Definition of Done

A delivery is done when every box is true. The ASEM checks this list and records the result in the item's implementation plan.

- [ ] Every changed file is listed for that developer role in the implementation plan.
- [ ] Nothing from the item's anti-scope is implemented.
- [ ] Every scenario in `uat.feature` has a passing test named with its ID ([tdd.md](tdd.md)).
- [ ] The report shows a red run before the green run.
- [ ] All gates in [ci-cd.md](ci-cd.md) pass for the touched toolchain, or are reported as skipped with the reason.
- [ ] Architecture rules hold ([architecture.md](architecture.md)): no repository or JSON in widgets, no `Platform.isX` in widgets, explicit states.
- [ ] Conventions hold ([coding-conventions.md](coding-conventions.md)), and wire shapes match [data-schema.md](data-schema.md).
- [ ] No new dependency without a [decisions.md](decisions.md) entry.
- [ ] No secrets, personal data, debug scripts or scratch files.
- [ ] A report exists in `docs/reports/`, with doc issues and lesson candidates filled in (or "none").

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Moved from `docs/quality/DOD.md`; commands moved to ci-cd.md, test rules to tdd.md |
