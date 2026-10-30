# Feature Proposal: SDTRD as an OpenSpec Addon

## Intent
Make SDTRD installable on top of an existing OpenSpec project as an `sdtrd` schema bundle plus a thin installer, so OpenSpec owns the spec lifecycle and SDTRD adds gates, lanes, worktree streams and test rails. Built on Option A from `research.md`.

## Problem Statement
SDTRD ships its own `specs/{features,living,archive}` lifecycle, full-copy specs and sync/archive steps, duplicating what OpenSpec already does (delta specs, `openspec archive`, validation). Teams on OpenSpec cannot adopt SDTRD's gates and rails without running two parallel spec systems.

## Scope

### In-Scope
- **`sdtrd` OpenSpec schema**: forked from `spec-driven`; adds a `research` artifact (Gate 0), gate-footer templates, SDTRD instructions for proposal/specs/design/tasks, and `apply.instruction` for the Gate 5.x slice loop.
- **Spec model migration**: adopt OpenSpec delta specs and the `openspec/` layout; drop the full-copy rule and `specs/{features,living,archive}`; Gate 6 uses `openspec archive`.
- **`REQ-*`/`NFR-*` convention**: key format inside OpenSpec delta requirement headers.
- **Thin installer CLI (`sdtrd`)**: idempotent POSIX shell wiring of schema, `config.yaml` entries, hooks, pre-commit, CI, mutation templates, `.worktrees/` ignore and agent rules into an existing `openspec/` project; requires a minimum `openspec` version.
- **Gate enforcement**: pre-commit/CI check of Review Gate boxes and lane/branch rules, using `openspec status --json`.
- **Worktree streams vs deltas**: rebase + `openspec validate` discipline for parallel streams.
- **Bugfix lane and roadmap mapping**: decide B1–B3 representation and `ROADMAP.md` vs OpenSpec initiatives.
- **Self-migration**: move SDTRD's own repo, docs, skill, rules and tests to the addon layout.

### Out-of-Scope (YAGNI)
- Changes to OpenSpec core or upstream PRs.
- A new runtime or language for the installer (no Node/Python package).
- Custom spec parser, delta merger or archive logic.
- Support for OpenSpec versions below the pinned minimum.
- Re-implementing OpenSpec's per-tool skill/command generation.
- Native (non-CI) enforcement inside OpenSpec.

## Assumptions
- **ASM-GEN-1**: Target OpenSpec is 1.x (verified at 1.15.0); custom schemas under `openspec/schemas/<name>/` and the `--json` surfaces in `docs/agent-contract.md` stay stable across 1.x.
- **ASM-GEN-2**: `openspec` CLI is installed in target projects.
- **ASM-GEN-3**: `specs/living/` is empty, so no living `REQ-*` content needs migration.
- **ASM-GEN-4**: SDTRD skills/rules live outside files that `openspec update` regenerates, or the installer re-applies them.

## Success Metrics
- **Install**: `sdtrd` on a fresh `openspec init` project yields `openspec validate` and `openspec status --change <c>` passing with the `sdtrd` schema, in one idempotent command (second run changes nothing).
- **Enforcement**: CI/pre-commit fails a change whose gate box is unticked while later artifacts or code exist.
- **Single source of truth**: zero SDTRD-owned spec directories remain; archive uses `openspec archive` only.
- **No regressions**: existing lint, unit and BDD suites pass or are migrated with equivalent coverage.

---

## Review Gate
- [x] **Gate 1 Approval**: Proposal reviewed and approved by human before drafting specs.
