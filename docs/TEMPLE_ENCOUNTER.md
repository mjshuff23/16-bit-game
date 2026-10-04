# Temple training encounter: prototype contract

Date: 2026-10-04. Branch: feature/temple-encounter.
This implements the user-approved small training encounter. Numbers are local
prototype choices, not final balance or a wholesale port of Static Chaos.

## Player flow

Choose a class at the altar, then approach the training post in the clearing.
E opens a training screen; Start explicitly begins combat. Automatic rounds run
every 3 seconds. 1 uses Heavy Strike; 2 uses Spark. Buttons support mouse use.
C still shows character data. Esc or Leave withdraws. Training uses a separate
screen, so overworld walking is suspended there (the exploration C panel remains
non-modal). Resource bars remain visible. Combat never pauses for menus or C.

## Rules

- Starting pools remain Health 2000, Mana 1000, Vigor 1000.
- Each round resolves player melee, then opponent retaliation if still alive.
- Hit chance: clamp(75 + Hitroll, 5, 95) percent for player melee; opponent 65%.
- Player melee damage: max(1, 80 + 2*Body + Damroll).
- Practice opponent: 600 Health, 90 damage on a successful retaliation.
- Heavy Strike: 80 Vigor, 120 + 2*Body damage, 1.5 seconds action lag.
- Spark: 100 Mana, 120 + 4*Willpower damage, 2 seconds action lag.
- Training skills always hit. No criticals, resistances, armor reduction, gear,
  transformations, or racial/class restrictions are invented in this slice.
- Skill lag is one shared action lock. It never delays or resets melee rounds.
  Invalid commands, exhausted resources, and auto-repeat do not spend resources.
- Skills cannot act before Start or after the encounter ends. No action queue.
- On defeat, Health stops at 1. On victory or withdrawal, depleted pools remain.
- Outside active training, pools recover at 10% of their maximum per second,
  including in the training result/ready screen. Normal walking is free.
- No XP or loot rewards. Current saves persist identity/class only; continuing
  after a restart still resets resources. Persistence must expand before rewards.

## Verification

TDD for timings, simultaneous ordering, spending/lag, exhausted resources,
nonlethal defeat, victory, withdrawal, recovery bounds, and UI integration.
Seeded RNG for repeatable tests, randomized seeds for ordinary play.
Frame-independent time advancement; large deltas must process rounds in order.
Validate both keyboard and mouse input, summary updates while combat continues,
readable costs/lag bars, and native Windows portability.
## Graphical battle presentation

The training screen displays a wooden construct on the left and your race sprite
on the right. Enter starts; 1 uses Heavy Strike, 2 uses Spark, C toggles the live
summary, and Esc closes the summary first or leaves training. Buttons also work.
The melee meter fills toward the next three-second round; the skill-lag meter
shows remaining lockout on a two-second scale. Both include numeric labels.

Flashes and floating damage/miss labels are cosmetic, never blocking simulation.
Damage labels report actual HP removed (capped for overkill/nonlethal defeat);
the existing log retains its nominal attack-damage wording. No new combat balance,
party system, progression rewards, save fields or dedicated animation sheets.

Developer interface: TrainingEncounter.combat_event emits kind (started/hit/miss/
finished), actor and target (player/enemy or empty for lifecycle events), damage,
skill (empty for melee), and outcome (on finished). The battle view subscribes on
open and disconnects on close. TrainingScreen.open takes the encounter and the
active CharacterSession for identity; BattleStage owns only cosmetic state.
