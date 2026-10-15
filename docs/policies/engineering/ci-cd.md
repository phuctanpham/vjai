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
| Flutter | ≥ 3.10 per `pubspec.yaml`; exact version not pinned yet ([CHG-002](../../changes/CHG-002-restore-green-build.md)) |
| Python | ≥ 3.10 |
| uv | latest |

`pubspec.lock` and `uv.lock` must be committed. `.gitignore` currently ignores `*.lock` (CHG-002).

## 3. CI (planned, not yet implemented)
`.github/workflows/ci.yml`, triggered on pull requests to `main`:

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
