# Development gaps and expansion routes

Living document. Updated 2026-10-04. Update statuses, evidence, and next decisions
at each milestone. PLAN.md describes the game direction; this file tracks what
is missing and which routes we could take next.

## Current branch: feature/temple-encounter

Before this work: named profiles, five races/twelve classes, temple class quest,
640x360 presentation, non-modal C summary, WASD/arrows, Windows exports.
The previous verified suite had 39 passing tests on WSL and Windows.

### Complete: temple training encounter

- Rename shared Move pool to Vigor, including code, UI, tests, and current docs.
- Resource bars for Health, Mana, Vigor; ordinary walking consumes no Vigor.
- A repeatable practice opponent near the temple, available after class selection.
- Automatic melee every 3 seconds, independent of skill action lag.
- Two provisional training actions available to every race/class: a physical
  strike spending Vigor and a magical spark spending Mana. They test the combat
  foundation; they do not define racial powers or the final class skill lists.
- Skills have explicit costs and action lag; reject insufficient resources and
  commands during lag without spending resources. No action queue yet.
- Nonlethal defeat, victory, and withdrawal. No XP rewards or permanent penalties
  in this exercise. Recovery outside training, no regeneration during a round.
- Optional turn-based mode remains deferred.

Prototype balance values and controls will be recorded in docs/TEMPLE_ENCOUNTER.md.
They are adjustable test values, not a claim to have reproduced the MUD formulas.

## Gaps and next decisions

| Area | State before encounter | Next decision or work |
| --- | --- | --- |
| Combat | Temple training implemented | Playtest/tune; next add encounter variety and progression once persistence is ready |
| Progression | Attributes start at 10; race caps exist | XP earning, training costs, cap enforcement, trainer UI; XP is the agreed training currency |
| Saves | Identity/race/class only | Versioned migration for trained stats, XP, inventory, position, narrative progress; prevent replay/save exploits once rewards exist |
| Stats | Health/Mana/Vigor pools, recovery, and provisional training damage | Decide derived maximum pools, attack accuracy/damage, armor, resistances; prototype formulas are temporary |
| Equipment | None | One weapon and one armor item before a full inventory; define stacking order for modifiers |
| Race powers | Names and cap data only | One signature ability per race; separate racial resource/state ownership |
| Classes | Choice and flavor only | Design small distinct skill kits; decide interactions with racial abilities |
| Reclass/subclass/profession | Deferred | Preserve ancestry/progression; define requirements and reset/refund policies |
| Narrative | Only class quest and neutral altar text | Priest/claim/evidence/return loop, fact registry, Dialogue Manager integration; final lore authored by user |
| Art/audio | Procedural placeholders; no sound | Choose palette and sprite proportions; one authored tileset and character; combat cues before larger asset sets |
| UX/accessibility | Keyboard movement/interaction/summary | Clear costs/lag feedback, rebinding, controller support, volume, readable color-independent indicators |
| Portability | Native Windows/source snapshots | Keep newest build easy to identify; personal saves remain separate from source/build ZIPs |
| Git/recovery | Baseline captured in commit 9961aca on feature/temple-encounter | Encounter ready for the user-requested PR; keep main unchanged until reviewed |
| Testing | Unit/integration plus rendered checks | Add deterministic combat tests and native input/playthrough checks; CI later |

## Possible routes after this encounter

1. **Combat/progression:** one enemy -> XP reward -> temple training -> first item.
   Best for validating the repeated gameplay loop and stat balance.
2. **Story/knowledge:** priest -> evidence -> changed dialogue. Best for proving
   the esoteric/gnostic storytelling hook before expanding combat content.
3. **Race identity:** one usable signature mechanic per race, with provisional
   visual cues. Best for testing whether ancestry/class combinations feel distinct.
4. **Presentation:** replace a small set of placeholders, add hit/skill/recovery
   sounds and animations. Best for readability and atmosphere after rules work.
5. **World exploration:** a second clearing with one encounter and one discovery.
   Best once persistence and interaction rules are reliable.

Avoid expanding all routes at once. Pick one playable milestone, retain the
others here, and revise after playing rather than committing to a giant roadmap.

## Decision log

- 2026-10-04: User chose **Vigor** for the shared physical resource, replacing Move.
- 2026-10-04: User requested a new branch and the proposed temple encounter.
- Previously confirmed: races are Saiyan, Patryn, Mazoku, Fist, Witch/Warlock;
  classes remain the original twelve. Attributes begin at 10; XP trains to caps.
- Previously confirmed: timed melee cannot be interrupted/reset by skill use;
  skills impose custom action lag. Optional turn-based combat can come later.
## Next selected milestone (user decision, 2026-10-04)

After the temple encounter PR: **race-specific sprites**. References and acceptance
criteria are in [race-sprites/README.md](reference/race-sprites/README.md). Implement
base appearances for the five races first; transformations and equipment layers
are later extensions. Other routes above remain available after this milestone.

## Verification record — 2026-10-04

- 54 tests / 417 assertions pass on WSL and native Windows.
- Native playthrough verified post proximity, mouse Start, keyboard skills, live
  character summary, automatic rounds, victory, withdrawal, and resource recovery.
- Windows build and source snapshot: C:\Users\mjshu\Games\16-bit-game\temple-training.
- WSL rendering used the dummy audio driver after a WSL PulseAudio timeout; no
  game audio is implemented yet. Native Windows rendering ran without that workaround.
- Source and native build remain compatible with existing identity/class profiles.
- Next work is the race-sprite milestone above. No new sprites are implemented here.
