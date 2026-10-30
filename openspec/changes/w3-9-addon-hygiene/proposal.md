# Proposal

## Intent
Remove drift left by the W3.8 self-migration: make the CI spec-to-code audit understand the `openspec/` layout, guard installed self-copies against drifting from their sources, and bring roadmap, docs and tests back in line with reality (Option A of `research.md`).

## Problem Statement
The shipped CI template checks for files under `specs/(features|archive|living|bug-reports)/`, which no longer exist, so valid OpenSpec changes fail the audit. Self-copies can drift silently, and several docs/tests/roadmap entries reference removed paths or show wrong status.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `openspec-addon`: adds REQ-OSA-21 (CI audit recognises OpenSpec layout) and REQ-OSA-22 (self-copies match sources).

## Scope

### In-Scope
- Update the spec-to-code audit in `templates/spec-rails-ci.yml` and its installed copy to accept `openspec/changes/`, `openspec/specs/` and `specs/bug-reports/`.
- Add a test asserting each installed self-copy equals its source.
- Fix stale paths in `tests/bdd/test_bdd.sh`; update `specs/ROADMAP.md` statuses and the `test_init.sh` reference; reconcile or remove `docs/ROADMAP.md`.
- Remove the no-op `test-unit` target if nothing runs under it.
- Pin `ludeeus/action-shellcheck` and align `actions/checkout` versions.

### Out-of-Scope (YAGNI)
- Restructuring source vs installed layout (Options B/C).
- Installer uninstall or removal of previously shipped files.
- Changing or deduplicating OpenSpec-generated `.agents/` and `.github/skills|prompts|agents`.
- Any change to the gate/lane check logic.

## Assumptions
- **ASM-GEN-1**: `specs/bug-reports/` remains the bugfix record location (per `specs/WORKFLOW.md` §7).
- **ASM-GEN-2**: `docs/ROADMAP.md` is superseded by `specs/ROADMAP.md`.

## Success Metrics
- A PR containing code plus an `openspec/changes/<id>/` change passes the audit step.
- `make test` fails if any self-copy differs from its source.
- No reference to `test_init.sh` or `specs/templates/` remains outside archived changes.

## Review Gate
- [x] **Gate 1 Approval**: Proposal reviewed and approved by human before drafting specs.
