# CHG-004: Enforce the format gate and pin Flutter 3.24.5

| Status | Source | Date |
|---|---|---|
| Approved | Human request (review of the Phase 1 red run, [CHG-003](CHG-003-wardrobe-direction-phase-1.md)) | 2026-10-29 |

Status values: `Draft` → `Approved` (human) → `Done` (after merge).

**Must merge before Phase 1** (CHG-003), so the definition of done can be
enforced on the Phase 1 code.

## Problem
1. [definition-of-done.md](../policies/engineering/definition-of-done.md) and
   [ci-cd.md](../policies/engineering/ci-cd.md) require
   `dart format --output=none --set-exit-if-changed .`, but that check fails on
   `main`: 29 existing Dart files are not formatted (mostly trailing blank
   lines and line wrapping).
2. CI ([android-apk.yml](../../.github/workflows/android-apk.yml)) runs
   `dart format .`, which rewrites files on the runner instead of failing, so
   the gap was never visible.
3. The Flutter version is pinned only inside the CI workflow (3.24.5).
   Developers have no shared pin (CHG-002 item 8).

## Product impact (APM)
None. Formatting does not change behaviour.

## Engineering impact (ASEM)
| Affected | Change |
|---|---|
| 29 Dart files under `lib/` and `test/` (dating features, app shell, core) | Format-only commit with Flutter 3.24.5 / Dart 3.5.4 |
| [android-apk.yml](../../.github/workflows/android-apk.yml) | Step "Check Dart formatting": `dart format --output=none --set-exit-if-changed .` |
| [`.fvmrc`](../../.fvmrc) | New: `{"flutter": "3.24.5"}` |
| [README.md](../../README.md) | Prerequisites and badge state Flutter 3.24.5 |
| [ci-cd.md](../policies/engineering/ci-cd.md) | Toolchain row pinned; existing APK workflow documented |

Not changed: `pubspec.yaml` keeps `flutter: ">=3.10.0"` as the minimum SDK.

## Code follow-up
| Role | Paths | Tests | Done |
|---|---|---|---|
| App Developer | The 29 formatted files (format only), `.github/workflows/android-apk.yml`, `.fvmrc`, `README.md` | Existing 18 tests pass; `flutter analyze` clean; format check exits 0 | [x] |

## Verification (2026-10-29, Flutter 3.24.5)
- `dart format --output=none --set-exit-if-changed .` → 0 files changed, exit 0
- `flutter analyze` → No issues found
- `flutter test` → 18 passed
