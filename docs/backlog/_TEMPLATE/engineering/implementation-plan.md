# BL-NNN Implementation Plan

## Generated files
| Role | Path | Change |
|---|---|---|
| App Developer | `lib/...` | <create / modify: what> |
| Backend Developer | `backend/...` | <create / modify: what> |

**Order:** <which role goes first, if both>. **Locked:** every path not listed above.

## State model
| Status | Trigger | UI | Actions |
|---|---|---|---|

## Contracts
- **Boundary:** <which layer owns what>
- **Data:** <entities and endpoints; link to data-schema.md sections; new fields are added there first>
- **Failure behaviour:** <what is visible to the user; what must never be swallowed>

## Sequence
1. <Domain → data → ViewModel → presentation, or endpoint → model → fixture>

## Verification
<Focused gate commands from ci-cd.md.>

## Engineering acceptance
<ASEM: date, definition-of-done result, notes.>

## Change history

| Date | CHG | Change |
|---|---|---|
