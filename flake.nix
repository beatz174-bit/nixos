{
  description = "LAN NixOS configs";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-conf-editor.url = "github:snowfallorg/nixos-conf-editor";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-conf-editor, home-manager, ... } @ inputs:
    let system = "x86_64-linux"; in {
      nixosConfigurations = {
        # automatically use each host folder by name
        nixos    = nixpkgs.lib.nixosSystem {
                   inherit system;
                   modules = [
                     ./hosts/nixos/configuration.nix
                     ./common/hardware-configuration.nix
                     home-manager.nixosModules.home-manager {
                      home-manager.useGlobalPkgs = true;
                      home-manager.useUserPackages = true;
                      home-manager.users.nixos = import ./hosts/nixos/home.nix;
                      
                    }
                      import ./hosts/nixos/overlay.nix
                   ];
                  specialArgs = { inherit inputs; };
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

      };
    };
}
