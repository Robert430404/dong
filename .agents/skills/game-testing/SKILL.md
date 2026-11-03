---
name: game-testing
description: Use when planning or performing real LÖVE runtime checks, interactive playtests, input diagnostics, or game verification in Dong.
---

# LÖVE game testing

Inspect the current branch, `README.md`, `conf.lua`, and affected gameplay code before testing. Use `unit-testing` for headless regression checks; a mocked LÖVE environment is not an interactive playtest.

1. Identify the relevant LÖVE version, available executable, display, and launch command. Run `love .` from the repository root if installed, or use an existing suitable Flatpak with `flatpak run org.love2d.love2d .`. Do not assume a particular installation or install system packages without appropriate authorization.
2. Agree on or state a focused test plan for the change. Exercise title and mode selection, serve and scoring, W/S and arrow controls, opponent behavior, and resize/fullscreen where relevant. Check collisions, speed, responsiveness, and perceptible frame pacing in actual play; compare different frame rates only when you can control or observe them.
3. Verify held and brief presses separately where relevant. Consider focus and platform input methods: text-entry features can intercept gameplay keys. Test text input and any diagnostic in the real runtime, without assuming a particular desktop or input method is the cause.
4. If interactive input or observation is unavailable, ask the user to play and report observations; do not claim a visual check or subjective gameplay result based only on launching a process. Use temporary diagnostics outside the repository when useful, respect sandbox filesystem boundaries, and avoid overwriting user files.
5. Run the relevant headless checks too. Report the runtime and commands used, the scenarios actually exercised, observed results, warnings, and unverified cases. Do not conflate an audio warning, application exit, or passing mock with a confirmed gameplay defect or successful playtest.
