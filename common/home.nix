{ config, pkgs, lib, ... }:

let
  remote = "root@proxmox-ip:/var/lib/vz/template/iso";
  localMount = "${config.home.homeDirectory}/proxmox-iso";
in {

  imports = [
    ./aliases.nix
  ];

  home.username = "nixos";         # your actual username
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "25.05";        # match your NixOS stateVersion

  programs.home-manager.enable = true;  # mandatory to activate HM

# Derive Age keys from the host SSH key
sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

programs.bash.enable = true;
  
  sops.secrets.nix_conf = {
    sopsFile = ../secrets/nix.conf.sops;
    owner = config.home.username;
    mode = "0400";
  };

  home.file = {
    ".config/nix/nix.conf".source = config.sops.secrets.nix_conf.path;
  };

  # Optional: packages
  home.packages = with pkgs; [
    git
    vim
    tmux
    nano
    sshfs
  ];

  # Optional: set environment vars
  home.sessionVariables = {
    EDITOR = "nano";
  };
  systemd.user.services.mount-proxmox-iso = {
    Unit = {
      Description = "Mount Proxmox ISO dir via SSHFS";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };

    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${localMount}";
      ExecStart = "${pkgs.sshfs}/bin/sshfs -o IdentityFile=${config.home.homeDirectory}/.ssh/id_ed25519,allow_other,reconnect,ServerAliveInterval=15,ServerAliveCountMax=3 root@proxmox-ip:/var/lib/vz/template/iso ${localMount}";
      ExecStop = "${pkgs.fuse3}/bin/fusermount3 -u ${localMount}";
      Restart = "on-failure";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
  # Optional: enable bash (or zsh, fish...)
#  programs.bash.enable = true;

  # Optional: manage dotfiles via symlinks
#  home.file = {
#    ".tmux.conf".source = ./dotfiles/tmux.conf;
#    ".config/nvim/init.vim".source = ./dotfiles/init.vim;
#  };
}
