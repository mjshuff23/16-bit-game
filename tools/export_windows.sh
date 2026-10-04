#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash tools/check.sh
mkdir -p builds/windows
godot_bin="${GODOT_BIN:-$HOME/.local/bin/godot}"
export_log="$(mktemp)"
trap 'rm -f "$export_log"' EXIT
"$godot_bin" --headless --path . --export-release "Windows Desktop" 2>&1 | tee "$export_log"
if grep -Eq '(^|[[:space:]])(SCRIPT ERROR:|ERROR:|Parse Error:)' "$export_log"; then
  exit 1
fi
cp LICENSE builds/windows/LICENSE.txt
cp docs/PORTABLE_README.txt builds/windows/README.txt
printf '\nWindows build: builds/windows/16-bit-game.exe\nKeep the .exe and .pck together.\n'
