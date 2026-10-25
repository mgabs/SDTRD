# How-To: Bootstrap a Project with SDTRD

This guide walks through initializing the SDTRD structure in any new or existing repository.

---

## 1. Run the Initializer

From the `sdtrd` repository, run:

```bash
/path/to/sdtrd/bin/sdtrd /path/to/your-project
```

Or from within your project directory:

```bash
/path/to/sdtrd/bin/sdtrd .
```

---

## 2. Verify Scaffolding

The command creates:

```text
your-project/
├── .gitignore               # Appends .worktrees/ if not present
├── .pre-commit-config.yaml  # Pre-commit hook configuration
└── specs/
    ├── WORKFLOW.md          # Canonical SDTRD workflow rules
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
rtk git add specs/ .gitignore Makefile
rtk git commit -m "chore: initialize SDTRD workflow and testing rails"
```
