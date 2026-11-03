---
name: code-review
description: Use when reviewing Dong changes, pull requests, correctness, regressions, maintainability, or alignment with its Lua style.
---

# Code review

Read [the Lua style reference](../shared/lua-style.md). Load `love-gameplay`, `unit-testing`, or `game-testing` when the review crosses those areas.

1. Establish scope and base, inspect the working tree without modifying it, and review the diff, nearby code, callers, and relevant tests. State the scope reviewed; ask when the intended base or scope cannot be determined.
2. Trace behavior through state, input, simulation, rendering, and window transitions as applicable. Inspect current runtime configuration and test setup instead of assuming they match another branch or a function's name.
3. Prioritize demonstrable correctness defects, regressions, crashes, state loss, gameplay impact, and missing meaningful tests over aesthetics. Review timing, collision boundaries, input, random behavior, and screen changes when relevant. Existing code is evidence of style, not proof of correctness.
4. Compare Lua style to the nearest sound pattern and the `main`-derived reference. Flag deviations only when they materially affect readability or maintainability; do not enforce inconsistent historic formatting, request unrelated rewrites, or reproduce accidental globals and other defects.
5. Report actionable findings first, ordered by severity. Give each a precise file and line reference, trigger, impact, and proportionate recommendation. Distinguish introduced defects from relevant pre-existing issues and avoid presenting speculation as fact.
6. Follow findings with questions or assumptions, checks actually run, and material residual risks. If there are no actionable findings, say so. Do not edit code, commit, or push during review unless separately requested.
