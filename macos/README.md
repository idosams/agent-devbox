# macOS Agent VM Runbook

Use this profile when native agent applications and complete macOS UI support
are the priority. VirtualBuddy runs the guest through Apple's Virtualization
framework; the host sees a VM window, while provider sessions, source code, and
app permissions stay in the guest.

## Prerequisites

- Apple-silicon Mac with macOS 13 or newer
- 16 GB host RAM minimum; see [Compatibility](../docs/COMPATIBILITY.md)
- 100 GB available disk space
- [Homebrew](https://brew.sh/)
- An intended use allowed by the license for the macOS release you install

Review the [threat model](../docs/THREAT_MODEL.md) first. This runbook assumes
the VM is for development, testing, or an otherwise permitted personal use on
Apple-branded hardware. You are responsible for complying with Apple's terms.

## 1. Install and configure VirtualBuddy

From the repository root:

```bash
make macos-install
make macos-create
```

The second command detects host memory and CPU count and prints recommended
values. Override them when needed:

```bash
MACOS_VM_CPUS=4 \
MACOS_VM_MEMORY_GIB=8 \
MACOS_VM_DISK_GIB=120 \
MACOS_VM_NAME='Agent Mac' \
make macos-create
```

### M4 and parallel-VM profile

An M4 host has the hardware capability for nested virtualization, but
VirtualBuddy does not currently expose nested virtualization to its macOS
guests. Docker Desktop therefore remains unsupported inside this macOS VM.

For a work Mac with at least 24 GB RAM, use parallel mode to keep resources
available for a separate Ubuntu container VM and install the remote Docker
client bundle in the macOS guest:

```bash
make macos-create DOCKER=remote PARALLEL=1
```

`PARALLEL=1` changes only the resource recommendation. It does not start a
second VM. `DOCKER=remote` installs Docker CLI, Compose, and Buildx, without a
local daemon.

In VirtualBuddy, select the latest **stable** macOS restore image that it marks
as supported by the host. Apply the printed CPU, memory, and disk values, then
set:

| Setting | Required value |
| --- | --- |
| Network | Shared/NAT |
| Bridged network | Off |
| Guest App disk | Off |
| Shared folders | Empty |
| Clipboard sharing | Off |
| Microphone/audio input | Off |
| Camera and USB devices | None |

Do not install `VirtualBuddyGuest`. It enables integration features that this
project intentionally excludes. Recheck these VM settings after VirtualBuddy
upgrades.

## 2. Complete macOS Setup Assistant

Create the first account as:

- Full name: `VM Administrator`
- Account name: `vm-admin`
- Role: Administrator

Use a unique password that is not the host login password. Skip Apple Account
sign-in. Disable Location Services, analytics, Siri, and iCloud-based recovery.
Do not use Migration Assistant.

After reaching the desktop:

1. Install all stable macOS updates and reboot.
2. Open **System Settings > Users & Groups**.
3. Create `Agent Workspace`, account name `agent`, role **Standard**.
4. Open **System Settings > General > Sharing**.
5. Enable **Remote Login** temporarily, allowing only `vm-admin`.
6. In the guest Terminal, run `ipconfig getifaddr en0` and note the IP.

If `en0` is empty, run `ifconfig` and use the private address assigned to the
active interface.

## 3. Provision the guest

Back on the host:

```bash
make macos-bootstrap HOST=VM_IP
```

If the VM was created with the remote Docker bundle, preserve that choice:

```bash
make macos-bootstrap HOST=VM_IP DOCKER=remote
```

The SSH host key is stored only in the ignored `state/macos_known_hosts` file.
Verify the fingerprint shown by SSH against this command in the guest before
accepting it:

```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

The first run may request Apple's Command Line Tools and stop. Approve the
dialog inside the VM, wait for installation to finish, and rerun the command.
Provisioning is idempotent.

The provisioner installs the desktop harnesses and development tools, creates
`/Users/Shared/AgentWorkspaces`, enables the guest firewall, verifies app code
signatures, and installs a conservative Codex configuration for `agent`.
Choose the default at the final prompt to turn Remote Login back off.
Confirm afterward that **System Settings > General > Sharing > Remote Login**
shows Off; recent macOS versions can require additional approval for this
setting.

## 4. Create a clean baseline

Before authenticating any provider:

1. Shut down macOS from inside the guest.
2. In VirtualBuddy, duplicate the VM.
3. Rename the duplicate `Agent Mac - clean`.
4. Keep that clone powered off and unauthenticated.

Treat authenticated snapshots and VM bundles as secrets: they contain browser
sessions, keychain items, source code, and possibly API credentials.

## 5. Authenticate inside the VM

Start the working VM and sign in as `agent`, not `vm-admin`. Open ChatGPT,
Claude, VS Code, and the guest browser and authenticate there.

For Codex CLI:

```bash
cd /Users/Shared/AgentWorkspaces
codex login
codex login status
```

The supplied configuration requests workspace-write sandboxing, approval on
request, and keychain credential storage. The desktop app and CLI can share
cached OpenAI login state; keep the entire guest disk protected accordingly.

For GitHub, prefer a dedicated account or a fine-grained token/SSH key that can
access only the repositories needed in this VM.

For remote Docker tooling, create a context only after the clean VM clone:

```bash
docker context create agent-worker --docker host=ssh://USER@CONTAINER_HOST
docker context use agent-worker
docker info
```

The SSH key and remote context are guest credentials. Restrict the remote user
and daemon to disposable development workloads. Do not point the context at
the physical Mac, a production host, or an unrestricted shared daemon.

Never import or expose these host resources:

- Apple Account, iCloud Drive, login keychain, or browser profile
- `~/.ssh`, `~/.aws`, `~/.config`, `.env` collections, or password vaults
- host home/project folders, SSH agent, or container socket
- camera, microphone, or USB devices unless a specific task truly requires one

## Daily use

```bash
make macos-open
make macos-doctor
```

`make macos-doctor` checks the host without needing SSH. For live guest checks,
temporarily enable Remote Login and run:

```bash
make macos-doctor HOST=VM_IP
# Or, when provisioned with the remote Docker bundle:
make macos-doctor HOST=VM_IP DOCKER=remote
```

Disable Remote Login again afterward.

## Updates

Temporarily enable Remote Login for `vm-admin`, rerun `make macos-bootstrap`,
and disable it afterward. Homebrew-managed components and the official Codex
installer follow their current stable channels. Review the
[supply-chain policy](../docs/SUPPLY_CHAIN.md) before unattended updates.

## Nested virtualization

Apple exposes nested virtualization on M3 and later hosts for generic platform
configurations. VirtualBuddy's current macOS guest path uses
`VZMacPlatformConfiguration` and does not expose a nested-virtualization
setting. Consequently, this project does not install Docker Desktop or other
VM-backed container runtimes inside the macOS guest. Normal desktop, terminal,
editor, browser, diff, and preview workflows do not require nested VMs.

## Recovery

If the guest or an account may be compromised:

1. Shut down the working VM.
2. Revoke affected OpenAI, Anthropic, GitHub, and other sessions remotely.
3. Rotate every secret that entered the guest.
4. Delete the authenticated VM from VirtualBuddy.
5. Duplicate the clean baseline, update it, and authenticate again.

Deleting a VM does not revoke remote account sessions by itself.

## Primary references

- [Apple: Virtualize macOS on a Mac](https://developer.apple.com/documentation/virtualization/virtualize-macos-on-a-mac)
- [Apple software license agreements](https://www.apple.com/legal/sla/)
- [VirtualBuddy](https://github.com/insidegui/VirtualBuddy)
- [OpenAI: ChatGPT desktop app](https://learn.chatgpt.com/docs/app)
- [OpenAI: Codex CLI](https://learn.chatgpt.com/docs/codex/cli)
- [OpenAI: authentication](https://learn.chatgpt.com/docs/auth)
- [Anthropic: Claude Desktop download](https://claude.com/download)
- [Anthropic: Claude Code setup](https://support.claude.com/en/articles/14554922-claude-code-user-faq)
