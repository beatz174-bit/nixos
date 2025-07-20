{ config, pkgs, lib, ... }:

let
  mySwitchCmd = ''
    sudo nixos-rebuild switch \
      --no-write-lock-file \
      --refresh \
      --flake git+https://gitea.lan.ddnsgeek.com/beatzaplenty/nixos.git#$(hostname)
  '';
  myTestCmd = ''
    sudo nixos-rebuild test \
      --no-write-lock-file \
      --refresh \
      --flake git+https://gitea.lan.ddnsgeek.com/beatzaplenty/nixos.git#$(hostname)
  '';
in {
  programs.bash = {
    enable = true;
    shellAliases = {
      "Switch-nix" = mySwitchCmd;
      "Test-nix" = myTestCmd;
    };
  };
}
