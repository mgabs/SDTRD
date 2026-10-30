# Bug Report: Existing pre-commit hook never runs sdtrd-check

## Status
- **Status**: Resolved
- **Date**: `2026-10-30`
- **Severity**: Medium
- **Component**: `bin/sdtrd` (hook install)
- **Worktree / Branch**: `fix/existing-hook-check`
- **Regression Tests Added**:
  - `tests/test_installer.sh` (existing hook section)

## Summary
When the target already has `.git/hooks/pre-commit`, the installer leaves it untouched, so gate and lane checks (REQ-OSA-16, 17) are silently absent.

## Steps to Reproduce
1. Create a git repo with a user `.git/hooks/pre-commit`.
2. Run the installer.

### Expected Result
The user hook is preserved and additionally runs `openspec/sdtrd/sdtrd-check`; re-running does not duplicate the call.

### Actual Result
The hook is unchanged and never calls `sdtrd-check`.
