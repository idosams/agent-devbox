#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
  echo 'This provisioner must run inside the macOS guest.' >&2
  exit 1
fi

model="$(sysctl -n hw.model)"
if [[ "$model" != VirtualMac* ]]; then
  echo "Refusing to provision non-virtual model '$model'." >&2
  exit 1
fi

if [[ "$EUID" -eq 0 ]]; then
  echo 'Run this script as vm-admin, not root. It invokes sudo when required.' >&2
  exit 1
fi

if ! id -Gn "$USER" | tr ' ' '\n' | grep -qx admin; then
  echo "User '$USER' must be the guest administrator." >&2
  exit 1
fi

if ! id agent >/dev/null 2>&1; then
  echo 'Create the standard macOS account "agent" before provisioning.' >&2
  exit 1
fi
if id -Gn agent | tr ' ' '\n' | grep -qx admin; then
  echo 'The macOS account "agent" must be Standard, not Administrator.' >&2
  exit 1
fi

codex_config_source="${CODEX_CONFIG_SOURCE:-/tmp/agent-devbox-codex-config.toml}"
if [[ ! -f "$codex_config_source" ]]; then
  echo "Missing Codex configuration: $codex_config_source" >&2
  exit 1
fi

if ! xcode-select -p >/dev/null 2>&1; then
  echo 'Requesting Apple Command Line Tools installation in the guest UI...'
  xcode-select --install >/dev/null 2>&1 || true
  echo 'Approve and finish that installation inside the VM, then rerun this command.' >&2
  exit 3
fi

if ! command -v brew >/dev/null 2>&1; then
  echo 'Installing Homebrew from its official installer...'
  NONINTERACTIVE=1 /bin/bash -c "$(curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

eval "$(/opt/homebrew/bin/brew shellenv)"
brew update

formulae=(
  git
  gh
  go
  jq
  node
  python@3.13
  ripgrep
  rust
  shellcheck
  tmux
)

casks=(
  chatgpt
  claude
  claude-code
  visual-studio-code
)

echo 'Installing development tools and agent harnesses...'
brew install "${formulae[@]}"
brew install --cask "${casks[@]}"

echo 'Installing Codex CLI for the non-admin agent user from OpenAI...'
sudo -u agent -H /bin/bash -c "curl --proto '=https' --tlsv1.2 -fsSL https://chatgpt.com/codex/install.sh | sh"

sudo install -d -m 0700 -o agent -g staff /Users/agent/.codex
sudo install -m 0600 -o agent -g staff "$codex_config_source" /Users/agent/.codex/config.toml

sudo mkdir -p /Users/Shared/AgentWorkspaces
sudo chown root:staff /Users/Shared/AgentWorkspaces
sudo chmod 2775 /Users/Shared/AgentWorkspaces

if [[ ! -f /etc/paths.d/agent-devbox-homebrew ]]; then
  printf '/opt/homebrew/bin\n/opt/homebrew/sbin\n' | sudo tee /etc/paths.d/agent-devbox-homebrew >/dev/null
  sudo chmod 0644 /etc/paths.d/agent-devbox-homebrew
fi

sudo softwareupdate --schedule on
sudo systemsetup -setremoteappleevents off >/dev/null
sudo pmset -a womp 0 >/dev/null 2>&1 || true
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

cat <<'EOF'

Installed successfully.

Before authenticating:
  1. Confirm the standard macOS user "agent" exists.
  2. Log out of vm-admin and sign in as agent.
  3. Verify VM settings: Shared/NAT, no shared folders, Guest App off,
     clipboard off, microphone off, and no USB devices.
  4. Take a clean APFS clone named "Agent Mac - clean" in VirtualBuddy.
  5. Sign in to ChatGPT/Codex, Claude, GitHub, and any other providers only
     from inside the agent account.

Work only under /Users/Shared/AgentWorkspaces. Do not migrate a host profile.
EOF
