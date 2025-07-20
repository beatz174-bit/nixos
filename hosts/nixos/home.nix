{ config, pkgs, lib, ... }:

{

    imports = [
    ../../common/aliases.nix
  ];

  home.username = "nixos";         # your actual username
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "25.05";        # match your NixOS stateVersion

  programs.home-manager.enable = true;  # mandatory to activate HM

  # Optional: packages
  home.packages = with pkgs; [
    git
    vim
    tmux
    nextcloud-client
  ];

  # Optional: set environment vars
  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Optional: enable bash (or zsh, fish...)
  programs.bash.enable = true;
    services.nextcloud-client = {
    enable = true;
    # Optionally start in background directly
    startInBackground = true;
  };

}