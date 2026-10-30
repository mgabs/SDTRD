# How-To: Bootstrap a Project with Spec-Rails

This guide walks through installing Spec-Rails on an OpenSpec project.

> **Prerequisites**: run `openspec init` first (OpenSpec ≥ 1.15.0 on `PATH`) and install `jq`. The installer exits non-zero and writes nothing otherwise. It is idempotent, sets `schema: spec-rails` in `openspec/config.yaml`, never overwrites an existing `.pre-commit-config.yaml`, and puts agent rules in `openspec/spec-rails/` so `openspec update` leaves them alone. The scaffold listing below describes the legacy layout; see `specs/WORKFLOW.md` §7 for the OpenSpec layout.

---

## 1. Run the Initializer

From the `spec-rails` repository, run:

```bash
/path/to/spec-rails/bin/spec-rails /path/to/your-project
```

Or from within your project directory:

```bash
/path/to/spec-rails/bin/spec-rails .
```

---

## 2. Verify Scaffolding

The command creates:

```text
your-project/
├── .gitignore               # Appends .worktrees/ if not present
├── .pre-commit-config.yaml  # Pre-commit hook configuration
└── specs/
    ├── WORKFLOW.md          # Canonical Spec-Rails workflow rules
    ├── features/            # Active and proposed feature specs
    ├── bug-reports/         # Fast-track bug reports
    ├── living/              # Evergreen canonical system specifications
    └── templates/           # Reusable markdown templates
        ├── proposal.md      # Gate 1 template
        ├── spec.md          # Gate 2 template
        ├── design.md        # Gate 3 template
        ├── tasks.md         # Gate 4 template
        ├── bug-report.md    # Gate B1 template
        └── .pre-commit-config.yaml
```

---

## 3. Install Pre-Commit Hooks

Install the git hooks into `.git/hooks/`:

```bash
pre-commit install
```

Verify that hooks run cleanly on all files:

```bash
pre-commit run --all-files
```

---

## 4. Configure Your Project Rails

Add testing rails to your project's task runner (e.g. `Makefile`, `package.json`, `Cargo.toml`, or `pyproject.toml`):

1. **Test Runner**: Command to run unit and BDD tests.
2. **Coverage Threshold**: Command to enforce $\ge 95\%$ line & branch coverage.
3. **Mutation Testing**: Command to execute mutation analysis on core domain logic.

Example `Makefile` targets:

```makefile
test:
	@# Run BDD and unit tests
	pytest tests/

coverage:
	@# Enforce >= 95% line & branch coverage
	pytest --cov=src --cov-fail-under=95 --cov-branch

mutants:
	@# Verify 100% mutation kill score on core logic
	mutmut run
```

---

## 4. Commit Baseline

```bash
git add specs/ .gitignore Makefile
git commit -m "chore: initialize Spec-Rails workflow and testing rails"
```
