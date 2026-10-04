# Downloaded test dependency

GUT 9.7.1: https://github.com/bitwes/Gut/releases/tag/v9.7.1

Run `python3 tools/setup_gut.py` on Linux or `python tools/setup_gut.py` on
Windows (Python 3). The check scripts do this automatically before editor import.
The first run needs internet. Later runs reuse the ignored `addons/gut/` folder.
The exact archive URL and SHA-256 are pinned in tools/setup_gut.py. Only the
addon subtree is installed, including its upstream MIT license. A failed download
or checksum check does not install anything. Existing unmanaged installations
are never overwritten: move them aside before running setup.

For upgrades, update the version and independently verified archive checksum,
move the previous addon aside, then run the full checks. Do not patch upstream
files locally. The optional GUT editor panel is not required.

Source ZIPs intentionally omit this dependency. Exported games do not need it.
