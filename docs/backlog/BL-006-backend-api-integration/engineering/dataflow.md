# BL-006 Dataflow

```mermaid
sequenceDiagram
    participant VM as DiscoveryViewModel
    participant Repo as HttpDiscoveryRepository
    participant Client as HttpApiClient
    participant API as FastAPI :8080
    participant Mock as MockDiscoveryRepository

    VM->>Repo: getProfiles()
    Repo->>Client: get('/api/v1/discovery')
    Client->>API: GET
    alt 200 OK
        API-->>Client: Profile[] JSON
        Client-->>Repo: decoded list
        Repo-->>VM: List<Profile> (minus swiped IDs, BL-005)
    else status ≥ 400
        Client-->>Repo: ServerFailure
        Repo-->>VM: throws ServerFailure → error state
    else connection refused / timeout
        Client-->>Repo: NetworkFailure
        Repo->>Mock: getProfiles()  + log warning
        Mock-->>Repo: sample profiles
        Repo-->>VM: List<Profile>
    end
```

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-10-16 | [CHG-001](../../../changes/CHG-001-agentic-documentation-system.md) | Migrated from the TASK-006 sequence diagram; server-error branch added |
