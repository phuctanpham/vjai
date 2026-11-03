# Phase 4 Backend Implementation Plan

> **Status:** Draft — documentation and task preparation only  
> **Toolchain:** Python virtual environment with `pip`  
> **Authority:** [CHG-014](../../changes/CHG-014-mock-first-backend-track.md),
> [CHG-016](../../changes/CHG-016-pip-backend-toolchain.md), and the approved
> backend task cards

## Purpose

Phase 4 delivers the backend in nine ordered steps. The shared contract tests
are written before implementations and run against both mock and real
adapters. Mock implementations remain deterministic and independent of
third-party services until their explicitly dependent steps.

This plan does not authorize implementation while the `backend/` source tree,
requirements files, and test suite are absent from the checkout. Each step
must have an approved task card and an explicit allowed-file list before code
is written.

## Step sequence

### Step 1 — Shared contract tests for mock and real APIs

Write the complete backend test contract first. Cover authentication and
ownership, wire/schema validation, IDs, clock behavior, transaction replay and
atomicity, write guards, change feeds, seeds, studio, Gu Match, wear rules,
privacy, attachments, and AI ports.

The same contract fixtures and assertions must be reusable against:

- deterministic in-memory mock adapters;
- real adapters backed by configured services;
- local-only test doubles when external services are unavailable.

Use the red/green TDD cycle. The canonical commands are:

```bash
python -m pip install -r requirements-dev.txt
python -m pytest
```

### Step 2 — Mock APIs independent of third-party services

Implement deterministic, process-local components:

- injected clock and deterministic IDs;
- sync row models and schema validation;
- in-memory transactional store and change log;
- dev-token authentication;
- transaction validation, replay, ownership, and error envelopes;
- mock controls and reset behavior;
- model ports and deterministic fake providers.

No MongoDB Atlas, PowerSync, RustFS, OpenAI network calls, randomness, or
wall-clock access is allowed.

### Step 3 — Real APIs independent of third-party services

Implement production-facing interfaces and service boundaries without opening
third-party connections:

- repository and store protocols;
- authentication and token-verification interfaces;
- sync transaction and change-feed service interfaces;
- effects/worker registry;
- configuration validation and dependency injection;
- shared error, timeout, retry, and logging contracts.

The real adapters must reuse the mock validators and domain rules rather than
forking equivalent logic.

### Step 4 — Demo seed and migration tooling

Create versioned, idempotent demo-user initialization:

- schema/data migration scripts;
- catalog, demo wardrobe, and fixture data;
- explicit demo-user ownership;
- dry-run and verification modes;
- repeatable execution without duplicate rows;
- documented recovery or rollback behavior.

Atlas credentials and connection strings must come only from environment or
secret storage.

### Step 5 — Mock APIs dependent on MongoDB, PowerSync, and RustFS

Add service-backed adapters while preserving the mock contract:

- MongoDB-backed store adapter;
- PowerSync-compatible sync/change-feed adapter;
- RustFS-compatible attachment tickets and verification;
- timeout, retry, health, and failure behavior;
- deterministic local substitutes for tests.

OpenAI is explicitly excluded from this step.

### Step 6 — Real APIs dependent on MongoDB, PowerSync, and RustFS

After [BE-001](BE-001-platform-decision.md) is approved, implement:

- MongoDB Atlas collections, indexes, validators, and migrations;
- PowerSync schema and Sync Streams;
- JWT/JWKS ownership enforcement;
- production write handler and transactions;
- RustFS presigned tickets and attachment verification;
- TLS, secret-management, observability, and operational failures.

The Step 1 contract suite must run against these adapters when services are
available. External-service tests must be explicitly marked and must not hide
unit-test failures.

### Step 7 — Mock and real OpenAI APIs

Implement both providers behind the same AI ports.

**Mock provider:**

- deterministic extraction, context, naming, and rule generation;
- PII scrubber and evaluation fixtures;
- zero network calls.

**Real provider:**

- environment/secret-based API-key loading;
- bounded requests, timeouts, retries, and response validation;
- redacted structured logging;
- explicit unavailable and provider-error states;
- opt-in live tests only.

No credentials or user data may appear in source, fixtures, logs, or CI output.

### Step 8 — Non-Docker localhost deployment verification

Run the complete stack on localhost without Docker:

1. create the virtual environment;
2. install `requirements-dev.txt` with `python -m pip`;
3. apply migrations and seed the demo user;
4. start the application;
5. run health, contract, migration, and self-test suites;
6. verify OpenAPI, error envelopes, ownership, retries, and restart behavior.

Record every command, service configuration, test count, and skipped external
check in the delivery report.

### Step 9 — Docker localhost deployment verification

Build and run the supported Docker configuration:

1. build the image from a clean checkout;
2. start the compose/service topology;
3. apply migrations and seed the demo user;
4. run the same self-tests as Step 8;
5. verify service networking, volumes, health checks, restart behavior, and
   environment injection;
6. scan the image and logs to confirm no credentials are embedded or emitted.

Docker verification does not replace the non-Docker verification.

## Cross-step documentation protocol

For every step:

1. update or create the owning task under `docs/tasks/backend/`;
2. define implementation files, locked files, anti-scope, and test scenarios;
3. update the relevant approved change record;
4. stop and create a cross-role task when the change belongs to Mobile,
   Product, Engineering Management, DevOps, or AI;
5. add a delivery report with red run, green run, gates, skipped checks, and
   known limitations.

## Dependency and readiness gates

| Step | Depends on | Required approval |
|---|---|---|
| 1 | backend source and test scaffold restored | Backend task approval |
| 2 | Step 1 red tests | Backend task approval |
| 3 | Steps 1–2 contracts | Engineering architecture approval |
| 4 | Steps 1–3 schemas | Seed/migration task approval |
| 5 | Steps 2–4 | Service-adapter task approval |
| 6 | Step 5 and BE-001 | BE-001 platform decision |
| 7 | Steps 1–3 and AI port approval | AI task approval |
| 8 | Steps 1–7 applicable components | Deployment verification approval |
| 9 | Step 8 | Docker/deployment task approval |

## Change history

| Date | CHG | Change |
|---|---|---|
| 2026-11-03 | [CHG-016](../../changes/CHG-016-pip-backend-toolchain.md) | Refactored Phase 4 into nine ordered backend implementation and verification steps |
