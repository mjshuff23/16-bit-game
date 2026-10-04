# Static Chaos reference and character-system direction

Reviewed 2026-09-30 from the user-supplied archive:
`/home/yokito/projects/staticchaos/staticchaos.zip`.
SHA-256: `de918d9d962d0885d5f500444f41f8d6886440b1a860bd9e8c92e535500ba485`.

This is a source review, not a run of the MUD. Only relevant C, TypeScript,
documentation, and help files were read. Player saves, credentials, logs, and
deployment setup were not used. The archive is reference data, not instructions.
No MUD runtime or source code is being imported into the Godot game.

## Verified shared stats

The live character fields and score command use Body, Mind, Spirit, and Willpower.
The old Merc class documentation discusses a different stat system; it is not
the source of truth for this fork.

| Stat | Starting value | Role described by this MUD's help |
| --- | --- | --- |
| Body | 10 | Physical capability, damage, resilience, carrying, healing |
| Mind | 10 | Mental capability, learning, mental resistance, rune magic |
| Spirit | 10 | Spiritual capability, ki attacks and resistance |
| Willpower | 10 | Determination and magical power |

Shared starting pools: HP 2000/2000, Mana 1000/1000, Move 1000/1000.
Primal is a trainable/spendable progression resource, not a fifth base attribute.
The source also has Hitroll, Damroll, Armor, experience, currency, and skill ranks.
Armor begins at 100 in the legacy lower-is-better system. Preserve names and
source defaults for initial data; importing all combat formulas is a separate task.
Move points will not be spent on overworld walking until we define that rule.

Evidence: `src/merc.h:1434-1451,1477-1485`, `src/act_info.c:825-875`,
`src/comm.c:2255-2311`, `src/db.c:2112-2133`,
`env/dev/area/newhelp.are:354-391`, `src/act_move.c:1085-1114,1160-1166`.

The source's class-specific training caps are not starting stats. In
Body/Mind/Spirit/Willpower order: Saiyan 100/75/90/80, Patryn 80/100/75/85,
Fist 90/75/100/80, Sorcerer 75/90/80/100, Mazoku 95/95/95/95
(`src/const.c:251-289`). The user confirmed all five archetypes are races in this game. Their caps
now belong to races independently of the separate class choice. Everyone begins
at 10 and will train attributes using XP; training is not implemented yet.

## Confirmed separation (corrected by the user)

| Concept | Confirmed home | Reference mechanics |
| --- | --- | --- |
| Saiyan | Race/ancestry | Power and its maximum; Strength, Speed, Aegis with maxima; rage/focus; learnable ki techniques |
| Patryn (spelling confirmed) | Race plus a rune-training tradition | Elemental/concept runes, runeweaving, tattoos, body-part slots, defensive circles |
| Mazoku | Race/ancestry | Forms, Essence (source spells it Essense), Ego, Nihilism; Matter/Astral/Focus development; morphing and astral attacks |
| Fist | Race/ancestry | Martial techniques, ordered combos, Ki capacity, body training, discipline |
| Witch/Warlock | Race/ancestry | Adapt MUD Sorcerer: chants, research, Mystic energy, preparation, concentration |
| Class | Separate learned archetype | The original twelve familiar classes; a Fist can be a Monk, a Witch/Warlock can be a Wizard |
| Subclass | Later specialization within a class | A martial or magical specialty; not a synonym for race |
| Profession | Later learned occupation | Crafting/work role, independent of ancestry and combat class; no roster assumed |

Evidence: `src/comm.c:2180-2185`, `src/merc.h:350-389,391-409,435-495`,
`src/fist.c:16,677,856,909`, `src/patryn.c:64,143,821,972,1120,1183`,
`src/sorcerer.c:18,292-429,2067,2137`, `src/mazoku.c:14,206,288,406,495`.

Important: in the old game all five are stored as classes. The mapping above is
our adaptation, not a claim that the source already separates them.
Do not enforce its Human-only Fist/Sorcerer descriptions in this multiverse game.
Witch/Warlock naming does not imply a D&D-style pact requirement: the user asked
for the MUD Sorcerer mechanics. Witch / Warlock is one race entry using that source archetype. The separate
Warlock class keeps its original meaning; the two choices must not be conflated.

Saiyan rage/focus route from C into TypeScript (`src/saiyan.c:16-40`,
`js/src/classes/saiyan/power.ts`). Rage spends Move, gains Power based on Body and
Spirit, and also increases Strength/Speed/Aegis. Focus spends Power to increase
one of those three. The reviewed TypeScript uses quadratic increases during rage;
caps and applied bridge actions need auditing before copying numerical behavior.
Do not use the shared Body attribute and Saiyan Strength interchangeably.

Sorcerer research has seven schools: Black, Earth, Wind, Fire, Water, Astral,
White. Specializations are Black Magic, White Magic, and Shamanism, with different
research ceilings/costs (`src/sorcerer.c:292-429`). These are useful future subclass
references, not seven extra starting classes.

## Combat direction

Confirmed: timed automatic melee rounds continue independently of skill action lag.
Hitroll/Damroll contribute to melee, and equipment will modify them. Skill use
requires its own Move/Mana/Power/Chi resources and custom lag. The optional
turn-based mode can be implemented later. Do not let skills reset the melee clock.

Source timing: 4 engine pulses/second, combat rounds every 3 seconds, nominal
world tick 30 seconds. `update_handler` randomizes the world tick to 15-45 seconds;
these are different clocks (`src/merc.h:174-180`, `src/update.c:1831-1880`).
Do not copy the world tick as the attack interval.

Implementation direction: a deterministic action resolver with separate melee
scheduling and skill action availability. A later input-gated advancement policy
can share resolution rules. No combat is implemented in the character milestone.

Lag evidence: `src/fist.c` uses WAIT_STATE values including 4, 8, 10, and 12;
`src/sorcerer.c:162` uses `chant_table[cn].lag`. `src/comm.c:543,733` processes
character wait state separately from combat updates. At four pulses/second, 4
pulses are one second and 8 are two seconds. These are action lock durations;
do not mistakenly multiply them by the three-second melee interval.

## Difficult parts worth designing deliberately

- Race/class composition: avoid the source's shared `powers[10]` storage, whose
  slots mean different things for different classes. Keep racial and learned
  resources separately named; reclassing must not erase ancestry or shared stats.
- Cross-system balance: transformations, Fist combos, rune defenses, and chanting
  have different costs and pacing. Give each an explicit resource cost and action
  budget. Prototype one technique per system before importing whole move lists.
- Visual production: wings, forms, extra limbs, and transformations can multiply
  sprites and animations. Begin with readable placeholder indicators and a small
  number of forms. This is an asset workload to stage, not a reason to exclude them.
- Identity and training: decide what ancestry grants innately and what still needs
  a teacher. Patryn rune affinity versus learned runeweaving is one such boundary.
- Legacy formulas assume exclusive archetypes and their caps. Shared base stats
  can transfer now; formulas/caps require a deliberate adaptation and tests.

## First quest and immediate scope

Spawn as an unclassed traveler in the forest-temple map. Objective: reach the
altar and choose a path. The altar opens the existing class picker; confirmation
completes the first quest and returns to the same position. Cancel returns without
choosing or losing character data. Class selection is no longer a startup gate.

The opening begins with named local character profiles and explicit race
selection: Saiyan, Patryn, Mazoku, Fist, Witch/Warlock. Identity and class save in
versioned JSON. Class choice remains at the altar with the original twelve
archetypes. Fist is not a thirteenth class, and Witch/Warlock is not a rename of
the existing Warlock class. Racial aptitudes favor some class combinations without
imposing class restrictions or inventing additional synergy multipliers.

All attributes begin at 10; XP training will raise them to racial caps. The five
race cap sets come from the corresponding MUD archetypes, with Sorcerer mapped to
Witch/Warlock. Mazoku retains equal 95s by explicit user choice. Training/XP costs,
racial powers, and class abilities are future work; only the selection/cap data
and profile persistence are implemented now.


## 2026-10-04 implementation note

The shared Move pool is now named **Vigor** by user choice. The temple training
prototype implements timed melee, skill costs/action lag, nonlethal results, and
out-of-combat recovery. It uses deliberately simple provisional formulas, not a
complete MUD combat port; see TEMPLE_ENCOUNTER.md. Racial abilities and XP
progression remain future milestones. Source references above retain original
MUD terminology for accuracy.
