# 🖥️ Desktop Machine Configuration
# This file defines host-specific system configurations for the Desktop environment.

{ config, lib, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix        # Desktop-specific disk and CPU configuration
      ../../modules/system/graphical.nix  # System-wide graphical stack settings (DMS daemon)
      ../../modules/system/base.nix       # General hardware-agnostic OS settings
      ./dynu.nix                          # Dynu DDNS update service
      ./traefik-deployments.nix           # Traefik deployments secrets module
      ./homeserver.nix                    # Homeserver core services module
    ];

  # Enable experimental Nix features (required for Flakes and newer command line tools)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System-wide fonts installed for general window manager / applications
  fonts.packages = with pkgs; [
    inter
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ];

  # Configure default fonts for system-wide alias fallbacks
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "Fira Code" ];
      sansSerif = [ "Inter" ];
    };
  };

  # EFI bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network identification
  networking.hostName = "desktop";

  # Define the main user profile
  users.users.kiskaadee = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel"           # Enable sudo access for administrative tasks
      "docker"          # Allows running docker commands without sudo
      "networkmanager"  # Allows modifying network configurations
      "lp"              # Allows managing printers and print jobs
      "scanner"         # Allows access to scanners
    ];
  };

  # Host graphical compositors (Niri as primary, Hyprland as secondary/fallback)
  programs = {
    niri.enable = true;
    hyprland.enable = true;
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        zlib
        glib
      ];
    };
  };

  # Specialisation for headless server mode
  specialisation.server.configuration = {
    # 1. Disable display manager and window manager
    services.greetd.enable = lib.mkForce false;
    programs.niri.enable = lib.mkForce false;
    programs.hyprland.enable = lib.mkForce false;
    programs.dms-shell.enable = lib.mkForce false;
    programs.dms-greeter.enable = lib.mkForce false;
    programs.dank-calendar.enable = lib.mkForce false;

    # 2. Disable peripheral hardware services to reduce power consumption
    services.pipewire.enable = lib.mkForce false;
    services.printing.enable = lib.mkForce false;
    hardware.bluetooth.enable = lib.mkForce false;
    services.blueman.enable = lib.mkForce false;

    # 3. Disable power-saving suspend/sleep/hibernate behaviors to keep server active
    systemd.targets.sleep.enable = lib.mkForce false;
    systemd.targets.suspend.enable = lib.mkForce false;
    systemd.targets.hibernate.enable = lib.mkForce false;
    systemd.targets.hybrid-sleep.enable = lib.mkForce false;

    # 4. Enable active kernel-level power management tuning
    powerManagement.powertop.enable = lib.mkForce true;
  };

  # Rebuild/State version. Do not modify.
  system.stateVersion = "26.05";
}
