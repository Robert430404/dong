---
name: love-gameplay
description: Use when changing Dong's LÖVE lifecycle, game loop, physics, opponent, input, screens, rendering, or window behavior.
---

# LÖVE gameplay

Read [the Lua style reference](../shared/lua-style.md), then trace the affected state through the current lifecycle callbacks, screen dispatch, gameplay, and tests. Use `lua-writing` for implementation style, `unit-testing` for deterministic checks, and `game-testing` for runtime verification.

1. Establish intended player-visible behavior and inspect the current branch before changing the simulation. Distinguish elapsed time, simulation steps, and rendering; state the units of velocities and timing. Do not assume the current branch uses the same timing model as `main`.
2. For collisions and scoring, check direction, boundaries, high-speed crossings, simultaneous contacts, repeated impacts, and one score per miss. Keep collision detection and state changes understandable; avoid introducing extra resolution calls from observers such as the opponent.
3. For opponent behavior, make decisions based on game state without accidentally changing ball physics or scores. Consider reaction rate, bounded paddle movement, prediction error, random seeding, and reset behavior. Make stochastic behavior controllable in tests and tune difficulty through observable play.
4. For input and screens, check held versus one-shot keys, both player modes, focus, resize/fullscreen, and state transitions. Distinguish keyboard controls from text entry; if text entry is introduced, manage LÖVE text input appropriately. Consider platform input methods without assuming every environment behaves the same way.
5. Keep rendering, simulation, and window changes as independent as the existing architecture reasonably permits. Avoid resetting a rally during resize unless intended. Preserve gameplay state and documented controls unless a behavior change is requested.
6. Add focused tests for relevant timing, collision, input, or opponent boundaries. Run available headless checks and a real LÖVE playtest when feasible; report commands, results, assumptions, and any user-facing behavior not verified.
