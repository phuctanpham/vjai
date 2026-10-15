# ADR 005: Agentic Product Management and Documentation Hierarchy

## Context
When building software as a solo fullstack developer paired with autonomous AI coding agents, conventional product management practices (loose user stories, verbal clarification during standups, unversioned PRD docs) cause severe agent failure modes:
1. **Agent Drift**: The agent hallucinates extra features not requested.
2. **Context Bloat**: Agents crawl the entire repository, exhausting context windows and generating buggy solutions.
3. **Architectural Erosion**: Agents introduce inconsistent design patterns, conflicting packages, or horizontal layers.

## Decision
We formally adopt the **5-Layer Agentic Product Management Documentation Hierarchy**:

```text
Layer 1: Governance & Agent Directives (Control Plane)
  ↳ .github/copilot-instructions.md & docs/architecture/MAP.md
Layer 2: Product Strategy & Domain Modeling (What & Why)
  ↳ APRDs, docs/architecture/GLOSSARY.md & ADRs
Layer 3: Interface Contracts & Technical Specs (Boundaries)
  ↳ Pydantic Schemas, Dart Domain Contracts & Adaptive UI Specs
Layer 4: Tactical Task Orchestration (Execution Engine)
  ↳ docs/tasks/README.md & docs/quality/DOD.md
Layer 5: Memory & Feedback Loops (Quality & Alignment)
  ↳ docs/agent/LESSONS_LEARNED.md & Test Playbooks
```

### Key Operating Rules
1. **Executable Specifications (APRD)**: Every major feature must have an Agentic PRD with an explicit **Anti-Scope** and a **Finite State Machine Matrix**.
2. **Strict File Locking**: Prompts must declare which files are permitted to be edited and which are locked.
3. **Automated Verification Gates**: No slice is complete until unit tests, widget tests, and static analysis execute successfully.
4. **Living Memory**: Every failure mode is recorded in `docs/agent/LESSONS_LEARNED.md` to prevent recurrence in future sessions.

## Consequences
### Positive
- Enables high-velocity solo development with deterministic AI code generation.
- Prevents cross-feature merge conflicts and architectural divergence.
- Keeps the secondary mock backend lightweight while keeping the primary Flutter application clean and multi-native.

### Negative
- Requires upfront discipline to maintain APRD templates, ADRs, and task cards.

