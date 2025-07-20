# flake.nix
{
  description = "Auto-install NixOS ISO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators.url = "github:nix-community/nixos-generators";
  };

  outputs = { self, nixpkgs, flake-utils, nixos-generators, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        iso = nixos-generators.nixosGenerate {
          inherit system;
          format = "install-iso";
          modules = [ ./installer.nix ];
        };
      in {
        packages.default = iso;
      });
}
