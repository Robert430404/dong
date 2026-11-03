# Dong

Pong with a twist, made with [LÖVE 11.5](https://love2d.org/).

Run from the repository directory with `love .`.

- On the title screen, use Left/Right to choose one or two players, then Enter to start.
- In one-player mode, use Up/Down on the title screen to choose Easy, Normal, or Hard. Normal is the default; Hard matches the original opponent tuning.
- Press Space to serve. The left paddle uses W/S; in two-player mode the right paddle uses Up/Down.
- F11 toggles fullscreen; Escape quits.

The game simulates at a fixed 60 steps per second independently of rendering. In one-player mode, the opponent predicts the ball's arrival with a limited reaction rate, speed, and accuracy; these settings are in `opponent.lua`. Its aiming error stays consistent during each approach and is chosen again on the next one.

The 16:9 playfield scales uniformly to fit the window, with bars when needed. Resizing or toggling fullscreen does not change the simulation's positions or speeds.

Run the headless regression checks with `luajit tests/run.lua` (or `lua tests/run.lua`).
Run a single suite with `luajit tests/run.lua collisions`, or select a scenario by name, for example `luajit tests/run.lua collisions 'ceiling reflects the ball once'`.
