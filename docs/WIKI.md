# SDTRD Wiki: Spec-Driven, Testing-Railed Development

SDTRD (Spec-Driven, Testing-Railed Development) is an engineering and AI-agent orchestration framework designed to eliminate hallucinated scope, stale documentation, untested regressions, and branch contamination in autonomous and pair-programming development.

---

## 1. Core Principles

### 1.1 The Ponytail Discipline (Strict YAGNI)
- **Zero Unsolicited Architecture**: Build strictly what the active capability requires. Never introduce hypothetical abstractions, premature plugin frameworks, or configurable toggles before a concrete requirement demands them.
- **Minimal Blast Radius**: Code changes must touch only the files strictly necessary to satisfy the active vertical slice.

### 1.2 Zero-Contamination Isolation
- Production branches (`main` / `master`) are immutable to direct edits.
- Feature work occurs on isolated branches (`feat/<id>-<name>`).
- Concurrent subagent execution occurs in dedicated Git worktrees (`.worktrees/<id>-<stream>`).
- Bugfixes occur in dedicated bugfix worktrees (`.worktrees/fix-<slug>`) branching directly off the base branch, preventing feature-branch bleed into hotfixes.

### 1.3 Testing Rails (Red-First & 100% Mutation Kill)
- Code does not exist until a test fails for its absence.
- Coverage metrics ($\ge 95\%$ line & branch) are necessary but insufficient.
- Every logical branch must survive mutation analysis (100% mutation kill score on core business logic). Any surviving mutant is treated as a blocking bug.

### 1.4 Living Specifications
- Specs are not discarded design documents.
- Delta specs created during feature proposals are synced into `specs/living/` upon feature completion (Gate 6), providing an evergreen, authoritative ground truth of system capabilities.

### 1.5 Pre-Commit Verification & Zero-Bypass Protocol
- Every project must maintain active pre-commit hooks (`.pre-commit-config.yaml`).
- Before any commit: inspect `rtk git status` / `rtk git diff`, run all linters, and execute all tests.
- Never bypass hooks using `git commit --no-verify` or `-n`. If a check fails, resolve the defect before committing.

---

## 2. Gate Architecture

SDTRD enforces 6 human-in-the-loop gates for features and 3 fast-track gates for defects.

```mermaid
flowchart TD
    subgraph Feature_Track [Feature Track]
        G1[Gate 1: Proposal] --> G2[Gate 2: Specs]
        G2 --> G3[Gate 3: Architecture & Design]
        G3 --> G4[Gate 4: Tasks & Stream DAG]
        G4 --> G5[Gate 5.x: Per-Slice Apply Loop]
        G5 --> G6[Gate 6: Living Sync & Archive]
    end

    subgraph Bug_Track [Fast-Track Bugfix Track]
        GB1[Gate B1: Bug Report & Triage] --> GB2[Gate B2: Red Reproduction in Worktree]
        GB2 --> GB3[Gate B3: Green Surgical Fix & Sign-off]
    end
```

### 2.1 Feature Gate Matrix

| Gate | Name | Artifact | Required Content | Next Step |
| :--- | :--- | :--- | :--- | :--- |
| **Gate 1** | Proposal Review | `specs/features/<feat>/proposal.md` | Intent, Problem Statement, Scope (In/Out-of-scope), Success Metrics, Assumptions (`ASM-GEN-*`). | Draft Specifications |
| **Gate 2** | Specifications Review | `specs/features/<feat>/specs/<cap>/spec.md` | Traceable Requirements (`REQ-*`), Non-Functional Budgets (`NFR-*`), Given/When/Then Scenarios. | Technical Design |
| **Gate 3** | Architecture Review | `specs/features/<feat>/design.md` | Overview, Domain Contracts, Boundary Rules, Latency/Allocation Budgets, Test Strategy. | Task Breakdown |
| **Gate 4** | Tasks Breakdown Review | `specs/features/<feat>/tasks.md` | Dependency DAG, Multi-agent worktree stream partitions, Test-first order of execution. | Launch Worktrees / Apply Phase |
| **Gate 5.x**| Slice Behavior Review | `tests/bdd/features/*.feature` | Gherkin scenarios covering all slice requirements before code is written. | Unit Red $\rightarrow$ Code Green |
| **Gate 6** | Living Sync & Archive | `specs/living/` + `tasks.md` | $\ge 95\%$ coverage, $100\%$ mutation kill, worktrees pruned, delta specs promoted to `specs/living/`. | Feature Complete |

### 2.2 Bugfix Gate Matrix (Fast-Track)

| Gate | Name | Artifact | Required Content | Next Step |
| :--- | :--- | :--- | :--- | :--- |
| **Gate B1** | Defect Triage | `specs/bug-reports/<date>-<slug>.md` | Steps to reproduce, expected vs actual behavior, root cause analysis. | Spawn `.worktrees/fix-<slug>` |
| **Gate B2** | Red Reproduction | Target test file in worktree | Failing test proving defect on unmodified base code. | Minimal surgical fix |
| **Gate B3** | Integration Sign-off | Worktree diff + test suite output | Green test, regression suite pass, `--ff-only` merge into base branch, prune worktree. | Hotfix Deployed |

---

## 3. Parallel Worktrees & Multi-Agent Streams

When a feature contains orthogonal tasks (decoupled modules, distinct endpoints, independent algorithms):

1. **Task DAG Partitioning (Gate 4)**: The feature lead breaks down independent streams in `tasks.md`:
   - `Stream A`: Core domain rules
   - `Stream B`: Parser / Data ingestion
2. **Worktree Spawning**:
   ```bash
   rtk git worktree add .worktrees/<feat>-stream-a -b feat/<feat>/stream-a
   rtk git worktree add .worktrees/<feat>-stream-b -b feat/<feat>/stream-b
   ```
3. **Agent Isolation**: Subagents are dispatched into the worktree path (`Workspace: 'share'`). No agent can dirty another agent's working directory.
4. **Integration**: Completed streams are merged fast-forward into the feature branch:
   ```bash
   rtk git checkout feat/<feat>-<name>
   rtk git merge --ff-only feat/<feat>/stream-a
   rtk git worktree remove .worktrees/<feat>-stream-a
   rtk git branch -d feat/<feat>/stream-a
   ```
5. **Rebasing**: If Stream B requires artifacts produced by Stream A, Stream B rebases on `feat/<feat>-<name>` before proceeding.

---

## 4. Testing Rails & Mutation Verification

### 4.1 The Three-Layer Rail
1. **Behavioral Acceptance (BDD)**: Gherkin feature files validating end-to-end domain contracts from the user/caller perspective.
2. **Unit Red-Green-Refactor**: Fine-grained assertions on all code paths, edge cases, and boundary values.
3. **Mutation Testing**: Code mutating engines (e.g. `cargo-mutants`, `mutmut`, `stryker`) generate mutations (flipping conditionals, replacing arithmetic, deleting statements). Every mutant MUST be caught and killed by tests.

### 4.2 Surviving Mutant Protocol
When a mutant survives:
1. **Case A: Missing Assertion**: The test suite failed to assert a critical boundary. Fix: Add a targeted assertion.
2. **Case B: Dead Code**: The code survived because its deletion does not alter system behavior. Fix: Delete the dead code (Ponytail rule).

---

## 5. Review Harness & Agent Steering: The LGTM Symbiosis

SDTRD relies on a human-in-the-loop review cockpit to steer coding agents in real time. We pair SDTRD natively with [mgabs/lgtm](https://github.com/mgabs/lgtm) (Fast terminal diff reviewer, agent steering TUI, and security scanner).

### 5.1 The Steering Feedback Loop

```mermaid
sequenceDiagram
    participant Reviewer as Human Reviewer (lgtm TUI)
    participant Harness as lgtm Guardrails
    participant Agent as Coding Agent
    participant Repo as Git Repository

    Agent->>Repo: Implement Slice (Green)
    Repo-->>Reviewer: Real-time File-Watcher Diff Update
    Reviewer->>Harness: Inspect Diff & Scope
    Harness-->>Reviewer: Flag Complexity Spike / Anti-Fraud / Typo
    Reviewer->>Agent: Send Directive chord (e.g. ca / cs / #ref file:line)
    Agent->>Agent: Parse #ref Directive & Target Line
    Agent->>Repo: Add Failing Test / Refactor / Fix
    Agent-->>Reviewer: Verified Pass & Update
```

### 5.2 Line-Anchored Directives (`#ref file:line <directive>`)
Rather than providing ambiguous conversational feedback, reviewers anchor corrections directly to exact file and line coordinates:
```text
#ref src/core/auth.rs:42 Ensure token expiration handles leap seconds and integer overflow.
```
In `lgtm`, this is injected via 1-key quick chords into the agent's active terminal pane (`tmux`, `zellij`, `wezterm`, `kitty`) or `.lgtm/reviews/`:
- `ca`: ⚡ Test Coverage (`Add unit/regression tests covering these branches.`)
- `cs`: 🔒 Security (`Ensure inputs are sanitized, parameterized, and auth checks enforced.`)
- `cr`: 🧹 Refactor / DRY (`Simplify logic, reduce cognitive nesting, eliminate duplication.`)
- `cp`: 🚀 Performance (`Optimize hot-path allocations and database query batching.`)
- `cw`: ❓ Rationale / Why (`Explain rationale and verify architectural invariants.`)

### 5.3 Automated Anti-Fraud & Guardrail Protection
Autonomous agents sometimes take shortcuts to satisfy gate requirements. `lgtm` enforces mechanical guardrails before commits:
1. **Test Neutering Guard**: Flags deleted assertions, skipped tests (`@pytest.mark.skip`, `#[ignore]`, `xit`), mock inflation, and self-assertions (`assert True`).
2. **Cognitive Complexity Spikes**: Flags functions where new branches/loops increase cognitive complexity by $\ge 5$.
3. **Dead Code Addition (YAGNI)**: Identifies newly added functions or methods with zero usages across the repository.
4. **Identifier Hallucination Guard**: Flags 1–2 character Levenshtein distance typos against the repository symbol index.
5. **Security Scan**: Catches SQLi, shell command injection, hardcoded secrets, and TLS bypass in diff hunks.

### 5.4 Native MCP Server Integration
AI agents operating under SDTRD connect directly to `lgtm` via its built-in Model Context Protocol server (`lgtm serve --mcp` / `lgtm mcp`), enabling agents to query diffs, verify static analysis status, and confirm resolution of review directives before requesting Gate sign-off.
