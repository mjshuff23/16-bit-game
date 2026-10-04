16-bit Game — portable Windows build

Keep 16-bit-game.exe and 16-bit-game.pck together. Double-click the EXE.
No Godot editor or WSL is required.

Create a named Saiyan, Patryn, Mazoku, Fist, or Witch/Warlock; or continue a saved character.
Walk to the temple altar to choose one of the twelve familiar classes.
Race and class are separate: for example, Fist Monk or Witch/Warlock Wizard.
All attributes start at 10. Training with XP up to racial caps is planned.
WASD/arrows: move. E/Enter: interact. Esc: close a modal or return to characters.
Use mouse or Tab/arrows and Enter/Space in menus.

Identity and class save automatically. Continuing starts at the forest spawn;
world position and progression are not saved. Temple training is available; final racial/class power kits come later.

Character data: %APPDATA%/Godot/app_userdata/16-bit Game/characters.json
Back up that file separately; source/build ZIPs do not contain personal saves.
To transfer from WSL, close the game and copy its characters.json from
~/.local/share/godot/app_userdata/16-bit Game/ to the Windows location.
Back up any existing destination first: this replaces, rather than merges, profiles.

Display: 640 x 360 base resolution, 1280 x 720 default window.
Menus and HUD use higher-resolution text; pixel art keeps its existing detail.
Integer scaling preserves pixels when resizing; some window sizes show borders.

C: open/close character summary. WASD and arrow keys still move while it is open.
Esc closes the summary; interaction closes it before opening another game panel.

Temple training: after choosing a class, approach the target post east of the steps.
E opens training. Enter starts; 1 Heavy Strike (80 Vigor), 2 Spark (100 Mana).
Melee runs every 3 seconds even during skill action lag. Esc leaves safely.
Health/Mana/Vigor recover outside active combat. Training has no XP/loot rewards.
Resources are session-only and reset when reloading a character.
