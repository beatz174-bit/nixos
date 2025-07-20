# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs,... }:
let
    nixosConfEditor = builtins.getFlake "github:snowfallorg/nixos-conf-editor";
in {
#{
    environment.systemPackages = with pkgs; [
      inputs.nixos-conf-editor.packages.${pkgs.system}.nixos-conf-editor
      nodejs
      appimage-run
      seahorse
      vscode
    ];



  imports =
    [ # Include the results of the hardware scan.
      ../../common/configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;
#  services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
#  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  users.users.nixos.extraGroups = [ "networkmanager" ]; # Enable ‘sudo’ for the user.

  # Install firefox.
  programs.firefox.enable = true;

  system.stateVersion = "25.05"; # Did you read the comment?


  nix.settings.experimental-features = "nix-command flakes";
services.xrdp.enable = true;
services.xrdp.defaultWindowManager = "cinnamon-session";
services.xrdp.openFirewall = true;
nixpkgs.config.allowUnfree = true;

services.gnome.gnome-keyring.enable = true;

# security.pam.services.lightdm.enableGnomeKeyring = true;

# services.gnome.gnome-keyring.enable = true;
security.pam.services.login.enableGnomeKeyring = true;
# systemd.services.nextcloud-appimage = {
#   enable = true;
#   Unit = {
#     Description = "Nextcloud AppImage client";
#     After = [ "graphical-session.target" ];
#     Wants = [ "graphical-session.target" ]; # optional but helpful
#   };
#   Service = {
#     ExecStart = "/run/current-system/sw/bin/appimage-run /home/nixos/Applications/Nextcloud.AppImage --background";
#     Restart = "on-failure";
#     # You can add RestartSec = "5s"; if you like
#   };
#   Install = {
#     WantedBy = [ "default.target" ];
#   };
# };

}
