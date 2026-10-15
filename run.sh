#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -x "$project_dir/.tools/godot" ]]; then
  engine="$project_dir/.tools/godot"
elif command -v godot4 >/dev/null 2>&1; then
  engine="$(command -v godot4)"
elif command -v godot >/dev/null 2>&1; then
  engine="$(command -v godot)"
else
  echo 'Godot 4 is required. Run ./tools/setup-godot.sh once, then ./run.sh.' >&2
  exit 1
fi
if [[ ! -d "$project_dir/.godot/imported" ]]; then
  "$engine" --headless --path "$project_dir" --editor --import --quit
fi
exec "$engine" --path "$project_dir" "$@"
