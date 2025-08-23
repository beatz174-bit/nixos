{ config, lib, pkgs, ... }:

{
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      
    ];
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Australia/Brisbane";

  # Enable QEMU agent
  services.qemuGuest.enable = true;

    # Enable docker-compose
  environment.systemPackages = with pkgs; [
  vim
  btop
  git
  gcr
  ];
# #Set root password
#   sops.secrets.nixos-users-password = {
#     sopsFile = ../secrets/nixos-users-password.sops;
#   };
#   sops.secrets.openssh-authorised-keys = {
#     sopsFile = ../secrets/openssh-authorised-keys.sops;
#     owner = "nixos";
#   };

sops.defaultSopsFile = ../secrets.enc.yaml;
sops.secrets = {
  nixos-users-password = {};
  github-token = {};
};

# Derive Age keys from the host SSH key instead of a separate age.key
sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  users.mutableUsers = false;

  users.users.root.hashedPasswordFile = config.sops.secrets."nixos-users-password";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    hashedPasswordFile = config.sops.secrets."nixos-users-password";
    openssh.authorizedKeys.keyFiles = [
      ./nixos-authorized_keys
    ];
  };


  # Enable the OpenSSH daemon and ensure an Ed25519 host key exists.
  services.openssh = {
    enable = true;
    hostKeys = [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
  };

  #Enable flakes

  nix.settings.experimental-features = "nix-command flakes";

nix.settings = {
  substituters = [
    "http://nix-cache"
#    "https://cache.nixos.org/"
  ];
  trusted-public-keys = [
    "cache.local-1:usoWYanY3Kpq2+kDIS2nhWoLZiRxanmdysdzqCFBHW4="
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
};


  programs.git = {
    enable = true;
    package = pkgs.git;
    config = {
      credential.helper = "store";
    };
  };



}