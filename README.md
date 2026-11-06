# Dong

Pong with a twist, made with [LÖVE 11.5](https://love2d.org/).

Run from the repository directory with `love .`.

- On the title screen, use Left/Right to choose one or two players, then Enter to start.
- In one-player mode, use Up/Down on the title screen to choose Easy, Normal, or Hard. Normal is the default; Hard matches the original opponent tuning.
- Easy and Normal also limit the maximum ball speed to 65% and 85% of Hard's maximum respectively. Two-player mode retains the full maximum speed.
- Press Space to serve. The left paddle uses W/S; in two-player mode the right paddle uses Up/Down.
- F11 toggles fullscreen; Escape quits.

During a rally, power-ups appear one at a time in random order, at most once each per rally. The first appears after a random delay; the next delay starts when the current power-up is collected. Blue splits the ball, purple resets its speed, and orange rotates its trajectory by 13.5° in a random direction and boosts its speed by 30% until the next paddle hit. Each missed ball awards a point; the rally continues until all balls are gone.

Power-up definitions live in `powerups/` and are registered in `powerups/registry.lua`. Each definition creates and draws its item and applies its effect; the manager handles active items and ball collisions.

The game simulates at a fixed 60 steps per second independently of rendering. In one-player mode, the opponent predicts the ball's arrival with a limited reaction rate, speed, and accuracy; these settings are in `opponent.lua`. Its aiming error stays consistent during each approach and is chosen again on the next one.

The 16:9 playfield scales uniformly to fit the window, with bars when needed. Resizing or toggling fullscreen does not change the simulation's positions or speeds.

Run the headless regression checks with `luajit tests/run.lua` (or `lua tests/run.lua`).
Run a single suite with `luajit tests/run.lua collisions`, or select a scenario by name, for example `luajit tests/run.lua collisions 'ceiling reflects the ball once'`.
