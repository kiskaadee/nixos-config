# 🏠 Desktop Host-Specific Home Manager Configuration
# This module defines user-space environment configs unique to the desktop host.

{ config, pkgs, ... }:

{
  # Host-specific package installations for desktop (Hyprland environment only)
  home.packages = with pkgs; [
    grimblast   # Screenshot utility for Hyprland
    obs-studio  # High-feature video capture and streaming studio
    wf-recorder # Light recorder for Wayland-based window managers
  ];

  # Mount custom Hyprland and DankMaterialShell configuration files declaratively
  home.file.".config/hypr/hyprland.lua".source = ./config/hypr/hyprland.lua;
  home.file.".config/hypr/dms".source = ./config/hypr/dms;
  home.file.".config/hypr/scripts".source = ./config/hypr/scripts;
}
