# Included Stack

Agent Devbox has two profiles with different goals. The macOS profile provides
the best native graphical-agent experience. The Ubuntu profile is more
automated and includes a native Linux container runtime.

`Installed` below means the project installs the component in the guest.
`Required on host` means the user must install it before running the profile.
Authentication is always performed manually inside the guest.

## At a glance

| Component | macOS host | macOS guest | Ubuntu host | Ubuntu guest |
| --- | --- | --- | --- | --- |
| Virtualization | VirtualBuddy installed by `make macos-install` | macOS on Apple Virtualization | Multipass required on host | Ubuntu 24.04 VM |
| Graphical desktop | VirtualBuddy window | Native macOS UI | Windows App required for RDP | Ubuntu Desktop through hardened xrdp |
| Homebrew | Required | Installed automatically | Optional | Not used |
| Apple Command Line Tools | Used by Homebrew | User approves installation once | Not applicable | Not applicable |
| Git | Used to clone this repository | Installed | Used to clone this repository | Installed with Git LFS |
| GitHub CLI (`gh`) | Used to publish the project, not installed by it | Installed | Optional | Installed |
| Codex | Not copied from host | ChatGPT desktop plus Codex CLI | Not copied from host | ChatGPT desktop plus Codex CLI |
| Claude | Not copied from host | Claude Desktop plus Claude Code | Not copied from host | Claude Desktop plus Claude Code |
| Gemini CLI | Not installed | Not currently installed | Not copied from host | Installed |
| GitHub Copilot CLI | Not installed | Not currently installed | Not copied from host | Installed |
| VS Code | Not installed by this project | Installed | Not installed by this project | Not currently installed |
| Node.js | Not installed by this project | Installed | Optional | Node.js 22 installed by Snap |
| Python | System Python only | Python 3.13 installed | Optional | Python 3, pip, venv, and pipx installed |
| Go | Not installed by this project | Installed | Optional | Installed |
| Rust | Not installed by this project | Installed with Cargo | Optional | Installed with Cargo |
| Containers | No host socket is shared | Optional remote Docker clients | No host socket is shared | Podman installed |
| Docker Engine/Desktop | Not installed | Unsupported; remote daemon only | Not installed | Not installed |

## macOS guest

The bootstrap script installs Homebrew inside the VM, then installs these
formulae:

```text
git  gh  go  jq  node  python@3.13  ripgrep  rust  shellcheck  tmux
```

It installs these graphical applications and harnesses:

```text
ChatGPT  Claude Desktop  Claude Code  Visual Studio Code
```

Codex CLI is installed separately with OpenAI's official installer under the
standard `agent` account. The project also:

- writes a conservative Codex configuration using the macOS keychain;
- creates `/Users/Shared/AgentWorkspaces` on the guest disk;
- enables the macOS application firewall and stealth mode; and
- verifies the installed application signatures.

Safari is supplied by macOS. Chrome, Firefox, databases, cloud-provider CLIs,
Kubernetes tools, package-manager globals, editor extensions, and language
version managers are not currently installed.

Use `DOCKER=remote` during create, bootstrap, and doctor commands to add these
client tools:

```text
docker  docker compose  docker buildx
```

They require a separately secured remote Docker context. There is no local
daemon and the physical Mac's Docker socket must never be forwarded.

### Why a local Docker runtime is absent on macOS

Docker Desktop inside a macOS VM depends on another virtualization layer.
Apple provides nested virtualization hardware support on M3 and later, but
VirtualBuddy does not currently expose that capability to macOS guests.

Installing Docker Desktop in the macOS guest would therefore make the
documented stack misleading. Use the Ubuntu profile for local containers, or
use `DOCKER=remote` with a separate container host. Never expose the everyday
Mac's Docker socket to an agent VM.

## Ubuntu guest

Cloud-init installs a full Ubuntu Desktop and common development utilities,
including:

- Git, Git LFS, GitHub CLI, build-essential, Make, curl, jq, ripgrep, fd, fzf,
  rsync, shellcheck, tmux, Vim, Neovim, and zsh;
- Node.js 22, Python 3 with pip/venv/pipx, Go, Rust, and Cargo;
- Podman, uidmap, bubblewrap, and supporting rootless-container packages;
- OpenSSH, xrdp, Xorg, GNOME keyring, UFW, and unattended upgrades; and
- ChatGPT, Claude Desktop, Codex CLI, Claude Code, Gemini CLI, and GitHub
  Copilot CLI.

Podman is a native Linux container runtime and does not share a daemon or
socket from the host. The `docker` compatibility command and Compose are not
currently installed. Projects that specifically require Docker Engine,
Docker Compose, or a Docker socket need a separate opt-in profile with an
explicit guest-root risk decision.

## Accounts and credentials

The project installs tools but does not authenticate accounts. This is
intentional. After taking a clean unauthenticated VM clone, sign in from inside
the guest:

- macOS: use the standard `agent` account for ChatGPT/Codex, Claude, GitHub,
  browsers, and editors;
- Ubuntu: use the provider-specific agent identity for each harness and use
  `dev` for GitHub and publishing operations.

Do not copy host keychains, browser profiles, `~/.ssh`, `~/.codex`, `.env`
collections, password-vault databases, or cloud credentials. Prefer dedicated
provider identities and repository-scoped GitHub credentials.

## Host responsibilities

The project deliberately makes few changes to the everyday Mac:

- Homebrew must already exist for the macOS profile.
- `make macos-install` installs VirtualBuddy only.
- Multipass and Microsoft Windows App are prerequisites for the Ubuntu profile;
  the project does not silently install either.
- No Docker runtime, SSH key, provider credential, browser extension, or agent
  account is installed or copied on the host.

See the [macOS runbook](../macos/README.md), [Ubuntu runbook](LINUX.md), and
[supply-chain policy](SUPPLY_CHAIN.md) for exact installation and update paths.
