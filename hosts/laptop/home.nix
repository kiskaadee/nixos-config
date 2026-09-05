# 🏠 Laptop Host-Specific Home Manager Configuration
# Graphical workstation environment for Niri-powered mobile laptop.

{ config, pkgs, ... }:

{
  imports = [
    ../../modules/user/apps.nix
    ../../modules/user/graphical.nix
  ];



  # Niri WM declarative configuration files
  home.file.".config/niri/config.kdl".source = ../../modules/user/config/niri/config.kdl;
  home.file.".config/niri/custom.kdl".source = ../../modules/user/config/niri/custom.kdl;
}
