#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"$root_dir/tests/static.sh"
"$root_dir/tests/unit.sh"
"$root_dir/tests/lint.sh"

echo 'All tests passed.'
