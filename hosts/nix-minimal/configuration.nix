# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../../common/configuration.nix
    ];

  networking.hostName = "nix-minimal"; # Define your hostname.

  environment.systemPackages = with pkgs; [
    sshfs
    fuse3 # needed for modern sshfs
  ];

  # Enable FUSE (if not already)
  boot.extraModprobeConfig = ''
    options fuse user_allow_other
  '';

  # Allow mounting with user permissions (optional, see note)
  security.wrappers.sshfs = {
    source = "${pkgs.sshfs}/bin/sshfs";
    owner = "nixos";
    group = "users";
    permissions = "4755";
  
  fileSystems."/mnt/proxmox-iso" = {
    device = "root@pve:/var/lib/vz/template/iso";
    fsType = "fuse.sshfs";
    options = [
      "IdentityFile=/home/nixos/.ssh/id_ed25519.pub"   # or your SSH key path
      "allow_other"
      "reconnect"
      "ServerAliveInterval=15"
      "ServerAliveCountMax=3"
      "StrictHostKeyChecking=no"         # only if you're OK with this
    ];
  };
  };


  # Open ports in the firewall.
#  networking.firewall.allowedTCPPorts = [ 80 8080 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.sta>
  system.stateVersion = "25.05"; # Did you read the comment?
}
