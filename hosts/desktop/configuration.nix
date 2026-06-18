{ config, lib, pkgs, ... }:

{
  imports = [
      ./hardware-configuration.nix
      ../../modules/system/graphical.nix
      ../../modules/system/base.nix # Injected Base OS Settings
    ];

  nix.settings.experimental-features = ["nix-command" "flakes" ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop";

  users.users.kiskaadee = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
  };

  programs = {
    hyprland.enable = true;
  };

  system.stateVersion = "26.05";
}
