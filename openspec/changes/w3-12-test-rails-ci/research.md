# Research & Technical Tradeoffs

## 1. Intent & Ground Truth
Goal: make the test half of the rails (BDD, Red, Green, Coverage, Mutation) verifiable instead of advisory. Verified in this repo:

- `schemas/spec-rails/schema.yaml` states BDD > Red > Green > Coverage (>= 95%) > Mutation (100% kill) only as prose in `apply.instruction` and `design` / `tasks` instructions.
- `templates/tasks.md` has tasks 3.3 to 3.5 (Red, Green, Coverage and mutation) that an agent can tick with no evidence.
- `bin/spec-rails-check` enforces Review Gates and branch rules only; it knows nothing about tests.
- `templates/spec-rails-ci.yml` (copied to `.github/workflows/spec-rails-ci.yml`) audits spec-to-code mapping, runs the gate check, pre-commit and `make test`. It never checks that a requirement has a test or that a coverage/mutation command ran.
- Requirement keys (`REQ-*`, `NFR-*`) are uniquely keyed in delta specs, so they are mechanically extractable.
- Spec-Rails is stack-agnostic and this repo is POSIX shell: no native coverage or mutation tooling exists here.

Decisions already taken by the human: stack-agnostic (commands live in config, no per-language presets) and CI-only enforcement (no commit blocking).

## 2. Options Explored
- **A. Config-driven CI verifier**: a new `spec-rails-verify` script, run only in CI. It (1) checks every `REQ-*`/`NFR-*` key in active change delta specs appears in the project's test files, (2) checks ticked Red/Green/Coverage/Mutation tasks carry an `Evidence:` note, (3) runs the optional commands from `openspec/spec-rails/rails.conf` (`RAILS_TEST`, `RAILS_COVERAGE`, `RAILS_MUTATION`) and fails on non-zero exit.
- **B. Evidence-in-tasks only**: template and instruction changes, honor system, no script.
- **C. Local pre-commit enforcement of Red/Green**: block commits unless tests fail then pass. Rejected by the human (CI-only), and unprovable from a single commit.

## 3. Tradeoff Matrix

| Criteria | Option A | Option B | Option C |
| :--- | :--- | :--- | :--- |
| **Complexity** | Medium (one script, one config) | Low | High |
| **New Dependencies** | None (sh, grep, jq already required) | None | None |
| **Performance & Latency** | CI only; extra seconds plus user commands | None | Slows every commit |
| **Maintenance Burden** | Low; thresholds live in user tools | Low but unenforced | High |
| **Blast Radius** | New script, CI template, tasks template, installer | Templates | Hooks |

## 4. Recommendation
Option A: add `spec-rails-verify`, run it from the CI template only, and keep thresholds inside the user's own commands so it stays stack-agnostic. Missing config means a visible warning, not a failure.

## 5. Breaking Changes & Deprecations
None. Adds REQ-OSA-26 to REQ-OSA-28 and NFR-OSA-9. REQ-OSA-21 (CI audit) is untouched: the verify step is added next to it.

## Review Gate
- [x] **Gate 0 Decision**: Human decides Go (name the option) or No-Go before the proposal is drafted.
