# 🏠 Laptop Host-Specific Home Manager Configuration
# This module defines user-space environment configs unique to the laptop host.

{ config, pkgs, ... }:

{
  # Host-specific package installations for laptop workstation
  home.packages = with pkgs; [
    obs-studio  # High-feature video capture and streaming studio
    wf-recorder # Light recorder for Wayland-based window managers
  ];

  # Niri WM declarative configuration files
  home.file.".config/niri/config.kdl".source = ../../modules/user/config/niri/config.kdl;
  home.file.".config/niri/custom.kdl".source = ../../modules/user/config/niri/custom.kdl;
}
