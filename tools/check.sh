#!/usr/bin/env bash
set -euo pipefail
project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
"$project_dir/run.sh" --headless --editor --import --quit
"$project_dir/run.sh" --headless --fixed-fps 60 --script res://tests/smoke.gd
