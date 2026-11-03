---
name: unit-testing
description: Use when planning, adding, reviewing, or debugging Lua unit tests, headless game tests, or test infrastructure in Dong.
---

# Lua unit and headless testing

Read [the test reference](references/test-plan.md) and [Lua style reference](../shared/lua-style.md). Inspect the current branch's implementation and tests before changing them; a passing characterization is not proof that behavior is correct.

1. Identify the subject, expected behavior, boundaries, and relevant regressions. Add tests for meaningful outcomes, including edge and failure cases, rather than assertions that only mirror implementation details.
2. Group tests into focused suites by functionality and write separately named scenarios for distinct behaviors or boundaries. Put new scenarios in the appropriate suite, or add a suite when the responsibility is distinct; avoid rebuilding a monolithic test file. Keep setup/action/assertion phases clear and use shared fixtures only for common setup.
3. Make each scenario independently runnable and independent of suite order. Reset or reload shared module state, input, clocks, random generators, and mocks where they could affect another test. Test fixtures should not hide behavior under test.
4. Control time and randomness for deterministic tests. Mock LÖVE or other external boundaries as narrowly as practical, rather than replacing the subject's behavior. Check that mocks actually exercise the path claimed by the test.
5. Test timing at different update rates and collision, scoring, movement, input, and opponent boundaries when relevant. For a known defect, describe the intended behavior and add a regression test when the fix is authorized; do not silently treat a defect as a requirement.
6. Run focused suites and the full available suite where appropriate. Report exact commands, failures, mocked boundaries, and gaps. Headless tests do not establish real keyboard input, graphics, window behavior, or play feel; use `game-testing` for runtime verification.
