# Proposal

## Intent
Add a real-CLI end-to-end test that builds a brand-new repo and shows how Spec-Rails layers its workflow (schema, gates, hook, CI) on top of OpenSpec (Option A of `research.md`).

## Problem Statement
The installer is only tested against a stubbed `openspec`. Nothing proves that, in a fresh repo, the real OpenSpec CLI resolves the installed `spec-rails` schema, enforces the artifact order, and that the Spec-Rails hook blocks an unticked gate. Regressions from OpenSpec upgrades would go unnoticed.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `openspec-addon`: adds REQ-OSA-25 (fresh-repo end-to-end behaviour with the real CLI) and NFR-OSA-8 (test runtime and isolation).

## Scope

### In-Scope
- `tests/test_e2e.sh`: temp dir, `git init`, real `openspec init`, `bin/spec-rails`, `openspec new change`, then assert schema resolution, artifact order, hook blocking, `openspec validate`.
- Makefile target `test-e2e`, wired into `make test`.
- Visible skip when `openspec` or `jq` is absent.
- BDD feature file `tests/bdd/features/fresh_repo_e2e.feature`.
- A short "try it in a new repo" section in `docs/how-tos/01-bootstrap-new-project.md` that links the test.

### Out-of-Scope (YAGNI)
- Replacing or reducing the stubbed installer tests.
- Network calls, `npm install`, or testing against several OpenSpec versions.
- Changing installer, schema or hook behaviour (a defect found is reported and fixed in its own change).
- Testing AI agent or `/opsx-*` prompt behaviour.

## Assumptions
- **ASM-GEN-1**: `openspec init` can run non-interactively in a temp dir (flag choice verified at implementation time with `openspec init --help`).
- **ASM-GEN-2**: `openspec` and `jq` are present on developer machines and CI (already required by REQ-OSA-11).

## Success Metrics
- `make test-e2e` passes in under 20 s on a clean checkout.
- Removing the schema line from the installer, or the hook wiring, makes the e2e test fail.
- The test leaves no files outside its temp dir.

## Review Gate
- [x] **Gate 1 Approval**: Proposal reviewed and approved by human before drafting specs.
