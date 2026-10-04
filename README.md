# 16-bit Game

A small Godot RPG for an original esoteric/gnostic story, starting at a forest temple.
See [PLAN.md](PLAN.md) for scope and milestones.

## Current state

Create a named character and choose Saiyan, Patryn, Mazoku, Fist, or Witch/Warlock, or select a saved
character to continue. The screen shows race caps; all four attributes start at 10.
New characters spawn unclassed in the forest. Your first quest is to reach the
altar and choose one of the original twelve classes. The five races are separate
from class: for example, Fist Monk or Witch/Warlock Wizard. Warlock the class
remains separate from Witch/Warlock the race. All races can choose any class.

- WASD or arrow keys: four-direction movement, including while the summary is open.
- C: toggle character summary; Esc closes it before returning to the character list.
  Shows name, race, class, base attributes/caps, Health/Mana/Vigor, Hitroll/Damroll,
  Armor, Primal, location, and first-quest status. This panel does not pause movement.
- E or Enter near the altar: choose a class, or inspect after choosing.
- E, Enter, or Esc: close inspection text.
- Esc in the class picker: cancel without losing your character.
- Esc while exploring: return to the character list.
- Mouse or Tab/arrows and Enter/Space: use character/class screens.

Profiles save identity and class automatically, so restarting the game preserves
those choices. Continuing starts at the forest spawn with default stats; world
position/progression is not saved yet. Reclassing is not implemented.

Shared stats: Body, Intellect (MUD Mind), Willpower, Spirit, all initially 10.
HP 2000, Mana 1000, Vigor 1000. Race caps are independent of class; Mazoku retains
95 in all four attributes by user choice. XP will train
attributes from 10 up to racial caps. Training costs and earning/spending XP,
equipment, racial powers, full class kits, subclasses and professions come later.
A repeatable temple training encounter now exercises timed melee and two practice skills.
See [MUD_REFERENCE.md](docs/MUD_REFERENCE.md) for the source analysis and
confirmed automatic-melee/skill-lag combat direction.

Profiles live in `user://characters.json`:
- WSL: `~/.local/share/godot/app_userdata/16-bit Game/characters.json`
- Windows: `%APPDATA%/Godot/app_userdata/16-bit Game/characters.json`

These are separate per-OS locations. Close the game before copying this JSON
between them. Back up the destination first; copying replaces the profile list,
not merges it. Source/build ZIPs do not include personal character files.

640 x 360 viewport, default 1280 x 720 window, nearest texture filtering, integer
scaling, Compatibility renderer. Menus and HUD render at the higher resolution;
the existing pixel-art world is framed with a 2x camera zoom without changing collision or
movement coordinates. Art detail itself is unchanged.

Engine: Godot 4.7.2 Standard, installed in WSL at `~/.local/bin/godot`.
GUT 9.7.1 is vendored in addons/gut. Dialogue Manager 4.1.0 is planned for the
narrative milestone and is not installed yet.

## Open from Ubuntu / WSL

```bash
cd ~/projects/games/16-bit-builder
~/.local/bin/godot --editor --path .
```

Press F6 to run the current scene, or F5 to run the project.

## Setup checks

```bash
bash tools/check.sh
```

Runs editor import, the GUT unit/integration suite, and a bounded startup check.
Checks fail on engine errors as well as nonzero exit codes. Set GODOT_BIN to use
another engine executable. Visual checks are still required for UI changes.

## Next

Windows export and recovery instructions: [PORTABILITY.md](docs/PORTABILITY.md).
A Windows build runs independently of WSL; source backups can open in the native
Windows editor. Run `bash tools/export_windows.sh` to regenerate the build.

## Temple training

After choosing a class, walk to the target post just east of the temple steps and
press E. Start with Enter or the Start button. Automatic melee resolves every
three seconds; Hitroll affects accuracy and Damroll adds damage.

- **1: Heavy Strike** spends 80 Vigor and imposes 1.5 seconds of action lag.
- **2: Spark** spends 100 Mana and imposes 2 seconds of action lag.
- Skill lag blocks further skills, never automatic melee. Buttons show availability.
- **C:** live character summary; combat continues. **Esc:** close summary, then leave.
- Victory, defeat, and withdrawal end training. Defeat is nonlethal (minimum 1 HP).
- Health/Mana/Vigor recover at 10% of maximum per second outside active training.
- Ordinary exploration does not spend Vigor. Training grants no XP or loot yet.

These are practice actions for all race/class combinations, not final class kits.
The first implementation uses a dedicated training screen, with the overworld
stationary until you leave. Existing profile saves are unchanged; spent pools
still reset when a character is reloaded. No new persistent progression is implied.

Rules and provisional balance: [TEMPLE_ENCOUNTER.md](docs/TEMPLE_ENCOUNTER.md).
Running gaps and possible routes: [DEVELOPMENT_ROADMAP.md](docs/DEVELOPMENT_ROADMAP.md).
Next selected milestone: [race-specific sprites](docs/reference/race-sprites/README.md),
after this encounter PR. Optional turn-based combat and the priest/evidence
knowledge loop remain planned.
