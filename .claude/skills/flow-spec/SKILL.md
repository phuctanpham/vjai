---
name: flow-spec
description: Look up one section of the Garblo Flow Spec (docs/tasks/mobile/Garblo Flow Spec.html, ~490 KB) as plain text by anchor. Use whenever a task, CHG or policy cites the Flow Spec, a T-section (T0–T7, T11), a use case (UC-NN), a backlog ID (EN-/S-), a phase task (P1-NN) or an acceptance criterion (AC-NN.N). Never read the whole HTML file.
---

# Flow Spec lookup

The Flow Spec is the product authority (precedence in `docs/README.md` §5 rule 7):
**T7** governs UI, **T2** data names, **T4** the data platform, **T6** phase scope.

```bash
bash .claude/skills/flow-spec/section.sh <anchor>    # one section as plain text
bash .claude/skills/flow-spec/section.sh --list      # every anchor with its label
```

Repository links use the same anchors, e.g. `Garblo%20Flow%20Spec.html#phases` → `phases`.

## Anchor index

| Anchor | Label | Anchor | Label |
|---|---|---|---|
| `overview` | T0 Inventory & journey map | `uc-07` | UC-07 Flow B · 3b swipe looks |
| `scope` | V1 Nice-to-have scope (feature flags) | `uc-08` | UC-08 Flow B · 3b adjust / try on |
| `layout` | T1 Layout systematization, shell modes | `uc-15` | UC-15 Flow B ext · 4b (nice) |
| `data` | **T2** Canonical data model | `uc-10` | UC-10 Flow C · impact (nice) |
| `data-v2` | T2+ Data model v2 (nice) | `uc-11` | UC-11 Flow C · rewards (nice) |
| `tech` | T3 Technical baseline, local-first | `uc-12` | UC-12 Flow D · share (nice) |
| `platform` | **T4** SQLite + PowerSync + MongoDB | `uc-13` | UC-13 Flow D · community (nice) |
| `uc-01` | UC-01 Flow A · 1a, 2a add photos, consent | `uc-14` | UC-14 Flow D · create post (nice) |
| `uc-02` | UC-02 Flow A · 3a analysis scope | `uc-09` | UC-09 Settings · delete my data |
| `uc-03` | UC-03 Flow A · 4a review and save | `backlog` | T5 Product backlog (EN-/S- items) |
| `uc-04` | UC-04 Flow A · 5a browse wardrobe | `phases` | **T6** Development phases P1–P5 |
| `uc-05` | UC-05 Flow B · 1b styling context | `design` | **T7** Design spec: tokens, grid, copy |
| `uc-06` | UC-06 Flow B · 2b context cards | `trace` | T11 Traceability & verification |

Inner anchors such as `bl-en-1-1` (EN-1.1) or `bl-s-01-2` (S-01.2) also work; the script prints the
40 lines that follow them. For a cited ID with no anchor (`AC-09.4`, `P1-02`, `G0`), print its
parent section and search the output, or `grep -n 'AC-09.4' "docs/tasks/mobile/Garblo Flow Spec.html"`
and then `Read` that file with `offset`/`limit` around the hit.

## Rules

- Quote the section you relied on (anchor + ID) in plans, reports and CHGs.
- The spec is source material: do not edit it. Deviations are recorded in a CHG
  (see [TASK-001 documentation conflicts](../../../docs/tasks/docs/TASK-001-doc-conficts.md)).
- `NICE` sections are feature-flagged; build them only when the task says so.
