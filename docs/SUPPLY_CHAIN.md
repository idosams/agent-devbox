# Supply-chain Policy

Agent Devbox is configuration and orchestration code. It does not redistribute
macOS, Ubuntu, VirtualBuddy, or vendor agent applications.

## Download paths

| Component | Installation path | Verification |
| --- | --- | --- |
| macOS restore image | VirtualBuddy catalog backed by Apple restore images | Apple Virtualization framework validates compatibility |
| VirtualBuddy | Homebrew cask | Homebrew checksum and macOS code signing |
| Homebrew | Official `Homebrew/install` script | HTTPS; review upstream before unattended use |
| ChatGPT desktop | Homebrew cask fetching the vendor artifact | Homebrew checksum, Gatekeeper, expected OpenAI Team ID |
| Codex CLI | `https://chatgpt.com/codex/install.sh` | Official OpenAI installer over TLS |
| Claude Desktop/Code | Homebrew casks or Anthropic apt repository | Homebrew checksum/code signing or pinned apt signing-key fingerprint |
| Ubuntu | Multipass image catalog | Multipass/Canonical image verification |
| Gemini and Copilot CLIs | npm registry | Package-manager integrity metadata |
| Optional Docker CLI/Compose/Buildx | Homebrew formulae | Homebrew bottle checksums; no daemon installed |

## Rolling versus pinned inputs

The repository pins its own release but intentionally follows stable upstream
channels for operating-system and agent updates. A build performed later can
therefore install newer vendor binaries than an earlier build from the same
tag. This is a maintainability choice, not bit-for-bit reproducibility.

The Ubuntu Anthropic signing-key fingerprint is pinned in cloud-init. Other
rolling downloads rely on TLS, package-manager integrity checks, and platform
code signing. Contributors should not add `curl | shell`, new apt keys, npm
packages, GitHub Actions, or binary downloads without documenting provenance,
integrity controls, and the reason a stable package channel is insufficient.

## Release review

Before tagging a release:

1. Inspect every URL and package name in `cloud-init.yaml.tmpl` and `macos/`.
2. Confirm official vendor documentation still recommends each path.
3. Verify code signatures in a clean guest.
4. Review new transitive package-manager behavior.
5. Record meaningful changes in `CHANGELOG.md`.

Never commit downloaded VM images, application bundles, generated SSH keys,
RDP profiles, credentials, or `state/` contents.
