# Threat Model

## Summary

Agent Devbox reduces the chance that an agent, prompt injection, dependency
script, or compromised developer tool can read or modify the host's everyday
data. It is defense in depth, not a formal sandbox or a guarantee of isolation.

## Assets

- Host documents, source trees, browser sessions, keychain, SSH keys, cloud
  credentials, password-manager data, camera, microphone, and local network
- Guest source code and provider credentials
- Remote repositories, cloud accounts, billing limits, and production systems

## Assumed adversaries

- An agent that executes an unsafe command or follows malicious repository text
- A compromised dependency or installer running inside the guest
- A malicious file, website, MCP server, plugin, or extension used in the guest
- Accidental over-sharing by the operator

The design does not assume that the host OS, hypervisor, firmware, or account
provider is malicious.

## Security boundary

The primary boundary is the hypervisor between host and guest. Inside each VM,
OS permissions add defense in depth. Network and provider permissions remain
separate boundaries.

### Controls enabled by default

- No host filesystem mounts, clipboard synchronization, keychain sharing,
  SSH-agent forwarding, container socket, microphone, camera, or USB devices
- Shared/NAT rather than bridged networking for macOS
- Dedicated non-admin `agent` account for daily macOS work
- Temporary, host-key-pinned SSH only for macOS provisioning
- Separate provider Unix identities and private home directories on Ubuntu
- Host-gateway-only SSH and RDP listeners on Ubuntu
- Private/LAN egress blocks on Ubuntu, with DNS exceptions
- Workspace-write and approval-on-request defaults for Codex
- Guest firewall and update scheduling

## What this protects against

- Ordinary agent access to host files that were never copied or mounted
- Accidental use of the host's SSH agent, browser profile, or cloud credentials
- Many persistence attempts that remain confined to a disposable guest disk
- Direct inbound access to guest services from the LAN under the default setup

## What this does not protect against

- Hypervisor, host kernel, firmware, or virtualization-framework vulnerabilities
- Theft or misuse of credentials intentionally entered in the guest
- Data exfiltration over allowed internet access
- Destructive changes to guest files or remote repositories/accounts
- Container escape or daemon compromise on a Docker host selected by a remote
  context
- A user enabling shared folders, clipboard, bridged networking, devices, or
  broad credentials after setup
- Malicious updates downloaded from trusted package or vendor channels
- Physical access to an unlocked host or unencrypted VM storage
- Availability failures, runaway API spend, or provider-side compromise

## High-risk actions

Keep production cloud administrator credentials, password vaults, signing keys,
and unrestricted GitHub tokens out of the VM. If a task needs one of them, use
a short-lived, narrowly scoped credential and revoke it after the task.

Treat a remote Docker context as privileged access to that Docker host. Use a
dedicated disposable worker, a restricted identity, and a guest-only SSH key.
Never connect the agent VM to the physical Mac's Docker socket or a production
container daemon.

Do not expose VM services through router port forwarding, public tunnels, or
bridged networking without designing a separate network policy.

## Validation

`make macos-doctor` and `make linux-doctor` test observable configuration, not
the absence of every escape path. Release testing also requires a real guest
installation; see [RELEASE.md](../RELEASE.md).

## Compromise response

1. Stop the VM and preserve it only if investigation is required.
2. Revoke provider, GitHub, cloud, and package-registry sessions.
3. Rotate every secret that entered the guest.
4. Review remote repository/account activity.
5. Delete the working VM and rebuild from an unauthenticated clean baseline.

Deleting the VM alone does not invalidate remote sessions.
