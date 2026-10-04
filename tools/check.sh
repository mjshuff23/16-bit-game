#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
godot_bin="${GODOT_BIN:-$HOME/.local/bin/godot}"
python3 tools/setup_gut.py
python3 tools/test_setup_gut.py
python3 tools/test_sprite_regions.py --godot "$godot_bin"
check_log="$(mktemp)"
trap 'rm -f "$check_log"' EXIT

run_check() {
  "$godot_bin" "$@" 2>&1 | tee "$check_log"
  if grep -Eq '(^|[[:space:]])(SCRIPT ERROR:|ERROR:|Parse Error:)' "$check_log"; then
    return 1
  fi
}

run_check --headless --path . --editor --import
run_check --headless --path . -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
run_check --headless --path . --quit-after 5
