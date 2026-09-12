# Contributing

Contributions that improve isolation, portability, diagnostics, documentation,
or provider compatibility are welcome.

## Before opening a change

For security-sensitive behavior, open an issue describing the proposed threat
and control before implementing a large redesign. Report vulnerabilities
privately according to [SECURITY.md](SECURITY.md).

## Development setup

The repository uses Bash, GNU Make, Ruby's standard YAML parser, and
ShellCheck. No VM is needed for static tests.

```bash
make test
make lint
```

On macOS, install ShellCheck with `brew install shellcheck`. On Ubuntu, use
`sudo apt-get install shellcheck ruby`.

## Change rules

- Preserve `set -euo pipefail` in executable Bash scripts.
- Quote expansions and validate user-controlled names, hosts, and numeric
  settings before passing them to system tools.
- Never mount or copy a host credential location in a default profile.
- Keep network and device sharing opt-in and document the risk.
- Add a test for every bug fix or meaningful command-path change.
- Document every new download in `docs/SUPPLY_CHAIN.md`.
- Prefer official vendor repositories or installers and verify signing keys,
  checksums, or code signatures where available.
- Do not commit generated `state/`, VM bundles, RDP files, private keys,
  credentials, or downloaded application artifacts.

## Pull requests

Keep changes focused. Explain the threat-model impact, platforms tested,
manual VM testing performed, and any new network/download behavior. Update
`CHANGELOG.md` for user-visible changes.

By contributing, you agree that your contribution is licensed under the MIT
license in this repository.
