# 💻 Laptop Machine Configuration
# This file defines host-specific system configurations for the Laptop environment.
# Sharing 100% of base shell, neovim, apps, and terminal settings with desktop,
# but swapping the graphical compositor stack to Niri.

{ config, lib, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../modules/system/graphical.nix # System-wide graphical stack settings (DMS daemon + greeter)
      ../../modules/system/base.nix      # General hardware-agnostic OS settings
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
  networking.hostName = "laptop";

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

  # Host-specific graphical compositor (Niri window manager for laptop)
  programs.niri.enable = true;

  # Dynamic binary execution support (for unpatched binaries, VS Code server, language servers)
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      glib
    ];
  };

  # 🔋 Laptop Power & Battery Management
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Backlight brightness control utility
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];

  # Rebuild/State version. Do not modify.
  system.stateVersion = "26.05";
}
