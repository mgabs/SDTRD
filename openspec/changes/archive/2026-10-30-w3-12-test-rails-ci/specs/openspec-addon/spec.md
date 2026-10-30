# Spec Delta

## ADDED Requirements

### Requirement: REQ-OSA-26 Requirement-to-Test Traceability
`spec-rails-verify` MUST read every `REQ-*` and `NFR-*` key declared under `## ADDED Requirements` or `## MODIFIED Requirements` in the delta specs of each active change (`openspec/changes/*/specs/**/spec.md`, excluding `archive/`) and MUST fail, listing each key, when a key does not appear as text in any file under the directories named by `RAILS_TEST_DIRS` (default `tests`).

#### Scenario: Covered key passes
- **WHEN** an active delta spec declares `REQ-X-1` and a `.feature` file under `tests/` contains `REQ-X-1`
- **THEN** the verifier reports the key as covered and exits 0

#### Scenario: Uncovered key fails
- **WHEN** a declared key appears in no test file
- **THEN** the verifier exits non-zero and prints that key

#### Scenario: No active changes
- **WHEN** there are no active changes
- **THEN** the verifier skips traceability and exits 0

### Requirement: REQ-OSA-27 Task Evidence
For each active change, every ticked (`- [x]`) task line in `tasks.md` that mentions Red, Green, Coverage or Mutation MUST contain `Evidence:` followed by non-empty text. `spec-rails-verify` MUST fail and name the task otherwise. Unticked tasks MUST be ignored.

#### Scenario: Ticked without evidence
- **WHEN** a ticked task says "Red unit tests fail" and has no `Evidence:` text
- **THEN** the verifier exits non-zero and names the task

#### Scenario: Ticked with evidence
- **WHEN** the ticked task ends with `Evidence: make test -> 3 failed`
- **THEN** the verifier passes that task

#### Scenario: Unticked task ignored
- **WHEN** the task is `- [ ]` with no evidence
- **THEN** the verifier does not report it

### Requirement: REQ-OSA-28 Config-Driven Test Commands in CI
When `openspec/spec-rails/rails.conf` defines `RAILS_TEST`, `RAILS_COVERAGE` or `RAILS_MUTATION`, `spec-rails-verify` MUST run each defined command in that order from the repository root and MUST fail on the first non-zero exit, reporting which command failed. An undefined command MUST be skipped with a visible warning. The CI workflow MUST run `spec-rails-verify` and the commit hook MUST NOT.

#### Scenario: Command fails
- **WHEN** `RAILS_COVERAGE` exits 1
- **THEN** the verifier exits non-zero and names `RAILS_COVERAGE`

#### Scenario: Undefined commands
- **WHEN** `rails.conf` is absent or defines no commands
- **THEN** the verifier prints a warning per undefined command and exits 0

#### Scenario: CI only
- **WHEN** the installer runs
- **THEN** the CI workflow contains a `spec-rails-verify` step and the installed git hook does not call it

### Requirement: NFR-OSA-9 Verifier Is Stack-Agnostic
`spec-rails-verify` MUST be POSIX `sh`, MUST NOT invoke any language-specific tool itself, MUST NOT overwrite an existing `rails.conf`, and MUST finish its own checks (excluding configured commands) within 5 seconds on this repository.

#### Scenario: Existing config preserved
- **WHEN** the installer runs on a project whose `rails.conf` was edited
- **THEN** the file is unchanged

#### Scenario: Own-check budget
- **WHEN** `spec-rails-verify` runs with no commands configured
- **THEN** it completes within 5 seconds

## Review Gate
- [x] **Gate 2 Approval**: Specifications reviewed and approved by human before technical design.
