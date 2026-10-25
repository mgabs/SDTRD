# How-To: Configure AI Agents with SDTRD

This guide explains how to install and enable SDTRD for Antigravity (AGY), Claude Code, and Cursor.

---

## 1. Antigravity (AGY) Integration

### Option A: Global Installation
Link the `sdtrd` plugin and skill into your user config:

```bash
mkdir -p ~/.gemini/config/plugins ~/.gemini/config/skills
ln -sfn /path/to/sdtrd ~/.gemini/config/plugins/sdtrd
ln -sfn /path/to/sdtrd/skills/sdtrd ~/.gemini/config/skills/sdtrd
```

The agent will discover `sdtrd` automatically across all projects.

### Option B: Project-Level Installation
Copy or symlink `skills/sdtrd` and `rules/AGENTS.md` into your project's `.agents/` folder:

```bash
mkdir -p .agents/skills .agents/rules
cp -r /path/to/sdtrd/skills/sdtrd .agents/skills/
cp /path/to/sdtrd/rules/AGENTS.md .agents/rules/sdtrd.md
```

Commit `.agents/` so the entire team's agents follow SDTRD rules.

---

## 2. Claude Code Integration

Add the SDTRD rules to `CLAUDE.md` in your project root:

```markdown
# SDTRD Protocol
This repository enforces Spec-Driven, Testing-Railed Development (SDTRD).
Always consult `specs/WORKFLOW.md` before starting work.
- Never edit code without human sign-off at Gates 1–4.
- Always use feature branches (`feat/*`) or isolated worktrees (`.worktrees/*`).
- Always write failing tests first (Red) before implementation (Green).
- Enforce >= 95% coverage and 100% mutation kill score on core modules.
```

---

## 3. Cursor / General IDE Integration

Place the always-on rules in `.cursorrules` or `.cursor/rules/sdtrd.mdc`:

```markdown
---
description: Spec-Driven, Testing-Railed Development Rules
globs: **/*
alwaysApply: true
---

Follow `specs/WORKFLOW.md`. Never make production changes directly on main.
Strictly follow human review gates 1 to 6. Always write tests before code.
```
