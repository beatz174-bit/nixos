{ lib, pkgs, modulesPath, config, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  networking.useDHCP = lib.mkDefault true;
  time.timeZone = "Australia/Brisbane";

  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

  environment.systemPackages = with pkgs; [
    git curl parted e2fsprogs btrfs-progs util-linux
  ];

  environment.etc."flake-url".text = "git+https://gitea.lan.ddnsgeek.com/beatzaplenty/nixos.git#nixos";

  systemd.services.autoInstall = {
    description = "Automatic NixOS installation";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "auto-install.sh" ''
        set -eux
        #create MBR table
        parted /dev/sda -- mklabel msdos
        #create nixos partition
        parted /dev/sda -- mkpart primary 1MB -8GB
        #set nixos partition to bootable
        parted /dev/sda -- set 1 boot on
        # create swap partition
        parted /dev/sda -- mkpart primary linux-swap -8GB 100%

        #format OS partition
        mkfs.ext4 -L nixos /dev/sda1
        #format swap
        mkswap -L swap /dev/sda2

        #activate swap
        swapon /dev/sda2

        #mount nixos partition
        mount /dev/disk/by-label/nixos /mnt
        nixos-install --flake "$(cat /etc/flake-url)" --no-root-password
        sleep 10
        reboot
      '';
    };
  };
}
