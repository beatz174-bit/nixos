{
  description = "LAN NixOS configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-conf-editor.url = "github:snowfallorg/nixos-conf-editor";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    winapps = {
      url = "github:winapps-org/winapps/feat-nix-packaging";
      flake = true;
    };
  };

  outputs = { self, nixpkgs, home-manager, winapps, ... } @ inputs:
    let system = "x86_64-linux"; in
    {
      nixConfig = {
        access-tokens = [
          "github.com=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"
        ];
      };

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };

          modules = [
            ./hosts/nixos/configuration.nix
            ./common/hardware-configuration.nix
            inputs.winapps.nixosModule

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nixos = import ./hosts/nixos/home.nix;
            }

            # Inline module to configure winapps and VM backend
            ({ config, pkgs, lib, inputs, ... }:
              {
                environment.systemPackages = with pkgs; [
                  inputs.winapps.packages.${system}.winapps
                  inputs.winapps.packages.${system}.winapps-launcher
                  freerdp
                ];

                services.libvirtd.enable = true;

                # Optionally, enable docker/podman container support
                # virtualisation.oci-containers.backend = "docker";
              })
          ];
        };

        docker = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/docker/configuration.nix
            ./common/hardware-configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nixos = import ./common/home.nix;
            }
          ];
        };

        server = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/server/configuration.nix
            ./common/hardware-configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nixos = import ./common/home.nix;
            }
          ];
        };

        "nix-cache" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/nix-cache/configuration.nix
            ./common/hardware-configuration.nix
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.nixos = import ./common/home.nix;
            }
          ];
        };
      };
    };
}
