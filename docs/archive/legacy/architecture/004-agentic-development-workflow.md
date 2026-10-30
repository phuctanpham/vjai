# ADR 004: Agentic Development Workflow and Bounded Vertical Slices

## Context
Garblo is developed by a solo engineer leveraging agentic AI coding assistants. Agents operate best when tasks are constrained, architectures are predictable, and code can be verified with fast automated test suites.

## Decision
We enforce an **agentic coding protocol**:
1. **Vertical Slices**: Each task delivers a single bounded capability (UI + state + repository + mock/API + test).
2. **Explicit Contracts**: Code boundaries are defined by Dart interfaces and Pydantic models.
3. **Explicit Agent Directives**: Stored in `.github/copilot-instructions.md`.
4. **Verification Gates**: Formatting, static analysis, and automated tests must pass before marking tasks complete.
5. **No Speculative Implementation**: Only build the minimal slice requested; avoid premature frameworks.

## Consequences
### Positive
- Predictable AI code generation with low hallucination risk.
- Minimal git merge conflicts.
- High test coverage and confidence.

### Negative
- Requires maintaining detailed documentation and architectural discipline.

