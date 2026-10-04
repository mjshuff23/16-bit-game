# 16-bit-game: current plan

Updated 2026-10-04 for Vigor and the temple training encounter.
Running gaps/routes: [DEVELOPMENT_ROADMAP.md](docs/DEVELOPMENT_ROADMAP.md).
This supersedes earlier implementation plans and the archived original proposal.
Detailed source evidence and proposed taxonomy: [MUD_REFERENCE.md](docs/MUD_REFERENCE.md).

## Intent

A 16-bit-inspired top-down RPG for the user's original esoteric/gnostic multiverse
story. Anime-inspired ancestries and disciplines are part of the intended game.
Separate what a character is from what they learn. The user controls mythology,
rosters, and final story text. Develop one playable, explainable step at a time.

## Current opening

- Start at a local character screen: create a named Saiyan, Patryn, Mazoku, Fist, or Witch/Warlock,
  or continue an existing character. New characters enter the forest unclassed.
  Identity and class persist in versioned JSON; returning characters retain class.
  Escape from exploration returns to the character list, not character deletion.
- First quest: walk to the altar and choose a path. E/Enter opens the picker only
  within range. Confirmation commits the class and completes the quest without
  moving the character. Cancel returns to exploration without losing state.
- Race and class are independent. The five anime/MUD choices are races, not
  additions to the class roster. Keep the original twelve familiar classes at
  the altar. Witch/Warlock the race is distinct from Warlock the class.
  Example combinations: Fist Monk, Witch/Warlock Wizard, Saiyan Fighter.
  Attributes can favor similar classes without restricting the available choices.
- Reclassing and subclassing come later. Esc must not silently erase the character
  or bypass the temple quest. Profiles save identity and class, not world progress.
- One map, four-direction movement, collision, and a fixed camera. Placeholder
  art and neutral altar text. The class quest leads to an optional training post. Racial powers remain future work.

## Character systems

Confirmed shared attributes: Body, Mind, Spirit, Willpower; each begins at 10.
Shared source defaults: HP 2000/2000, Mana 1000/1000, Vigor 1000/1000, Primal 0.
Vigor replaces the MUD Move pool. Health, Mana, and Vigor now power the training
encounter; walking remains free and resources recover outside active combat. The opening summary shows shared stats. Mind is labeled Intellect in UI; it is
not a fifth attribute. Base attributes remain 10 independently of racial caps until XP training is added.

Confirmed classification (corrected after user clarification):
- Race/ancestry: Saiyan, Patryn, Mazoku, Fist, Witch/Warlock. Each has innate
  attributes and future racial powers, separate from learned class features.
- Class: the original twelve D&D-inspired archetypes. Fist is not a class;
  Witch/Warlock is not a replacement name for the existing Warlock class.
- Subclass: later specialization within a class.
- Profession: later occupation/crafting role, independent of race and class.

All four attributes begin at 10. The player will spend XP to train them up to
racial caps. Earning XP, training costs, and the training UI belong to a future
progression milestone; this correction implements race selection and cap data.
Do not substitute Primal for the user's chosen XP training currency.

| Race | Body | Intellect | Willpower | Spirit |
| --- | --- | --- | --- | --- |
| Saiyan | 100 | 75 | 80 | 90 |
| Patryn | 80 | 100 | 85 | 75 |
| Mazoku | 95 | 95 | 95 | 95 |
| Fist | 90 | 75 | 80 | 100 |
| Witch/Warlock | 75 | 90 | 100 | 80 |

These use the MUD's corresponding archetype caps, including Sorcerer for the
Witch/Warlock race. Mazoku's equal 95s are an explicit user choice. Caps are
independent of class; no class-cap stacking or implicit starting stat bonuses.

Keep racial resources separate from shared stats and learned class resources.
Saiyan Power/Strength/Speed/Aegis must not replace Body/Mind/Spirit/Willpower.
Fist Ki, Witch/Warlock Mystic energy, Mazoku resources, and rune progression need
separate names and ownership. Do not port the MUD's overlapping powers[10] array.
Do not carry over legacy Human-only restrictions or add class cap bonuses. Names are inspired by the reference; no entire ruleset is assumed.

## Combat direction

Confirmed default: automatically timed melee rounds that skill use cannot interrupt
or reset. Melee uses Hitroll/Damroll, with equipment modifiers later. Skills have
individual Vigor, Mana, and Power/Chi requirements and per-skill action lag.
Keep automatic melee scheduling separate from the player's skill availability.
Lag means a temporary action lock, not a synonym for a per-skill cooldown.
Prototype rules are defined in [TEMPLE_ENCOUNTER.md](docs/TEMPLE_ENCOUNTER.md).
A three-second round, Hitroll-based accuracy, Damroll-based melee, and two universal
practice skills are implemented. These do not establish the final racial/class kits.

Optional turn-based mode is explicitly deferred. Keep battle resolution separate
from advancement policy so it can later wait for decisions without duplicating
combat rules. The source uses 3-second melee rounds and 4 engine pulses/second;
WAIT_STATE values are pulses (4 = 1 second). World ticks are a different clock.
The training encounter is implemented with nonlethal defeat and no rewards.
Equipment effects and usable racial/class powers remain unimplemented.

## Stack and portability

- Godot Standard 4.7.2, typed GDScript, GUT 9.7.1 installed.
- Dialogue Manager 4.1.0 planned for the narrative milestone, not yet installed.
- Recheck stable releases at dependency changes, address breaking changes, and
  record and test exact versions. Prefer current stable, compatible releases.
- WSL is the active checkout. Native Windows exports and source snapshots on C:\
  provide a fallback. Refresh both at playable milestones; do not develop in two
  copies simultaneously. Follow docs/PORTABILITY.md.
- No backend, database, runtime AI, Node toolchain, or MUD server dependency.
  Reference C/TypeScript remains reference material. Offline asset generation is
  optional later. VS Code/art tools are optional, not prerequisites.

## Art and scenes

640 x 360 base viewport, default 1280 x 720 window. The 16 x 16 tile world is
framed by a Camera2D at 2x zoom to preserve its existing movement/collision
coordinates. Menus and the independent HUD render directly at 640 x 360 with
larger fonts. Placeholder art retains its existing detail; four directions.
Nearest filtering, viewport stretch, preserved aspect ratio, integer scaling.
Partial edge tiles are acceptable. Check movement and text visually; scaling alone
cannot guarantee jitter-free cameras or readable UI. Use TileMapLayer for scenery.

Keep scenes small, compose behavior, and separate UI from state. Small validated
.tscn edits are allowed. Use editor tooling for complex authored resources and code
for appropriate runtime construction. Never invent UIDs or edit .godot/ caches.
Keep engine-generated .uid files; use exact path casing and consistent line endings.

Agree on palette, proportions, lighting, and a small number of forms before final
asset production. Editable art belongs in art/source/; runtime art in assets/.
Do not create empty frameworks or speculative manager systems.

## Narrative and knowledge

The future loop remains: meet a priest/keeper, hear a claim, find evidence, return
with a new question. The same sprite can acquire new meaning through knowledge.
Keep observation, testimony, and world truth distinct; learning a claim is not
proof that it is true. Final lore and NPC claims come from the user.

KnowledgeState will be a deterministic Resource with one instance per game;
PlayerKnowledge will be a thin autoload wrapper adding signals. Use a registry
of stable fact IDs. Dialogue reads/writes must use a documented literal-ID form;
validate every .dialogue reference and compile it with the addon. Reject typos
and unsupported dynamic references explicitly. Dialogue does not own game state.

## Saves and verification

Local profiles now use version-1 JSON with validated names, IDs, races, and
classes. Validate the whole file before replacing loaded data; reject corrupt or
unsupported files without overwriting them. Write a temporary file then rename,
and commit class choice only after saving succeeds. Saves currently include only
identity and class; entering the world starts at the forest spawn with default stats.
Add world position, attribute progression, combat pools, and narrative state with
explicit schema migrations when those systems arrive. Do not load external saves as Resources or instantiate save-supplied
scripts/paths. Reclassing must preserve ancestry, shared progression, and knowledge
according to an explicit future policy.

Follow Red -> Green -> Refactor for behavior. Run tools/check.sh (WSL) or
 tools/check.ps1 (Windows): headless import, GUT, bounded startup, error-log checks.
Verify visible changes with rendered inspection and real input paths. Keep tests
for unclassed spawn, altar range, modal movement lock, cancel, confirmation, shared
stat preservation, and quest completion. Add combat and race tests as those systems
are introduced. Keep combat timing/resource tests deterministic and verify the rendered training screen.

## Character summary hotkey

C toggles a non-modal character side panel while exploring. WASD and arrows
continue moving; Esc closes the panel without leaving the world. Name entry and
class selection retain their own keyboard behavior. The panel reads current
session values, including racial caps and the first quest; it adds no progression
or save-format changes. Interaction closes it before opening another game UI.


## Next selected milestone

After the temple encounter PR: race-specific sprites. The user supplied Mazoku,
Saiyan, and Patryn images plus Fist-brawler and caped-mage directions. See
[the visual brief](docs/reference/race-sprites/README.md). Do not change stats or
race/class taxonomy as part of that visual work.
