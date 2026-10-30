# Codebase Map

The only repository tree in the docs. Use it to find files instead of crawling. Updated by the ASEM after every merge that changes structure.

## Monorepo layout

| Path | Package | Role |
|---|---|---|
| `apps/mobile/` (`pubspec.yaml`, `analysis_options.yaml`, `dart_test.yaml`, `lib/`, `test/`) | `garblo` (Flutter) | **Primary product.** One app for Android, iOS, Windows, macOS. Run Flutter commands from here ([CHG-010](../../changes/CHG-010-monorepo-mobile-move.md)) |
| `backend/` | `garblo-backend` (uv) | **Secondary.** Legacy dating mock API; not the wardrobe contract ([BE-001](../../tasks/backend/BE-001-platform-decision.md)) |
| `docs/` | — | Every document; start at [docs/README.md](../../README.md) |
| `.github/` | — | Copilot adapter and the APK workflow |
| `CLAUDE.md`, `.claude/` | — | Claude Code adapter: entry instructions, subagents, skills, settings |
| `.fvmrc` | — | Flutter SDK pin (3.24.5) for the whole repo; FVM finds it from `apps/mobile/` |

Platform folders (`android/ ios/ windows/ macos/`) are not committed; CI generates `android/` ([CHG-002](../../changes/CHG-002-restore-green-build.md)).

## Flutter app (`apps/mobile/lib/`)

Wardrobe features (`studio`, `wardrobe`, `gu_match`, `privacy`) are routed. Dating features are legacy and unrouted ([CHG-003](../../changes/CHG-003-wardrobe-direction-phase-1.md)).

```text
apps/mobile/lib/
├── main.dart                          runApp(GarbloBootstrap)
├── app/
│   ├── bootstrap.dart                 opens SQLCipher store, builds provider overrides, StorageErrorApp
│   ├── app.dart                       GarbloApp: MaterialApp, themes
│   ├── router.dart                    AppRouter: '/' → AppShell; '/privacy' → PrivacyView;
│   │                                  anything else → UnknownRouteView
│   ├── providers.dart                 apiClientProvider, localStorageProvider (legacy, unused)
│   ├── shell/                         AppShell (header + 5-pillar nav), pillarPagesProvider,
│   │                                  ComingSoonView (impact, community), UnknownRouteView
│   └── theme/app_theme.dart           AppTheme: T7 tokens, light and dark
├── core/
│   ├── errors/failures.dart           Failure, ServerFailure, NetworkFailure, StorageFailure
│   ├── layout/breakpoints.dart        Breakpoints.desktop = 800 (D-003)
│   ├── navigation/pillar.dart         Pillar enum, PillarController, pillarProvider
│   ├── media/                         PhotoPicker (+ ImagePicker / Preset), PhotoSanitizer, image MIME sniffing
│   ├── storage/
│   │   ├── garblo_database.dart       GarbloDatabase: open, migrate, SQLCipher key
│   │   ├── phone_schema.dart          PhoneSchema v1 tables (PowerSync-shaped, CHG-005)
│   │   ├── local_data_store.dart      LocalDataStore: open store, erase everything
│   │   ├── storage_providers.dart     localDatabaseProvider, ownerIdProvider, attachmentStoreProvider,
│   │   │                              objectIdGeneratorProvider, dataResetProvider (overridden in bootstrap)
│   │   ├── attachment_store.dart      AttachmentStore, FileAttachmentStore (private photo files)
│   │   ├── install_identity.dart      InstallIdentity: owner ID + DB key in SecureStore
│   │   ├── secure_store.dart          SecureStore, FlutterSecureStore
│   │   ├── object_id.dart             ObjectIdGenerator (deterministic, clock-based)
│   │   └── local_storage.dart         LocalStorage, InMemoryLocalStorage (legacy)
│   ├── time/clock.dart                Clock, SystemClock, clockProvider
│   ├── networking/api_client.dart     ApiClient, MockApiClient (legacy placeholder)
│   └── widgets/                       EmptyView, ErrorView, LoadingView, PrimaryButton
└── features/
    ├── studio/                        Flow A · Add pillar · UC-01–03 · TASK-003, 005, 007
    │   ├── domain/                    UploadBatch, BatchStatus, PhotoTray, MediaAsset, PrivacyConsent,
    │   │                              AnalysisTask/Selection, ExtractedItem, ReviewDraft, LastWornInput, StagedPhoto
    │   ├── data/                      StudioRepository + MockStudioRepository, LocalStudioRepository
    │   └── presentation/              StudioState/ViewModel/View; widgets: add_photos_panel,
    │                                  analysis_scope_sheet, review_panel
    ├── wardrobe/                      Flow A · Wardrobe pillar (Archive) · UC-04 · TASK-003, 005, 006
    │   ├── domain/                    WardrobeItem, ItemGroup, ItemType(Catalog), WearEvent, DormancyRules
    │   ├── data/                      WardrobeRepository / WearRepository (+ Mock, Local), demo_seed
    │   └── presentation/              WardrobeState/ViewModel/View; widgets/wardrobe_item_card
    ├── gu_match/                      Flow B · Gu Match pillar · UC-05–08 · TASK-004, 005
    │   ├── domain/                    GuMatchSession, StylingContext, Occasion, SessionPath, ContextCard,
    │   │                              OutfitCandidate, SlotRole, SwipeStatus, Interaction/CardAction,
    │   │                              GeneratedDeck, GuMatchSnapshot, VisualMode, NoEligibleItemsFailure
    │   ├── data/                      GuMatchRepository + Mock, LocalGuMatchRepository, FakeCandidateGenerator
    │   └── presentation/              GuMatchState/ViewModel/View; widgets: styling_studio_panel,
    │                                  context_analysis_panel, outfit_deck_panel
    ├── privacy/                       UC-09 local erasure · Avatar › Privacy & data · TASK-008
    │   ├── domain/erasure_counts.dart ErasureCounts
    │   ├── data/                      PrivacyRepository, LocalPrivacyRepository
    │   └── presentation/              PrivacyState/ViewModel/View
    ├── discovery/                     LEGACY dating slice (BL-004), unrouted; do not extend
    └── auth/ onboarding/ matching/ chat/ profile/ notifications/ moderation/
                                       LEGACY placeholders, one *_placeholder.dart each
```

## Tests (`apps/mobile/test/`)

Mirror `apps/mobile/lib/` paths with a `_test.dart` suffix. Beyond the mirror:

```text
apps/mobile/test/
├── app/                               shell, router, bootstrap, theme, and journeys:
│                                      flow_a_journey, flow_b_journey, persistence_restore, privacy_entry
├── architecture/                      layering_test (import rules), storage_boundary_test
├── integration/                       TASK-009: offline_reliability (crash images, replay, migrations, files),
│                                      offline_error_view (retryable errors on screen)
├── features/<f>/{domain,data,presentation}/
│   ├── studio/studio_boundary_test    feature-level boundary test
│   └── wardrobe/data/wear_benchmark   tagged `benchmark`, skipped by default
└── helpers/
    ├── contracts/                     shared repository contract suites (wardrobe, wear): run against Mock and Local
    ├── local_db.dart                  opens a temp SQLite DB (host library; GARBLO_SQLITE3_DLL on Windows);
    │                                  crashImage() copies DB + WAL as a kill leaves them
    ├── reliability.dart               withoutNetwork, FlakyWardrobeRepository, FlakyWearRepository
    ├── fixed_clock.dart  layout.dart  surface-size helpers for both layouts
    └── image_fixtures.dart  privacy_fakes.dart  wardrobe_fixtures.dart
```

## Backend (`backend/`)

```text
backend/
├── pyproject.toml                     fastapi, uvicorn, pydantic; dev: pytest, httpx; readme = README.md
├── app/
│   ├── main.py                        FastAPI app, CORS
│   ├── config.py                      Settings from env: PORT, HOST, ENV, SERVICE_NAME
│   ├── api/router.py                  includes every endpoint router
│   ├── api/v1/endpoints/              health, discovery, auth*, matches*, chat*   (* placeholder)
│   ├── models/                        health.py, profile.py (Profile, SwipeRequest, SwipeResponse)
│   └── data/sample_data.py            SAMPLE_PROFILES fixtures
└── tests/                             test_health.py, test_discovery.py
```

## Docs (`docs/`)

The folder contract is in [docs/README.md](../../README.md) §2. Two locations matter for navigation:

- **Product authority:** [`tasks/mobile/Garblo Flow Spec.html`](../../tasks/mobile/Garblo%20Flow%20Spec.html) (≈ 490 KB). Read one section by anchor, never the whole file; the anchor index is in [`.claude/skills/flow-spec/SKILL.md`](../../../.claude/skills/flow-spec/SKILL.md).
- **Current work:** [`tasks/mobile/README.md`](../../tasks/mobile/README.md) (TASK-NNN, wardrobe phases) and [`tasks/backend/README.md`](../../tasks/backend/README.md). `backlog/BL-NNN` items are the legacy dating backlog.

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Moved from `docs/archive/legacy/architecture/MAP.md`; now the only tree in the docs |
| 2026-10-30 | [CHG-008](../../changes/CHG-008-claude-code-adapter.md) | Rebuilt for the Phase 1–2 wardrobe tree (studio, wardrobe, gu_match, privacy, core storage and media); added monorepo layout, test helpers and docs navigation |
| 2026-10-30 | [CHG-009](../../changes/CHG-009-phase-2-verification.md) | Added `apps/mobile/test/integration/` and the reliability helpers |
| 2026-10-30 | [CHG-010](../../changes/CHG-010-monorepo-mobile-move.md) | Flutter app moved to `apps/mobile/`; `.fvmrc` row; `/privacy` route |
