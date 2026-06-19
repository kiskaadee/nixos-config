# 💻 Laptop Machine Configuration
# This file defines host-specific system configurations for the Laptop environment.
# Sharing 100% of base shell, neovim, apps, and terminal settings with desktop,
# but swapping the graphical compositor stack to Niri.

{ config, lib, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../modules/system/base.nix # General hardware-agnostic OS settings
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
    ];
  };

  # Host-specific graphical compositor (Niri window manager for laptop)
  programs.niri.enable = true;

  # Override greetd to launch Niri compositor instead of Hyprland on the laptop
  services.greetd.settings.default_session.command = lib.mkForce "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session --asterisks --greeting '❄️ Declarative NixOS Workstation' --cmd niri";

  # Rebuild/State version. Do not modify.
  system.stateVersion = "26.05";
}
