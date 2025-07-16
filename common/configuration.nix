{ config, lib, pkgs, ... }:

{
    imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      
    ];
  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Australia/Brisbane";

  # Enable QEMU agent
  services.qemuGuest.enable = true;

    # Enable docker-compose
  environment.systemPackages = with pkgs; [
  vim
  btop
  git
  ];
#Set root password
users.users.root = {
  hashedPassword = "$6$Kwv9KAyvcurAViQF$H4.u3feqGE7lVoNgkFXhE3n2Pmo//9JYDTCz8ifrVHBxPjwa1xMby7tEZ8Bpt5MXs9Rkx6/YbZWxs5CpH0s/70";
};

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
    hashedPassword = "$6$Kwv9KAyvcurAViQF$H4.u3feqGE7lVoNgkFXhE3n2Pmo//9JYDTCz8ifrVHBxPjwa1xMby7tEZ8Bpt5MXs9Rkx6/YbZWxs5CpH0s/70";
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCq/Q5LvIXlZwO2kdeAN5nLGZ59nZB7JHYMEszHxmNtGMzv1lM31jiPNsr0z2EKVZhE7OOfa2IF9rhWYD7JUA9G0yzdZ4WTXFNGVVOJoOVH6vAF3XCxoVilOEwTc7h2Wiy+rzd0B28/3spffzQQWJhY6GRQVa8j+6xAGF60Fcvl1vLosYT9Bn2ZbK4TCWOwAn2jqXIieGpZdn/UNZbGOeKRiCvhktDfMAzuQzN/9jMu/oF4pkPn2X1UrsQdNlvp0Ci8md612MozIpncQJyAF1ADhunr3sMx0isUXiqD29R5DS4TftpekqLNLak+zcxFa8N7DcRNp3DcKfJvyTkwQrR4r+b7lFLYOLHLagSso9CzeW/paAS2q9I5SBm/2DtE1diLLg2jZikYcstsu/G5RgvbzbKqjiaMwTdXC3AMvDxQrs7U5pDRZFzoofG3cpODbTm+uy3m0kP70z0M1K45UbDG0p+itnTu9x40JbQEgefbx38AItNvAIx1A8HO4I1VX28= wayne@stream"
  ];
  };


  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  #Enable flakes

  nix.settings.experimental-features = "nix-command flakes";

nix.settings = {
  substituters = [
    "http://nix-cache"
    "https://cache.nixos.org/"
  ];
  trusted-public-keys = [
    "nix-ccache-1:<base32‑pubkey‑hash‑from‑cache-pub.pem>"
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  ];
};

{
  programs.git = {
    enable = true;
    package = pkgs.git.override { withLibsecret = true; };
    extraConfig = {
      credential.helper = "libsecret";
    };
  };
}


}