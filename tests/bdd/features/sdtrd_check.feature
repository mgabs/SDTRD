Feature: sdtrd gate and lane check
  As a team using the sdtrd schema
  We want a check runnable from pre-commit and CI
  So that artifacts cannot advance past an unticked human gate or land on main.

  Scenario: Unticked gate blocks later artifacts (4.6, REQ-OSA-16)
    Given a change whose "proposal.md" exists with an unticked Gate 1 box
    And a "specs/" artifact is present
    When the gate check runs
    Then it exits non-zero
    And the output names the change and the unticked gate

  Scenario: Ticked gates pass (REQ-OSA-16)
    Given a change whose gates for every present predecessor artifact are ticked
    When the gate check runs
    Then it exits 0

  Scenario: Artifact missing its gate section (REQ-OSA-16)
    Given a change whose "proposal.md" has no Gate checkbox and "specs/" is present
    When the gate check runs
    Then it exits non-zero naming the change and "proposal"

  Scenario: Multiple violations are all reported (REQ-OSA-16)
    Given two changes each with an unticked gate before a later artifact
    When the gate check runs
    Then it exits non-zero
    And both changes are named in the output

  Scenario: No active changes (Edge 4)
    Given "openspec status --json" reports no changes
    When the gate check runs
    Then it exits 0

  Scenario: Direct commit on main (4.7, REQ-OSA-17)
    Given the current branch is "main"
    When the check runs
    Then it exits non-zero
    And it also fails on "master"

  Scenario: Feature branch is allowed (REQ-OSA-17)
    Given the current branch is "feat/x"
    When the check runs
    Then the lane check passes

  Scenario: Malformed status output (4.8, Edge 5)
    Given "openspec status --json" returns invalid JSON
    When the gate check runs
    Then it exits non-zero
    And the output contains the parse error

  Scenario: Artifact presence comes from openspec (REQ-OSA-18)
    Given the check is run with a stub "openspec" on PATH
    Then artifact presence is read from the stub's "status --json" output
    And the check does not parse "schema.yaml"
