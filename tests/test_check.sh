#!/usr/bin/env sh
set -eu

REPO_ROOT="$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)"
BIN="${SPEC_RAILS_CHECK_BIN:-$REPO_ROOT/bin/spec-rails-check}"

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
    *)
      echo "FAIL: $3 (expected to contain '$1', got '$2')"
      FAILED=$((FAILED + 1))
      ;;
  esac
}

assert_not_contains() {
  case "$2" in
    *"$1"*)
      echo "FAIL: $3 (unexpected '$1' in '$2')"
      FAILED=$((FAILED + 1))
      ;;
    *) PASSED=$((PASSED + 1)) ;;
  esac
}

echo "=== Running spec-rails-check tests ==="

if [ ! -f "$BIN" ]; then
  echo "FAIL: $BIN missing"
  exit 1
fi

# Scratch space lives outside the repo so no parent git repo leaks into the tests.
SCR=$(mktemp -d "${TMPDIR:-/tmp}/spec-rails-check.XXXXXX")
trap 'rm -rf "$SCR"' EXIT INT TERM
mkdir -p "$SCR/stub"

# Stub openspec: canned JSON from $STUB_DIR, every call logged to $STUB_DIR/log.
cat >"$SCR/stub/openspec" <<'STUB'
#!/usr/bin/env sh
echo "$*" >>"$STUB_DIR/log"
case "$1" in
  list)
    cat "$STUB_DIR/list.json"
    exit "${STUB_LIST_RC:-0}"
    ;;
  status)
    cat "$STUB_DIR/status-$3.json"
    exit "${STUB_STATUS_RC:-0}"
    ;;
esac
exit 64
STUB
chmod +x "$SCR/stub/openspec"

# PATH without jq: symlink the tools the script needs, minus jq.
mkdir -p "$SCR/nojq"
for tool in sh git awk sort find cat dirname; do
  ln -s "$(command -v "$tool")" "$SCR/nojq/$tool"
done
ln -s "$SCR/stub/openspec" "$SCR/nojq/openspec"

N=0
# new_repo <branch|""> -> sets WORK (a fresh git repo, or plain dir if branch is empty)
new_repo() {
  N=$((N + 1))
  WORK="$SCR/w$N"
  mkdir -p "$WORK/openspec/changes"
  if [ -n "$1" ]; then git init -q -b "$1" "$WORK"; fi
  STUB_DIR="$WORK/.stub"
  mkdir -p "$STUB_DIR"
  export STUB_DIR
  printf '{"changes":[]}' >"$STUB_DIR/list.json"
  unset STUB_LIST_RC STUB_STATUS_RC || true
}

requires_of() {
  case "$1" in
    proposal) echo '"research"' ;;
    specs) echo '"proposal"' ;;
    design) echo '"specs"' ;;
    tasks) echo '"design"' ;;
    *) echo '' ;;
  esac
}

# add_change <name> <research=done ...>: registers the change and its status JSON.
add_change() {
  _name=$1
  shift
  _arts=""
  for _kv in "$@"; do
    _id=${_kv%%=*}
    _st=${_kv#*=}
    _arts="$_arts${_arts:+,}{\"id\":\"$_id\",\"status\":\"$_st\",\"requires\":[$(requires_of "$_id")]}"
  done
  printf '{"changeName":"%s","artifactPaths":{},"artifacts":[%s]}' "$_name" "$_arts" \
    >"$STUB_DIR/status-$_name.json"
  _names=$(cat "$STUB_DIR/list.json" | sed 's/^{"changes":\[//; s/\]}$//')
  printf '{"changes":[%s{"name":"%s"}]}' "${_names:+$_names,}" "$_name" >"$STUB_DIR/list.json"
  mkdir -p "$WORK/openspec/changes/$_name"
}

# artifact <change> <relpath> <ticked|unticked|none|nobox> <gate n>
artifact() {
  _f="$WORK/openspec/changes/$1/$2"
  mkdir -p "$(dirname "$_f")"
  {
    printf '# Title\n\nBody\n\n'
    case "$3" in
      ticked) printf '## Review Gate\n- [x] **Gate %s Approval**: ok\n' "$4" ;;
      unticked) printf '## Review Gate\n- [ ] **Gate %s Approval**: ok\n' "$4" ;;
      nobox) printf '## Review Gate\nNo box here.\n' ;;
    esac
  } >"$_f"
}

RC=0
OUT=""
ERR=""
run_check() {
  RC=0
  (cd "$WORK" && PATH="$SCR/stub:$PATH" sh "$BIN" >"$WORK/out" 2>"$WORK/err") || RC=$?
  OUT=$(cat "$WORK/out")
  ERR=$(cat "$WORK/err")
}

# --- Unit: gate_state / gate_ticked -----------------------------------------
SPEC_RAILS_SOURCE_ONLY=1
export SPEC_RAILS_SOURCE_ONLY
# shellcheck disable=SC1090
. "$BIN"
unset SPEC_RAILS_SOURCE_ONLY

U="$SCR/unit"
mkdir -p "$U"
printf '# T\n## Review Gate\n- [x] **Gate 1**: a\n' >"$U/ticked.md"
printf '# T\n## Review Gate\n- [X] **Gate 1**: a\n' >"$U/upper.md"
printf '# T\n## Review Gate\n- [ ] **Gate 1**: a\n' >"$U/unticked.md"
printf '# T\n\nNo gate here\n' >"$U/nosection.md"
printf '# T\n- [x] early box\n## Review Gate\n- [ ] **Gate 1**: a\n' >"$U/before.md"
printf '# T\n## Review Gate\n- [ ] **Gate 1**: a\n## Appendix\n- [x] other\n' >"$U/after.md"
printf '# T\n## Review Gate  \nprose only\n' >"$U/nobox.md"
printf '# T\n## Review Gate\n- [ ] **Gate 1**: a\n- [x] **Gate 1b**: b\n' >"$U/mixed.md"

assert_eq ticked "$(gate_state "$U/ticked.md")" "gate_state ticked"
assert_eq ticked "$(gate_state "$U/upper.md")" "gate_state accepts [X]"
assert_eq unticked "$(gate_state "$U/unticked.md")" "gate_state unticked"
assert_eq missing "$(gate_state "$U/nosection.md")" "gate_state no section"
assert_eq unticked "$(gate_state "$U/before.md")" "gate_state ignores box before section"
assert_eq unticked "$(gate_state "$U/after.md")" "gate_state ignores box after section"
assert_eq missing "$(gate_state "$U/nobox.md")" "gate_state section without box"
assert_eq ticked "$(gate_state "$U/mixed.md")" "gate_state any ticked box in section"
assert_eq missing "$(gate_state "$U/absent.md")" "gate_state missing file"

for f in ticked upper mixed; do
  if gate_ticked "$U/$f.md"; then PASSED=$((PASSED + 1)); else
    echo "FAIL: gate_ticked true for $f"
    FAILED=$((FAILED + 1))
  fi
done
for f in unticked nosection before after nobox absent; do
  if gate_ticked "$U/$f.md"; then
    echo "FAIL: gate_ticked false for $f"
    FAILED=$((FAILED + 1))
  else PASSED=$((PASSED + 1)); fi
done

# --- Unit: violations --------------------------------------------------------
ST='{"artifacts":[{"id":"research","status":"done","requires":[]},{"id":"proposal","status":"done","requires":["research"]},{"id":"specs","status":"done","requires":["proposal"]},{"id":"design","status":"ready","requires":["specs"]}]}'
assert_eq "" "$(violations c1 "$ST" "research ticked
proposal ticked
specs unticked
")" "violations none (last done artifact's own gate not checked)"
assert_eq "c1: Gate 1 (proposal) unticked but 'specs' exists" "$(violations c1 "$ST" "research ticked
proposal unticked
specs unticked
")" "violations single unticked"
assert_eq "c1: Gate 0 (research) unticked but 'proposal' exists
c1: Gate 1 (proposal) Review Gate section missing but 'specs' exists" "$(violations c1 "$ST" "research unticked
proposal missing
")" "violations multiple, missing section wording"
SK='{"artifacts":[{"id":"proposal","status":"done","requires":[]},{"id":"specs","status":"skipped","requires":["proposal"]},{"id":"design","status":"done","requires":["specs"]}]}'
assert_eq "" "$(violations c1 "$SK" "specs unticked
")" "violations ignores skipped upstream"

# --- artifact_state ---------------------------------------------------------
AC="$SCR/ac"
mkdir -p "$AC/specs/a" "$AC/specs/b"
assert_eq missing "$(artifact_state "$AC" specs)" "artifact_state specs: no files"
printf '## Review Gate\n- [x] **Gate 2**: a\n' >"$AC/specs/a/spec.md"
assert_eq ticked "$(artifact_state "$AC" specs)" "artifact_state specs: one ticked"
printf '## Review Gate\n- [ ] **Gate 2**: a\n' >"$AC/specs/b/spec.md"
assert_eq unticked "$(artifact_state "$AC" specs)" "artifact_state specs: one unticked"
printf 'no section\n' >"$AC/specs/b/spec.md"
assert_eq missing "$(artifact_state "$AC" specs)" "artifact_state specs: section missing"
assert_eq ticked "$(artifact_state "$AC" bogus)" "artifact_state unknown id"

# --- Scenario: unticked gate blocks later artifacts --------------------------
new_repo feat/x
add_change c1 research=done proposal=done specs=done design=ready tasks=blocked
artifact c1 research.md ticked 0
artifact c1 proposal.md unticked 1
artifact c1 specs/cap/spec.md unticked 2
run_check
assert_eq 1 "$RC" "unticked gate exits 1"
assert_contains "c1" "$ERR" "names change"
assert_contains "Gate 1" "$ERR" "names unticked gate"
assert_not_contains "Gate 2" "$ERR" "later gate not reported"
assert_eq "" "$OUT" "no stdout noise"

# --- Scenario: ticked gates pass ---------------------------------------------
new_repo feat/x
add_change c1 research=done proposal=done specs=done design=done tasks=done
artifact c1 research.md ticked 0
artifact c1 proposal.md ticked 1
artifact c1 specs/a/spec.md ticked 2
artifact c1 specs/b/spec.md ticked 2
artifact c1 design.md ticked 3
artifact c1 tasks.md unticked 4
run_check
assert_eq 0 "$RC" "ticked gates exit 0"
assert_eq "" "$ERR" "no stderr on success"

# --- Scenario: missing gate section ------------------------------------------
new_repo feat/x
add_change c1 research=done proposal=done specs=done design=ready tasks=blocked
artifact c1 research.md ticked 0
artifact c1 proposal.md none 1
artifact c1 specs/cap/spec.md unticked 2
run_check
assert_eq 1 "$RC" "missing section exits 1"
assert_contains "c1" "$ERR" "missing section names change"
assert_contains "proposal" "$ERR" "missing section names artifact"

# specs done but one spec file lacks its gate; specs done with no files at all
new_repo feat/x
add_change c1 research=done proposal=done specs=done design=done tasks=ready
artifact c1 research.md ticked 0
artifact c1 proposal.md ticked 1
artifact c1 specs/a/spec.md ticked 2
artifact c1 specs/b/spec.md none 2
artifact c1 design.md ticked 3
run_check
assert_eq 1 "$RC" "spec file without gate exits 1"
assert_contains "Gate 2 (specs)" "$ERR" "names specs gate"

new_repo feat/x
add_change c1 research=done proposal=done specs=done design=done tasks=ready
artifact c1 research.md ticked 0
artifact c1 proposal.md ticked 1
artifact c1 design.md ticked 3
run_check
assert_eq 1 "$RC" "specs done but absent exits 1"

# skipped specs do not trigger a violation
new_repo feat/x
add_change c1 research=done proposal=done specs=skipped design=done tasks=ready
artifact c1 research.md ticked 0
artifact c1 proposal.md ticked 1
artifact c1 design.md ticked 3
run_check
assert_eq 0 "$RC" "skipped specs exit 0"

# --- Scenario: all violations reported ---------------------------------------
new_repo feat/x
add_change c1 research=done proposal=done specs=blocked design=blocked tasks=blocked
add_change c2 research=done proposal=done specs=done design=blocked tasks=blocked
artifact c1 research.md unticked 0
artifact c2 research.md ticked 0
artifact c2 proposal.md unticked 1
run_check
assert_eq 1 "$RC" "multiple violations exit 1"
assert_contains "c1: Gate 0" "$ERR" "first change reported"
assert_contains "c2: Gate 1" "$ERR" "second change reported"

new_repo feat/x
add_change c1 research=done proposal=done specs=done design=blocked tasks=blocked
artifact c1 research.md unticked 0
artifact c1 proposal.md unticked 1
run_check
assert_contains "Gate 0" "$ERR" "same change: first violation"
assert_contains "Gate 1" "$ERR" "same change: second violation"

# --- Scenario: no active changes ---------------------------------------------
new_repo feat/x
run_check
assert_eq 0 "$RC" "no changes exit 0"
assert_not_contains "status" "$(cat "$STUB_DIR/log")" "no status call without changes"

# --- Scenario: lane check ----------------------------------------------------
for b in main master; do
  new_repo "$b"
  run_check
  assert_eq 1 "$RC" "branch $b exits 1"
  assert_contains "$b" "$ERR" "branch $b named"
done

new_repo feat/x
run_check
assert_eq 0 "$RC" "feature branch allowed"

new_repo ""
run_check
assert_eq 0 "$RC" "non-git directory allowed"

new_repo feat/x
git -C "$WORK" -c user.name=t -c user.email=t@t commit -q --allow-empty -m x
git -C "$WORK" checkout -q --detach
run_check
assert_eq 0 "$RC" "detached HEAD allowed"

# --- Scenario: malformed / failing openspec output ---------------------------
new_repo feat/x
add_change c1 research=done
printf 'not json{' >"$STUB_DIR/status-c1.json"
run_check
assert_eq 2 "$RC" "malformed status exits 2"
assert_contains "c1" "$ERR" "malformed status names change"
assert_contains "parse error" "$ERR" "malformed status includes jq parse error"

new_repo feat/x
add_change c1 research=done
printf '{"changeName":"c1"}' >"$STUB_DIR/status-c1.json"
run_check
assert_eq 2 "$RC" "status without artifacts exits 2"
assert_contains "no artifacts array" "$ERR" "missing artifacts message"

new_repo feat/x
printf 'garbage' >"$STUB_DIR/list.json"
run_check
assert_eq 2 "$RC" "malformed list exits 2"
assert_contains "cannot parse 'openspec list --json'" "$ERR" "malformed list message"

new_repo feat/x
printf '{"other":1}' >"$STUB_DIR/list.json"
run_check
assert_eq 2 "$RC" "list without changes key exits 2"

new_repo feat/x
STUB_LIST_RC=1
export STUB_LIST_RC
run_check
assert_eq 2 "$RC" "list command failure exits 2"
assert_contains "failed" "$ERR" "list failure message"

new_repo feat/x
add_change c1 research=done
STUB_STATUS_RC=1
export STUB_STATUS_RC
run_check
assert_eq 2 "$RC" "status command failure exits 2"
assert_contains "failed" "$ERR" "status failure message"
unset STUB_STATUS_RC STUB_LIST_RC

# --- Scenario: environment prerequisites -------------------------------------
new_repo feat/x
RC=0
(cd "$WORK" && PATH="$SCR/nojq" sh "$BIN" >"$WORK/out" 2>"$WORK/err") || RC=$?
assert_eq 2 "$RC" "missing jq exits 2"
assert_contains "jq" "$(cat "$WORK/err")" "missing jq message"

mkdir -p "$SCR/noos"
for tool in sh git awk sort find cat dirname jq; do
  ln -s "$(command -v "$tool")" "$SCR/noos/$tool"
done
RC=0
(cd "$WORK" && PATH="$SCR/noos" sh "$BIN" >"$WORK/out" 2>"$WORK/err") || RC=$?
assert_eq 2 "$RC" "missing openspec exits 2"
assert_contains "openspec" "$(cat "$WORK/err")" "missing openspec message"

# --- Scenario: presence comes from openspec, not schema.yaml -----------------
new_repo feat/x
add_change c1 research=done proposal=ready specs=blocked design=blocked tasks=blocked
artifact c1 research.md unticked 0
run_check
assert_eq 0 "$RC" "only done artifacts trigger gate checks"
assert_contains "status --change c1 --json" "$(cat "$STUB_DIR/log")" "status --json consulted"
assert_eq 0 "$(grep -c 'schema\.yaml' "$BIN" || true)" "check never references schema.yaml"

echo ""
echo "Check Summary: Passed: $PASSED, Failed: $FAILED"

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi
