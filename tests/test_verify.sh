#!/usr/bin/env sh
# Fixture tests for bin/spec-rails-verify (REQ-OSA-26/27/28, NFR-OSA-9).
set -eu

REPO_ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
VERIFY="${SPEC_RAILS_VERIFY:-$REPO_ROOT/bin/spec-rails-verify}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
PASSED=0
FAILED=0

[ -f "$VERIFY" ] || { echo "FAIL: $VERIFY missing"; exit 1; }

# new_repo: fresh fixture with one active change declaring REQ-X-1 (ADDED) and NFR-X-2 (MODIFIED).
new_repo() {
  rm -rf "$TMP/p"
  mkdir -p "$TMP/p/openspec/changes/demo/specs/cap" "$TMP/p/openspec/spec-rails" "$TMP/p/tests"
  printf '%s\n' '# Delta' '## ADDED Requirements' '### Requirement: REQ-X-1 One' '## MODIFIED Requirements' '### Requirement: NFR-X-2 Two' '## Review Gate' '### Requirement: REQ-X-9 Not a delta key' \
    > "$TMP/p/openspec/changes/demo/specs/cap/spec.md"
  printf '%s\n' '- [ ] 3.3 Red tests fail' > "$TMP/p/openspec/changes/demo/tasks.md"
}

# run_case NAME EXPECTED_EXIT OUTPUT_PATTERN
run_case() {
  name="$1"; want="$2"; pat="$3"
  rc=0
  out="$(cd "$TMP/p" && sh "$VERIFY" 2>&1)" || rc=$?
  if [ "$rc" -eq "$want" ] && printf '%s' "$out" | grep -qE "$pat"; then
    PASSED=$((PASSED + 1)); echo "PASS: $name"
  else
    FAILED=$((FAILED + 1)); echo "FAIL: $name (exit $rc, wanted $want, pattern '$pat')"; echo "$out"
  fi
}

new_repo
printf '%s\n' '@REQ-X-1 @NFR-X-2' > "$TMP/p/tests/a.feature"
run_case "covered keys pass" 0 'all checks passed'

new_repo
printf '%s\n' '@REQ-X-1' > "$TMP/p/tests/a.feature"
run_case "uncovered key fails and is named" 1 'FAIL: NFR-X-2'

new_repo
printf '%s\n' '@REQ-X-1 @NFR-X-2' > "$TMP/p/tests/a.feature"
run_case "non-delta section keys ignored" 0 'all checks passed'
if (cd "$TMP/p" && sh "$VERIFY" 2>&1 | grep -q 'REQ-X-9'); then
  FAILED=$((FAILED + 1)); echo "FAIL: REQ-X-9 should not be checked"
else
  PASSED=$((PASSED + 1)); echo "PASS: REQ-X-9 not checked"
fi

rm -rf "$TMP/p"; mkdir -p "$TMP/p/openspec/spec-rails"
run_case "no active changes passes" 0 'all checks passed'

new_repo
printf '%s\n' '@REQ-X-1 @NFR-X-2' > "$TMP/p/tests/a.feature"
printf '%s\n' '- [x] 3.3 Red tests fail' > "$TMP/p/openspec/changes/demo/tasks.md"
run_case "ticked task without evidence fails" 1 'without .Evidence:'

printf '%s\n' '- [x] 3.3 Red tests fail Evidence: make test -> 3 failed' > "$TMP/p/openspec/changes/demo/tasks.md"
run_case "ticked task with evidence passes" 0 'all checks passed'

printf '%s\n' '- [x] 3.3 Red tests fail Evidence:   ' > "$TMP/p/openspec/changes/demo/tasks.md"
run_case "empty evidence fails" 1 'without .Evidence:'

printf '%s\n' '- [ ] 3.3 Red tests fail' '- [x] 4.1 Write docs' > "$TMP/p/openspec/changes/demo/tasks.md"
run_case "unticked and unrelated tasks ignored" 0 'all checks passed'

printf '%s\n' 'RAILS_COVERAGE="exit 1"' > "$TMP/p/openspec/spec-rails/rails.conf"
run_case "failing command is named" 1 'RAILS_COVERAGE exited non-zero'

printf '%s\n' 'RAILS_TEST="true"' 'RAILS_COVERAGE="true"' 'RAILS_MUTATION="true"' > "$TMP/p/openspec/spec-rails/rails.conf"
run_case "all commands pass" 0 'running RAILS_MUTATION'

rm "$TMP/p/openspec/spec-rails/rails.conf"
run_case "missing config warns" 0 'warning: RAILS_TEST is not defined'

printf '%s\n' 'RAILS_TEST_DIRS="spec"' > "$TMP/p/openspec/spec-rails/rails.conf"
run_case "custom test dir honoured" 1 'FAIL: REQ-X-1'

new_repo
printf '%s\n' '@REQ-X-1 @NFR-X-2' > "$TMP/p/tests/a.feature"
start="$(date +%s)"
(cd "$TMP/p" && sh "$VERIFY" >/dev/null 2>&1)
if [ $(( $(date +%s) - start )) -le 5 ]; then
  PASSED=$((PASSED + 1)); echo "PASS: own checks within 5s"
else
  FAILED=$((FAILED + 1)); echo "FAIL: own checks exceeded 5s"
fi

echo "verify: $PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
