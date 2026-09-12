# Ubuntu Agent VM Runbook

The Ubuntu profile is a reproducible graphical workstation built with
Multipass and cloud-init. It favors separate provider identities and automated
rebuilds over native macOS app behavior.

## Prerequisites

- macOS on Apple silicon or Intel
- [Multipass](https://canonical.com/multipass/install)
- Microsoft [Windows App](https://apps.apple.com/app/windows-app/id1295203466)
  as the RDP client

Do not enable Multipass host-directory mounts.

## Create the guest

```bash
make linux-create
```

Provisioning installs Ubuntu Desktop, ChatGPT, Claude Desktop, Codex CLI,
Claude Code, Gemini CLI, Copilot CLI, Git, GitHub CLI, Node.js, Python, Go,
Rust, Podman, and common shell tools. A first build can take tens of minutes.

Override the generated resources when needed:

```bash
DEVBOX_CPUS=6 DEVBOX_MEMORY=12G DEVBOX_DISK=150G make linux-create
```

## Open a desktop

```bash
make linux-gui SESSION=dev
make linux-gui SESSION=codex
make linux-gui SESSION=claude
```

The generated RDP profile disables clipboard, drive, printer, smart-card,
location, and audio redirection. Compare the printed xrdp TLS fingerprint
before accepting a certificate.

Use `dev` for GitHub login, cloning, pushing, publishing, and other privileged
external actions. Agent users can edit the shared `/workspaces` tree but cannot
read `dev` credentials or use sudo.

## CLI login

```bash
make linux-login PROVIDER=codex
make linux-login PROVIDER=claude
make linux-login PROVIDER=gemini
make linux-login PROVIDER=copilot
make linux-login PROVIDER=github
```

For Codex, device-code login stays inside the guest workflow. Never copy a host
`~/.codex/auth.json` into the VM; authentication caches are credentials.

## Shell and optional SSH targets

```bash
make linux-shell
make linux-harnesses
```

`linux-harnesses` adds an `Include` line to the host's `~/.ssh/config` after
creating a timestamped backup. This is optional and weaker than keeping native
harness logins inside the graphical VM.

## Lifecycle

```bash
make linux-doctor
make linux-stop
make linux-start
make linux-snapshot
make linux-destroy
```

`linux-destroy` permanently deletes the selected Multipass VM after requiring
its exact name. It does not revoke remote sessions.

## Network policy

SSH and RDP accept traffic only from the Multipass host gateway. New outbound
connections to RFC 1918 private networks and the common cloud metadata address
are blocked, with DNS exceptions. This can break private registries and
corporate Git hosts; add a narrow exception only after reviewing the threat
model.

## Feature differences

Vendor feature availability changes over time. Confirm required desktop and
computer-control capabilities in current OpenAI and Anthropic documentation
before depending on the Ubuntu profile. Features that require nested KVM work
only when `/dev/kvm` is exposed and writable in the guest; `make linux-doctor`
reports that condition.
