# Proposal

## Intent
Delete unused helpers and make README, wiki, how-tos and the agent skill describe the OpenSpec-native workflow that actually ships (Option A of `research.md`).

## Problem Statement
Docs still instruct manual template copying and list an incomplete gate set; two helpers are dead code; docs can reference paths that no longer exist with nothing catching it.

## Capabilities

### New Capabilities
None.

### Modified Capabilities
- `openspec-addon`: adds REQ-OSA-23 (docs links resolve and describe the OpenSpec-native commands), REQ-OSA-24 (no unused shell helpers in shipped scripts and tests) and NFR-OSA-7 (lint latency).

## Scope

### In-Scope
- Remove `gate_ticked()` and its unit test from `bin/spec-rails-check` and `tests/test_check.sh`; sync `openspec/spec-rails/spec-rails-check`.
- Remove unused `assert_dir()` from `tests/bdd/test_bdd.sh`.
- Rewrite how-tos 01/02, `skills/spec-rails/SKILL.md` and README sections to use `openspec new change`, `openspec instructions`, `/opsx-*` and `openspec archive`; add Gate 0 and the slice loop to the README gate list; fix repo layout and roadmap labels.
- Update `docs/WIKI.md` and `docs/WAY_OF_WORKING.md` only where they contradict the above.
- A lint check that relative markdown links in README, `docs/` and `skills/` resolve, and that every function defined in shipped shell scripts is used.

### Out-of-Scope (YAGNI)
- Merging or restructuring docs (Option B).
- Changing gate semantics or `specs/WORKFLOW.md` protocol content.
- Deciding W3.3/W3.6/W3.7 status; committing OpenSpec-generated `.agents/` and `.github/` files; removing `.feature` files.

## Assumptions
- **ASM-GEN-1**: `.feature` files stay as documentation of scenarios.
- **ASM-GEN-2**: `/opsx-*` commands are available wherever the OpenSpec skills are installed (`openspec update`).

## Success Metrics
- `make test` passes with the two helpers gone and the new lint checks included.
- No doc tells users to `cp` schema templates by hand.
- README gate list matches the schema artifacts (research, proposal, specs, design, tasks).

## Review Gate
- [x] **Gate 1 Approval**: Proposal reviewed and approved by human before drafting specs.
