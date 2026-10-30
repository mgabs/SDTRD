# Research & Technical Tradeoffs: SDTRD as an OpenSpec Addon

## 1. Intent & Ground Truth
SDTRD should install on top of an existing OpenSpec project rather than ship its own spec lifecycle. OpenSpec (v1.15.0, `@fission-ai/openspec`) already owns change folders, delta specs, archive and sync; SDTRD's unique value is the human gates, lanes, worktree streams, test rails (Red/Green, coverage, 100% mutation kill) and LGTM pairing. Chosen form (human decision): **schema bundle + thin `sdtrd` installer CLI**. Chosen spec model: **adopt OpenSpec deltas and layout; drop full-copy rule and `specs/{features,living,archive}`**.

### Verified Constraints & Prior Art
- **OpenSpec extension points** (verified in `docs/customization.md`, `src/core/`):
  - No plugin API. Extension is via custom schemas at `openspec/schemas/<name>/schema.yaml` (artifacts with `id`, `generates`, `template`, `instruction`, `requires`; plus `apply: {requires, tracks, instruction}`).
  - Schema resolution order: `--schema` flag → change `.openspec.yaml` → `openspec/config.yaml` → default `spec-driven`.
  - `openspec/config.yaml` supports `schema`, `context`, and per-artifact `rules` (`specs`, `tasks`, `design`).
  - `openspec init`/`update` generate skills and slash commands for ~35 tools (`src/core/command-generation/adapters/`); `openspec update` regenerates them, so hand-edited generated files are overwritten.
  - Change metadata `.openspec.yaml` accepts `skip_specs`, `retire_capabilities` and custom `x-*` keys.
  - OpenSpec only checks that artifacts **exist** (artifact graph states: done/ready/blocked/skipped). It does not enforce approvals. Community schema `anvil` documents the same limit and tells users to enforce gates with CI or hooks.
- **OpenSpec spec model**: changes live in `openspec/changes/<name>/` with `proposal.md`, `specs/**` (ADDED/MODIFIED/REMOVED/RENAMED delta requirements with scenarios), `design.md`, `tasks.md`; `openspec archive` merges deltas into `openspec/specs/` and moves the change to `changes/archive/YYYY-MM-DD-<name>`. A MODIFIED scenario-loss check exists; parallel-delta divergence is a known problem tracked in `openspec-parallel-merge-plan.md` and the `add-change-stacking-awareness` / `spec-diffs` changes.
- **OpenSpec agent contract** (`docs/agent-contract.md`): stable `--json` surfaces (`status`, `instructions`, `validate`, `list`, `archive`) that a thin installer or CI can rely on.
- **SDTRD today**: `specs/WORKFLOW.md` (Gates 0–6, B1–B3, lanes, worktrees), `templates/*.md`, `bin/sdtrd init` (copies into `specs/`), `rules/AGENTS.md`, `skills/sdtrd/SKILL.md`, `templates/sdtrd-ci.yml`, mutation configs. Strict YAGNI and "no custom CLI" stance in `docs/ROADMAP.md` (the installer CLI must stay a thin file-copier/wirer, consistent with `bin/sdtrd init`, which is already a POSIX shell script).

### Concept Map (SDTRD → OpenSpec)

| SDTRD | OpenSpec equivalent | Verdict |
| :--- | :--- | :--- |
| Gate 0 Research | none | **Add** `research` artifact in the `sdtrd` schema (root of the DAG) |
| Gate 1 Proposal | `proposal` artifact | Map; schema instruction adds Out-of-Scope (YAGNI), Success Metrics, `ASM-GEN-*` |
| Gate 2 Specs (`REQ-*`, `NFR-*`, G/W/T) | `specs` delta artifact | Map; **full-copy rule dropped**; `REQ-*`/`NFR-*` keys go into requirement headers; NFR budgets need a convention |
| Gate 3 Design | `design` artifact | Map; instruction adds Pure Core vs I/O Shell, budgets, testing strategy |
| Gate 4 Tasks & DAG | `tasks` artifact | Map; instruction adds DAG, streams/worktrees, slice order |
| Gate 5.x slice loop (BDD → Red → Green → Coverage → Mutation) | `apply.instruction` + `tasks.md` tracking | Map via apply instruction; **human BDD approval gate is not enforceable by OpenSpec** |
| Gate 6 sync/archive/merge | `openspec archive` (+ sync) | Replace spec sync/`git mv`; keep rebase/full-suite/mutation/`--ff-only` as SDTRD rails |
| Review Gate checkbox | none | Keep as artifact footer in templates; **enforce in CI/hook** |
| Lanes (feat/fix/chore) + branch protection | none | SDTRD-only layer (hook + rules) |
| Bugfix lane B1–B3 | none (could be a change) | Second schema `sdtrd-bugfix` or lane doc only (open question) |
| Worktree streams | none | SDTRD-only layer; delta-conflict risk (below) |
| ROADMAP.md waves/IDs | initiatives/work dirs (`openspec/initiatives`, `openspec/work`) | Open question: keep `specs/ROADMAP.md` vs map to OpenSpec work items |
| Red-commit policy, coverage, mutation, LGTM directives, pre-commit, CI | none | SDTRD-only layer |

---

## 2. Options Explored

### Option A: `sdtrd` schema + thin installer CLI *(human-selected form)*
- **Description**: Ship `schemas/sdtrd/` (forked from `spec-driven`: adds `research` artifact and gate/rail instructions, review-gate templates, `apply.instruction` for the slice loop) plus rules and skills. A thin `sdtrd` installer (POSIX shell, like today's `bin/sdtrd`) copies the schema into `openspec/schemas/sdtrd/`, sets `schema: sdtrd` and rules in `openspec/config.yaml`, installs hooks, `.pre-commit-config.yaml`, CI workflow, mutation templates, `.worktrees/` ignore, and `AGENTS.md` rules. CI/hook checks the Review Gate boxes via `openspec status --json` and file contents.
- **Pros**:
  - Uses OpenSpec's supported extension point; survives `openspec update`.
  - No duplicated spec lifecycle; OpenSpec archive/sync/validate reused.
  - Matches community-schema pattern (`anvil`).
  - Installer stays a file wirer; no new runtime.
- **Cons**:
  - Gates remain advisory inside OpenSpec; enforcement lives in SDTRD hooks/CI.
  - Installer must edit `config.yaml` safely (YAML merge in shell is fragile).
  - Must track OpenSpec schema/CLI changes (v1.x).

### Option B: Config-only (`config.yaml` context + rules, no schema)
- **Description**: Inject SDTRD rules via `openspec/config.yaml` `context`/`rules` and `AGENTS.md`; keep `spec-driven` schema.
- **Pros**: Smallest footprint; no schema to maintain.
- **Cons**: No `research` artifact or DAG position for Gate 0; gate footers not in templates; weak, prompt-only guidance; per-artifact `rules` only cover `specs`/`tasks`/`design`-style keys.

### Option C: Upstream contribution to OpenSpec
- **Description**: Propose gates/rails natively in Fission-AI/OpenSpec.
- **Pros**: Real enforcement (e.g., approval state in artifact graph); no addon to maintain.
- **Cons**: Out of our control and timeline; OpenSpec philosophy is "fluid not rigid", which conflicts with strict gates; SDTRD rails (worktrees, mutation) are out of its scope.

---

## 3. Comparative Tradeoff Matrix

| Criteria | Option A (Schema + installer) | Option B (Config-only) | Option C (Upstream) |
| :--- | :--- | :--- | :--- |
| **Complexity** | Med | Low | High |
| **New Dependencies** | none (POSIX sh; requires `openspec` CLI present) | none | OpenSpec release cycle |
| **Performance & Latency** | n/a | n/a | n/a |
| **Maintenance Burden** | Med (track OpenSpec schema format) | Low | Low after merge, High to land |
| **Blast Radius** | Localized (`openspec/schemas/sdtrd`, config, hooks/CI) | Localized | Wide (OpenSpec core) |
| **Gate Enforcement** | Hook/CI + prompts | Prompts only | Native |
| **Survives `openspec update`** | Yes | Yes | Yes |

---

## 4. Recommendation & Rationale
Go with **Option A**: a custom `sdtrd` schema is OpenSpec's sanctioned extension point and the only one that can add the Gate 0 `research` artifact and gate templates; keep the installer a thin shell wirer and put enforcement in the existing pre-commit/CI rails (YAGNI: no new runtime, no core changes).

### Proposed Wave 3 Items (added to ROADMAP after Go)
Final scope belongs to Gate 1; indicative only:

| ID | Item | Depends on |
| :--- | :--- | :--- |
| W3.2 | `sdtrd` OpenSpec schema + templates (research, proposal, specs, design, tasks) with gate footers | W3.1 |
| W3.3 | Gate-to-OpenSpec mapping: `REQ-*`/`NFR-*` conventions in delta specs; Gate 5.x `apply.instruction`; Gate 6 reduced to rails + `openspec archive` | W3.2 |
| W3.4 | Installer CLI: wire schema, `config.yaml`, hooks, CI, mutation templates into an existing `openspec/` project; idempotent | W3.2 |
| W3.5 | Enforcement: CI/pre-commit check of Review Gate boxes (via `openspec status --json`) and branch/lane rules | W3.2, W3.4 |
| W3.6 | Parallel worktree streams vs delta-spec conflicts (rebase + `openspec validate`; align with OpenSpec change-stacking work) | W3.3 |
| W3.7 | Bugfix lane mapping (B1–B3) and ROADMAP/initiatives decision | W3.3 |
| W3.8 | Migrate SDTRD's own repo to the addon layout (`specs/` → `openspec/`), update docs/README/WORKFLOW/AGENTS/skill, tests | W3.2–W3.5 |

---

## 5. Breaking Changes & Deprecations
There is no `specs/living/` content yet (empty), so no `REQ-*`/`NFR-*` keys are modified. Breaking changes apply to the **protocol and tooling**:
- **Affected Living Requirements**: none (no living specs exist).
- **Protocol changes** (`specs/WORKFLOW.md` §2, §6):
  - Gate 2 **Full-Copy Rule removed**; replaced by OpenSpec delta specs.
  - Canonical layout `specs/{features,living,archive}` replaced by `openspec/{changes,specs,changes/archive}`.
  - Gate 6 steps 5 and 7 (`cp -R ... specs/living/`, `git mv` archive) replaced by `openspec archive`.
  - ID/dir convention `specs/features/<id>-<slug>/` becomes `openspec/changes/<id>-<slug>/`.
- **Tooling changes**: `bin/sdtrd init` superseded by the installer; `tests/test_init.sh`, `tests/bdd`, `docs/how-tos/*`, `rules/AGENTS.md`, `skills/sdtrd/SKILL.md`, `templates/*` need updates.

### Open Questions / Risks
1. **Gate enforcement**: OpenSpec checks artifact existence only; checkbox verification must live in CI/hooks and may be bypassable locally.
2. **Delta conflicts under parallel streams**: archive-order overwrites are a known OpenSpec issue (`openspec-parallel-merge-plan.md`); streams need rebase + validate discipline until upstream lands fixes.
3. **`REQ-*`/`NFR-*` keys in delta headers**: OpenSpec matches MODIFIED/REMOVED by requirement name; key stability and NFR placement need a convention. The spec parser rules need checking at Gate 2.
4. **Skills/commands drift**: `openspec update` regenerates skills/commands for configured tools; SDTRD skills must live outside generated files (or be re-installed by the installer).
5. **Roadmap model**: keep `specs/ROADMAP.md` or map to OpenSpec `initiatives`/`work`.
6. **Bugfix lane**: second schema vs documented lane over a normal change.
7. **Version coupling**: schema format and CLI JSON shapes are tied to OpenSpec 1.x; pin a minimum version in the installer.
- **Zero Breaking Changes**:
  - [ ] Not applicable: protocol and tooling changes listed above.

---

## Review Gate: Developer Decision
- [ ] **Decision**:
  - **Go**: Proceed with Option A | Option B | Option C $\rightarrow$ Open Gate 1 (Proposal)
  - **No-Go**: Reject all options $\rightarrow$ via a `chore/roadmap-<id>` branch on `main`: commit `research.md` to `specs/archive/<id>-<slug>/` and record `❌ Dropped` + rationale in `specs/ROADMAP.md`; then delete the feature branch.
- [ ] **Developer Sign-off**: Approved by human.
