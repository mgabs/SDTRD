# <Project Name> Roadmap

Baseline: `main` · Status: Active

---

## 1. Dependency Spine & Waves

```mermaid
flowchart TD
    W1[Wave 1: Core Foundation] --> W2[Wave 2: Capability Streams]
    W2 --> W3[Wave 3: Integrations & Hardening]
```

---

## 2. Work Items & Backlog

Status Legend:
- `⬜ Planned`: Scheduled for execution.
- `🔬 In Research (Gate 0)`: Actively investigating technical feasibility and options.
- `🚀 In Progress (Gates 1–5)`: Active feature branch / worktree streams.
- `✅ Shipped`: Verified, merged, living specs synced, archived.
- `❌ Dropped`: Discarded at Gate 0 with documented rationale.

### Wave 1: Core Foundation

| ID | Item | Effort | Depends on | Status | Spec / Feature Dir | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **W1.1** | Core Domain Models | S | — | ⬜ | `specs/features/01-core-models` | Contract lock for downstream streams |
| **W1.2** | Data Ingestion | M | W1.1 | ⬜ | `specs/features/02-data-ingestion` | Requires W1.1 domain contracts |

### Wave 2: Capability Streams

| ID | Item | Effort | Depends on | Status | Spec / Feature Dir | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **W2.1** | Stream A: Processing Engine | L | W1.2 | ⬜ | `specs/features/03-processing-engine` | Can run in parallel worktree with W2.2 |
| **W2.2** | Stream B: Reporting / Export | M | W1.2 | ⬜ | `specs/features/04-reporting` | Orthogonal to W2.1 |

---

## 3. Wave Exit Criteria

### Wave 1 Exit Criteria
- [ ] All W1 items marked `✅ Shipped`.
- [ ] Core contracts verified with $\ge 95\%$ test coverage and $100\%$ mutation kill score.
- [ ] Living specs established in `specs/living/`.

### Wave 2 Exit Criteria
- [ ] All W2 items marked `✅ Shipped`.
- [ ] End-to-end BDD scenarios pass across combined streams.
- [ ] No regression against Wave 1 baselines.
