# Research & Technical Tradeoffs

## 1. Intent & Ground Truth
Follow-up to W3.9: delete dead code and bring README, wiki and how-tos in line with the OpenSpec-native workflow. Verified in the repo:

- Dead code: `gate_ticked()` in `bin/spec-rails-check` is called only by its own unit test (production uses `gate_state`/`artifact_state`); `assert_dir()` in `tests/bdd/test_bdd.sh` is never called. The installed copy `openspec/spec-rails/spec-rails-check` must change with the source (REQ-OSA-22).
- `tests/bdd/features/*.feature` are not executed by `test_bdd.sh`; they are living documentation only (kept, per W3.9 convention).
- Stale docs: `docs/how-tos/02-drive-feature-lifecycle.md` and `skills/spec-rails/SKILL.md` tell users to `mkdir`/`cp` templates by hand, although `openspec new change`, `openspec instructions <artifact>` and the `/opsx-*` commands (installed in `.github/skills`, `.github/prompts`) do this and apply the schema instructions. How-to 01 says to create `specs/ROADMAP.md` manually. README names Gates 1-4 only (no Gate 0, slice-loop 5.x or Gate 6) and its layout omits `.agents/`, `.github/skills|prompts|agents` and the installed `openspec/spec-rails/` dir.
- `docs/ROADMAP.md` is a design note, not a delivery roadmap; README labels it "Engineering Roadmap" while status lives in `specs/ROADMAP.md`.
- W3.3, W3.6, W3.7 still show ⬜ in `specs/ROADMAP.md` although REQ-OSA-7, 8, 19 describe them; needs a human status decision.

## 2. Options Explored
- **A. Targeted cleanup**: remove the two unused helpers (and the test that only exercises one), rewrite how-to 02/01, SKILL.md and README sections to the OpenSpec-native flow, fix labels and layout lists.
- **B. Docs rewrite**: consolidate README/WIKI/WAY_OF_WORKING/specs/WORKFLOW.md into one source. Large churn, risk of contradicting the canonical protocol.
- **C. Docs only**: leave dead code. Misses the explicit request.

## 3. Tradeoff Matrix

| Criteria | Option A | Option B | Option C |
| :--- | :--- | :--- | :--- |
| **Complexity** | Low | High | Low |
| **New Dependencies** | None | None | None |
| **Performance & Latency** | None | None | None |
| **Maintenance Burden** | Lower | Lowest | Unchanged |
| **Blast Radius** | Docs, one script plus copy, tests | All docs | Docs |

## 4. Recommendation
Option A: delete what nothing uses, and make docs describe the commands that actually exist.

## 5. Breaking Changes & Deprecations
None. Adds REQ-OSA-23, REQ-OSA-24 and NFR-OSA-7; no existing requirement changes. `gate_ticked` is an internal helper, not an interface.

## Review Gate
- [x] **Gate 0 Decision**: Human decides Go (name the option) or No-Go before the proposal is drafted.
