# Class Selection Implementation Plan

**Goal:** Choose and confirm one of twelve familiar RPG classes, with race as a
separate future choice. This implements the class-selection portion of PLAN.md.

**Architecture:** A small immutable-by-convention class catalog supplies IDs,
names, and original descriptions. A session object validates pending and confirmed
choices. A Control scene presents the choices and owns the current session until
world integration needs to share it. No stats, abilities, race rules, or autoload.

**Stack:** Godot 4.7.2 Standard, typed GDScript, GUT 9.7.1.

## Tasks

- [x] Install GUT and write failing tests in tests/unit/test_character_session.gd
  and tests/integration/test_class_picker.gd.
- [x] Implement game/character/class_catalog.gd and character_session.gd.
  preview_class(StringName) -> bool rejects unknown IDs or a committed session;
  confirm_class() -> bool requires a preview; reset() clears both IDs.
- [x] Add game/ui/class_picker.gd and replace the starter main.tscn contents with
  a compact picker, descriptions, confirmation, and an explicit reset action.
- [x] Verify with headless import, GUT, startup, and rendered layout inspection.
- [x] Update PLAN.md and README.md with class scope, race separation, and checks.

## Review focus

Tests cover no default selection, confirmation without selection, invalid IDs
preserving state, preview changes before confirmation, locked confirmed state,
reset, independent sessions, all twelve options being reachable, and the UI's
confirm/reset flow. Check keyboard focus and description fit at 320 x 180.
