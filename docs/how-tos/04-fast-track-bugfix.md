# How-To: Fast-Track Bugfix Protocol (Zero-Contamination)

When a regression, runtime panic, or dogfood defect is discovered, this guide details how to resolve it with zero branch contamination.

---

## Hard Rules

- **NEVER** edit production code directly on `main` or `master`.
- **NEVER** fix a bug inside an uncommitted, dirty feature branch.
- **NEVER** apply a fix without a failing test reproducing the defect first.

---

## Step 1: Gate B1 — Log Bug Report & Root Cause

1. Copy the bug report template:
   ```bash
   date_str=$(date +%Y-%m-%d)
   cp specs/templates/bug-report.md "specs/bug-reports/${date_str}-token-expiry-panic.md"
   ```
2. Document:
   - Component affected
   - Exact reproduction steps
   - Expected vs Actual behavior
   - Root cause analysis
   - Remediation plan
3. Obtain Gate B1 human approval before touching code.

---

## Step 2: Spawn Isolated Bugfix Worktree

Branch directly off the target base branch (`main` or `master`):

```bash
rtk git worktree add .worktrees/fix-token-expiry -b fix/token-expiry main
```

Navigate to the worktree:

```bash
cd .worktrees/fix-token-expiry
```

---

## Step 3: Gate B2 — Mandatory Red-First Reproduction

1. Write a targeted regression test recreating the defect *before modifying production code*.
2. Run the test:
   ```bash
   # Test MUST fail (Red)
   cargo test test_token_expiry_panic
   # or: pytest tests/test_token.py -k test_token_expiry_panic
   ```
3. Verify test failure matches the reported defect.

---

## Step 4: Minimal Surgical Fix (Green)

1. Apply the minimal code change to turn the test passing (`Green`).
2. Run the full test suite to guarantee zero regressions.
3. Check mutation resistance if applicable.

---

## Step 5: Gate B3 — Integration Sign-off & Pruning

1. Return to the main repository:
   ```bash
   cd ../..
   rtk git checkout main
   ```
2. Fast-forward merge the fix:
   ```bash
   rtk git merge --ff-only fix/token-expiry
   ```
3. Prune the worktree and delete the fix branch:
   ```bash
   rtk git worktree remove .worktrees/fix-token-expiry
   rtk git branch -d fix/token-expiry
   ```
4. Mark the bug report as `Resolved` in `specs/bug-reports/` with the commit hash.
5. If active feature streams or worktrees need the fix, rebase them on updated `main`.
