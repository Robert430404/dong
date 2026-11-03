# Dong skill bundle

These project skills are discoverable by OpenCode under `.agents/skills/`. Each `SKILL.md` defines when to use it and a focused workflow. Load the skill for the primary task and any others needed for its implementation, testing, or review; do not load the whole bundle for every change.

- `lua-writing`: Lua modules, implementation, and refactoring.
- `love-gameplay`: LÖVE lifecycle, game simulation, input, screens, and rendering.
- `unit-testing`: deterministic, headless tests and test infrastructure.
- `game-testing`: real-runtime and interactive game verification.
- `code-review`: review for correctness, regressions, and meaningful style concerns.
- `git-workflow`: Git operations, commits, pushes, and pull requests.

The writing and review skills share `shared/lua-style.md`. Preserve that reference when copying the bundle. Update the references when the codebase or test setup changes, and verify the current branch rather than assuming every branch has the same features or tooling.
