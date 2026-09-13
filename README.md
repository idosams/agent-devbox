# Agent Devbox

Run graphical coding agents in a disposable virtual machine instead of giving
them direct access to your everyday Mac.

> [!IMPORTANT]
> A VM reduces host exposure; it does not make an agent or its online accounts
> harmless. Review the [threat model](docs/THREAT_MODEL.md) before adding
> credentials or sensitive source code.

## Choose a profile

| Profile | Best for | Host | Guest UI |
| --- | --- | --- | --- |
| [macOS + VirtualBuddy](macos/README.md) | Native ChatGPT/Codex, Claude Desktop, editors, browsers, and Mac development | Apple-silicon Mac | Native macOS window |
| [Ubuntu + Multipass](docs/LINUX.md) | Disposable CLI work and separate provider identities | macOS on Apple silicon or Intel | Ubuntu Desktop over RDP |

The macOS profile is the recommended path when desktop agent harnesses are the
main workflow. The Ubuntu profile is useful when separate Unix identities and a
more automated rebuild matter more than native-app feature parity.

## Five-minute start

Prerequisites for the macOS profile:

- Apple-silicon Mac running macOS 13 or newer
- 16 GB RAM minimum; 24 GB or more is more comfortable
- At least 100 GB of free disk space for a sparse VM disk
- [Homebrew](https://brew.sh/)

```bash
git clone https://github.com/idosams/agent-devbox.git
cd agent-devbox
make macos-install
make macos-create
```

On a higher-memory M4 work Mac, reserve resources for a second VM and install
remote Docker tooling in the macOS guest with:

```bash
make macos-create DOCKER=remote PARALLEL=1
```

`make macos-create` detects the host resources and prints recommended VM
settings before opening VirtualBuddy. Complete Apple's graphical installer,
create the required `vm-admin` and `agent` users, then provision the guest:

```bash
make macos-bootstrap HOST=VM_IP
```

Use the same Docker mode during provisioning and diagnostics:

```bash
make macos-bootstrap HOST=VM_IP DOCKER=remote
make macos-doctor HOST=VM_IP DOCKER=remote
```

`DOCKER=remote` installs Docker CLI, Compose, and Buildx. It does not install
Docker Desktop or a daemon inside the macOS VM. Point it only at a separately
secured remote/container VM; never expose the physical Mac's Docker socket.

All ChatGPT, Codex, Claude, GitHub, and other sign-ins happen inside the
standard `agent` account in the VM. Do not migrate a host profile or enable
host folder, clipboard, keychain, SSH-agent, microphone, camera, or USB sharing.

See the [macOS runbook](macos/README.md) for the complete procedure. To use the
Ubuntu profile instead, start with `make linux-create`.

## What the project installs

The macOS guest receives:

- ChatGPT desktop app with Codex
- Claude Desktop and Claude Code
- Codex CLI using the macOS keychain for cached credentials
- VS Code, GitHub CLI, Git, Node.js, Python, Go, Rust, and shell utilities
- optional Docker CLI, Compose, and Buildx for a restricted remote context
- a guest-only `/Users/Shared/AgentWorkspaces` directory

The Ubuntu guest adds separate `codex-agent`, `claude-agent`, `gemini-agent`,
and `copilot-agent` Unix identities; a hardened RDP desktop; and a shared
`/workspaces` directory that is not mounted from the host.

## Security defaults

- No host directory or container socket is mounted.
- Host SSH agents and host credentials are not forwarded or copied.
- macOS uses shared/NAT networking, not bridged networking.
- VirtualBuddyGuest, clipboard sharing, and shared folders stay disabled.
- The everyday macOS `agent` account is not an administrator.
- Temporary macOS SSH access is pinned to a dedicated known-hosts file and is
  disabled after provisioning.
- Ubuntu SSH and RDP accept connections only from the VM host gateway.
- Agent processes still have network access and can affect accounts and data
  available inside the guest.

Read [Architecture](docs/ARCHITECTURE.md), [Threat model](docs/THREAT_MODEL.md),
and [Supply-chain policy](docs/SUPPLY_CHAIN.md) before treating the setup as a
security boundary.

## Common commands

```bash
make help
make macos-doctor
make macos-open

make linux-create
make linux-gui SESSION=codex
make linux-doctor

make test
make lint
```

## Project status

The project is preparing its `0.1.0` release. The host scripts and static
configuration are tested in CI. A complete macOS or Ubuntu installation still
requires real virtualization hardware and is documented as a manual release
test.

## Documentation

- [macOS runbook](macos/README.md)
- [Ubuntu runbook](docs/LINUX.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Threat model](docs/THREAT_MODEL.md)
- [Compatibility](docs/COMPATIBILITY.md)
- [Included stack](docs/STACK.md)
- [Supply-chain policy](docs/SUPPLY_CHAIN.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Launch playbook](docs/LAUNCH.md)
- [Contributing](CONTRIBUTING.md)
- [Security policy](SECURITY.md)
- [Release checklist](RELEASE.md)

## Independence and trademarks

Agent Devbox is an independent community project. It is not affiliated with or
endorsed by Apple, Anthropic, Canonical, GitHub, Google, Microsoft, OpenAI, or
the VirtualBuddy project. Product names and trademarks belong to their
respective owners.

## License

[MIT](LICENSE)
