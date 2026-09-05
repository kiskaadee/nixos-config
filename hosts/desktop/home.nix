# 🏠 Desktop Host-Specific Home Manager Configuration
# Graphical workstation environment for legacy desktop host.

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/user/apps.nix
    ../../modules/user/graphical.nix
  ];

  # Host-specific package installations for desktop (Hyprland environment)
  home.packages = with pkgs; [
    grimblast   # Screenshot utility for Hyprland
  ];

  # Mount custom Hyprland and DankMaterialShell configuration files declaratively
  home.file.".config/hypr/hyprland.lua".source = ./config/hypr/hyprland.lua;
  home.file.".config/hypr/dms".source = ./config/hypr/dms;
  home.file.".config/hypr/scripts".source = ./config/hypr/scripts;
}
