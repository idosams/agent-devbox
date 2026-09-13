# Changelog

All notable changes will be documented in this file. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Optional `DOCKER=remote` macOS guest bundle with Docker CLI, Compose, and
  Buildx for a separately secured remote daemon.
- `PARALLEL=1` resource recommendations for running a macOS agent VM alongside
  a separate container VM on higher-memory Apple-silicon hosts.

### Security

- Explicitly reject unsupported local Docker Desktop/daemon configurations in
  the macOS guest diagnostics; no host Docker socket is shared.

## [0.1.0] - Unreleased

### Added

- Hardened macOS full-UI profile using VirtualBuddy and Apple's Virtualization
  framework.
- Automated macOS guest provisioning with a separate administrator and
  non-administrator agent account.
- Ubuntu Desktop profile using Multipass, cloud-init, separate provider users,
  xrdp, and restricted networking.
- Host and guest diagnostic commands.
- Architecture, threat-model, compatibility, supply-chain, troubleshooting,
  security, contribution, and release documentation.
- Static test suite and GitHub Actions CI.

[Unreleased]: https://github.com/idosams/agent-devbox/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/idosams/agent-devbox/releases/tag/v0.1.0
