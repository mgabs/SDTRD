#!/usr/bin/env sh
set -eu

REPO_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
BIN="$REPO_ROOT/bin/sdtrd"

FAILED=0
PASSED=0

assert_eq() {
  expected="$1"
  actual="$2"
  msg="$3"
  if [ "$expected" != "$actual" ]; then
    echo "FAIL: $msg (expected '$expected', got '$actual')"
    FAILED=$((FAILED + 1))
  else
    PASSED=$((PASSED + 1))
  fi
}

assert_file_exists() {
  file="$1"
  msg="$2"
  if [ ! -f "$file" ]; then
    echo "FAIL: $msg (missing file '$file')"
    FAILED=$((FAILED + 1))
  else
    PASSED=$((PASSED + 1))
  fi
}

assert_dir_exists() {
  dir="$1"
  msg="$2"
  if [ ! -d "$dir" ]; then
    echo "FAIL: $msg (missing directory '$dir')"
    FAILED=$((FAILED + 1))
  else
    PASSED=$((PASSED + 1))
  fi
}

# Test 1: Init into brand new directory
TMP1="$(mktemp -d /tmp/sdtrd-test1-XXXXXX)"
sh "$BIN" "$TMP1" >/dev/null

assert_dir_exists "$TMP1/specs" "specs/ created"
assert_dir_exists "$TMP1/specs/features" "specs/features/ created"
assert_dir_exists "$TMP1/specs/bug-reports" "specs/bug-reports/ created"
assert_dir_exists "$TMP1/specs/living" "specs/living/ created"
assert_dir_exists "$TMP1/specs/archive" "specs/archive/ created"
assert_dir_exists "$TMP1/specs/templates" "specs/templates/ created"
assert_file_exists "$TMP1/specs/WORKFLOW.md" "specs/WORKFLOW.md copied"
assert_file_exists "$TMP1/specs/ROADMAP.md" "specs/ROADMAP.md created"
assert_file_exists "$TMP1/specs/templates/roadmap.md" "roadmap template copied"
assert_file_exists "$TMP1/specs/templates/research.md" "research template copied"
assert_file_exists "$TMP1/specs/templates/proposal.md" "proposal template copied"
assert_file_exists "$TMP1/specs/templates/spec.md" "spec template copied"
assert_file_exists "$TMP1/specs/templates/design.md" "design template copied"
assert_file_exists "$TMP1/specs/templates/tasks.md" "tasks template copied"
assert_file_exists "$TMP1/specs/templates/bug-report.md" "bug-report template copied"
assert_file_exists "$TMP1/specs/templates/.pre-commit-config.yaml" ".pre-commit-config.yaml template copied"
assert_file_exists "$TMP1/specs/templates/sdtrd-ci.yml" "sdtrd-ci.yml template copied"
assert_file_exists "$TMP1/.pre-commit-config.yaml" ".pre-commit-config.yaml created in root"
assert_file_exists "$TMP1/.gitignore" ".gitignore created"

# Verify .gitignore content
GITIGNORE_COUNT="$(grep -c "^\.worktrees/$" "$TMP1/.gitignore" || true)"
assert_eq "1" "$GITIGNORE_COUNT" ".worktrees/ entry in .gitignore exactly once"
rm -rf "$TMP1"

# Test 2: Init into directory with existing .gitignore containing .worktrees/
TMP2="$(mktemp -d /tmp/sdtrd-test2-XXXXXX)"
printf "# Existing rules\ntarget/\n.worktrees/\n" > "$TMP2/.gitignore"
sh "$BIN" "$TMP2" >/dev/null

GITIGNORE_COUNT2="$(grep -c "^\.worktrees/$" "$TMP2/.gitignore" || true)"
assert_eq "1" "$GITIGNORE_COUNT2" ".gitignore not duplicated when already present"
rm -rf "$TMP2"

# Test 3: Init using explicit 'init' subcommand
TMP3="$(mktemp -d /tmp/sdtrd-test3-XXXXXX)"
sh "$BIN" init "$TMP3" >/dev/null

assert_file_exists "$TMP3/specs/WORKFLOW.md" "init subcommand copies specs/WORKFLOW.md"
rm -rf "$TMP3"

# Test 4: Existing .pre-commit-config.yaml is preserved
TMP4="$(mktemp -d /tmp/sdtrd-test4-XXXXXX)"
printf "custom: pre-commit\n" > "$TMP4/.pre-commit-config.yaml"
sh "$BIN" "$TMP4" >/dev/null
CONTENT="$(cat "$TMP4/.pre-commit-config.yaml")"
assert_eq "custom: pre-commit" "$CONTENT" "existing .pre-commit-config.yaml not overwritten"
rm -rf "$TMP4"

# Test 5: Inits git pre-commit branch hook when .git directory exists
TMP5="$(mktemp -d /tmp/sdtrd-test5-XXXXXX)"
git init "$TMP5" >/dev/null 2>&1
sh "$BIN" "$TMP5" >/dev/null
assert_file_exists "$TMP5/.git/hooks/pre-commit" ".git/hooks/pre-commit created"
rm -rf "$TMP5"

# Summary
echo ""
echo "=== Test Summary ==="
echo "Passed: $PASSED"
echo "Failed: $FAILED"

if [ "$FAILED" -gt 0 ]; then
  exit 1
fi
