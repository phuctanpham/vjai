# TASK-015: Performance & Accessibility Polish

> **Phase:** 6 — Quality  
> **Status:** Planned  
> **Target:** `lib/` and `test/`  
> **Dependencies:** TASK-008, TASK-009, and TASK-011

## Objective

Improve measurable responsiveness, semantics, keyboard navigation, and layout resilience across completed slices.

## Allowed files

Only files with a demonstrated performance or accessibility issue, plus focused tests and documentation.

## Locked files

Do not refactor feature architecture or introduce unrelated product behavior.

## In scope

- Accessibility labels, focus order, and sufficient touch targets.
- Keyboard navigation for desktop views.
- Avoidable rebuild and image-loading improvements.
- Golden or constraint tests for critical responsive states.
- Baseline measurements and documented thresholds before changes.

## Anti-scope

No broad rewrite, speculative optimization, analytics SDK, or visual redesign unrelated to an identified issue.

## Acceptance criteria

- Critical interactive controls have semantic labels.
- Mobile and desktop layouts remain valid at their documented breakpoints.
- Targeted performance measurements improve or remain within the recorded baseline.
- `flutter analyze` and all affected tests pass.

## Technical implementation contract

- **Boundary:** changes remain limited to measured hotspots or accessibility defects; no architecture rewrite is permitted.
- **Measurement:** record the baseline, target threshold, device/layout conditions, and post-change result in the task or pull request.
- **Failure behavior:** accessibility regressions and threshold misses block completion rather than being waived silently.
- **Test matrix:** semantics tree, focus order, keyboard interaction, touch target constraints, responsive constraints, and targeted performance measurement.

## Verification

Run format, `flutter analyze`, focused tests, and the full `flutter test` suite.
