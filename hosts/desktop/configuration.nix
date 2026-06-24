# 🖥️ Desktop Machine Configuration
# This file defines host-specific system configurations for the Desktop environment.

{ config, lib, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix        # Desktop-specific disk and CPU configuration
      ../../modules/system/graphical.nix  # System-wide graphical stack settings (DMS daemon)
      ../../modules/system/base.nix       # General hardware-agnostic OS settings
      ./dynu.nix                          # Dynu DDNS update service
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
    ];
  };

  # Host-specific graphical compositor (Hyprland window manager for desktop)
  programs = {
    hyprland.enable = true;
  };

  # Rebuild/State version. Do not modify.
  system.stateVersion = "26.05";
}
