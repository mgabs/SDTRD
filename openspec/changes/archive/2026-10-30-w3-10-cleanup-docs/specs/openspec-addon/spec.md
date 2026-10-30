# Spec Delta

## ADDED Requirements

### Requirement: REQ-OSA-23 Docs Accuracy
README, `docs/` and `skills/` MUST NOT instruct manual copying of schema templates into a change, MUST describe change creation through `openspec new change` and artifact generation through `openspec instructions` or `/opsx-*`, and every relative markdown link in them MUST resolve to an existing file.

#### Scenario: Broken link detected
- **WHEN** a doc links to a missing file
- **THEN** `make test-lint` fails naming the doc and the link

#### Scenario: No manual template copy
- **WHEN** README, `docs/` and `skills/` are searched for `cp openspec/schemas/spec-rails/templates`
- **THEN** no match is found

### Requirement: REQ-OSA-24 No Unused Helpers
Every function defined in `bin/` scripts and `tests/` shell files MUST be referenced at least once outside its own definition, and `make test-lint` MUST fail naming any that is not.

#### Scenario: Unused helper detected
- **WHEN** a shell function is defined and never called
- **THEN** `make test-lint` fails naming the file and function

#### Scenario: All helpers used
- **WHEN** every defined function is called
- **THEN** the check passes

### Requirement: NFR-OSA-7 Lint Latency
The docs-link and unused-helper checks MUST complete within 2 seconds combined.

#### Scenario: Lint budget
- **WHEN** both checks run
- **THEN** they complete within 2 seconds

## Review Gate
- [x] **Gate 2 Approval**: Specifications reviewed and approved by human before technical design.
