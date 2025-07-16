{ config, pkgs, lib, ... }:

{
  home.username = "nixos";         # your actual username
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "25.05";        # match your NixOS stateVersion

  programs.home-manager.enable = true;  # mandatory to activate HM

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
