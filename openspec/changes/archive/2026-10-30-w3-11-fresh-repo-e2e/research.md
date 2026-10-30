# Research & Technical Tradeoffs

## 1. Intent & Ground Truth
Goal: prove, in a brand-new repo, how Spec-Rails layers its workflow on top of OpenSpec. Verified in this repo:

- `tests/test_installer.sh` runs `bin/spec-rails` against a **stub** `openspec` binary (prints a version, exits 0). It checks files, idempotency and version gating (REQ-OSA-11 to 15) but never asks the real OpenSpec CLI to resolve the installed schema.
- `tests/test_schema.sh` validates the schema in this repo only; `tests/test_check.sh` unit-tests `spec-rails-check` with fixtures. Nothing runs the whole chain: `openspec init` -> `spec-rails` -> `openspec new change` -> `openspec status/instructions` -> gate hook behaviour.
- The installer wires: schema copy to `openspec/schemas/spec-rails/`, `schema: spec-rails` in `openspec/config.yaml`, rules and templates under `openspec/spec-rails/`, `.pre-commit-config.yaml`, `.github/workflows/spec-rails-ci.yml`, and a git pre-commit hook that runs `spec-rails-check`.
- OpenSpec CLI >= 1.15.0 and `jq` are required (REQ-OSA-11); the installer must survive `openspec update` (REQ-OSA-14).
- Not verified: whether the real CLI in a fresh temp repo resolves the project-local schema and reports the gate artifacts in order. This is exactly what the change would establish. Network access is not needed if the CLI is already installed.

## 2. Options Explored
- **A. Real-CLI end-to-end shell test**: `tests/test_e2e.sh` creates a temp git repo, runs the real `openspec init`, runs `bin/spec-rails`, creates a change, and asserts schema resolution, artifact order, hook blocking an unticked gate, and `openspec validate`. Skips with a visible message when `openspec` or `jq` is missing. New `make test-e2e` target; included in `make test`.
- **B. Manual how-to only**: document a walkthrough in `docs/how-tos/`. Cheap, but not enforced, and drifts again.
- **C. Replace the stub in `test_installer.sh` with the real CLI**: removes the stub's version-gating cases, which need a fake version. Loses coverage.

## 3. Tradeoff Matrix

| Criteria | Option A | Option B | Option C |
| :--- | :--- | :--- | :--- |
| **Complexity** | Medium (one script) | Low | Medium |
| **New Dependencies** | None (needs `openspec`, `jq`, already required) | None | None |
| **Performance & Latency** | A few seconds, temp dir only | None | Slower installer test |
| **Maintenance Burden** | Low; catches CLI drift | Higher; manual | Medium |
| **Blast Radius** | Tests and Makefile only | Docs | Existing installer tests |

## 4. Recommendation
Option A: keep the stubbed installer test for version gating and add one real-CLI end-to-end test that exercises the whole addon chain in a fresh repo. No production code changes unless the test finds a real defect (reported, not silently fixed).

## 5. Breaking Changes & Deprecations
None. Adds REQ-OSA-25 and NFR-OSA-8; no existing requirement changes.

## Review Gate
- [x] **Gate 0 Decision**: Human decides Go (name the option) or No-Go before the proposal is drafted.
