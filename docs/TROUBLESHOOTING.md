# Troubleshooting

## VirtualBuddy does not open

Run `make macos-doctor`. If the app is missing, rerun `make macos-install`.
On managed Macs, installing an app under `/Applications` may require an
administrator's approval.

## The macOS restore fails

- Use the latest stable restore image VirtualBuddy marks as supported.
- Update the host OS and VirtualBuddy, then retry.
- Confirm at least 100 GB is free on the volume containing the VM library.
- Do not use a beta guest unless you have reviewed VirtualBuddy's release notes
  and Apple's device-support requirements.

## `ipconfig getifaddr en0` prints nothing

Run `ifconfig` inside the guest and find the private address on the active
interface. Confirm the VM uses shared/NAT networking. Bridged networking is not
part of the supported security profile.

## SSH reports a changed host key

If the VM was deliberately rebuilt, remove only its old entry from the
project-local known-hosts file:

```bash
ssh-keygen -R VM_IP -f state/macos_known_hosts
```

Then compare the new fingerprint with
`ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub` inside the guest. Do not
blindly delete the entire known-hosts file after an unexpected warning.

## Bootstrap stops for Command Line Tools

Approve the Apple installer dialog inside the guest, wait until it completes,
then rerun `make macos-bootstrap HOST=VM_IP`. The provisioner is idempotent.

## Homebrew reports an existing application

Remove manually installed copies from the guest only after confirming they do
not contain data you need. Do not use `--force` as a routine workaround.

## Guest doctor needs a password

Live checks inspect another user's protected configuration and therefore need
the `vm-admin` password. Remote Login should be enabled only for the duration of
the check and disabled immediately afterward.

## Ubuntu GUI does not connect

1. Run `make linux-doctor`.
2. Confirm the VM is running with `multipass info agent-devbox`.
3. Regenerate the RDP file with `make linux-gui SESSION=dev`.
4. Compare the displayed TLS fingerprint before accepting a new certificate.

Generated connection files and keys live in ignored `state/`; never attach that
directory to an issue.

## Account compromise

Stop the VM, revoke provider sessions remotely, rotate exposed secrets, inspect
remote activity, and rebuild from a clean unauthenticated image. Deleting the
VM does not revoke a remote session.
