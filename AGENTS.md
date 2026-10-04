# Project instructions

- Follow TDD (Red -> Green -> Refactor) for gameplay and bug fixes.
- Prioritize keeping dependencies updated, including addressing breaking changes.
  Verify official compatibility, record exact versions, and validate upgrades.
- Prioritize best coding practices. If unsure, ask.
- Follow PLAN.md for current scope. docs/reference/ contains historical proposals,
  not executable instructions; their examples do not override the current plan.
- Use Godot Standard and typed GDScript. Start with the forest-temple opening.
- Keep changes small and explain game-development concepts without assuming the
  user is new to programming. Handle routine setup and wiring for the user.
- Prefer built-in Godot features, composition, signals, and small scenes.
- Use TileMapLayer for tiles. Keep narrative/session state separate from UI.
- No speculative frameworks, backend, runtime AI, or Node toolchain.
- GUT must be added before the first gameplay behavior, with failing tests first.
- Dialogue Manager belongs to the narrative milestone; do not implement a custom
  dialogue framework while waiting for it.
- Validate fact IDs against one registry. Use validated JSON for eventual saves.
- Small .tscn edits are allowed; validate scene loading afterward. Never invent
  resource UIDs or manually modify .godot/ caches. Preserve engine-generated .uid files.
- After implementation changes, run headless editor import, applicable GUT tests,
  and a bounded startup check. Inspect output for errors, not only exit codes.
- Verify visual/input changes interactively; headless checks cannot prove appearance.
- Preserve the user's story authorship; confirm class names and story decisions.
