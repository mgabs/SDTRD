# Spec Delta

## ADDED Requirements

### Requirement: REQ-OSA-21 CI Audit Layout
The CI spec-to-code audit in `templates/spec-rails-ci.yml` MUST treat a PR as spec-backed when it changes any file under `openspec/changes/`, `openspec/specs/` or `specs/bug-reports/`, and MUST NOT reference `specs/features`, `specs/living` or `specs/archive`. Chore-lane branches remain exempt.

#### Scenario: OpenSpec change passes audit
- **WHEN** a PR changes code and a file under `openspec/changes/<id>/`
- **THEN** the audit step exits 0

#### Scenario: Code without spec fails audit
- **WHEN** a non-chore PR changes code and no file under `openspec/changes/`, `openspec/specs/` or `specs/bug-reports/`
- **THEN** the audit step exits 1 and lists the modified files

### Requirement: REQ-OSA-22 Self-Copy Sync
The repo's installed self-copies (`openspec/schemas/spec-rails/`, `openspec/spec-rails/`) MUST be byte-identical to their sources (`schemas/spec-rails/`, `bin/spec-rails-check`, `rules/AGENTS.md`, `templates/bug-report.md`, `templates/mutation/`), and the test suite MUST fail when they differ.

#### Scenario: Drift detected
- **WHEN** a source file is changed without updating its installed copy
- **THEN** `make test` fails naming the differing file

#### Scenario: In sync
- **WHEN** all self-copies match their sources
- **THEN** the sync test passes

### Requirement: NFR-OSA-6 Sync Check Latency
The self-copy sync test MUST complete within 2 seconds.

#### Scenario: Sync check budget
- **WHEN** the sync test runs
- **THEN** it completes within 2 seconds

## Review Gate
- [x] **Gate 2 Approval**: Specifications reviewed and approved by human before technical design.
