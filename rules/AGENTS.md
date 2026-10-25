# SDTRD (Spec-Driven, Testing-Railed Development) Rules

When working in a repository containing `specs/WORKFLOW.md`:

1. **Branch Isolation**: Never commit directly to `main`/`master`. Always use `feat/<id>-<name>` for features and isolated worktrees (`.worktrees/fix-<slug>` on branch `fix/<slug>`) for bugfixes.
2. **Strict Human Gates**: Stop and obtain explicit human approval at every gate before advancing:
   - **Features**: Gate 0 (`research.md`) $\rightarrow$ Gate 1 (`proposal.md`) $\rightarrow$ Gate 2 (`specs/<cap>/spec.md`) $\rightarrow$ Gate 3 (`design.md`) $\rightarrow$ Gate 4 (`tasks.md`) $\rightarrow$ Gate 5.x (BDD scenarios per slice) $\rightarrow$ Gate 6 (Sync & Archive).
   - **Bugs**: Gate B1 (`specs/bug-reports/<date>-<slug>.md`) $\rightarrow$ Gate B2 (Failing Red regression test in isolated worktree) $\rightarrow$ Gate B3 (Minimal Green fix + `--ff-only` merge).
3. **Testing Rails**:
   - Write failing unit tests (`Red`) before production code (`Green`).
   - Enforce $\ge 95\%$ line and branch coverage and $100\%$ mutation kill score on domain/core logic.
   - Never delete assertions, skip failing tests, or write vacuous tests to force a green run.
4. **Pre-Commit Verification & Commit Hygiene**:
   - Always install and maintain pre-commit hooks (`.pre-commit-config.yaml`).
   - Run all linters, formatting checks, and test suites prior to committing.
   - Inspect `rtk git status` and `rtk git diff` before every commit.
   - Never bypass hooks using `--no-verify` or `-n`.
5. **LGTM Harness & Directive Preemption**: Review directives (`#ref file:line`) preempt all forward progress. When incoming review directives exist in `.lgtm/reviews/` or user chat, immediately halt active `tasks.md` execution, resolve directives to clean verification, and only then resume forward tasks.
