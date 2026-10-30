# Spec Delta

## ADDED Requirements

### Requirement: REQ-OSA-25 Fresh-Repo End-to-End
In a new git repository initialised by the real OpenSpec CLI and then wired with `spec-rails`, the combined system MUST: resolve `spec-rails` as the project schema, list the artifacts research, proposal, specs, design and tasks in dependency order for a new change, and make `spec-rails-check` fail a commit that adds a downstream artifact while its upstream Review Gate is unticked and pass once that gate is ticked. `openspec validate` MUST accept the resulting change. When `openspec` or `jq` is unavailable the test MUST report a skip, not a pass.

#### Scenario: Schema resolved and artifact order
- **WHEN** `openspec new change demo` and `openspec status --change demo --json` run in the wired repo
- **THEN** the schema name is `spec-rails` and the artifact ids appear in the order research, proposal, specs, design, tasks

#### Scenario: Unticked gate blocks commit
- **WHEN** `research.md` has an unticked Gate 0 box and `proposal.md` is staged and committed
- **THEN** the pre-commit hook exits non-zero and names the unticked gate

#### Scenario: Ticked gate allows commit
- **WHEN** the Gate 0 box is ticked and committed before `proposal.md`
- **THEN** the commit on a non-main branch succeeds

#### Scenario: Tool missing
- **WHEN** `openspec` or `jq` is not on PATH
- **THEN** the test prints a skip message and exits 0 without claiming a pass

#### Scenario: No residue
- **WHEN** the test finishes or fails
- **THEN** its temp directory is removed and no file outside it has changed

### Requirement: NFR-OSA-8 End-to-End Budget
The fresh-repo end-to-end test MUST complete within 20 seconds on a developer machine and MUST NOT access the network.

#### Scenario: Budget check
- **WHEN** `make test-e2e` runs
- **THEN** it completes within 20 seconds with no network access

## Review Gate
- [x] **Gate 2 Approval**: Specifications reviewed and approved by human before technical design.
