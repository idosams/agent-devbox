# Security Policy

## Supported versions

Until the first stable release, only the latest tagged `0.x` release and the
default branch receive security fixes.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability or publish guest
credentials, VM images, generated `state/` files, logs containing secrets, or
provider tokens.

Use the repository's private **Report a vulnerability** form under GitHub's
Security tab. Maintainers should enable private vulnerability reporting before
the repository is announced. If that channel is unavailable, contact a
maintainer privately and ask for a secure reporting method without including
exploit details in the first message.

Include:

- affected version or commit;
- host and guest OS versions and architecture;
- reproduction steps using non-sensitive test data;
- expected and observed boundary behavior;
- likely impact; and
- any suggested mitigation.

Maintainers should acknowledge a complete report within seven days, provide a
status update within fourteen days, and coordinate disclosure after a fix or
mitigation is available. These are targets, not guarantees.

## Scope

Security issues in this repository's scripts, generated configuration, or
documented isolation claims are in scope. Vulnerabilities in Apple,
VirtualBuddy, Multipass, Ubuntu, or vendor agent software should also be
reported to the relevant upstream project.
