{ config, pkgs, lib, ... }:

let
  mySwitchCmd = ''
    sudo nixos-rebuild switch \
      --no-write-lock-file \
      --refresh \
      --flake git+https://gitea.lan.ddnsgeek.com/beatzaplenty/nixos.git#$(hostname)
  '';
  myTestCmd = ''
    sudo nixos-rebuild switch \
      --no-write-lock-file \
      --refresh \
      --flake git+https://gitea.lan.ddnsgeek.com/beatzaplenty/nixos.git#$(hostname)
  '';
in {
  home.username = "nixos";         # your actual username
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "25.05";        # match your NixOS stateVersion

  programs.home-manager.enable = true;  # mandatory to activate HM
  programs.bash.enable = true;
    programs.bash.aliases = {
    "Switch-nix" = mySwitchCmd;
    "Test-nix" = myTestCmd;
  };

  
  # Optional: packages
  home.packages = with pkgs; [
    git
    vim
    tmux
  ];

  # Optional: set environment vars
  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Optional: enable bash (or zsh, fish...)
  programs.bash.enable = true;

  # Optional: manage dotfiles via symlinks
#  home.file = {
#    ".tmux.conf".source = ./dotfiles/tmux.conf;
#    ".config/nvim/init.vim".source = ./dotfiles/init.vim;
#  };
}
