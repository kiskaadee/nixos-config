# 🏠 Desktop Host-Specific Home Manager Configuration
# This module defines user-space environment configs unique to the desktop host.

{ config, pkgs, ... }:

{
  # Mount custom Hyprland and DankMaterialShell configuration files declaratively
  home.file.".config/hypr/hyprland.lua".source = ./config/hypr/hyprland.lua;
  home.file.".config/hypr/dms".source = ./config/hypr/dms;
}
