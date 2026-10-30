#!/usr/bin/env sh
# End-to-end: real OpenSpec CLI + spec-rails installer in a brand-new repo (REQ-OSA-25, NFR-OSA-8).
set -eu

REPO_ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
BIN="$REPO_ROOT/bin/spec-rails"

for tool in openspec jq git; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "SKIP: '$tool' not found on PATH; end-to-end test not run"
    exit 0
  fi
done

FAILED=0
PASSED=0

assert_eq() {
  if [ "$1" != "$2" ]; then
    echo "FAIL: $3 (expected '$1', got '$2')"
    FAILED=$((FAILED + 1))
  else
    PASSED=$((PASSED + 1))
  fi
}

assert_contains() {
  case "$2" in
    *"$1"*) PASSED=$((PASSED + 1)) ;;
    *) echo "FAIL: $3 (missing '$1' in '$2')"; FAILED=$((FAILED + 1)) ;;
  esac
}

SCRATCH="$(mktemp -d /tmp/spec-rails-e2e-XXXXXX)"
trap 'rm -rf "$SCRATCH"' EXIT
P="$SCRATCH/proj"
mkdir -p "$P"
cd "$P"

git init -q -b main
git config user.name e2e
git config user.email e2e@example.com
openspec init --tools none >/dev/null 2>&1 || { echo "FAIL: openspec init failed"; exit 1; }
sh "$BIN" "$P" >/dev/null 2>&1 || { echo "FAIL: spec-rails install failed"; exit 1; }

git checkout -q -b feat/demo
openspec new change demo >/dev/null 2>&1 || { echo "FAIL: openspec new change failed"; exit 1; }

# ---- Schema resolved, artifact order ----
STATUS="$(openspec status --change demo --json)"
assert_eq "spec-rails" "$(printf '%s' "$STATUS" | jq -r '.schemaName')" "schema resolved"
assert_eq "research proposal specs design tasks" \
  "$(printf '%s' "$STATUS" | jq -r '[.artifacts[].id] | join(" ")')" "artifact order"

# ---- Gates: unticked blocks, ticked allows ----
D="openspec/changes/demo"
printf '# Research\n\n## Review Gate\n- [ ] **Gate 0 Decision**: x\n' > "$D/research.md"
printf '# Proposal\n\n## Review Gate\n- [ ] **Gate 1 Approval**: x\n' > "$D/proposal.md"
git add "$D/research.md" "$D/proposal.md"
RC=0
OUT="$(git commit -q -m "proposal before gate 0" 2>&1)" || RC=$?
assert_eq "1" "$RC" "unticked gate blocks commit"
assert_contains "Gate 0 (research) unticked" "$OUT" "hook names the unticked gate"

printf '# Research\n\n## Review Gate\n- [x] **Gate 0 Decision**: x\n' > "$D/research.md"
git add "$D/research.md"
RC=0
OUT="$(git commit -q -m "tick gate 0" 2>&1)" || RC=$?
assert_eq "0" "$RC" "ticked gate allows commit"

echo "E2E Summary: Passed: $PASSED, Failed: $FAILED"
[ "$FAILED" -eq 0 ]
