{ config, pkgs, lib, ... }:

 {

  imports = [
    ./aliases.nix
  ];

  home.username = "nixos";         # your actual username
  home.homeDirectory = "/home/nixos";
  home.stateVersion = "25.05";        # match your NixOS stateVersion

  programs.home-manager.enable = true;  # mandatory to activate HM
  
programs.bash.enable = true;
  
  home.file = {
    ".config/nix/nix.conf".text = ''
      access-tokens = github.com=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
    '';
  };

  # Optional: packages
  home.packages = with pkgs; [
    git
    vim
    tmux
    nano
  ];

  # Optional: set environment vars
  home.sessionVariables = {
    EDITOR = "nano";
  };

  # Optional: enable bash (or zsh, fish...)
#  programs.bash.enable = true;

  # Optional: manage dotfiles via symlinks
#  home.file = {
#    ".tmux.conf".source = ./dotfiles/tmux.conf;
#    ".config/nvim/init.vim".source = ./dotfiles/init.vim;
#  };
}
