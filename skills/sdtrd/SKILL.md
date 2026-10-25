---
name: sdtrd
description: >-
  Spec-Driven, Testing-Railed Development (SDTRD) workflow for gated feature
  delivery, multi-agent Git worktree streams, Red-Green-Mutation testing rails,
  and zero-contamination bugfix isolation. Activate when bootstrapping `specs/`,
  proposing features, triaging bugs, or executing gated vertical slices.
---

# SDTRD Skill

Follow [specs/WORKFLOW.md](../../specs/WORKFLOW.md) and copy templates from [templates/](../../templates/).

## Initialization

Initialize a target repository:
```bash
sdtrd [target-repo-path]
```

## Gate Execution Checklist

1. **Gate 0 (Research & Tradeoffs)**: Copy [templates/research.md](../../templates/research.md) $\rightarrow$ `specs/features/<id>-<slug>/research.md`. Present 2–3 options & tradeoffs. Stop for human developer decision.
2. **Gate 1 (Proposal)**: Copy [templates/proposal.md](../../templates/proposal.md) $\rightarrow$ `specs/features/<id>-<slug>/proposal.md` based on chosen option. Stop for human review.
3. **Gate 2 (Specs)**: Copy [templates/spec.md](../../templates/spec.md) $\rightarrow$ `specs/features/<id>-<slug>/specs/<capability>/spec.md`. Stop for human review.
4. **Gate 3 (Design)**: Copy [templates/design.md](../../templates/design.md) $\rightarrow$ `specs/features/<id>-<slug>/design.md`. Stop for human review.
5. **Gate 4 (Tasks)**: Copy [templates/tasks.md](../../templates/tasks.md) $\rightarrow$ `specs/features/<id>-<slug>/tasks.md` with DAG and worktree streams. Stop for human review.
6. **Apply (Step 5.x)**: Per vertical slice:
   - **5.x-A**: Write BDD `.feature` scenarios $\rightarrow$ **Stop for Gate 5.x human approval**.
   - **5.x-B**: Write failing unit tests (`Red`) $\rightarrow$ minimal code (`Green`) $\rightarrow$ verify $\ge 95\%$ line/branch coverage.
   - **5.x-C**: Run mutation testing $\rightarrow$ achieve $100\%$ kill score on core logic.
7. **Gate 6 (Archive)**: Merge worktrees (`--ff-only`), sync specs into `specs/living/`, mark `tasks.md` complete.
