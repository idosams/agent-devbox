#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

while IFS= read -r file; do
  bash -n "$file"
  if [[ ! -x "$file" ]]; then
    echo "Expected executable script: $file" >&2
    exit 1
  fi
done < <(find "$root_dir/bin" "$root_dir/macos" "$root_dir/tests" -type f -name '*.sh' | sort)

ruby -e '
  require "yaml"
  ARGV.each do |path|
    document = YAML.load_file(path)
    abort "#{path}: expected a YAML mapping" unless document.is_a?(Hash)
  end
' "$root_dir/cloud-init.yaml.tmpl" \
  "$root_dir/.github/workflows/ci.yml" \
  "$root_dir/.github/dependabot.yml" \
  "$root_dir/.github/ISSUE_TEMPLATE/config.yml" \
  "$root_dir/.github/ISSUE_TEMPLATE/bug_report.yml"

"$root_dir/tests/check-links.rb"

required_files=(
  LICENSE
  NOTICE.md
  README.md
  SECURITY.md
  CONTRIBUTING.md
  CODE_OF_CONDUCT.md
  CHANGELOG.md
  RELEASE.md
  VERSION
)
for file in "${required_files[@]}"; do
  [[ -s "$root_dir/$file" ]] || {
    echo "Missing release file: $file" >&2
    exit 1
  }
done

absolute_user_paths="$(
  rg -n '/Users/[[:alnum:]_.-]+' "$root_dir" \
    -g '!state/**' -g '!tests/static.sh' || true
)"
unexpected_user_paths="$(
  printf '%s\n' "$absolute_user_paths" | \
    rg -v '/Users/(Shared|agent|vm-admin)(/|[^[:alnum:]_.-])' || true
)"
if [[ -n "$unexpected_user_paths" ]]; then
  echo 'A personal absolute path is present in tracked source:' >&2
  printf '%s\n' "$unexpected_user_paths" >&2
  exit 1
fi

if rg -n 'BEGIN (RSA |OPENSSH |EC )?PRIVATE KEY|sk-[A-Za-z0-9_-]{20,}|gh[opusr]_[A-Za-z0-9]{20,}' \
  "$root_dir" -g '!state/**' >/dev/null; then
  echo 'A value resembling a private key or provider token is present.' >&2
  exit 1
fi

rg -q 'ufw allow from "\$host_gateway" to any port 22 proto tcp' "$root_dir/cloud-init.yaml.tmpl"
if rg -q '\[ufw, allow, 22/tcp\]' "$root_dir/cloud-init.yaml.tmpl"; then
  echo 'Ubuntu SSH must not be open to every source.' >&2
  exit 1
fi

rg -q 'cli_auth_credentials_store = "keyring"' "$root_dir/macos/codex-config.toml"
rg -q 'ForwardAgent=no' "$root_dir/bin/macos-bootstrap"
rg -q 'ClearAllForwardings=yes' "$root_dir/bin/macos-bootstrap"
rg -q 'VirtualBuddyGuest' "$root_dir/macos/guest-doctor.sh"
rg -q 'TeamIdentifier' "$root_dir/macos/guest-doctor.sh"

dummy_key='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK9mVZgNq0gX0testonlynotasecret release-test'
rendered="$(mktemp -t agent-devbox-cloud-init-test.XXXXXX)"
trap 'rm -f "$rendered"' EXIT
sed "s|__SSH_PUBLIC_KEY__|$dummy_key|g" "$root_dir/cloud-init.yaml.tmpl" > "$rendered"
if rg -q '__SSH_PUBLIC_KEY__' "$rendered"; then
  echo 'Cloud-init rendering left an SSH placeholder behind.' >&2
  exit 1
fi
ruby -e 'require "yaml"; abort unless YAML.load_file(ARGV.fetch(0)).is_a?(Hash)' "$rendered"

echo 'Static checks passed.'
