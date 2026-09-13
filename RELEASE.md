# Release Checklist

## Repository setup

- [ ] Add the GitHub remote and protect the default branch.
- [ ] Require the CI workflow on pull requests.
- [ ] Enable private vulnerability reporting.
- [ ] Add a repository description, topics, and social preview if desired.

## Automated checks

- [ ] `make test` passes on macOS.
- [ ] GitHub Actions passes on Ubuntu and macOS.
- [ ] `git diff --check` is clean.
- [ ] No `state/`, private key, VM image, RDP file, credential, or personal path
      is tracked.

## Manual macOS matrix

- [ ] Fresh Apple-silicon host or clean test account.
- [ ] `make macos-install` installs or detects VirtualBuddy.
- [ ] `make macos-create` recommends sensible resources.
- [ ] Latest stable supported macOS guest installs successfully.
- [ ] `agent` is a Standard user and `vm-admin` is the only admin used here.
- [ ] Bootstrap succeeds twice to prove idempotence.
- [ ] ChatGPT, Codex CLI, Claude Desktop, Claude Code, and VS Code launch.
- [ ] `make macos-doctor HOST=...` passes.
- [ ] Shared folders, Guest App, clipboard, bridged network, audio input,
      camera, and USB remain disabled.
- [ ] Remote Login is off after validation.
- [ ] `DOCKER=remote` installs CLI, Compose, and Buildx without Docker Desktop
      or a local daemon socket.
- [ ] A remote Docker context, when tested, targets only a disposable worker
      and never the physical Mac or a production daemon.
- [ ] `PARALLEL=1` recommendations are checked on a host with at least 24 GB
      RAM while the intended second VM is running.

## Manual Ubuntu matrix

- [ ] Test at least one Apple-silicon Mac; test Intel when claiming it for the
      release.
- [ ] Cloud-init completes from a new Multipass instance.
- [ ] `make linux-doctor` passes.
- [ ] All three RDP sessions connect and show the expected identity/app.
- [ ] Agent users cannot read `dev` credentials or use sudo.
- [ ] SSH and RDP are reachable from the host but not the LAN.
- [ ] RFC 1918 and metadata egress policy behaves as documented.

## Tagging

- [ ] Update `VERSION` and move the changelog entries from Unreleased.
- [ ] Review all URLs and package names against `docs/SUPPLY_CHAIN.md`.
- [ ] Tag `vX.Y.Z` from a clean, reviewed commit.
- [ ] Publish release notes with security-impacting changes highlighted.
