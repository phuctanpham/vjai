# CI/CD

## 1. Quality gates (run locally today, in CI once added)

**Flutter** (from the repository root)
```bash
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test                      # or a focused path: flutter test test/features/<feature>/
```

**Backend** (from `backend/`)
```bash
uv sync --extra dev
uv run pytest
```

A gate that cannot run (missing toolchain) is reported as **skipped** with the reason, never as passed.

## 2. Toolchain
| Tool | Version |
|---|---|
| Flutter | **3.24.5** (Dart 3.5.4), pinned in [`.fvmrc`](../../../.fvmrc) and the CI workflow ([CHG-004](../../changes/CHG-004-enforce-format-gate.md)). `pubspec.yaml` keeps `>= 3.10.0` as the minimum |
| Python | ≥ 3.10 |
| uv | latest |

`pubspec.lock` and `uv.lock` are committed ([CHG-005](../../changes/CHG-005-phase-2-local-persistence.md)).

Tests that open SQLite use the host library: the system `libsqlite3` on Linux and macOS, and on Windows a `sqlite3.dll` outside the repo (default `F:\tools\sqlite\sqlite3.dll`, or the path in `GARBLO_SQLITE3_DLL`). Benchmarks carry the `benchmark` tag and run with `flutter test --run-skipped --tags benchmark`.

## 3. CI
**Today:** [`.github/workflows/android-apk.yml`](../../../.github/workflows/android-apk.yml)
runs on every push to `main` (and on manual dispatch) with Flutter 3.24.5:
`flutter pub get` → `dart format --output=none --set-exit-if-changed .` →
`flutter analyze` → `flutter test` → release APK artifact. An unformatted file
fails the build ([CHG-004](../../changes/CHG-004-enforce-format-gate.md)).

**Planned:** `.github/workflows/ci.yml`, triggered on pull requests to `main`:

| Job | Steps |
|---|---|
| `flutter` | Set up the pinned Flutter version → Flutter gates |
| `backend` | Set up Python + uv → backend gates |

`main` accepts merges only when both jobs pass. A workflow file is Type 3 code, written by the developer whose toolchain it runs, through a backlog item or CHG.

## 4. CD
None. The backend is a local mock and the app is not distributed yet. Release pipelines are anti-scope until a backlog item asks for them.

## 5. Running locally
```bash
cd backend && uv run uvicorn app.main:app --reload --port 8080 --host 0.0.0.0
flutter run          # requires platform folders, see CHG-002
```

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Created; gate commands moved here from README, DoD and copilot instructions |
| 2026-10-29 | [CHG-004](../../changes/CHG-004-enforce-format-gate.md) | Flutter pinned to 3.24.5 (`.fvmrc`); CI checks formatting instead of rewriting it; existing APK workflow documented |
| 2026-10-30 | [CHG-005](../../changes/CHG-005-phase-2-local-persistence.md) | Lock files committed; host SQLite for tests; benchmark tag |
