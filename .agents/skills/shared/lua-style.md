# Lua style and repository reference

This reference describes tendencies observed in Dong's `main` branch, not a requirement to reproduce every historical choice. Inspect the current branch and nearest related code before editing. Correctness, clear ownership, and maintainability take precedence over imitating a defect.

## Lua conventions

- Existing files generally use tabs for indentation and camelCase for variables, fields, and functions. Names such as `computedX` and `handleBallAngle` describe the operation or value.
- Modules such as `opponent.lua` and `screens/renderer.lua` commonly declare a local table, define methods with `function module:method(...)`, and `return` the table. Dependencies generally use `local name = require 'module.path'`.
- State is often grouped into tables; methods use `self` to access module state. Use locals for temporary values and make ownership explicit. Avoid accidental globals, including assignments that omit `local` and fields accessed without `self`.
- Prefer straightforward control flow, descriptive intermediate values, early returns where useful, and small helpers when they clarify a responsibility. Preserve meaningful blank lines between logical sections.
- Single and double quotes, spaces in function calls, and some naming details vary. Follow the surrounding code; do not impose a new repository-wide formatting convention or make unrelated cosmetic edits.
- Target the Lua/LuaJIT environment supported by the project's configured LÖVE version. Do not assume features from newer Lua versions are available without checking the runtime. Confirm APIs against the installed LÖVE version when in doubt.

## Game structure

- `main.lua` owns LÖVE lifecycle callbacks, `screens/renderer.lua` dispatches screen operations, and the `screens/` modules own screen presentation and input routing. `match.lua` owns match state and rules; `ballPhysics.lua` handles ball movement and collisions. `opponent.lua` owns opponent behavior; `config/` holds system and keybind configuration. Reinspect the current branch because responsibilities can change.
- `match.balls` is the authoritative collection of ball and velocity entries. The primary `match.ball` and `match.ballVelocity` compatibility accessors derive from its first entry; do not maintain separate copies or assign to those accessors.
- Inspect how state, input, simulation, and drawing interact before changing a boundary. Do not assume that a function is pure because of its name or that an existing collision, timing, resize, or random-number pattern is correct.
- Keep new code in the closest appropriate module; avoid introducing a framework or broad refactor for a small change. Make changes to behavior explicit and cover them with relevant tests.

Examples on `main` are evidence of style, not correctness. In particular, implicit globals and reseeding randomness on each decision are not conventions to copy. When current code differs from this reference, evaluate its intent and match the nearest sound pattern rather than forcing old code or new code to match mechanically.
