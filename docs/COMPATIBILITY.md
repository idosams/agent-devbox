# Compatibility

## macOS profile

| Host | Status | Notes |
| --- | --- | --- |
| Apple silicon, macOS 13+ | Supported | Required by VirtualBuddy |
| Intel Mac | Unsupported | Apple's macOS guest path used here requires Apple silicon |
| 8 GB RAM | Not recommended | A graphical host and guest will be memory constrained |
| 16 GB RAM | Minimum practical | Default guest memory is 8 GB |
| 24 GB RAM | Recommended | Default guest memory is 12 GB |
| 32 GB+ RAM | Recommended for heavier builds | Default guest memory is 16 GB |

`make macos-create` detects host resources. Override its recommendation with
`MACOS_VM_CPUS`, `MACOS_VM_MEMORY_GIB`, and `MACOS_VM_DISK_GIB`.

For M4 and other higher-memory hosts, `PARALLEL=1` caps the macOS guest's
automatic recommendation so resources remain available for a second VM. At
least 24 GB host RAM is recommended for two graphical VMs.

Apple documents nested virtualization for M3 and later hardware, but
VirtualBuddy's macOS guest configuration does not currently expose it. M4
hardware therefore does not make Docker Desktop supported inside the macOS
guest. `DOCKER=remote` is a client-only option for a separately secured Docker
host.

## Ubuntu profile

The Multipass profile supports Intel and Apple-silicon Macs. Package
availability is checked at provisioning time for `amd64` and `arm64`. The
default memory allocation ranges from 4 GB to 16 GB based on the host; a 100 GB
sparse disk is used unless overridden.

## Tested scope

CI validates shell syntax, ShellCheck findings, generated configuration,
documentation links, and command behavior with mocks. CI cannot boot nested
desktop VMs. Each release therefore requires the manual matrix in
[RELEASE.md](../RELEASE.md).
