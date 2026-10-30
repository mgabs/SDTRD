# Research & Technical Tradeoffs

## 1. Intent & Ground Truth
Review of the repo (OpenSpec 1.15.0, current with npm; `make test` green) found drift left over from the W3.8 self-migration:

- `templates/spec-rails-ci.yml` (also installed as `.github/workflows/spec-rails-ci.yml`) audits `^specs/(features|archive|living|bug-reports)/`. Those directories no longer exist; changes live in `openspec/changes|specs/`. Any PR touching code without a `specs/bug-reports/` file fails the audit even with a valid OpenSpec change.
- `specs/ROADMAP.md` still lists W3.2-W3.7 as ⬜ although the schema, installer and `spec-rails-check` exist, and cites a nonexistent `tests/test_init.sh` (W1.4).
- `docs/ROADMAP.md` defines a second milestone list (M1-M3) that conflicts with the W-waves.
- `tests/bdd/test_bdd.sh` copies from a nonexistent `specs/templates/` and seeds `specs/ROADMAP.md` from `templates/roadmap.md`.
- Repo self-copies are byte-identical to their sources and can silently drift: `schemas/spec-rails` vs `openspec/schemas/spec-rails`, `bin/spec-rails-check` vs `openspec/spec-rails/spec-rails-check`, `rules/AGENTS.md`, `templates/bug-report.md`, `templates/mutation/` vs `openspec/spec-rails/`.
- `make test-unit` is `@true`; `.worktrees/` is empty; `.github/skills` and `.agents/skills` are identical OpenSpec-generated copies, uncommitted.
- `.github/workflows/test.yml` uses `ludeeus/action-shellcheck@master` (unpinned); `copilot-setup-steps.yml` uses `actions/checkout@v4` vs `@v7` elsewhere.

## 2. Options Explored
- **A. Targeted hygiene**: fix the CI audit paths, add a drift guard test for self-copies, refresh roadmap/docs/tests references, delete dead targets. No structural change.
- **B. Remove self-copies**: make the repo consume only its source dirs and drop the installed copies under `openspec/`. Breaks dogfooding (`openspec` resolves schemas from `openspec/schemas/`), so the copies would have to become symlinks or be generated on demand.
- **C. Full restructure**: move sources under `openspec/` and make the installer copy from there. Largest churn; changes the installer contract.

## 3. Tradeoff Matrix

| Criteria | Option A | Option B | Option C |
| :--- | :--- | :--- | :--- |
| **Complexity** | Low | Medium (symlink portability) | High |
| **New Dependencies** | None | None | None |
| **Performance & Latency** | None | None | None |
| **Maintenance Burden** | Low; guard catches drift | Low once done | Low once done |
| **Blast Radius** | CI template, docs, tests | Installer, tests, Windows checkouts | Installer, docs, all tests |

## 4. Recommendation
Option A: fix the real bug (CI audit) and guard drift with a test, rather than restructuring working dogfood layout.

## 5. Breaking Changes & Deprecations
None. Adds REQ-OSA-21 and REQ-OSA-22 to `openspec-addon`; no existing requirement is modified.

## Review Gate
- [x] **Gate 0 Decision**: Human decides Go (name the option) or No-Go before the proposal is drafted.
