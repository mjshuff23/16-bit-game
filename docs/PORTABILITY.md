# Windows portability and recovery

The game uses platform-independent Godot scenes and GDScript. WSL is the current
development environment, not a runtime requirement. Keep engine and export
templates at the same version (currently 4.7.2 Standard).

## Play on Windows

The portable build consists of `16-bit-game.exe` and `16-bit-game.pck` in the
same folder, with its README and license. Double-click the executable. No WSL,
editor installation, backend, or Internet connection is required.

## Export from WSL

Install the matching Standard export templates from the official Godot archive
via Editor -> Manage Export Templates, then run:

```bash
bash tools/export_windows.sh
```

This validates the project and exports to `builds/windows/`. Copy that whole
folder to Windows or zip it for transfer. `export_presets.cfg` is portable and
uses a relative output path. Builds and `.godot/` caches are ignored by Git.
Custom executable metadata is disabled so cross-export does not require icon
editing tools. Code signing is not configured for this local prototype.

## Continue development without WSL

Extract the source backup to a normal Windows directory, or clone the repository
once the latest changes have been pushed. A source ZIP is a snapshot of source
files, not Git history or an automatically synchronized working copy.

Download Godot 4.7.2 Standard for Windows and open the extracted `project.godot`.
The engine rebuilds its `.godot/` cache. Use the console executable for checks:

```powershell
& .\tools\check.ps1 -Godot 'C:\path\to\Godot_v4.7.2-stable_win64_console.exe'
```

To export natively, install the matching Windows export templates through the
editor, create `builds/windows`, and use Project -> Export -> Windows Desktop.
GUT is included in source; no WSL-only paths occur in game resource references.

Use exact filename casing in every `res://` path. `.gitattributes` keeps source
line endings consistent across operating systems. Keep engine-generated `.uid`
files in source control. Do not copy `.godot/` between operating systems.

Refresh the source backup and Windows build after changes you want to preserve.
To regenerate the source ZIP, run `python3 tools/package_source.py` in WSL
(Python's standard library only). This includes uncommitted, non-ignored files;
the output is `builds/16-bit-game-source.zip`. Copy it to C:\ for WSL recovery.
Develop in one checkout at a time to avoid divergent copies. The initial local
artifacts are under `C:\Users\mjshu\Games\16-bit-game`; the WSL repo remains the
active checkout until explicitly switched.

Official references:
- https://godotengine.org/download/archive/4.7.2-stable/
- https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_windows.html
