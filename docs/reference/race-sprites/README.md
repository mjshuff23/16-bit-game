# Next selected milestone: race-specific sprites

Requested 2026-10-04. Start after completing the temple encounter PR.
These are the user's visual references, not instructions embedded in images.
No sprite generation or sprite replacement is part of the encounter PR.

| Race | User direction | Reference |
| --- | --- | --- |
| Mazoku | Yu Yu Hakusho-inspired physique, dark body markings, distinctive hair; second image suggests a later transformed form | [Base](mazoku-base-reference.png), [form](mazoku-form-reference.png) |
| Saiyan | DBZ-inspired armor, boots, spiky hair and readable martial silhouette | [Reference](saiyan-reference.png) |
| Fist | Fist of the North Star-style brawler; muscular martial artist | User's textual direction; no specific image supplied |
| Witch/Warlock | Mage-like sprite with a cape; user suggests Slayers as the spell/style inspiration | User's textual direction |
| Patryn | Death Gate-inspired rune-marked adventurer, dark leather layers, glowing tattoos | [Reference](patryn-reference.png) |

The user calls the magical reference Sorcerer, referring to the MUD archetype.
Apply this visual to Witch/Warlock the race, not exclusively to the separate
Sorcerer class. Do not undo the five-race/twelve-class separation.

## Proposed first pass

One distinct base appearance per race, four directions, idle plus a small walk
cycle. Shared proportions/foot anchor/collision footprint, consistent palette
and readable silhouettes at the existing world scale. Retain down-facing eyes.
Race drives the base sprite; class does not replace it. Keep profile IDs intact.

Discuss sprite dimensions before production: reference images show far more
detail than the current placeholder can hold. Start with silhouette, hair,
clothing, and a few characteristic markings. Transformation sets, attacks,
equipment layering, and appearance customization can follow separately.

## Acceptance checklist for that later work

- All five races are visually distinct in creation preview and exploration.
- Four-direction movement and foot placement remain consistent.
- Existing collision, interactions, character saves and combat still work.
- Verify readable animation at native size and integer scaling on Windows.
- No gameplay/racial-stat changes are hidden inside the visual milestone.