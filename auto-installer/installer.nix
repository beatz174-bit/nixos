{ lib, pkgs, modulesPath, config, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  networking.useDHCP = lib.mkDefault true;
  time.timeZone = "Australia/Brisbane";

  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  environment.systemPackages = with pkgs; [
    git curl parted e2fsprogs btrfs-progs util-linux
  ];

  environment.etc."flake-url".text = "git+https://gitea.lan.ddnsgeek.com/beatzaplenty/nixos.git?ref=main#nixos";   

environment.etc."git-credentials".text = 
  "https://beatzaplenty:2b7e178eeee4af437fc721295d59e9e19366fd02@gitea.lan.ddnsgeek.com";
#programs.git.enable = true;
#programs.git.extraConfig."credential.helper" = "store --file=/etc/git-credentials";
  programs.git = {
    enable = true;
    package = pkgs.git;
    config = {
      credential.helper = "store --file=/etc/git-credentials";
    };
  };

  # Write auto-install script to /root
  environment.etc."auto-install.sh".text = ''
    #!/run/current-system/sw/bin/bash
    set -eux

    mkdir -p /mnt/install-tmp
    export TMPDIR=/mnt/install-tmp

    parted -s /dev/sda -- mklabel msdos
    parted -s /dev/sda -- mkpart primary 1MB -8GB
    parted -s /dev/sda -- set 1 boot on
    parted -s /dev/sda -- mkpart primary linux-swap -8GB 100%
    mkfs.ext4 -L nixos /dev/sda1
    mkswap -L swap /dev/sda2
    swapon /dev/sda2
    mount /dev/disk/by-label/nixos /mnt

    nixos-install --flake "$(cat /etc/flake-url)" --no-root-password --no-write-lock-file
    rm -rf /mnt/install-tmp
    sleep 10
    reboot
  '';
  environment.etc."auto-install.sh".mode = "0755";

  # systemd.services.autoInstallInteractive = {
  #   description = "Interactive NixOS installer on tty1";
  #   conflicts = [ "getty@tty1.service" ];
  #   after = [ "getty@tty1.service" ];
  #   wantedBy = [ "multi-user.target" ];

  #   serviceConfig = {
  #     Type = "simple";
  #     StandardInput = "tty";
  #     StandardOutput = "inherit";
  #     TTYPath = "/dev/tty1";
  #     TTYReset = true;
  #     TTYVHangup = true;
  #   };

systemd.services."autovt@tty1" = {
  description = "Run installer script on TTY1";
  after = [ "getty@tty1.service" ];
  wantedBy = [ "multi-user.target" ];

  serviceConfig = {
    ExecStart = [ "" "@${pkgs.util-linux}/sbin/agetty" "agetty --noclear --autologin root --login-program /etc/auto-install.sh %I $TERM" ];
    Type = "idle";  # wait for console initialization
    Restart = "no";
  };


    path = [
      pkgs.bash
      pkgs.parted
      pkgs.util-linux
      pkgs.e2fsprogs
      pkgs.nixos-install
      pkgs.git
    ];
    # Run script attached to tty1
#    script = "exec /etc/auto-install.sh";
  };
  # systemd.services.autoInstall = {
  #   description = "Automatic NixOS installation";
  #   wantedBy = [ "multi-user.target" ];
  #   after = [ "network-online.target" ];
  #   path = [
  #     pkgs.parted
  #     pkgs.util-linux
  #     pkgs.e2fsprogs
  #     pkgs.nixos-install
  #     pkgs.nix
  #     pkgs.git
  #     pkgs.bash
  #   ];    
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = pkgs.writeShellScript "auto-install.sh" ''
  #       set -eux
  #       #create MBR table
  #       parted /dev/sda -- mklabel msdos
  #       #create nixos partition
  #       parted /dev/sda -- mkpart primary 1MB -8GB
  #       #set nixos partition to bootable
  #       parted /dev/sda -- set 1 boot on
  #       # create swap partition
  #       parted /dev/sda -- mkpart primary linux-swap -8GB 100%

  #       #format OS partition
  #       mkfs.ext4 -L nixos /dev/sda1
  #       #format swap
  #       mkswap -L swap /dev/sda2

  #       #activate swap
  #       swapon /dev/sda2

  #       #mount nixos partition
  #       mount /dev/disk/by-label/nixos /mnt
  #     # Choose a disk-backed temp directory
  #       mkdir -p /mnt/install-tmp
  #       export TMPDIR=/mnt/install-tmp

  #       nixos-install --flake "$(cat /etc/flake-url)" --no-root-password --no-write-lock-file
  #       rm -r /mnt/install-tmp
  #       sleep 10
  #       reboot
  #     '';
  #   };  
  # };
}
