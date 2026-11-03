---
name: git-workflow
description: Use when inspecting Git changes, creating branches or commits, pushing, or working with pull requests in Dong.
---

# Git workflow

1. Inspect the current branch, working-tree status, and relevant diff before changing branches, staging, or committing. Treat staged, unstaged, and untracked changes as potential user work; do not discard or overwrite them.
2. Choose a descriptive branch and an appropriate base when asked to start one. Reuse a suitable existing branch when it is part of the same work. Preserve existing changes during branch operations; ask before proceeding if their ownership or the safe scope is unclear.
3. Stage only the intended files or hunks, review the staged diff, and run relevant available checks. Group related changes into a clear commit; do not infer a mandatory branch naming or commit-message policy from another repository.
4. Commit only when requested or clearly authorized. Push and create or update pull requests only when requested or clearly authorized; never merge, force-push, amend, rewrite history, reset, or discard changes without explicit authorization. Avoid committing credentials or temporary diagnostics.
5. Use noninteractive Git commands. Confirm the intended remote and base for a push or pull request, and report the commit, branch, checks, push status, and PR link as applicable. Check the working tree before claiming it is clean.
