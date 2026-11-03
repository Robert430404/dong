---
name: lua-writing
description: Use when writing, refactoring, or reviewing Lua modules, functions, state, or code style in Dong.
---

# Lua writing

Read [the Lua style reference](../shared/lua-style.md). Inspect the current branch, the implementation, callers, and nearby code before making changes. Use `love-gameplay` for LÖVE lifecycle or gameplay changes and `unit-testing` for test work.

1. Follow the closest sound local convention for indentation, names, module tables, and method definitions. Keep code hand-composed, readable, and appropriately scoped; do not reformat unrelated code or treat historical bugs as style requirements.
2. Use `local` for temporary variables and explicit `self` or table access for state. Check whether a table or required module is shared mutable state, and avoid introducing hidden globals, surprising side effects, or unnecessarily coupled modules.
3. Check Lua and LuaJIT compatibility, `nil` and truthiness behavior, table ownership, and the installed LÖVE version where relevant. Preserve public module contracts and established behavior unless the task calls for a change.
4. Prefer named values and straightforward branches over clever expressions or unnecessary abstractions. Use helpers where they clarify a repeated operation or responsibility, not merely to shorten code.
5. Cover changed behavior and boundaries with focused tests where practical. Run the checks available on the current branch and report actual results and unverified runtime behavior.
