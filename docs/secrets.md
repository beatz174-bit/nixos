# Secrets Management

This repository uses [sops-nix](https://github.com/Mic92/sops-nix) to manage sensitive
values such as GitHub tokens and user password hashes.

## Setup

1. Install `sops` and `age`.
2. Derive the Age key from the host's SSH key by adding to your NixOS configuration:

   ```nix
   sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
   services.openssh = {
     enable = true;
     hostKeys = [{
       path = "/etc/ssh/ssh_host_ed25519_key";
       type = "ed25519";
     }];
   };
   ```

   This ensures an Ed25519 host key is generated if it does not already exist.
   To manually create one:

   ```bash
   sudo ssh-keygen -t ed25519 -N '' -f /etc/ssh/ssh_host_ed25519_key
   ```

3. Encrypt secrets:

   ```bash
   sops secrets/nix.conf.sops
   sops secrets/root-password.sops
   sops secrets/nixos-password.sops
   ```

   Enter the GitHub token and password hashes when prompted.
4. Commit the encrypted `.sops` files. The host's SSH key stays on the machine and is not committed.

## Rotating secrets

1. Update the secret value with `sops secrets/<file>.sops`.
2. Commit the changed encrypted file.
3. If keys change, run `sops updatekeys secrets/*.sops` to re-encrypt.

Decrypted files are placed in `/run/secrets` by `sops-nix` with permission `0400`
and are referenced from the NixOS configuration via `hashedPasswordFile` or
`home.file` source paths.
