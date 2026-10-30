# Proposal

## Intent
Add a stack-agnostic, CI-only verifier that turns the test rails (traceability, Red/Green evidence, coverage, mutation) from prose into checks (Option A of `research.md`).

## Problem Statement
Spec-Rails says every requirement is BDD-covered, tests are written Red then Green, coverage is >= 95% and mutation kill is 100%, but nothing checks it. A requirement can ship without any test, and task boxes can be ticked with no proof.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `openspec-addon`: adds REQ-OSA-26 (requirement-to-test traceability), REQ-OSA-27 (task evidence), REQ-OSA-28 (config-driven test, coverage and mutation commands in CI) and NFR-OSA-9 (verifier is stack-agnostic and CI-only).

## Scope

### In-Scope
- `bin/spec-rails-verify` (POSIX sh) with its self-copy at `openspec/spec-rails/spec-rails-verify`.
- `templates/rails.conf`: optional `RAILS_TEST_DIRS`, `RAILS_TEST`, `RAILS_COVERAGE`, `RAILS_MUTATION`.
- Installer copies the verifier and creates `rails.conf` only if absent (never overwrites).
- A "Verify Test Rails" step in `templates/spec-rails-ci.yml` and the identical `.github/workflows/spec-rails-ci.yml`.
- `templates/tasks.md`, schema `tasks` and `apply` instructions: ticked Red/Green/Coverage/Mutation tasks end with `Evidence: <command and result>`. Schema stays byte-identical to its self-copy.
- Tests `tests/test_verify.sh`, a Makefile target, a BDD feature, and a short docs update.

### Out-of-Scope (YAGNI)
- Per-language presets or bundled coverage/mutation tools.
- Blocking commits or changing `spec-rails-check`.
- Proving Red happened (a script cannot see history); only evidence notes are required.
- Parsing coverage reports or enforcing thresholds inside Spec-Rails; the user's command owns thresholds and signals them by exit code.

## Assumptions
- **ASM-GEN-1**: Tests reference requirement keys as plain text (for example in a `.feature` tag `@REQ-OSA-25` or a comment).
- **ASM-GEN-2**: Configured commands exit non-zero when their own threshold is missed.

## Success Metrics
- A change whose delta spec has a key found in no test file fails `spec-rails-verify`.
- A ticked Red/Green/Coverage/Mutation task without `Evidence:` fails it.
- With no `rails.conf` the verifier passes with a visible warning.
- `make test` stays green and `spec-rails-verify` runs in under 5 s on this repo, excluding user commands.

## Review Gate
- [x] **Gate 1 Approval**: Proposal reviewed and approved by human before drafting specs.
