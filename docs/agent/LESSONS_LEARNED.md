# Agent Lessons Learned & Guardrails Log

This living document captures historical agent anti-patterns, drift incidents, and the corresponding corrective rules incorporated into the codebase directives.

---

### Incident #001: Backend Technology & Role Misalignment
- **Context**: Initial prompt suggested Go backend skeleton.
- **Symptom / Drift**: Go backend added unnecessary compiled infrastructure for a solo developer focusing on a Flutter-driven application.
- **Correction**: Replaced Go backend with lightweight **Python / FastAPI** managed with **`uv`**.
- **Rule Established**:
  - The Flutter application is the **primary** product.
  - The Python backend is **secondary and minimal**, functioning strictly as an on-demand mock API to supply fixtures and simulate endpoints.
  - Never introduce heavy backend microservices or compiled daemons when a lightweight mock API suffices.

---

### Incident #002: Risk of Platform-Specific Widget Fragmentation
- **Context**: Targeting Android, iOS, Windows, and macOS.
- **Symptom / Drift**: Agents frequently insert `if (Platform.isAndroid)` or `if (Platform.isWindows)` across widget build trees to render platform-specific UI.
- **Correction**: Centralized layout adaptation inside `DiscoveryLayout` using **`LayoutBuilder`** and an **`800px` breakpoint**.
- **Rule Established**:
  - Presentation logic adapts strictly to **available width constraints**, not OS checks.
  - Native platform capabilities (storage, notifications, window control) are hidden behind abstract service contracts in `core/`.

---

### Incident #003: Over-Engineered Clean Architecture Boilerplate
- **Context**: Creating a new feature slice.
- **Symptom / Drift**: Agents instinctively generate dozens of empty mapper classes, use cases with a single `call()` line, and DTO objects that duplicate domain models.
- **Correction**: Enforced lightweight MVVM: `View` $\rightarrow$ `ViewModel` (Riverpod) $\rightarrow$ `Repository` $\rightarrow$ `DataSource`.
- **Rule Established**:
  - Do NOT introduce use cases or mappers unless there is cross-repository coordination or complex domain computation.
  - Simple CRUD passes directly through the repository to the ViewModel.

---

### Incident #004: Lack of Explicit Negative Boundaries (Anti-Scope)
- **Context**: Implementing Discovery feature.
- **Symptom / Drift**: Agents tend to spontaneously attempt real SQLite caching, WebSocket connections, or authentication checks.
- **Correction**: Every APRD must feature an **Anti-Scope** section explicitly listing forbidden features for that slice.
- **Rule Established**:
  - Agents must review the task's Anti-Scope before writing code.

