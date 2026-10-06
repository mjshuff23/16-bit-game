# Browser / iPhone preview

The Web export runs the same Godot game, with on-screen controls. Open the preview
in iPhone Chrome or Safari, rotate to landscape, then tap Play. Actual iPhone
hardware testing is still required; desktop touch emulation is not an iOS test.

## Controls and saves

- Direction pad: hold to walk. Use: interact with the altar or training post.
- Char: live character summary. Back: close the summary or return/leave.
- Class choice and battle commands are tappable. Combat still uses timed rounds.
- Desktop keyboard controls remain available. Browser buttons also accept a mouse.
- The game pauses when the page is hidden or a touch device is in portrait.
  Returning discards the first simulation delta, preventing background catch-up.
- Names, races and class choices save in this browser's site storage. They are
  separate from Windows saves and other browsers/devices. Private browsing or
  clearing site data can remove them. Position, resources and XP are not saved.

## Export and host

Use Godot 4.7.2 Standard with matching **Web non-threaded** export templates.
Install the matching templates through Godot's export-template manager. Then:

```bash
bash tools/export_web.sh
python3 -m http.server 8765 --directory builds/web
```

Local preview: http://localhost:8765. A phone cannot use the PC's localhost URL;
use the deployed HTTPS link. WebGL 2 and WebAssembly support are required.
The first download is about 43 MB before HTTP compression/browser caching.

The preset uses one thread, so hosting does not require cross-origin isolation
headers. It excludes tests, GUT and source artwork. The fixed 640x360 canvas is
scaled by the HTML shell to fit; native Windows keeps integer scaling. No PWA
service worker is installed, avoiding an extra stale-build cache during iteration.

To publish a tested, committed build, run `python3 tools/publish_web.py`. It pushes
compiled files to `gh-pages` in a temporary checkout; it does not merge game code
or add binaries to the feature PR. GitHub Pages must use `gh-pages` / root.
The site is a preview of that published commit, not an automatic main deployment.

## Phone acceptance check

1. Open the HTTPS preview in normal iPhone Chrome, landscape, and tap Play.
2. Create a named character using the phone keyboard; choose a race.
3. Walk with the pad, use the altar and confirm a class.
4. Open/close Char; check movement still works and all stats are readable.
5. Walk to the training post, Use, Start, Heavy Strike and Spark, then Leave.
6. During another battle switch apps or rotate to portrait. Return and check
   there is no burst of missed rounds and no stuck direction.
7. Reload and confirm the same name/race/class appears.

If Chrome fails, note the iPhone model/iOS version and try Safari on the same
link to distinguish a browser-specific issue from the game. Dedicated iOS
packaging, offline installation and cross-device save sync are outside this PR.

Verification (2026-10-06): 72 GUT tests / 970 assertions pass on WSL and native
Windows, plus the existing Python setup/sprite tests, headless import/startup,
Web export and Windows export. Browser playthrough covered identity/class save
reload, pad movement, altar, summary and training skills. Touch-event integration
checks cover two fingers, menu cancellation and resumed contacts. Native iPhone
keyboard behavior, safe-area fit and performance remain hardware-test items.
