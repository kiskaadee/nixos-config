# 🌐 Server Machine Configuration (Headless Homelab Node)
# This file defines host-specific system configurations for the dedicated Server environment.

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix        # Server-specific disk and CPU configuration
    ../../modules/system/base.nix       # General hardware-agnostic OS settings
    ./dynu.nix                          # Dynu DDNS update service
    ./traefik-deployments.nix           # Traefik deployments secrets module
    ./homeserver.nix                    # Homeserver core services module
  ];

  # Enable experimental Nix features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # System-wide fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-mono
    inter
  ];

  # Configure default fonts
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "FiraCode Nerd Font" "JetBrainsMono Nerd Font" "Fira Code" ];
      sansSerif = [ "Inter" ];
    };
  };

  # Console font for local TTY screen
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # EFI bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Network identification
  networking.hostName = "server";

  # Define the main user profile
  users.users.kiskaadee = {
    isNormalUser = true;
    extraGroups = [ 
      "wheel"           # Enable sudo access
      "docker"          # Allows running docker commands without sudo
      "networkmanager"  # Allows modifying network configurations
    ];
  };

  # Dynamic binary execution support
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      glib
    ];
  };

  # Headless Server Optimizations:
  # Disable peripheral hardware & desktop services
  services.pipewire.enable = lib.mkForce false;
  services.printing.enable = lib.mkForce false;
  hardware.bluetooth.enable = lib.mkForce false;
  services.blueman.enable = lib.mkForce false;
  services.greetd.enable = lib.mkForce false;

  # Disable power-saving suspend/sleep/hibernate behaviors to keep homelab always active
  systemd.targets.sleep.enable = lib.mkForce false;
  systemd.targets.suspend.enable = lib.mkForce false;
  systemd.targets.hibernate.enable = lib.mkForce false;
  systemd.targets.hybrid-sleep.enable = lib.mkForce false;

  # Kernel-level power management tuning
  powerManagement.powertop.enable = true;

  # Rebuild/State version. Do not modify.
  system.stateVersion = "26.05";
}
