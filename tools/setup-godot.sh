#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
version='4.7.2-stable'
if [[ "$(uname -s)" != Linux || "$(uname -m)" != x86_64 ]]; then
  echo 'This installer targets Ubuntu/Linux x86_64. Install Godot 4 for your platform separately.' >&2
  exit 1
fi
command -v curl >/dev/null
command -v unzip >/dev/null
mkdir -p "$project_dir/.tools"
archive="$(mktemp /tmp/quiet-array-godot.XXXXXX.zip)"
trap 'rm -f "$archive"' EXIT
curl --fail --location --show-error "https://github.com/godotengine/godot/releases/download/$version/Godot_v${version}_linux.x86_64.zip" -o "$archive"
unzip -o "$archive" -d "$project_dir/.tools"
mv "$project_dir/.tools/Godot_v${version}_linux.x86_64" "$project_dir/.tools/godot"
chmod +x "$project_dir/.tools/godot"
"$project_dir/.tools/godot" --version
