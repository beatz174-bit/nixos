# Secrets Management

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) to manage sensitive
values such as GitHub tokens and user password hashes.

## Setup

1. Install `sops` and `age`.
2. Generate an `age` key:

   ```bash
   age-keygen -o age.key
   ```

   The command prints the public key; copy it into `.sops.yaml` under
   `age:`.

3. Encrypt secrets:

   ```bash
   sops secrets/nix.conf.sops
   sops secrets/root-password.sops
   sops secrets/nixos-password.sops
   ```

   Enter the GitHub token and password hashes when prompted.
4. Commit the encrypted `.sops` files but never commit the generated `age.key`.

## Rotating secrets

1. Update the secret value with `sops secrets/<file>.sops`.
2. Commit the changed encrypted file.
3. If keys change, run `sops updatekeys secrets/*.sops` to re-encrypt.

Decrypted files are placed in `/run/secrets` by `sops-nix` with permission `0400`
and are referenced from the NixOS configuration via `hashedPasswordFile` or
`home.file` source paths.
