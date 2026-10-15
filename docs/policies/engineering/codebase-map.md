# Codebase Map

The only repository tree in the docs. Use it to find files instead of crawling. Updated by the ASEM after every merge that changes structure.

## Flutter app (`lib/`)
```text
lib/
├── main.dart                         ProviderScope bootstrap
├── app/
│   ├── app.dart                      MaterialApp, themes
│   ├── router.dart                   onGenerateRoute: '/', '/discovery'
│   ├── providers.dart                apiClientProvider, localStorageProvider (not yet used)
│   └── theme/app_theme.dart          Material 3 light and dark themes
├── core/
│   ├── errors/failures.dart          Failure, ServerFailure, NetworkFailure, StorageFailure
│   ├── networking/api_client.dart    ApiClient interface + MockApiClient placeholder
│   ├── storage/local_storage.dart    LocalStorage interface + InMemoryLocalStorage
│   └── widgets/                      EmptyView, ErrorView
└── features/
    ├── discovery/                    BL-004 · Done
    │   ├── domain/                   profile.dart (Profile), swipe_type.dart (SwipeType)
    │   ├── data/                     discovery_repository.dart (interface, MockDiscoveryRepository, provider)
    │   └── presentation/             discovery_state, discovery_view_model, discovery_view,
    │                                 widgets/discovery_layout, widgets/profile_card
    └── auth/ onboarding/ matching/ chat/ profile/ notifications/ moderation/
                                      one *_placeholder.dart each; no behaviour
```

## Tests (`test/`)
Mirror `lib/` paths. Today: `test/features/discovery/{domain,data,presentation}/`.

## Backend (`backend/`)
```text
backend/
├── pyproject.toml                    fastapi, uvicorn, pydantic; dev: pytest, httpx
├── app/
│   ├── main.py                       FastAPI app, CORS
│   ├── config.py                     Settings from env: PORT, HOST, ENV, SERVICE_NAME
│   ├── api/router.py                 includes every endpoint router
│   ├── api/v1/endpoints/             health, discovery, auth*, matches*, chat*   (* placeholder)
│   ├── models/                       health.py, profile.py (Profile, SwipeRequest, SwipeResponse)
│   └── data/sample_data.py           SAMPLE_PROFILES fixtures
└── tests/                            test_health.py, test_discovery.py
```

## Not present yet
- Platform folders `android/ ios/ windows/ macos/` (see [CHG-002](../../changes/CHG-002-restore-green-build.md)).
- CI workflows (see [ci-cd.md](ci-cd.md)).

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../changes/CHG-001-agentic-documentation-system.md) | Moved from `docs/architecture/MAP.md`; now the only tree in the docs |
