#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_dir="$(mktemp -d -t agent-devbox-tests.XXXXXX)"
trap 'rm -rf "$test_dir"' EXIT

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain: $needle"
}

mkdir -p "$test_dir/VirtualBuddy.app"

output="$(
  VIRTUALBUDDY_APP_PATH="$test_dir/VirtualBuddy.app" \
  AGENT_DEVBOX_NO_OPEN=1 \
  MACOS_VM_CPUS=4 \
  MACOS_VM_MEMORY_GIB=7 \
  MACOS_VM_DISK_GIB=120 \
  MACOS_VM_NAME='Test Agent Mac' \
  "$root_dir/bin/macos-create"
)"
assert_contains "$output" 'Create a VM named "Test Agent Mac"'
assert_contains "$output" 'CPU:         4 cores'
assert_contains "$output" 'Memory:      7 GB'
assert_contains "$output" 'Disk:        120 GB sparse'
assert_contains "$output" 'latest stable macOS supported by this host'

if VIRTUALBUDDY_APP_PATH="$test_dir/VirtualBuddy.app" \
  AGENT_DEVBOX_NO_OPEN=1 MACOS_VM_CPUS=oops \
  "$root_dir/bin/macos-create" >/dev/null 2>&1; then
  fail 'macos-create accepted a non-numeric CPU value'
fi

VIRTUALBUDDY_APP_PATH="$test_dir/VirtualBuddy.app" \
  AGENT_DEVBOX_NO_OPEN=1 "$root_dir/bin/macos-open"

if MACOS_VM_HOST='bad host' "$root_dir/bin/macos-bootstrap" >/dev/null 2>&1; then
  fail 'macos-bootstrap accepted an unsafe host value'
fi
if MACOS_VM_HOST='192.0.2.10' MACOS_VM_USER='-unsafe' \
  "$root_dir/bin/macos-bootstrap" >/dev/null 2>&1; then
  fail 'macos-bootstrap accepted an unsafe user value'
fi

valid_name="$(DEVBOX_NAME='test-box-1' bash -c 'source "$1/bin/_lib"; devbox_name' _ "$root_dir")"
[[ "$valid_name" == test-box-1 ]] || fail 'devbox_name changed a valid name'
if DEVBOX_NAME=$'bad\nname' bash -c 'source "$1/bin/_lib"; devbox_name' _ "$root_dir" >/dev/null 2>&1; then
  fail 'devbox_name accepted a newline'
fi

if DEVBOX_NAME='-unsafe' "$root_dir/bin/create" >/dev/null 2>&1; then
  fail 'Linux create accepted an unsafe instance name'
fi
if DEVBOX_NAME='-unsafe' "$root_dir/bin/start" >/dev/null 2>&1; then
  fail 'Linux start accepted an unsafe instance name'
fi

help_output="$(make -s -C "$root_dir" help)"
assert_contains "$help_output" 'make macos-create'
assert_contains "$help_output" 'make linux-create'
assert_contains "$help_output" 'make test'

echo 'Unit checks passed.'
