# DOC-001: Phase history documentation reconciliation

> **Type:** Documentation follow-up  
> **Status:** Open — blocked on product/Flow Spec authority review  
> **Owner:** Product Manager + Engineering Manager  
> **Related:** [CHG-012](../../changes/CHG-012-compact-context-entry-point.md),
> [CHG-013](../../changes/CHG-013-final-documentation-cleanup.md)

## Objective

Reconcile documentation conflicts discovered during the compact-context
migration without changing implemented Phase 1 or Phase 2 behavior or
rewriting their historical task records.

## Conflicts in scope

1. **Consent copy:** CHG-003 Q-01 remains open even though Phase 2 strips
   metadata. Confirm the truthful per-phase line for P1 and P2.
2. **Breakpoint:** CHG-003 Q-02 records 800 px while the Flow Spec uses a
   different rail threshold. Confirm the accepted deviation and its scope.
3. **Generated deck ownership:** CHG-005 says `gu_match_sessions` and
   `outfit_candidates` are phone-written through P3; the later platform
   direction may make them server-owned from P3. Confirm the migration wording
   without changing the shipped P2 local implementation.
4. **Source version and phase ladder:** task records cite v2.7 while the
   repository contains later reconciliation claims. Confirm the authoritative
   Flow Spec version and phase scope before updating forward-looking records.

## Acceptance criteria

- [ ] Each conflict has an owner, decision, source anchor and decision date.
- [ ] P1/P2 task cards and delivery history are not rewritten.
- [ ] Any amendment links to the affected CHG and states whether it changes
  future work only.
- [ ] The mobile task index and compact context entry point link to the
  accepted result.
- [ ] No application or backend code changes are introduced.

## Verification

Documentation review only: check links, statuses and consistency against the
Flow Spec sections [T4 `platform`](../../tasks/mobile/Garblo%20Flow%20Spec.html#platform),
[T6 `phases`](../../tasks/mobile/Garblo%20Flow%20Spec.html#phases) and
[T7 `design`](../../tasks/mobile/Garblo%20Flow%20Spec.html#design) using the
`flow-spec` skill. The root `docs/README.md` integration link is also pending
because it is Type 1 and outside the ASEM ownership boundary.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-30 | [CHG-012](../../changes/CHG-012-compact-context-entry-point.md) | Created explicit follow-up for unresolved conflicts affecting implemented Phase 1/2 records. |
| 2026-10-30 | [CHG-013](../../changes/CHG-013-final-documentation-cleanup.md) | Renamed from TASK-003 and retained as the open reconciliation follow-up; historical Phase 1/2 records remain unchanged. |
