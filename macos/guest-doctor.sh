#!/usr/bin/env bash
set -euo pipefail

fail=0
docker_mode="${AGENT_DEVBOX_DOCKER_MODE:-none}"
case "$docker_mode" in
  none|remote) ;;
  *)
    echo "FAIL guest: invalid Docker mode '$docker_mode'"
    exit 2
    ;;
esac
model="$(sysctl -n hw.model 2>/dev/null || true)"
if [[ "$model" == VirtualMac* ]]; then
  echo "OK guest: $model"
else
  echo "FAIL guest: expected VirtualMac, found '$model'"
  fail=1
fi

for app in ChatGPT Claude 'Visual Studio Code'; do
  if [[ -d "/Applications/$app.app" ]]; then
    echo "OK guest app: $app"
  else
    echo "FAIL guest app: $app is missing"
    fail=1
  fi
done

recorded_docker_mode="$(cat /etc/agent-devbox-docker-mode 2>/dev/null || printf none)"
if [[ "$recorded_docker_mode" == "$docker_mode" ]]; then
  echo "OK guest: Docker mode is $docker_mode"
else
  echo "FAIL guest: Docker mode is '$recorded_docker_mode', expected '$docker_mode'"
  fail=1
fi

if [[ "$docker_mode" == remote ]]; then
  for tool in docker docker-compose docker-buildx; do
    if PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH" command -v "$tool" >/dev/null 2>&1; then
      echo "OK guest remote Docker tool: $tool"
    else
      echo "FAIL guest remote Docker tool: $tool is missing"
      fail=1
    fi
  done
fi

if [[ -d /Applications/Docker.app ]] || [[ -S /var/run/docker.sock ]]; then
  echo 'FAIL isolation: a local Docker Desktop app or daemon socket is present'
  fail=1
else
  echo 'OK isolation: no local Docker Desktop app or daemon socket'
fi

for tool in brew claude gh git node python3 rg; do
  if PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH" command -v "$tool" >/dev/null 2>&1; then
    echo "OK guest tool: $tool"
  else
    echo "FAIL guest tool: $tool is missing"
    fail=1
  fi
done

if sudo -u agent -H test -x /Users/agent/.local/bin/codex; then
  echo 'OK guest tool: codex (agent user)'
else
  echo 'FAIL guest tool: codex is missing for the agent user'
  fail=1
fi

if sudo -u agent -H test -f /Users/agent/.codex/config.toml && \
   sudo -u agent -H grep -Eq '^cli_auth_credentials_store[[:space:]]*=[[:space:]]*"keyring"' /Users/agent/.codex/config.toml; then
  echo 'OK guest: Codex credentials use the macOS keychain'
else
  echo 'FAIL guest: Codex keychain credential policy is missing'
  fail=1
fi

for app in ChatGPT Claude 'Visual Studio Code'; do
  if codesign --verify --deep --strict "/Applications/$app.app" >/dev/null 2>&1; then
    echo "OK guest signature: $app"
  else
    echo "FAIL guest signature: $app"
    fail=1
  fi
done

chatgpt_team="$(codesign -dv --verbose=4 /Applications/ChatGPT.app 2>&1 | awk -F= '/^TeamIdentifier=/ { print $2; exit }')"
if [[ "$chatgpt_team" == 2DC432GLL2 ]]; then
  echo 'OK guest publisher: ChatGPT is signed by OpenAI'
else
  echo "FAIL guest publisher: unexpected ChatGPT TeamIdentifier '$chatgpt_team'"
  fail=1
fi

if id agent >/dev/null 2>&1; then
  if id -Gn agent | tr ' ' '\n' | grep -qx admin; then
    echo 'FAIL guest user: agent must be a Standard user, not an administrator'
    fail=1
  else
    echo 'OK guest user: agent is non-admin'
  fi
else
  echo 'FAIL guest user: create the standard user agent'
  fail=1
fi

if [[ -d /Applications/VirtualBuddyGuest.app ]] || pgrep -x VirtualBuddyGuest >/dev/null 2>&1; then
  echo 'FAIL isolation: VirtualBuddyGuest is installed or running'
  fail=1
else
  echo 'OK isolation: VirtualBuddyGuest is absent'
fi

if mount | grep -Eiq 'virtiofs|VirtualBuddyShared'; then
  echo 'FAIL isolation: a host-shared filesystem appears to be mounted'
  fail=1
else
  echo 'OK isolation: no host-shared filesystem is mounted'
fi

firewall_state="$(/usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate 2>/dev/null || true)"
if [[ "$firewall_state" == *enabled* ]]; then
  echo 'OK guest: application firewall enabled'
else
  echo 'FAIL guest: application firewall disabled or unreadable'
  fail=1
fi

if [[ -d /Users/Shared/AgentWorkspaces ]]; then
  echo 'OK guest: isolated workspace exists'
else
  echo 'FAIL guest: /Users/Shared/AgentWorkspaces is missing'
  fail=1
fi

exit "$fail"
