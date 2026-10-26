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

## 0. The Ponytail Mindset & Strict YAGNI

- Strictly apply YAGNI (You Aren't Gonna Need It). Build exactly what is asked; do not over-engineer or add unsolicited features.
- Zero speculative architecture: no unused abstractions, premature plugin frameworks, or hypothetical configuration flags.
- Minimal blast radius: touch only files strictly required for the slice.
- Kill mutants or delete dead code: any surviving mutant triggers deletion of unneeded code.

## 1. Pick a Lane First

- **Feature** (`feat/<id>-<slug>`): Follow Gates 0–6.
- **Bugfix** (`fix/<slug>`): Follow Gates B1–B3.
- **Chore** (`chore/<slug>`): Zero behavior change; run pre-commit & tests; no gates.

## 2. Gate Execution Checklist

1. **Gate 0 (Research & Tradeoffs)**: Copy [templates/research.md](../../templates/research.md) $\rightarrow$ `specs/features/<id>-<slug>/research.md`. Present 2–3 options, tradeoffs, and breaking changes. Stop for human developer decision.
   - If **Go**: Update `specs/ROADMAP.md` to `🚀 In Progress` via `chore/roadmap-<id>`.
   - If **No-Go**: Commit `research.md` to `specs/archive/<id>-<slug>/`, mark `❌ Dropped` in `specs/ROADMAP.md` with rationale via `chore/roadmap-<id>`, and prune feature branch.
2. **Gate 1 (Proposal)**: Copy [templates/proposal.md](../../templates/proposal.md) $\rightarrow$ `specs/features/<id>-<slug>/proposal.md` based on chosen option. Stop for human review.
3. **Gate 2 (Specs)**: Full capability specs (never partial deltas). If modifying existing capability, start from `specs/living/<cap>/spec.md`. Stop for human review.
4. **Gate 3 (Design)**: Copy [templates/design.md](../../templates/design.md) $\rightarrow$ `specs/features/<id>-<slug>/design.md`. Stop for human review.
5. **Gate 4 (Tasks)**: Copy [templates/tasks.md](../../templates/tasks.md) $\rightarrow$ `specs/features/<id>-<slug>/tasks.md` with DAG and worktree streams. Stop for human review.
6. **Apply (Gate 5.x)**: Per vertical slice:
   - **5.x-A**: Write BDD `.feature` scenarios $\rightarrow$ **Stop for Gate 5.x human approval**.
   - **5.x-B**: Write failing unit tests (`Red`) tested locally, then implement minimal code (`Green`). Commit tests + code together. Line & branch coverage $\ge 95\%$.
   - **5.x-C**: Run mutation testing $\rightarrow$ achieve $100\%$ kill score on core logic (no exemptions: kill, delete dead code, or restructure equivalent mutants).
7. **Gate 6 (Archive & Merge)**: Ensure all stream worktrees are merged, removed, and pruned (`git worktree prune`). Rebase onto `main`, re-verify rails, sync specs to `specs/living/` (safe overwrite), archive to `specs/archive/<id>-<slug>/`, merge `--ff-only`, and update `specs/ROADMAP.md` to `✅ Shipped`.
