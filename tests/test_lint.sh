#!/usr/bin/env sh
set -eu

REPO_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"

FAILED=0
PASSED=0

pass() {
  echo "  ✓ $1"
  PASSED=$((PASSED + 1))
}

fail() {
  echo "  ✗ $1 ($2)"
  FAILED=$((FAILED + 1))
}

echo "=== Running Shell Syntax & Spec Sanity Checks ==="

# 1. POSIX shell syntax validation
for script in "$REPO_ROOT/bin/sdtrd" "$REPO_ROOT/tests/test_init.sh" "$REPO_ROOT/tests/bdd/test_bdd.sh"; do
  if sh -n "$script"; then
    pass "Syntax valid: $(basename "$script")"
  else
    fail "Syntax error: $(basename "$script")" "sh -n failed"
  fi
done

# 2. Template integrity checks
for template in roadmap.md research.md proposal.md spec.md design.md tasks.md bug-report.md sdtrd-ci.yml .pre-commit-config.yaml; do
  path="$REPO_ROOT/templates/$template"
  if [ -s "$path" ]; then
    pass "Template present and non-empty: $template"
  else
    fail "Template missing or empty: $template" "file empty or not found"
  fi
done

# 3. Shellcheck if installed
if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck "$REPO_ROOT/bin/sdtrd" "$REPO_ROOT/tests/test_init.sh" "$REPO_ROOT/tests/bdd/test_bdd.sh"; then
    pass "ShellCheck passed"
  else
    fail "ShellCheck failed" "issues found"
  fi
else
  echo "  - ShellCheck not found in PATH (skipped locally, runs in CI)"
fi

echo ""
echo "Lint Summary: Passed: $PASSED, Failed: $FAILED"

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi
