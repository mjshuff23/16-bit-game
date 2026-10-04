# Race artwork

User-supplied transparent PNG sheets, mapped by the user in chat:
Saiyan, Fist, Mazoku, Witch/Warlock (mage sheet), Patryn.
Original pixels are preserved. These are supplied assets, not newly generated art.

Each 1086x1448 sheet contains a 3x4 grid of 362px cells. Rows are down, left,
right, up; columns are idle and two walking poses. The game cycles idle/step/idle/step
at eight frames per second while moving. Stopping returns to idle.

`regions.gd` records the opaque bounds and boot anchors without resampling or
rewriting the PNGs. Rebuild after replacing a sheet with:

```sh
godot --headless --path . --script tools/build_sprite_regions.gd
```

The generator runs only during asset preparation, never in exports. Runtime loads
imported textures and preloaded metadata. All frames use the same 0.08 world scale
and nearest filtering. Character height is roughly 26-28 world units; collision
remains the existing 8x6 feet rectangle. Class selection does not change race art.

Current limitations: source pose proportions vary slightly; this is a three-pose
walk cycle, not attack/casting animation. Equipment shown is decorative and has
no stat effect. Transformations, equipment layers and character-screen portraits
remain future work.
