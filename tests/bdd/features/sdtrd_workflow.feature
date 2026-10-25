Feature: SDTRD Workflow Lifecycle
  As a development team and autonomous coding agent
  We want to execute features, bugfixes, and chores under strict rails
  So that code is never built on unverified assumptions, specifications remain evergreen, and branches remain pristine.

  Scenario: Bootstrap a clean repository with SDTRD structure
    Given a fresh git repository
    When I initialize SDTRD using "bin/sdtrd"
    Then the directory "specs/" should contain "WORKFLOW.md" and "ROADMAP.md"
    And the directories "specs/features", "specs/living", "specs/archive", "specs/bug-reports" should exist
    And the file ".pre-commit-config.yaml" should be configured
    And ".worktrees/" should be ignored in ".gitignore"

  Scenario: Feature Gate 0 Go decision advances to Proposal and preserves living specs
    Given an initialized SDTRD repository
    When a developer selects item "W1.1" from "specs/ROADMAP.md"
    And starts feature branch "feat/w1.1-core-contracts"
    And conducts Gate 0 research in "specs/features/w1.1-core-contracts/research.md"
    And developer approves Option A
    Then the status in "specs/ROADMAP.md" can be updated to In Progress
    And Gate 1 proposal and Gate 2 full capability specs can be drafted

  Scenario: Feature Gate 0 No-Go archives research and drops item without dirtying code
    Given an initialized SDTRD repository
    When a developer researches item "W1.2" on branch "feat/w1.2-unfeasible-service"
    And Gate 0 research reveals the feature is unfeasible
    Then the research artifact is archived to "specs/archive/w1.2-unfeasible-service/research.md"
    And "specs/ROADMAP.md" records status "❌ Dropped" with rationale
    And the feature branch is deleted with zero production code changes

  Scenario: Chore lane merges zero-behavior-change commits without gates
    Given an initialized SDTRD repository
    When a developer creates a branch "chore/update-docs"
    And modifies "README.md" without altering production code
    And verifies pre-commit and test suites pass
    Then the branch merges fast-forward into "main" without requiring feature gates

  Scenario: Fast-track bugfix reproduces defect red-first, fixes green, and updates living specs
    Given an initialized SDTRD repository with production code
    When a defect is discovered in production code
    And an isolated worktree ".worktrees/fix-timeout" is spawned off "main"
    And a regression test fails on unmodified code
    And a minimal surgical fix makes the test pass
    And the living specs are updated to reflect the fix
    Then the bugfix merges fast-forward into "main" and the worktree is pruned
