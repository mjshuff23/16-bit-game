#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
bash tools/check.sh
mkdir -p builds/web
log="$(mktemp)"
trap 'rm -f "$log"' EXIT
"${GODOT_BIN:-$HOME/.local/bin/godot}" --headless --path . --export-release Web 2>&1 | tee "$log"
if grep -Eq '(^|[[:space:]])(SCRIPT ERROR:|ERROR:|Parse Error:)' "$log"; then exit 1; fi
cp LICENSE builds/web/LICENSE.txt
printf '\nServe builds/web over HTTPS (or localhost for testing).\n'
