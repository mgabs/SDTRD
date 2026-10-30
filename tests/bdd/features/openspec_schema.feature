Feature: sdtrd OpenSpec schema
  As a team running OpenSpec
  We want an "sdtrd" schema with a research gate and gate footers
  So that SDTRD gates exist as OpenSpec artifacts without a parallel spec lifecycle.

  Scenario: Schema bundle is resolvable by OpenSpec (REQ-OSA-1)
    Given the shipped bundle "schemas/sdtrd/" with "schema.yaml" and "templates/"
    When it is copied to "openspec/schemas/sdtrd/" in an OpenSpec project
    Then "openspec schemas" lists "sdtrd"

  Scenario: Research is the root artifact and gates proposal (REQ-OSA-2, Scenario 4.5)
    Given a change using schema "sdtrd" with no "research.md"
    When "openspec status --change <c>" runs
    Then "research" is ready and "proposal" is blocked on "research"

  Scenario: Artifact DAG matches the SDTRD gates (REQ-OSA-3)
    Given the "sdtrd" schema
    Then the artifacts are research, proposal, specs, design, tasks in that dependency order
    And proposal requires research, specs requires proposal, design requires specs, tasks requires design

  Scenario: Every template ends with an unticked Review Gate (REQ-OSA-4)
    Given each template in "schemas/sdtrd/templates/"
    Then it ends with a "## Review Gate" section
    And that section contains one unticked "- [ ]" checkbox naming its gate

  Scenario: Artifact instructions carry the gate's mandatory sections (REQ-OSA-5)
    Given the instruction of each artifact in the "sdtrd" schema
    Then research names Options, Tradeoff Matrix and Breaking Changes
    And proposal names Out-of-Scope (YAGNI)
    And design names Pure Core vs I/O Shell

  Scenario: Apply drives the slice loop (REQ-OSA-6)
    Given the "apply" block of the "sdtrd" schema
    Then it requires "tasks" and tracks "tasks.md"
    And its instruction lists BDD, Gate 5.x approval, Red, Green, coverage, mutation in order

  Scenario: Feature changes use the lowercased roadmap ID (REQ-OSA-10)
    Given roadmap item "W3.1" with slug "openspec-addon"
    Then the change directory is named "w3.1-openspec-addon"

  Scenario: Malformed templates are rejected (REQ-OSA-4 boundary)
    Given a template missing its "## Review Gate" footer or with a pre-ticked box
    When the template check runs
    Then it fails naming the template
