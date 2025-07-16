# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs,... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ../../common/configuration.nix
    ];

  networking.hostName = "server"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Mount server data
  fileSystems."/srv" = {
    device = "/dev/disk/by-label/server-data";
    fsType = "ext4";
    options = [ "defaults" ];
  };

  fileSystems."/backup" = {
    device = "/dev/disk/by-label/backup-data";
    fsType = "ext4";
    options = [ "defaults" ];
  };

#Add sym links to data on users home folder
system.userActivationScripts.createDockerSymlink.text = ''
  ln -sf /srv/scripts /home/nixos/scripts
'';
#system.userActivationScripts.createSetupSymlink.text = ''
#  ln -sf /mnt/docker-persistent-data/setup /home/nixos/setup
#'';

services.nfs.server = {
  enable = true;
  exports = ''
    /srv/ 192.168.2.0/24(rw,sync,no_subtree_check)
    /backup 	192.168.2.0/24(rw,sync,no_subtree_check)
  '';
};

  security.sudo = {
    enable = true;
    extraRules = [
      {
        users = [ "nixos" ];
        commands = [
          {
            command = "/run/current-system/sw/bin/rsync";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };


  systemd.services.backup = {
    description = "Backup data";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
#      WorkingDirectory = "/home/nixos/scripts";
      ExecStart = "${pkgs.bash}/bin/bash -e /srv/scripts/rsync.sh";
      StandardOutput = "journal";
      StandardError = "journal";
    };
path = with pkgs; [ bash rsync openssh coreutils ];
  };


systemd.timers.backup = {
  description = "Daily backup";
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnUnitActiveSec = "1d";       # Run every day after last run
    Persistent = true;            # Catch up if system was off
  };
};

  services.openssh.settings.PermitRootLogin = "yes";
  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 2049 ];
#  networking.firewall.allowedUDPPorts = [ 111 2049 20048 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.sta>
  system.stateVersion = "25.05"; # Did you read the comment?
}
