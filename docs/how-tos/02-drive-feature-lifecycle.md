# How-To: Drive a Feature Through Gates 1 to 6

This guide demonstrates end-to-end execution of a feature under the SDTRD lifecycle.

---

## Step 1: Branch Creation

Never work on `main`. Start a dedicated feature branch:

```bash
git checkout -b feat/w1.1-user-authentication
```

Create the feature directory in `specs/features/`:

```bash
mkdir -p specs/features/w1.1-user-authentication/specs
```

---

## Step 2: Gate 0 — Research & Technical Tradeoffs

1. Copy the research template:
   ```bash
   cp specs/templates/research.md specs/features/w1.1-user-authentication/research.md
   ```
2. Document:
   - **Ground Truth**: Verified constraints in existing codebase and docs.
   - **2–3 Options**: Concrete candidate architectures (e.g. standard library vs minimal custom vs alternative).
   - **Tradeoff Matrix**: Compare complexity, dependencies, performance, and maintenance burden.
   - **Recommendation**: Agent's reasoned suggestion.
3. **Gate 0 Review**: Present options to human developer. The developer explicitly selects the winning path before Gate 1 starts.

---

## Step 3: Gate 1 — Feature Proposal

1. Copy the proposal template:
   ```bash
   cp specs/templates/proposal.md specs/features/w1.1-user-authentication/proposal.md
   ```
2. Fill in:
   - **Intent**: High-level capability summary.
   - **Scope**: Explicit In-Scope list and Out-of-Scope (YAGNI) list based on the chosen Gate 0 option.
   - **Assumptions**: `ASM-GEN-*`.
   - **Success Metrics**: Quantifiable outcomes.
3. **Gate 1 Review**: Present proposal to human reviewer. Do not proceed until approved.

---

## Step 4: Gate 2 — Specifications

1. For each capability, create a **full** spec (never a partial delta):
   - **Existing capability** — start from the living spec, then edit in place (mark retired keys `[DEPRECATED by w1.1]`, never reuse keys):
     ```bash
     mkdir -p specs/features/w1.1-user-authentication/specs/token-verification
     cp specs/living/token-verification/spec.md specs/features/w1.1-user-authentication/specs/token-verification/spec.md
     ```
   - **New capability** — start from the template:
     ```bash
     cp specs/templates/spec.md specs/features/w1.1-user-authentication/specs/token-verification/spec.md
     ```
2. Fill in:
   - **Functional Requirements**: `REQ-AUTH-1`, `REQ-AUTH-2`, etc.
   - **Non-Functional Requirements & Budgets**: `NFR-AUTH-1` (e.g. verification latency $< 2\text{ms}$).
   - **Given / When / Then Scenarios**: Behavioral test cases.
3. **Gate 2 Review**: Present specifications to human reviewer.

---

## Step 5: Gate 3 — Architecture & Design

1. Copy the design template:
   ```bash
   cp specs/templates/design.md specs/features/w1.1-user-authentication/design.md
   ```
2. Document:
   - Domain models, state machines, and interfaces.
   - Boundary rules: Pure core logic isolated from I/O and network.
   - Concurrency, allocation, or frame deadline invariants.
3. **Gate 3 Review**: Human approval required before writing task breakdown.

---

## Step 6: Gate 4 — Task Breakdown & Worktree DAG

1. Copy the tasks template:
   ```bash
   cp specs/templates/tasks.md specs/features/w1.1-user-authentication/tasks.md
   ```
2. Structure the DAG into vertical slices and identify orthogonal streams suitable for parallel worktrees.
3. **Gate 4 Review**: Human approval required before writing any test code.

---

## Step 7: Step 5.x — Vertical Slice Apply Phase

For each vertical slice:

1. **Step 5.x-A (BDD)**: Write Gherkin `.feature` scenarios.
   - **Gate 5.x Review**: Human inspects scenarios.
2. **Step 5.x-B (Red-Green-Refactor)**:
   - Write failing unit tests (`Red`). Verify test failure. Do **not** commit yet — the pre-commit suite would reject it.
   - Implement minimal code to pass (`Green`). Commit tests and code together.
   - Clean up code under green test protection.
   - Enforce $\ge 95\%$ line and branch coverage.
3. **Step 5.x-C (Mutation Testing)**:
   - Run mutation tests scoped to the slice.
   - Kill 100% of survivors: add an assertion, delete dead code, or restructure equivalent mutants away. No exemptions.

---

## Step 8: Gate 6 — Sync, Archive & Merge

1. Merge stream worktrees (rebase + re-verify each, then `--ff-only`) and prune them.
2. Rebase onto `main`, then run the full test suite and full-project mutation suite.
3. Promote specs to living (safe overwrite thanks to the full-copy rule):
   ```bash
   cp -R specs/features/w1.1-user-authentication/specs/. specs/living/
   ```
4. Tick all tasks and the Gate 6 box in `tasks.md`, archive, commit, and merge:
   ```bash
   git mv specs/features/w1.1-user-authentication specs/archive/w1.1-user-authentication
   git commit -m "feat(w1.1): ship user authentication"
   git checkout main
   git merge --ff-only feat/w1.1-user-authentication
   ```
5. Mark `✅ Shipped` in `specs/ROADMAP.md` through a `chore/roadmap-w1.1` branch.
