# SDTRD (Spec-Driven, Testing-Railed Development) Rules

When working in a repository containing `specs/WORKFLOW.md`:

1. **Pick a Lane First**: Feature (`feat/<id>-<slug>`, Gates 0–6), Bugfix (`fix/<slug>`, Gates B1–B3), or Chore (`chore/<slug>`, zero behavior change, no gates). Never commit on `main`/`master`.
2. **Strict Human Gates**: Stop and obtain explicit human approval at every gate. A gate passes only when its Review Gate checkbox is ticked and committed.
   - **Features**: Gate 0 (`research.md`) → Gate 1 (`proposal.md`) → Gate 2 (`specs/<cap>/spec.md`, full copy, never delta) → Gate 3 (`design.md`) → Gate 4 (`tasks.md`) → Gate 5.x (BDD per slice) → Gate 6 (Sync, Archive, Merge).
   - **Bugs**: Gate B1 (`specs/bug-reports/<date>-<slug>.md`) → Gate B2 (Red regression test shown, uncommitted) → Gate B3 (Green fix + docs/spec sync + merge).
3. **Testing Rails**:
   - Red before Green. Red tests are never committed alone; commit them together with Green.
   - $\ge 95\%$ line and branch coverage; $100\%$ mutation kill score, no exemptions (kill, delete dead code, or restructure equivalent mutants away).
   - Never delete assertions, skip failing tests, or write vacuous tests.
4. **Commit & Merge Hygiene**:
   - Pre-commit hooks installed; run linters, formatters, and the full suite before every commit. Never `--no-verify`.
   - Inspect `git status` and `git diff` before every commit.
   - Before any merge: rebase onto target, re-verify rails, merge `--ff-only`.
   - After any worktree merge: immediately remove worktree (`git worktree remove`), delete branch (`git branch -d`), and prune metadata (`git worktree prune`).
   - `specs/ROADMAP.md` changes only on `main` via `chore/roadmap-<id>`.
5. **LGTM Directive Preemption**: Review directives (`#ref file:line`) in `.lgtm/reviews/` or chat preempt all forward work. Halt `tasks.md`, resolve, verify, then resume.
