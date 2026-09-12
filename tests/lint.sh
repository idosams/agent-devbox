#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v shellcheck >/dev/null 2>&1; then
  echo 'shellcheck is required. See CONTRIBUTING.md.' >&2
  exit 127
fi

while IFS= read -r file; do
  shellcheck -x "$file"
done < <(find "$root_dir/bin" "$root_dir/macos" "$root_dir/tests" -type f -name '*.sh' | sort)

echo 'ShellCheck passed.'
