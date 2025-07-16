# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

let
  pythonEnv = pkgs.python3.withPackages (ps: with ps; [
    docker
    pytz
  ]);
in

{
  imports =
    [ # Include the results of the hardware scan.
      ../../common/configuration.nix
    ];

  networking.hostName = "docker"; # Define your hostname.
  virtualisation.docker.enable = true;

  # Enable docker-compose
  environment.systemPackages = with pkgs; [
  docker-compose
  ];

  # Mount docker persistent data
  fileSystems."/mnt/docker-persistent-data" = {
    device = "/dev/disk/by-label/docker-data";
    fsType = "ext4";
    options = [ "defaults" "nofail" "noatime" ];
  };

# Create nextcloud cron scheduled task
systemd.services.nextcloud = {
  description = "Nextcloud scheduled task";
  script = ''docker-compose -f ~/docker/nextcloud/docker-compose.yml exec -u 33 webapp php ./cron.php'';
  serviceConfig = {
    Type = "oneshot";
    User = "nixos";
  };
  path = with pkgs; [ docker docker-compose ];
};

systemd.timers.nextcloud = {
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnCalendar = "*:0/5";
    Persistent = true;
  };
};

# create update task

  systemd.services.update-containers = {
    description = "Update Docker Compose Containers";
    after = [ "docker.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "nixos";
      WorkingDirectory = "/home/nixos/docker";
      ExecStart = "${pythonEnv}/bin/python3 /home/nixos/docker/update-containers.py";
      StandardOutput = "journal";
      StandardError = "journal";
    };

    path = [ pkgs.docker pkgs.docker-compose ]; # Ensures docker CLI is available in $PATH
  };


systemd.timers.update-containers = {
  description = "Weekly + Reboot container update";
  wantedBy = [ "timers.target" ];
  timerConfig = {
    OnBootSec = "5min";           # Run 5 minutes after boot
    OnUnitActiveSec = "1w";       # Run every week after last run
    Persistent = true;            # Catch up if system was off
  };
};

#Add sym links to data on users home folder
system.userActivationScripts.createDockerSymlink.text = ''
  ln -sf /mnt/docker-persistent-data/docker /home/nixos/docker
'';
system.userActivationScripts.createSetupSymlink.text = ''
  ln -sf /mnt/docker-persistent-data/setup /home/nixos/setup
'';

  users.users.nixos.extraGroups = [ "docker" ];
  services.openssh.settings.PermitRootLogin = "yes";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 8080 443 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
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
